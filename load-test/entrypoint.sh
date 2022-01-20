#!/bin/bash -l

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ITER8="/bin/iter8"

echo "Creating working directory"

WORK_DIR=`mktemp -d -p  "$DIR"`
if [[ ! "$WORK_DIR" || ! -d  "$WORK_DIR" ]]; then
  echo "Cound not create temporary working directory"
  exit 1
fi

# no need to cleanup

echo "Fetch load-test experiment"
$ITER8 hub -e load-test
cd load-test

echo "Modify experiment using inputs"
if [[ ! -z "${INPUT_URL}" ]]; then
  yq eval -i ".url = \"${INPUT_URL}\"" values.yaml
fi
if [[ ! -z "${INPUT_NUMQUERIES}" ]]; then
  yq eval -i ".numQueries = \"${INPUT_NUMQUERIES}\"" values.yaml
fi
if [[ ! -z "${INPUT_DURATION}" ]]; then
  yq eval -i ".duration = \"${INPUT_DURATION}\"" values.yaml
fi
if [[ ! -z "${INPUT_QPS}" ]]; then
  yq eval -i ".qps = \"${QPS}\"" values.yaml
fi
if [[ ! -z "${INPUT_CONNECTIONS}" ]]; then
  yq eval -i ".connections = \"${INPUT_CONNECTIONS}\"" values.yaml
fi
if [[ ! -z "${INPUT_PAYLOADSTR}" ]]; then
  yq eval -i ".payloadStr = \"${INPUT_PAYLOADSTR}\"" values.yaml
fi
if [[ ! -z "${INPUT_PAYLOADURL}" ]]; then
  yq eval -i ".payloadUrl = \"${INPUT_PAYLOADURL}\"" values.yaml
fi
if [[ ! -z "${INPUT_CONTENTTYPE}" ]]; then
  yq eval -i ".contentType = \"${INPUT_CONTENTTYPE}\"" values.yaml
fi
if [[ ! -z "${INPUT_ERRORRANGES}" ]]; then
  yq eval -i ".errorRanges = \"${INPUT_ERRORRANGES}\"" values.yaml
fi
if [[ ! -z "${INPUT_PERCENTILES}" ]]; then
  yq eval -i ".percentiles = \"${INPUT_PERCENTILES}\"" values.yaml
fi
if [[ ! -z "${INPUT_ERROR_RATE}" ]]; then
  yq eval -i ".error-rate = \"${INPUT_ERROR_RATE}\"" values.yaml
fi
if [[ ! -z "${INPUT_MEAN_LATENCY}" ]]; then
  yq eval -i ".mean-latency = \"${INPUT_MEAN_LATENCY}\"" values.yaml
fi
if [[ ! -z "${INPUT_P95_0}" ]]; then
  yq eval -i ".p96\.0 = \"${INPUT_P95_0}\"" values.yaml
fi

echo ">>>>>>>>>>>>>>>>>>>>>"
echo ">>>>>     values.yaml"
echo ">>>>>>>>>>>>>>>>>>>>>"
cat values.yaml
$ITER8 run --dry
echo ">>>>>>>>>>>>>>>>>>>>>"
echo ">>>>> experiment.yaml"
echo ">>>>>>>>>>>>>>>>>>>>>"
cat experiment.yaml

echo "Run Experiment"
LOG_LEVEL=trace $ITER8 run

echo "Log result"
$ITER8 report

echo "Run completed; verifying completeness"
# return 0 if satisfied; else non-zero
$ITER8 assert -c completed -c noFailure -c slos
rc=$?

echo "Return code: $rc"
exit $rc
