#!/usr/bin/env bash

TEXTFILE_COLLECTOR_DIR="/var/lib/node_exporter/textfile_collector/"

rm -f "${TEXTFILE_COLLECTOR_DIR}/raid_check.prom"

mkdir -p ${TEXTFILE_COLLECTOR_DIR}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

inc=0

for datum in $(/usr/local/bin/arcconf getsmartstats 1 tabular | sed -n '/Length/{n;p;}' | grep -o '..$' |  tr -d '\n') ; do
    var[${inc}]="${datum}";
    inc=$((${inc}+1));
done

unset inc

inc=0

for values  in ${var[@]}; do
    echo "raid_reloc_count{instance=\"$(hostname)\",id=\"${inc}\"} ${values}" >> "${TEXTFILE_COLLECTOR_DIR}/raid_check.prom"
    inc=$((${inc}+1));
done
