| stats values(cs_host) as cs_host by time c_ip total_connections anomaly_score
| where mvcount(cs_host) = 1
