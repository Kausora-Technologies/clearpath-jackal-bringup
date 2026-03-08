# Sensor Validation

This page covers validation of all standard sensors on the Jackal UGV. Perform these checks after a successful platform bring-up before any autonomous operation.

> **Namespace note:** Clearpath platform topics are published under the robot's ROS 2 namespace
> (e.g., `/a200_0000/imu/data`). Verify the prefix with `ros2 topic list | head -20` and prepend
> it to all topic names in the commands below if your robot uses a namespace.

---

## Validation Order

1. IMU
2. GPS / NavSat
3. Odometry (wheel encoders + EKF)
4. LiDAR (if equipped)
5. Camera (if equipped)
6. TF tree integrity

---

## 1. IMU Validation

The Jackal's internal IMU (gyroscope, accelerometer, magnetometer) is integrated into the MCU.

### Check topic is publishing

```bash
ros2 topic hz /imu/data
```

Expected: ~50 Hz

### Inspect message content

```bash
ros2 topic echo /imu/data --once
```

Verify:

- `header.frame_id` = `imu_link`
- `orientation` — non-zero quaternion
- `angular_velocity` — near-zero when robot is stationary
- `linear_acceleration` — z-component near 9.81 m/s² when flat
- Covariance matrices — non-zero values indicate filter is active

### Raw IMU data

```bash
ros2 topic hz /imu/data_raw
# Expected: higher than /imu/data (rate is firmware-dependent; typically 50–200 Hz)
```

---

## 2. GPS / NavSat Validation

The Jackal includes an integrated GPS receiver connected via the MCU.

### Check fix topic

```bash
ros2 topic hz /navsat/fix
# Expected: ~1 Hz (GPS update rate)
```

```bash
ros2 topic echo /navsat/fix --once
```

Key fields:

| Field | Expected |
|---|---|
| `status.status` | `0` (fix) or `1` (SBAS fix); `-1` = no fix |
| `latitude` | Degrees, near actual location |
| `longitude` | Degrees, near actual location |
| `altitude` | Metres |
| `position_covariance_type` | `1` (approximated) or `2` (diagonal known) |

> GPS fix may take 30–120 seconds outdoors after first power-on. Indoor GPS signal is not expected.

### Check velocity topic

```bash
ros2 topic echo /navsat/vel --once
```

---

## 3. Odometry Validation

The Jackal uses a `robot_localization` EKF node to fuse wheel encoder odometry with IMU data.

### Check raw odometry

```bash
ros2 topic hz /odom
# Expected: ~50 Hz

ros2 topic echo /odom --once
```

Verify `child_frame_id` = `base_link`.

### Check filtered odometry

```bash
ros2 topic hz /odometry/filtered
# Expected: ~50 Hz

ros2 topic echo /odometry/filtered --once
```

The filtered odometry should have lower covariance values than raw odometry.

### Motion test

Briefly drive the robot forward 0.5 m (see [08-teleoperation.md](08-teleoperation.md)) and verify that the `pose.pose.position.x` field in `/odometry/filtered` increments by approximately 0.5 m.

---

## 4. LiDAR Validation (if equipped)

Standard LiDAR payloads on Jackal include the Hokuyo UST-10LX, SICK LMS1xx, or Velodyne VLP-16.

### Check scan topic

```bash
ros2 topic hz /scan
# Expected: 10–25 Hz depending on sensor model
```

```bash
ros2 topic echo /scan --once
```

Verify:

| Field | Expected |
|---|---|
| `header.frame_id` | `laser` or sensor-specific frame |
| `angle_min` / `angle_max` | Sensor FOV bounds (e.g., -2.356 / 2.356 rad for 270° sensor) |
| `ranges` | Array of valid float values; `inf` for out-of-range readings |
| `range_min` / `range_max` | Matches sensor datasheet |

### LiDAR in RViz

In RViz, add a **LaserScan** display on `/scan`. Confirm point cloud is visible and aligned with the robot model.

---

## 5. Camera Validation (if equipped)

Payload cameras vary. Standard checks apply regardless of camera type.

```bash
ros2 topic list | grep image
```

Common topics:

- `/camera/color/image_raw`
- `/camera/depth/image_rect_raw`
- `/camera/color/camera_info`

```bash
ros2 topic hz /camera/color/image_raw
# Expected: 15–30 Hz depending on configuration
```

Use `rqt_image_view` to inspect the feed:

```bash
ros2 run rqt_image_view rqt_image_view
```

---

## 6. TF Tree Validation

The TF tree must be complete and continuously updating for navigation to function correctly.

### Generate TF tree diagram

```bash
ros2 run tf2_tools view_frames
evince frames.pdf
```

Verify all expected frames are present:

```text
odom
└── base_link
    ├── imu_link
    ├── navsat_link
    ├── front_left_wheel_link
    ├── front_right_wheel_link
    ├── rear_left_wheel_link
    ├── rear_right_wheel_link
    └── [payload frames]
```

### Check specific transform

```bash
ros2 run tf2_ros tf2_echo odom base_link
```

Expected: Continuous transform updates at ~50 Hz.

### Check for stale or broken transforms

```bash
ros2 run tf2_ros tf2_monitor
```

Look for any frames with `Most Recent Transform: xx.xx sec` that are not updating. Stale transforms indicate a sensor driver or publisher failure.

---

## Sensor Validation Summary

| Sensor | Topic | Expected Rate | Pass Criteria |
|---|---|---|---|
| IMU (filtered) | `/imu/data` | ~50 Hz | Quaternion non-zero, accel z ≈ 9.81 |
| IMU (raw) | `/imu/data_raw` | ~200 Hz | Data publishing |
| GPS | `/navsat/fix` | ~1 Hz | Status 0 or 1 outdoors |
| Raw odometry | `/odom` | ~50 Hz | Increments during motion |
| Filtered odometry | `/odometry/filtered` | ~50 Hz | Lower covariance than raw |
| LiDAR | `/scan` | 10–25 Hz | Valid ranges, correct frame |
| TF tree | `/tf` | ~50 Hz | All frames present, no stale |

---

## Related Documents

- [06-robot-bringup.md](06-robot-bringup.md)
- [08-teleoperation.md](08-teleoperation.md)
- [10-rviz-visualization.md](10-rviz-visualization.md)
- [validation-checklist.md](validation-checklist.md)
