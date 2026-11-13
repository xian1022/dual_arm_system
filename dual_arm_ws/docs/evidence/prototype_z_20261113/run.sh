#!/usr/bin/env bash
# Prototype heights 2 mm lower (2026-11-13): load the config and run the coordinator and HMI tests.
# Run in WSL from anywhere: bash docs/evidence/prototype_z_20261113/run.sh
cd "$(dirname "$0")/../../.." || exit 90
source /opt/ros/jazzy/setup.bash
source install/setup.bash
E=docs/evidence/prototype_z_20261113
python3 -c 'from dual_arm_coordinator import task_config as t; d = t.load("src/dual_arm_coordinator/config/prototype/coordinator.yaml"); print(d["mode"], d["heights"])' > $E/load_prototype.txt 2>&1
echo "load $?"
(cd src/dual_arm_coordinator && python3 -m pytest -q -p no:cacheprovider test) > $E/pytest_coordinator.log 2>&1
echo "coordinator $?"
(cd src/dual_arm_hmi && python3 -m pytest -q -p no:cacheprovider test) > $E/pytest_hmi.log 2>&1
echo "hmi $?"
