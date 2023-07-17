#!/bin/bash

# Check if the first argument is "bash"
if [ "$1" = "bash" ]; then
  # If the first argument is "bash", execute /bin/bash
  exec /bin/bash
else
  # Otherwise, activate the Spack environment with the given arguments
  . /home/spack/share/spack/setup-env.sh
  spack env activate myenv
  #cd /home/cm1/src
  #mpiexec -n 2 cm1.exe --namelist namelist.restC
  # Execute the provided command with the given arguments
  exec "$@"
fi
