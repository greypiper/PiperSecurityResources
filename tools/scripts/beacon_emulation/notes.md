| rex field=cs_uri "(?i)([0-9A-Fa-f]{64,128})"



index=proxy sourcetype="bluecoat:proxysg:access:file" cs_uri_scheme=http cs_uri_query=*

cs_host!=*microsoft* AND cs_host!=*adaptiva.cloud AND cs_host!=*windowsupdate.com

| eval time=strftime(time, "%Y-%m-%d")

| eventstats sum(bytes_in) as total_bytes_in, sum(bytes_out) as total_bytes_out by c_ip, r_ip cs_host

| stats stdev(total_bytes_out) as stdev_bytes_out, mean(total_bytes_out) as mean_bytes_out by cs_host

| eval z_score = coalesce((total_bytes_out - mean_bytes_out) / stdev_bytes_out, 0)

| where total_bytes_in > 300000 AND total_bytes_out > 300000

| eval ratio = coalesce(total_bytes_out / total_bytes_in, 0)

| eval score = 1 / (1 + abs(1 - ratio))

| streamstats range(total_bytes_out) as range_bytes_out by c_ip

| eval cv_bytes_out = stdev_bytes_out / mean_bytes_out * 100

| table c_ip, r_ip, cs_host, total_bytes_in, total_bytes_out, score, mean_bytes_out, stdev_bytes_out, z_score, cv_bytes_out
