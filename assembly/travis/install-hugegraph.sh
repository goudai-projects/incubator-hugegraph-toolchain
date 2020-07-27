#!/bin/bash

set -ev

if [[ $# -ne 1 ]]; then
    echo "Must pass server version of hugegraph"
    exit 1
fi

VERSION=$1
HUGEGRAPH_LINK="https://github.com/hugegraph/hugegraph/releases/download/v${VERSION}/hugegraph-${VERSION}.tar.gz"

wget ${HUGEGRAPH_LINK} || exit 1

tar -zxvf hugegraph-${VERSION}.tar.gz

HTTPS_SERVER_DIR="hugegraph_https"

mkdir $HTTPS_SERVER_DIR

cp -r hugegraph-${VERSION}/. $HTTPS_SERVER_DIR

cd hugegraph-${VERSION}

bin/init-store.sh || exit 1

bin/start-hugegraph.sh || exit 1

cd ../

cd $HTTPS_SERVER_DIR

cp ../$TRAVIS_DIR/conf/server.keystore conf

REST_SERVER_CONFIG="conf/rest-server.properties"

GREMLIN_SERVER_CONFIG="conf/gremlin-server.yaml"

sed -i "s?http://127.0.0.1:8080?https://127.0.0.1:8443?g" "$REST_SERVER_CONFIG"

sed -i "s/#port: 8182/port: 8282/g" "$GREMLIN_SERVER_CONFIG"

echo "server.protocol=https" >> $REST_SERVER_CONFIG

echo "ssl.server_keystore_password=123456" >> $REST_SERVER_CONFIG

echo "ssl.server_keystore_file=conf/server.keystore" >> $REST_SERVER_CONFIG

echo "gremlinserver.url=http://127.0.0.1:8282" >> $REST_SERVER_CONFIG

bin/init-store.sh

bin/start-hugegraph.sh

cd ../
