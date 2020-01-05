#!/bin/bash -e

if [ $# -lt 1 ]; then
    echo "E: Missing action parameter"
    exit 1
fi

build_mix_release() {
    echo "--> Building a release"
    MIX_ENV=prod mix release
}

run_mix_release() {
    echo "--> Running a release"

    SECRET_KEY_BASE="LwReJOh3Y09DrbyNCr19keXJ/swHD/sT2idUWhBQcyXs+ogxcBAkRFaDHsamki/0" \
    APP_PORT=4000 \
    DB_URL="postgres://localhost:5432/ogahunt_dev" \
    DB_SSL=false \
    DB_POOL_SIZE=5 \
    GCS_SERVICE_ACCOUNT_FILE=secrets/gcs-service-account.json \
    GCS_IMAGE_BUCKET=ogahunt-images \
    _build/prod/rel/ogahunt/bin/ogahunt start
}

show_usage() {
    echo "./dev.sh <command>
        serve|s
        serve-iex|si
        iex|i
        build-release|br 
        start-release|sr
        test|t
    "
}

case "$1" in

    "serve"|s)
        echo "--> Serve app"
        MIX_ENV=dev mix phx.server
    ;;

    "serve-iex"|si)
        echo "--> Serve app over iEx"
        MIX_ENV=dev iex -S mix phx.server
    ;;

    "iex"|i)
        echo "--> iEx console"
        MIX_ENV=dev iex -S mix
    ;;

    "test"|t)
        echo "--> Running all tests"
        MIX_ENV=test mix test
    ;;

    help|h)
        show_usage
    ;;

    "build-release"|br)
        build_mix_release
    ;;

    "start-release"|sr)
        run_mix_release
    ;;

    *)
        echo "E: Unknown option: $1"
        show_usage
        exit 1
    ;;

esac