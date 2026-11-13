#!/usr/bin/env bash
# Taught C slots (2026-11-13): rebuild the coordinator, then start hardware_prototype.launch.py on
# Mock Serial and check that the coordinator loads the taught slots and stays up. Moves nothing
# real; the driver uses the mock calibration, the coordinator the prototype one (as in
# prototype_mode_20261113). Run in WSL: bash docs/evidence/slot_teach_20261113/mock_launch.sh
cd "$(dirname "$0")/../../.." || exit 90
source /opt/ros/jazzy/setup.bash
E=docs/evidence/slot_teach_20261113
colcon build --symlink-install --packages-select dual_arm_coordinator > $E/build.log 2>&1
echo "build $?"
source install/setup.bash
JOURNAL=$(mktemp -d)/journal.json
ros2 launch dual_arm_bringup hardware_prototype.launch.py use_mock_serial:=true \
  calibration_file:=$PWD/src/cm530_hardware/test/fixtures/calibration_mock.yaml \
  home_calibration_file:=$PWD/src/cm530_hardware/config/calibration_prototype.yaml \
  journal_path:=$JOURNAL > $E/launch.log 2>&1 &
LAUNCH=$!
for _ in $(seq 1 60); do
  grep -q 'C slots use taught' $E/launch.log && break
  grep -q 'process has died' $E/launch.log && break
  sleep 2
done
sleep 10
{
  echo "== nodes"; ros2 node list 2>&1 | sort
  echo "== status"; timeout 10 ros2 topic echo --once /dual_arm/status 2>&1 | head -20
} > $E/steps.log
kill -INT $LAUNCH; wait $LAUNCH
echo "launch stopped"
grep -n -E 'C slots use taught|PROTOTYPE mode|Taught slot|Traceback|dual_arm_coordinator.*died' $E/launch.log
