#!/bin/bash

INGRESS_PUBLIC_IP=172.213.64.220
TEST_PATH=test
DOMAINS=$(grep "^ *- " myvalues.yaml | sed 's/^ *- //g' | tr -d '\r')

for domain in $DOMAINS; do
    echo "* Testing $domain ..."
    if [ -f tmp_result.txt ]; then
        rm tmp_result.txt
    fi
    curl --insecure -vvv --stderr - --connect-to "$domain:443:$INGRESS_PUBLIC_IP:443" https://$domain/$TEST_PATH > tmp_result.txt
    if grep -q -E "HTTP/[0-9\.]+ 200" tmp_result.txt && grep -q "subject: CN=$domain" tmp_result.txt && grep -q '"host": "'$domain'"' tmp_result.txt; then
        echo "  PASS: $domain is reachable and certificate is valid."
    elif grep -q -E "HTTP/[0-9\.]+ 200" tmp_result.txt ; then
        echo "  FAIL: $domain is reachable but certificate is not valid." | tee -a errors.txt
        cat tmp_result.txt >> errors.txt
        break
    else
        echo "  FAIL: $domain is not reachable." | tee -a errors.txt
        cat tmp_result.txt >> errors.txt
        break
    fi
done