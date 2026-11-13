# 2026-11-13 Prototype 吸取高度降 2 mm

現場回報：實機跑 Prototype 時，吸盤停在瓶蓋上方，吸不到瓶蓋，大約高了 2 mm。使用者要求降約 2 mm。

## 修改

只改 `src/dual_arm_coordinator/config/prototype/coordinator.yaml` 的 `heights`。模擬和嚴格實機模式都不動。

| 欄位 | 原值（同模擬） | 新值 |
|---|---|---|
| `surface_z_m` | 0.014 | 0.012 |
| `contact_z_m` | 0.0243 | 0.0223 |
| `release_z_m` | 0.0253 | 0.0233 |
| `approach_z_m` | 0.054 | 0.052 |
| `cap_height_m` | 0.01 | 0.01（不變） |

設定檢查要求瓶蓋頂端 ≤ 吸取高度（`task_config.py`），所以只降 `contact_z_m` 會被拒絕。這裡把整組高度一起降 2 mm，等於把實機桌面當成比模型低 2 mm（估計值，誤差也可能來自 Prototype 校正）。放置高度和接近高度也一起降，三個高度之間的間距不變。

## 檢查（WSL Ubuntu 24.04 + Jazzy，`bash docs/evidence/prototype_z_20261113/run.sh`）

- 載入 Prototype 設定：通過（`load_prototype.txt`）
- coordinator 單元測試：328 passed（`pytest_coordinator.log`）
- HMI 單元測試：307 passed（`pytest_hmi.log`）

## 還沒做

- 實機沒有重跑。Orin 上要 `git pull` 並重新建置（`colcon build`，或至少 `dual_arm_coordinator`），安裝目錄裡的設定檔才會更新。
- 如果還是吸不到，或吸盤壓太大力，再以 1 mm 為單位調整。
