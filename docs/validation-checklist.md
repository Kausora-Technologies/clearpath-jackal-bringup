# Validation Checklist

Use this checklist to confirm the Jackal is fully operational before deployment. Each item maps to a detailed documentation page.

---

## How to Use

Work through each section in order. Mark items as pass (✓) or fail (✗). Document any failures and their resolutions before signing off.

> **Do not proceed to autonomous navigation until all items in Sections 1–6 are marked PASS.**

---

## Section 1 — Hardware and Power

| # | Check | Method | Pass |
|---|---|---|---|
| 1.1 | Robot powers on; HMI LEDs run test pattern | Power button press | ☐ |
| 1.2 | Comms LED goes green within 90 seconds | Visual — HMI panel | ☐ |
| 1.3 | Wi-Fi LED green (if Wi-Fi configured) | Visual — HMI panel | ☐ |
| 1.4 | Battery indicator shows ≥ 2 bars | Visual — HMI panel | ☐ |
| 1.5 | Battery percentage > 30% via ROS topic | `ros2 topic echo /platform/battery_state --once` | ☐ |

---

## Section 2 — Network and SSH Access

| # | Check | Method | Pass |
|---|---|---|---|
| 2.1 | Robot responds to ping | `ping -c 4 192.168.131.1` | ☐ |
| 2.2 | SSH login successful | `ssh administrator@192.168.131.1` | ☐ |
| 2.3 | Platform service active on robot | `sudo systemctl status clearpath-robot.service` | ☐ |
| 2.4 | Wi-Fi SSH working (if applicable) | `ssh administrator@<wifi_ip>` | ☐ |

---

## Section 3 — ROS 2 Environment

| # | Check | Method | Pass |
|---|---|---|---|
| 3.1 | `ROS_DOMAIN_ID` matches on workstation and robot | `echo $ROS_DOMAIN_ID` on both | ☐ |
| 3.2 | `RMW_IMPLEMENTATION` matches on workstation and robot | `echo $RMW_IMPLEMENTATION` on both | ☐ |
| 3.3 | `ros2 topic list` on workstation returns platform topics | `ros2 topic list` | ☐ |
| 3.4 | `ros2 node list` on workstation returns robot nodes | `ros2 node list` | ☐ |

---

## Section 4 — Sensor Validation

| # | Check | Topic | Expected Rate | Pass |
|---|---|---|---|---|
| 4.1 | IMU (filtered) publishing | `/imu/data` | ~50 Hz | ☐ |
| 4.2 | IMU linear acceleration z ≈ 9.81 m/s² (static) | `ros2 topic echo /imu/data --once` | — | ☐ |
| 4.3 | IMU (raw) publishing | `/imu/data_raw` | ~200 Hz | ☐ |
| 4.4 | Raw odometry publishing | `/odom` | ~50 Hz | ☐ |
| 4.5 | Filtered odometry publishing | `/odometry/filtered` | ~50 Hz | ☐ |
| 4.6 | GPS topic publishing | `/navsat/fix` | ~1 Hz | ☐ |
| 4.7 | GPS fix obtained (outdoor only) | `status.status ≥ 0` | — | ☐ |
| 4.8 | LiDAR scan publishing (if equipped) | `/scan` | 10–25 Hz | ☐ |
| 4.9 | Camera publishing (if equipped) | `/camera/color/image_raw` | 15–30 Hz | ☐ |

---

## Section 5 — TF Tree

| # | Check | Method | Pass |
|---|---|---|---|
| 5.1 | TF tree generates without errors | `ros2 run tf2_tools view_frames` | ☐ |
| 5.2 | `odom → base_link` transform present and updating | `ros2 run tf2_ros tf2_echo odom base_link` | ☐ |
| 5.3 | `base_link → imu_link` transform present | `ros2 run tf2_ros tf2_echo base_link imu_link` | ☐ |
| 5.4 | `base_link → laser` transform present (if LiDAR equipped) | `ros2 run tf2_ros tf2_echo base_link laser` | ☐ |
| 5.5 | No stale transforms in `tf2_monitor` | `ros2 run tf2_ros tf2_monitor` | ☐ |

---

## Section 6 — Teleoperation

| # | Check | Method | Pass |
|---|---|---|---|
| 6.1 | `/cmd_vel` accepts commands | `ros2 topic echo /cmd_vel` while teleop running | ☐ |
| 6.2 | Robot moves forward on command | Manual observation during keyboard teleop | ☐ |
| 6.3 | Robot rotates on command | Manual observation during keyboard teleop | ☐ |
| 6.4 | Robot stops when velocity command is zero | Manual observation | ☐ |
| 6.5 | Odometry increments during motion | `ros2 topic echo /odometry/filtered` | ☐ |
| 6.6 | PS4 deadman switch (L1) stops robot when released | Manual observation | ☐ |
| 6.7 | E-stop tested and confirmed (if installed) | Manual test | ☐ |

---

## Section 7 — Navigation and SLAM (Pre-Autonomous)

| # | Check | Method | Pass |
|---|---|---|---|
| 7.1 | SLAM toolbox launches without errors | `ros2 launch slam_toolbox online_async_launch.py use_sim_time:=false` | ☐ |
| 7.2 | Map topic publishing | `ros2 topic hz /map` | ☐ |
| 7.3 | Map builds correctly during manual drive | Visual inspection in RViz | ☐ |
| 7.4 | Map saved successfully | `ros2 run nav2_map_server map_saver_cli -f map` | ☐ |
| 7.5 | Nav2 stack launches without errors | `ros2 launch nav2_bringup navigation_launch.py` | ☐ |
| 7.6 | Global costmap updating | `ros2 topic hz /global_costmap/costmap` | ☐ |
| 7.7 | Local costmap updating | `ros2 topic hz /local_costmap/costmap` | ☐ |
| 7.8 | Initial pose set in RViz | AMCL particles converge on robot position | ☐ |
| 7.9 | Navigation goal reached successfully | Send goal in RViz; robot navigates to target | ☐ |

---

## Section 8 — RViz Visualisation

| # | Check | Method | Pass |
|---|---|---|---|
| 8.1 | Robot model displays correctly | RViz — RobotModel display | ☐ |
| 8.2 | TF frames visible and updating | RViz — TF display | ☐ |
| 8.3 | LiDAR scan visible and aligned with model (if equipped) | RViz — LaserScan display | ☐ |
| 8.4 | Odometry path traces correctly | RViz — Odometry display | ☐ |
| 8.5 | No error messages in RViz status bar | Visual | ☐ |

---

## Sign-off

| Field | Value |
|---|---|
| Robot serial number | |
| Date | |
| Operator name | |
| ROS 2 distribution | Humble |
| Platform software version | |
| Validation result | PASS / FAIL |
| Outstanding issues | |
| Notes | |

---

## Related Documents

- [07-sensor-validation.md](07-sensor-validation.md)
- [troubleshooting.md](troubleshooting.md)
- [safety-notes.md](safety-notes.md)
