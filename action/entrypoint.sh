#!/bin/bash -l

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ITER8="/bin/iter8"

echo "Creating working directory"

WORK_DIR=`mktemp -d -p  "$DIR"`
if [[ ! "$WORK_DIR" || ! -d  "$WORK_DIR" ]]; then
  echo "Cound not create temporary working directory"
  exit 1
fi

# no need to cleanup

echo "Set LOG_LEVEL for iter8 commands to: ${INPUT_LOGLEVEL}"
export LOG_LEVEL="${INPUT_LOGLEVEL}"

echo "Identify values file"
OPTIONS=""
if [[ ! -z "${INPUT_VALUESFILE}" ]]; then
  OPTIONS="$OPTIONS -f ${INPUT_VALUESFILE}"
fi

LOG_LEVEL=${INPUT_LOGLEVEL} $ITER8 launch -c ${INPUT_CHART} ${OPTIONS}

echo "Log result"
$ITER8 report

echo "Experiment completed"
# return 0 if satisfied; else non-zero
if [[ "${INPUT_VALIDATESLOS}" == "true" ]]; then
  echo "Asserting SLOs satisfied"
  $ITER8 assert -c completed -c noFailure -c slos
fi
