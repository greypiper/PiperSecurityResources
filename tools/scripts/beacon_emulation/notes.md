... | rex field=query "^(?<subdomain>[^.]+)\." | eval subdomain_entropy = if(isnull(subdomain), null(), -(entropy(subdomain) / log(2))) | eval entropy_score = if(isnull(subdomain_entropy), null(), max(0, min(10, 10 - subdomain_entropy)))

