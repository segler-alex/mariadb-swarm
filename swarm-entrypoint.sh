#!/bin/bash
echo "Startup.."

CLUSTER_NAME="MyCluster"
WSREP_SST_AUTH="root:123"

if [ -z "$DNS" ]; then
    echo "DNS is not set!"
    exit 1
fi

sleep 3

echo "Startup..1"

HOSTS=$(dig +short $DNS)
HOST_NUMBER=$(echo "$HOSTS" | wc -l)

echo "Startup..2"

if [ $HOST_NUMBER -gt 0 ]; then
    echo "Startup..3"
    HOSTS_LINE=$(echo "$HOSTS" | xargs | sed -e 's/ /,/g')

    echo "Line: $HOSTS_LINE"
    echo "Found hosts: $HOST_NUMBER"

    if [ $HOST_NUMBER -gt 1 ]; then
        echo "*** JOIN CLUSTER @ $HOSTS_LINE"
        docker-entrypoint.sh "$@" "--wsrep-cluster-name=$CLUSTER_NAME" "--wsrep-cluster-address=gcomm://$HOSTS_LINE" "--wsrep-sst-auth=${WSREP_SST_AUTH}"
    else
        echo "*** START NEW CLUSTER"
        docker-entrypoint.sh "$@" --wsrep-new-cluster "--wsrep-cluster-name=$CLUSTER_NAME" "--wsrep-cluster-address=gcomm://" "--wsrep-sst-auth=${WSREP_SST_AUTH}"
    fi
else
    echo "cound not find DNS entry: $DNS"
    exit 1
fi
