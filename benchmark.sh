#!/bin/bash

if [[ ! -f /usr/bin/sysbench ]]; then
  wget -O /tmp/sysbench.sh https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh
  chmod +x /tmp/sysbench.sh
  /tmp/sysbench.sh
  apt update
  apt -y install sysbench
fi

echo "Category5.TV SBC Benchmark v1.0"
printf "Powered by "
/usr/bin/sysbench --version

cp benchmark-parse.sh /tmp/
chmod +x /tmp/benchmark-parse.sh

# Run the tests
cores=$(nproc --all)

echo "Number of threads for this SBC: $cores"

# we want the junk to go to /tmp
cd /tmp

printf "Performing CPU Benchmark... "
cpu=`/usr/bin/sysbench --test=cpu --cpu-max-prime=20000 --num-threads=$cores run | /tmp/benchmark-parse.sh cpu`
echo $cpu

printf "Performing RAM Benchmark... "
ram=`/usr/bin/sysbench --test=memory --num-threads=$cores --memory-total-size=10G run | /tmp/benchmark-parse.sh ram`
echo $ram

printf "Performing Mutex Benchmark... "
mutex=`/usr/bin/sysbench --test=mutex --num-threads=64 run | /tmp/benchmark-parse.sh mutex`
echo $mutex

printf "Performing I/O Benchmark... "
io=`/usr/bin/sysbench --test=fileio --file-test-mode=seqwr run | /tmp/benchmark-parse.sh io`
echo $io

# Clear the test files
rm -f /tmp/test_file.*
rm -f /tmp/benchmark-parse.sh