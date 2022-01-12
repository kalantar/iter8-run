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

echo "Fetch basic experiment"
$ITER8 hub -e load-test
cd load-test

echo "Modify experiment using inputs"
yq eval -i ".url = \"${INPUT_URL}\" |  .SLOs[2].upperLimit = ${INPUT_P95_LATENCY}" values.yaml
cat values.yaml
$ITER8 run --dry
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
