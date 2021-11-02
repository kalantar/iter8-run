#!/bin/bash -l

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Creating working directory"

WORK_DIR=`mktemp -d -p  "$DIR"`
if [[ ! "$WORK_DIR" || ! -d  "$WORK_DIR" ]]; then
  echo "Cound not create temporary working directory"
  exit 1
fi

# no need to cleanup

echo "Copying experiment definition"
mv "${1}" ${WORK_DIR}/experiment.yaml
cd ${WORK_DIR}

echo "Running Experiment"
/bin/iter8 run

echo "Run completed; verifying completeness"
/bin/iter8 assert -c completed -c noFailure
rc=$?

echo "Return code: $rc"
exit $rc
