#!/usr/bin/env bash
# Taught C slots (2026-11-13): slot report, prototype config load, coordinator and HMI tests.
# Run in WSL from anywhere: bash docs/evidence/slot_teach_20261113/run.sh
cd "$(dirname "$0")/../../.." || exit 90
source /opt/ros/jazzy/setup.bash
source install/setup.bash
E=docs/evidence/slot_teach_20261113
python3 scripts/teach_to_slots.py > $E/teach_to_slots.txt 2>&1
echo "teach_to_slots $?"
(cd src/dual_arm_coordinator && python3 -m dual_arm_coordinator.task_config config/prototype/coordinator.yaml) > $E/load_prototype.txt 2>&1
echo "load $?"
(cd src/dual_arm_coordinator && python3 -m pytest -q -p no:cacheprovider test) > $E/pytest_coordinator.log 2>&1
echo "coordinator $?"
(cd src/dual_arm_hmi && QT_QPA_PLATFORM=offscreen python3 -m pytest -q -p no:cacheprovider test) > $E/pytest_hmi.log 2>&1
echo "hmi $?"
