#!/usr/bin/env bash
# Source: https://raw.githubusercontent.com/Loyalsoldier/geoip/master/asn.sh
# Downloads CIDR lists for ASNs listed in `asn.csv`

set -e
INPUT="./asn.csv"
OUTPUT="./custom"
mkdir -p ${OUTPUT}

while IFS= read -r line; do
  filename=$(echo ${line} | awk -F ',' '{print $1}')
  IFS='|' read -r -a asns <<<$(echo ${line} | awk -F ',' '{print $2}')
  file="${OUTPUT}/${filename}"

  echo "==================================="
  echo "Generating ${filename} CIDR list..."
  rm -rf ${file} && touch ${file}
  for asn in ${asns[@]}; do
    url="https://stat.ripe.net/data/ris-prefixes/data.json?list_prefixes=true&types=o&resource=${asn}"
    echo "-----------------------"
    echo "Fetching ${asn}..."
    curl -sL ${url} \
      -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36' | \
      jq --raw-output '.data.prefixes.v4.originating[], .data.prefixes.v6.originating[]' | sort -u >>${file}
  done
done <${INPUT}
