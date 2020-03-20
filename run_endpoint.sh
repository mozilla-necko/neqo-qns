#!/bin/bash

# Set up the routing needed for the simulation.
./setup.sh

cd neqo

CLIENT_PARAMS="--qns-mode --output-dir downloads"
SERVER_PARAMS=""

if [ "$ROLE" == "client" ]; then
    echo "Starting Neqo client ..."
    echo "CLIENT_PARAMS:" $CLIENT_PARAMS
    echo "REQUESTS:" $REQUESTS
    # RUST_LOG=debug RUST_BACKTRACE=1 strace -f ./target/neqo-client $CLIENT_PARAMS $REQUESTS
    sleep 5
    strace -f ./target/neqo-client $CLIENT_PARAMS $REQUESTS
elif [ "$ROLE" == "server" ]; then
    exit 127
fi
