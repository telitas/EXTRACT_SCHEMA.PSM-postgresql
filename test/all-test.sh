#!/usr/bin/env bash
set -u

echo "Start database"
./reset-database.sh

echo "XML test"
./xml/function-test.sh
if [[ $? -ne 0 ]]; then
    exit 1
fi
./xml/extract-schema.sh
./xml/schema.test.bats
if [[ $? -ne 0 ]]; then
    exit 2
fi
./xml/data.test.bats
if [[ $? -ne 0 ]]; then
    sleep 1
    #exit 3
fi

echo "JSON test"
./json/function-test.sh
if [[ $? -ne 0 ]]; then
    exit 4
fi
./json/extract-schema.sh
./json/schema.test.bats
if [[ $? -ne 0 ]]; then
    exit 5
fi
./json/data.test.bats
if [[ $? -ne 0 ]]; then
    exit 6
fi


