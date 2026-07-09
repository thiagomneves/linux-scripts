#!/bin/bash

echo "=== BENCHMARK START ==="
date

echo
echo "=== SYSTEM INFO ==="
fastfetch

echo
echo "Aguardando 10 minutos para estabilização do sistema..."
sleep 600

echo
echo "=== BENCHMARK ==="
date

echo
echo "--- MEM INFO ---"
grep MemTotal /proc/meminfo
grep MemAvailable /proc/meminfo

echo
echo "--- FREE ---"
free -b

echo
echo "--- TOP MEMORY USERS ---"
ps -eo comm,rss --sort=-rss | head -n 15

echo
echo "=== BENCHMARK END ==="
date
