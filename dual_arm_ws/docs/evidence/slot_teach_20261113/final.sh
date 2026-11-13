#!/usr/bin/env bash
# After the --from-config option: report from the config, then the t0 docs check.
cd "$(dirname "$0")/../../.." || exit 90
source /opt/ros/jazzy/setup.bash
source install/setup.bash
E=docs/evidence/slot_teach_20261113
python3 scripts/teach_to_slots.py --from-config > $E/teach_to_slots_from_config.txt 2>&1
echo "from_config $?"
bash scripts/run_checks.sh t0 $E/t0 > $E/t0.log 2>&1
echo "t0 $?"
