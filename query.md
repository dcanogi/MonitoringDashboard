# Hardware metrics
## CPU Usage:

### Total CPU Usage:

```promql
sum(rate(node_cpu_seconds_total{mode!="idle"}[5m])) by (instance)
```
### CPU Usage by Mode:

```promql
sum(rate(node_cpu_seconds_total[5m])) by (mode)
```
## Memory Usage:

### Total Memory Usage:

```promql
node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes
```
### Memory Usage Percentage:

```promql
(node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes) / node_memory_MemTotal_bytes * 100
```
## Disk Usage:

### Disk Space Usage (Percentage):

```promql
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100
```
### Disk I/O Operations:

```promql
rate(node_disk_io_time_seconds_total[5m])
```
## Network Metrics

### Total Network Traffic (Bytes):

```promql
sum(rate(node_network_receive_bytes_total[5m])) by (instance)
```
### Network Errors:

```promql
sum(rate(node_network_receive_errs_total[5m])) by (instance)
```

### Packets Sent:

```promql
sum(rate(node_network_transmit_packets_total[5m])) by (instance)
```
### Packets Received:

```promql
sum(rate(node_network_receive_packets_total[5m])) by (instance)
```

# Docker Metrics
## Container CPU Usage:

### Container CPU Usage Rate:
```promql
sum(rate(container_cpu_usage_seconds_total{container_label_com_docker_swarm_task_name!=""}[5m])) by (container_label_com_docker_swarm_task_name)
```
## Container Memory Usage:

### Memory Usage:
```promql
sum(container_memory_usage_bytes{container_label_com_docker_swarm_task_name!=""}) by (container_label_com_docker_swarm_task_name)
```
## Container Disk I/O:

### Disk I/O Read/Write:
```promql
sum(rate(container_fs_reads_bytes_total{container_label_com_docker_swarm_task_name!=""}[5m])) by (container_label_com_docker_swarm_task_name)
sum(rate(container_fs_writes_bytes_total{container_label_com_docker_swarm_task_name!=""}[5m])) by (container_label_com_docker_swarm_task_name)
```
