# 2026-11-13 Prototype：C 格改用示教關節值

使用者決定（2026-11-13）：實機 Prototype 的 Arm 2 放置改用 11-11 H1 的 C 格示教讀值，不再走「xy → IK」。示教時吸盤是壓著格子裡的瓶蓋（使用者確認），所以讀值就是放置姿勢。B 區交接讀值不使用；A 區與 B 區照舊。模擬與嚴格實機不變。

## 做法

- `config/prototype/coordinator.yaml` 新增 `c_slot_teach`：arm2 八格的 raw（`teach_arm2_C_1..8.csv` 最後一筆 READ）、`release_lift_m` 0、`arrival_tolerance_raw` 4、`max_line_drift_m` 0.003。只有 `mode: prototype` 能用（`task_config.py`）。
- `homes.load_slot_joints()`：用和 driver 同一份校正檔（`home_calibration_file`，預設等於 `calibration_file`）把 raw 換成弧度，並檢查在 `min_raw..max_raw` 內。driver 再用同一份檔案換回 raw，所以馬達收到的就是示教值；`zero_raw` 估錯也不影響（`test_taught_slots_round_trip_to_the_taught_counts`）。
- `motion_math.prepare_slot_poses()`：放置姿勢 = 示教值；接近姿勢 = 模型 TCP 正上方 `approach_z`（純垂直，j1 不變）。某格在 `approach_z` 解不到（傾角上限 9° 內）就每次降 2 mm，最低要比放置點高 20 mm。C8 因此在 50 mm 接近；**沒有放寬傾角上限**。
- `MotionGateway.move_slot()`：APPROACH_C 由 MoveIt 規劃到關節目標；DESCEND_C、LIFT_C 是關節空間直線，模型 TCP 偏離直線超過 `max_line_drift_m` 就停；到位判定是每軸 ≤ 4 raw。場景裡的格位瓶蓋用示教點的 FK xy。
- `arm2_workflow`、`transfer` 的下一格預檢：有示教時改呼叫 `check_slot`（接近、放置兩個姿勢的碰撞檢查）。

## 示教點的模型報告（`teach_to_slots.txt`，`scripts/teach_to_slots.py`）

| 格 | 示教 TCP（mm，模型） | 傾角 | 接近高度 | 關節直線偏離 | 離 `c_slots_xy_m` |
|---|---|---|---|---|---|
| C1 | 126.6, 41.0, 16.1 | 2.4° | 52 | 1.79 mm | 9.3 mm |
| C2 | 160.2, 42.3, 17.4 | 2.3° | 52 | 1.50 | 10.1 |
| C3 | 128.3, 12.0, 18.1 | 7.0° | 52 | 1.41 | 7.0 |
| C4 | 162.1, 9.0, 18.3 | 4.9° | 52 | 1.19 | 8.0 |
| C5 | 129.2, −27.1, 17.5 | 5.2° | 52 | 1.12 | 6.2 |
| C6 | 161.4, −27.0, 18.0 | 3.2° | 52 | 0.99 | 8.8 |
| C7 | 126.6, −59.0, 19.9 | 3.2° | 52 | 0.71 | 8.5 |
| C8 | 163.2, −61.0, 19.1 | 8.7° | **50** | 0.86 | 6.9 |

模型數字含估計零點，只用來檢查；示教 raw 本身不經過模型。示教點離尺量格位 6～10 mm，和現場照片看到的放置偏移同一個量級。

## 檢查（WSL Ubuntu 24.04 + Jazzy）

| 紀錄 | 內容 | 結果 |
|---|---|---|
| `run.sh` → `teach_to_slots.txt`、`load_prototype.txt` | 示教報告；Prototype 設定載入 | PASS |
| `run.sh` → `pytest_coordinator.log` | coordinator 單元測試（新增設定驗證、raw 往返、接近姿勢、直線偏離、工作流程） | PASS，349 |
| `run.sh` → `pytest_hmi.log` | 操作介面單元測試 | PASS，307 |
| `mock_launch.sh` → `build.log`、`launch.log`、`steps.log` | 重建 coordinator；Mock Serial 啟動 `hardware_prototype.launch.py`：coordinator 印出 `C slots use taught arm2 joints`、沒有例外、發布 `/dual_arm/status` | PASS |
| `final.sh` → `teach_to_slots_from_config.txt`、`t0/` | 加上 `--from-config` 後從設定檔重出報告，和 CSV 版相同；t0 文件檢查 | PASS |
| `mock_launch.sh` | 沒有相機，任務不會開始；Ctrl-C 後 launch 沒結束（相機切換節點），手動 TaskStop 與 pkill 清掉，事後確認沒有殘留程序 | 預期限制 |

第一次跑單元測試有 2 項 FAIL，都是新測試本身的假設錯了（任務一開始先回 HOME；j1 擺 0.5 rad 的弧只偏 4.6 mm），改測試後全部 PASS，程式沒改。

## 還沒做

- **`move_slot` 沒有在 MoveIt + 控制器上實際執行過**（Mock 沒有相機，任務不會走到 C 區）。實機 NOT_RUN。
- 實機第一次建議：先只到接近姿勢、從上方看是否對準；再空手下到放置姿勢看高度；最後才跑完整流程。
- 扭力關閉時示教，上扭力後可能差 1～3 raw。C1（j4 最後 20 筆全距 27、j1 11）、C2（j2 7）示教時不穩，最需要注意。
- 壓太深就調 `release_lift_m`（0～0.02 m）；個別格偏了，jog 後改該格 raw。
- Orin 要 `git pull` 後重建 `dual_arm_coordinator`。
