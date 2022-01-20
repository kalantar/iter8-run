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
if [[ -v "${INPUT_URL}" ]]; then
  yq eval -i ".url = \"${INPUT_URL}\"" values.yaml
fi
if [[ -v "${NUMQUERIES}" ]]; then
  yq eval -i ".numQueries = \"${NUMQUERIES}\"" values.yaml
fi
if [[ -v "${DURATION}" ]]; then
  yq eval -i ".duration = \"${DURATION}\"" values.yaml
fi
if [[ -v "${QPS}" ]]; then
  yq eval -i ".qps = \"${QPS}\"" values.yaml
fi
if [[ -v "${CONNECTIONS}" ]]; then
  yq eval -i ".connections = \"${CONNECTIONS}\"" values.yaml
fi
if [[ -v "${PAYLOADSTR}" ]]; then
  yq eval -i ".payloadStr = \"${PAYLOADSTR}\"" values.yaml
fi
if [[ -v "${PAYLOADURL}" ]]; then
  yq eval -i ".payloadUrl = \"${PAYLOADURL}\"" values.yaml
fi
if [[ -v "${CONTENTTYPE}" ]]; then
  yq eval -i ".contentType = \"${CONTENTTYPE}\"" values.yaml
fi
if [[ -v "${ERRORRANGES}" ]]; then
  yq eval -i ".errorRanges = \"${ERRORRANGES}\"" values.yaml
fi
if [[ -v "${PERCENTILES}" ]]; then
  yq eval -i ".percentiles = \"${PERCENTILES}\"" values.yaml
fi
if [[ -v "${ERROR_RATE}" ]]; then
  yq eval -i ".error-rate = \"${ERROR_RATE}\"" values.yaml
fi
if [[ -v "${MEAN_LATENCY}" ]]; then
  yq eval -i ".mean-latency = \"${MEAN_LATENCY}\"" values.yaml
fi
if [[ -v "${P95_0}" ]]; then
  yq eval -i ".p96\.0 = \"${P95_0}\"" values.yaml
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
