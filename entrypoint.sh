#!/bin/sh -l

echo "Starting Experiment..."
/bin/iter8 run
echo "Run completed; verifying completeness"
/bin/iter8 assert -c completed -c noFailure
echo $?
