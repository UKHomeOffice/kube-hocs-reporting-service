#!/bin/bash

export KUBE_NAMESPACE=${KUBE_NAMESPACE}
export KUBE_SERVER=${KUBE_SERVER}

if [[ -z ${VERSION} ]] ; then
    export VERSION=${IMAGE_VERSION}
fi

if [[ ${ENVIRONMENT} == "prod" ]] ; then
    echo "deploy ${VERSION} to prod namespace, using HOCS_REPORTING_SERVICE_PROD drone secret"
    export KUBE_TOKEN=${HOCS_REPORTING_SERVICE_PROD}
    export REPLICAS="2"
    export DNS_PREFIX=
else
    export DNS_PREFIX=${ENVIRONMENT}.notprod.
    if [[ ${ENVIRONMENT} == "qa" ]] ; then
        echo "deploy ${VERSION} to test namespace, using HOCS_REPORTING_SERVICE_QA drone secret"
        export KUBE_TOKEN=${HOCS_REPORTING_SERVICE_QA}
        export REPLICAS="2"
    else
        echo "deploy ${VERSION} to dev namespace, using HOCS_REPORTING_SERVICE_DEV drone secret"
        export KUBE_TOKEN=${HOCS_REPORTING_SERVICE_DEV}
        export REPLICAS="1"
    fi
fi

if [[ -z ${KUBE_TOKEN} ]] ; then
    echo "Failed to find a value for KUBE_TOKEN - exiting"
    exit -1
fi

cd kd

kd --insecure-skip-tls-verify \
   --timeout 10m \
   -f ingress.yaml \
   -f service.yaml \
   -f deployment.yaml
