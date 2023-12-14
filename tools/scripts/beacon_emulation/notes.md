| stats dc(c_ip) as distinct_c_ips by date_bucket, cs_host
| where distinct_c_ips = 1
| table date_bucket, cs_host, c_ip
