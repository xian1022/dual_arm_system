# 2026-11-13 上游同步（Prototype 為主）

使用者決定：先以 Prototype 為主，和 Azeem1010/Dual-Arm-TEST-2.0、Azeem1010/env_camera_vision 同步。

## 分支盤點

| repo / 分支 | HEAD | 處理 |
|---|---|---|
| Dual-Arm-TEST-2.0 `e0-esp32-suction` | `6fb080a` | 從本機 `1e80cde` 快轉合併（`3a90ba2`、`6fb080a`，E0 吸盤實測） |
| Dual-Arm-TEST-2.0 `env-scene-debug-image` | `52a6518` | 已在本機歷史 |
| Dual-Arm-TEST-2.0 `main` | `13a5b4f` | 11-10／11-11 現場紀錄，文字與 CSV 已在 `d2ddfae` 匯入；照片與大型日誌留在來源 repo |
| Dual-Arm-TEST-2.0 `orin-source` | `c0bed71` | Orin 初始快照，`src` 與 `3fd258c` 相同，不取 |
| env_camera_vision `main`、`calib/c-slot-positions` | `6b3d5c1` | 同一個 commit；子模組與 `src/env_scene/env_scene/scene_core.py` 換版，保留本地框線影像修改 |

## 修改

- `src/env_scene/env_scene/scene_core.py`：`STD_SLOTS_MM` y = 45／10／−25／−60（上游 `6b3d5c1` 原樣）。`env_scene_node.py`、`env_scene.yaml` 的本地修改（`52a6518`）不動。
- `dual_arm_coordinator/config/prototype/coordinator.yaml`：`c_slots_xy_m` y 改成 0.045／0.010／−0.025／−0.060。模擬設定不變，嚴格實機仍是 null。
- `docs/sources.lock.json`：env_camera_vision 鎖 `6b3d5c1`。

## 檢查（Windows 上的 WSL Ubuntu 24.04 + Jazzy）

- `bash scripts/run_checks.sh t0 docs/evidence/sync_20261113/t0`：PASS
- `bash scripts/run_checks.sh t1 docs/evidence/sync_20261113/t1`：全部 PASS（coordinator 328、HMI 307、vision 104）。t1 改到的三個追蹤中的 evidence 日誌已用 `git checkout` 還原。
- `cd src/env_scene && python3 -m pytest -q -p no:cacheprovider`：10 passed（`env_scene_pytest.log`）

## 還沒做

- Prototype 在新的 C 格座標的實機放置沒有跑；y −0.060 在實機上搆不搆得到也沒有確認。
- E0 的韌體腳位修改（12/13/25/26）還沒推回 ray000518/micro-ros。
- env_scene 的尺量標定檔 `env_field_homography.yaml` 只在現場機器上，不在 repo。
