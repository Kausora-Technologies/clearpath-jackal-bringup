# Robot Bring-up

This page covers powering on the Jackal, verifying the HMI status, and launching the ROS 2 platform drivers.

---

## Step 1 — Pre-Power Check

Before powering on:

- [ ] Battery is connected (large Anderson Power Pole connector inside chassis)
- [ ] Charging cable is disconnected
- [ ] Workspace is clear of obstructions (minimum 1 m clearance)
- [ ] E-stop (if fitted) is released
- [ ] PS4 controller is charged

---

## Step 2 — Power On

Press the **power button** on the HMI panel (rightmost button).

The LED indicators will run a test pattern. Allow approximately **30–60 seconds** for the onboard PC to complete booting.

### HMI Panel Status After Boot

| Indicator | Expected State |
|---|---|
| Power LED | Solid green |
| Comms LED | Solid green (MCU–PC link established) |
| Wi-Fi LED | Solid green (if Wi-Fi configured) |
| Battery indicator | Reflects current charge level |
| Motor LED | Off (motors disabled at startup) |

> If the Comms LED does not go green within 90 seconds, the platform software may have failed to start. Check [troubleshooting.md](troubleshooting.md#comms-led-not-green-after-boot).

---

## Step 3 — Verify SSH Access

```bash
ssh administrator@192.168.131.1
```

Once connected, check that the Clearpath platform service is running:

```bash
sudo systemctl status clearpath-robot.service
```

Expected output: `active (running)`

---

## Step 4 — Launch Platform Drivers

### Automatic Launch (systemd service)

The Clearpath robot software is configured to start automatically at boot via a systemd service. No manual launch is required in a standard deployment.

Verify:

```bash
sudo systemctl status clearpath-robot.service
```

To restart the service:

```bash
sudo systemctl restart clearpath-robot.service
```

To view live logs:

```bash
journalctl -u clearpath-robot.service -f
```

---

### Manual Launch (development / debugging)

If the service is disabled or you need to launch manually:

```bash
# On the robot via SSH
source /opt/ros/humble/setup.bash
ros2 launch clearpath_robot robot.launch.py
```

Leave this terminal open. Open a second SSH session for further commands.

---

## Step 5 — Verify Platform Topics

From the **workstation** (ensure `ROS_DOMAIN_ID` matches):

```bash
ros2 topic list
```

> **Namespace note:** Clearpath platform topics are published under the robot's ROS 2 namespace
> (e.g., `/a200_0000/imu/data`). Run `ros2 topic list | head -20` to see the actual prefix for
> your robot. The namespace is set by `ros2.namespace` in `/etc/clearpath/robot.yaml`. The examples
> below use bare topic names — prepend your robot's namespace if needed.

Minimum expected topics after successful bring-up:

```
/cmd_vel
/diagnostics
/imu/data
/imu/data_raw
/navsat/fix
/navsat/vel
/odom
/odometry/filtered
/platform/battery_state
/tf
/tf_static
```

Check message rates on key topics:

```bash
# IMU should publish at ~50 Hz
ros2 topic hz /imu/data

# Odometry should publish at ~50 Hz
ros2 topic hz /odometry/filtered

# Battery state — typically 1 Hz
ros2 topic hz /platform/battery_state
```

---

## Step 6 — Verify TF Tree

```bash
ros2 run tf2_tools view_frames
```

This generates `frames.pdf` in the current directory. Inspect it to confirm the TF tree is complete:

```
odom → base_link → [sensor frames]
```

Alternatively, check specific transforms:

```bash
ros2 run tf2_ros tf2_echo odom base_link
```

---

## Step 7 — Check Diagnostics

```bash
ros2 topic echo /diagnostics
```

Look for any `ERROR` or `WARN` level messages. Common diagnostic fields:

- `jackal_base`: MCU connection and firmware status
- `imu_filter`: IMU data health
- `robot_localization`: EKF filter status
- Sensor drivers (LiDAR, camera) if payloads are installed

---

## Step 8 — Check Battery Level

```bash
ros2 topic echo /platform/battery_state --once
```

Key fields:

| Field | Description |
|---|---|
| `percentage` | Battery charge 0.0–1.0 |
| `voltage` | Pack voltage (nominal ~29.6 V) |
| `power_supply_status` | Charging/discharging/full |

> Do not operate the Jackal below 20% battery. Return to charging when the battery indicator shows one bar.

---

## Shutting Down

To power off cleanly:

```bash
# On the robot via SSH
sudo shutdown -h now
```

Wait for the onboard PC to power off (activity LED stops), then press the HMI power button to cut main power. Connect the charging cable to the rear charge port.

---

## Related Documents

- [07-sensor-validation.md](07-sensor-validation.md)
- [08-teleoperation.md](08-teleoperation.md)
- [troubleshooting.md](troubleshooting.md)
- [safety-notes.md](safety-notes.md)
