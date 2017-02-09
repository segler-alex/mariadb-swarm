#!/bin/bash
echo "Startup.."

CLUSTER_NAME="MyCluster"
WSREP_SST_AUTH="root:$MYSQL_ROOT_PASSWORD"

if [ -z "$DNS" ]; then
    echo "DNS is not set!"
    exit 1
fi

sleep 3

echo "Startup..1"

HOSTS=$(dig +short $DNS)
HOST_NUMBER=$(echo "$HOSTS" | wc -l)
OWN_IPS=$(hostname -I)

echo "Startup..2"

if [ $HOST_NUMBER -gt 0 ]; then
    echo "Startup..3"
    HOSTS_LINE_SPACE=$(echo "$HOSTS" | xargs)
    HOSTS_LINE=$(echo "$HOSTS" | xargs | sed -e 's/ /,/g')

    for HOSTS_LINE_SPACE_I in $HOSTS_LINE_SPACE; do
        FOUND=0
        for OWN_IPS_I in $OWN_IPS; do
            if [[ "$HOSTS_LINE_SPACE_I" == "$OWN_IPS_I" ]]; then
                FOUND=1
            fi
        done

        if [ $FOUND -eq 0 ]; then
            if [ -z $GCOMM ]; then
                GCOMM="${HOSTS_LINE_SPACE_I}"
            else
                GCOMM="${GCOMM},${HOSTS_LINE_SPACE_I}"
            fi
        fi
    done

    echo "Line: $HOSTS_LINE"
    echo "Own Ips: $OWN_IPS"
    echo "Found hosts: $HOST_NUMBER"
    echo "Found other hosts: $GCOMM"

    if [ $HOST_NUMBER -gt 1 ]; then
        echo "Creating MySQL data dir.."
        mkdir -p /var/lib/mysql/mysql
        echo "*** JOIN CLUSTER @ $GCOMM"
        docker-entrypoint.sh "$@" "--wsrep-cluster-name=$CLUSTER_NAME" "--wsrep-cluster-address=gcomm://$GCOMM" "--wsrep-sst-auth=${WSREP_SST_AUTH}"
    else
        echo "*** START NEW CLUSTER"
        docker-entrypoint.sh "$@" --wsrep-new-cluster "--wsrep-cluster-name=$CLUSTER_NAME" "--wsrep-cluster-address=gcomm://" "--wsrep-sst-auth=${WSREP_SST_AUTH}"
    fi
else
    echo "cound not find DNS entry: $DNS"
    exit 1
fi
