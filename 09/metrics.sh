#!/bin/bash

OUTPUT_FILE="/var/www/my_exporter/index.html"

update_metrics() {
    # Метрики памяти
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2 * 1024}')
    MEM_AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2 * 1024}')

    # Метрики диска
    DISK_INFO=$(df / --block-size=1 --output=size,avail | tail -1)
    DISK_SIZE=$(echo $DISK_INFO | awk '{print $1}')
    DISK_AVAIL=$(echo $DISK_INFO | awk '{print $2}')

    # Метрики CPU
    # CPU_USAGE=$(top -bn2 -d 0.5 | grep "Cpu(s)" | tail -1 | awk '{printf "%.1f", 100 - $8}')
    # CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    CPU_USAGE=$(top -bn1 | awk '/Cpu\(s\)/ {print $2}' | tr ',' '.')

    # Метрики дисковых операций
    DISK_READS=$(grep -m1 -E " (sda|vda|nvme0n1) " /proc/diskstats | awk '{print $4}')
    DISK_WRITES=$(grep -m1 -E " (sda|vda|nvme0n1) " /proc/diskstats | awk '{print $8}')

    cat > $OUTPUT_FILE << EOF
# HELP node_memory_MemTotal_bytes Memory information field MemTotal.
# TYPE node_memory_MemTotal_bytes gauge
node_memory_MemTotal_bytes $MEM_TOTAL
# HELP node_memory_MemAvailable_bytes Memory information field MemAvailable.
# TYPE node_memory_MemAvailable_bytes gauge
node_memory_MemAvailable_bytes $MEM_AVAILABLE
# HELP node_filesystem_size_bytes Filesystem size in bytes.
# TYPE node_filesystem_size_bytes gauge
node_filesystem_size_bytes $DISK_SIZE
# HELP node_filesystem_avail_bytes Filesystem space available to non-root users in bytes.
# TYPE node_filesystem_avail_bytes gauge
node_filesystem_avail_bytes $DISK_AVAIL
# HELP node_cpu_usage_percent CPU usage percentage
# TYPE node_cpu_usage_percent gauge
node_cpu_usage_percent $CPU_USAGE
# HELP node_disk_reads_completed_total Total number of reads completed successfully.
# TYPE node_disk_reads_completed_total counter
node_disk_reads_completed_total $DISK_READS
# HELP node_disk_writes_completed_total Total number of writes completed successfully.
# TYPE node_disk_writes_completed_total counter
node_disk_writes_completed_total $DISK_WRITES
EOF
}

while true; do
    update_metrics
    sleep 3
done