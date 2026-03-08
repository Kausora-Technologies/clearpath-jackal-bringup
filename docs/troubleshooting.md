# Troubleshooting

This page documents common issues encountered during Jackal bring-up and their resolutions. Issues are grouped by stage.

---

## Network and SSH

### Cannot SSH to robot

**Symptom:** `ssh administrator@192.168.131.1` times out or returns "Connection refused".

**Steps:**

1. Verify the Ethernet cable is connected to the **STATIC** port on the robot.
2. Confirm workstation static IP is set correctly:
   ```bash
   ip addr show | grep 192.168.131
   # Expected: 192.168.131.51
   ```
3. Ping the robot:
   ```bash
   ping -c 4 192.168.131.1
   ```
4. If ping fails, check the HMI panel — the robot must be fully booted (Comms LED green).
5. If ping succeeds but SSH fails, restart the SSH service on the robot (physical access required):
   ```bash
   # Console access via monitor/keyboard plugged into robot
   sudo systemctl restart sshd
   ```

---

### Comms LED not green after boot

**Symptom:** Power LED is on but Comms LED remains off after 90 seconds.

**Steps:**

1. SSH to robot if possible:
   ```bash
   sudo systemctl status clearpath-robot.service
   ```
2. Check for USB device:
   ```bash
   ls /dev/ttyUSB* /dev/ttyACM*
   ```
   The MCU should appear as `/dev/ttyACM0` or similar.
3. If no device found, check physical USB connection between MCU and onboard PC.
4. Restart the platform service:
   ```bash
   sudo systemctl restart clearpath-robot.service
   ```
5. View logs for errors:
   ```bash
   journalctl -u clearpath-robot.service -n 50
   ```

---

## ROS 2 Topic Discovery

### No topics visible from workstation

**Symptom:** `ros2 topic list` on workstation returns only `/parameter_events` and `/rosout`, or nothing.

**Steps:**

1. Confirm `ROS_DOMAIN_ID` matches on workstation and robot:
   ```bash
   # Workstation
   echo $ROS_DOMAIN_ID

   # Robot (via SSH)
   echo $ROS_DOMAIN_ID
   ```
   Both must be the same value (default: `0`).

2. Confirm `RMW_IMPLEMENTATION` matches:
   ```bash
   echo $RMW_IMPLEMENTATION
   ```

3. Check if the robot has active publishers:
   ```bash
   # On robot via SSH
   ros2 topic list
   ```
   If topics appear on the robot but not the workstation, the issue is network/DDS discovery.

4. Test DDS multicast on the network. Multicast is required for default DDS discovery. Switch to Discovery Server if multicast is blocked:
   ```bash
   # On robot — start discovery server
   fastdds discovery -i 0 -l 192.168.131.1 -p 11811

   # On workstation
   export ROS_DISCOVERY_SERVER="192.168.131.1:11811"
   ros2 topic list
   ```

5. Check for firewall rules blocking UDP:
   ```bash
   sudo ufw status
   # If active, allow UDP traffic on the ROS 2 DDS ports
   sudo ufw allow 7400:7500/udp
   ```

---

### Topics appear but data is not received

**Symptom:** `ros2 topic list` shows topics, but `ros2 topic echo /imu/data` produces no output.

**Steps:**

1. Check the topic has publishers:
   ```bash
   ros2 topic info /imu/data
   # Should show Publisher count: 1
   ```
2. Verify QoS compatibility:
   ```bash
   ros2 topic info /imu/data --verbose
   ```
   Mismatched QoS (e.g., reliable vs best-effort) prevents message delivery. Use `--qos-reliability best_effort` if needed:
   ```bash
   ros2 topic echo /imu/data --qos-reliability best_effort
   ```

---

## Sensor Issues

### IMU not publishing

**Steps:**

1. Check MCU connection (see Comms LED section above).
2. Check IMU filter node:
   ```bash
   ros2 node list | grep imu
   ros2 node info /imu_filter_node
   ```
3. Check diagnostics:
   ```bash
   ros2 topic echo /diagnostics | grep -A5 imu
   ```

---

### LiDAR not publishing

**Steps:**

1. Verify LiDAR driver node is running:
   ```bash
   ros2 node list | grep laser
   ros2 node list | grep lidar
   ```
2. Check the USB or Ethernet connection to the LiDAR.
3. For USB LiDARs, verify device is present:
   ```bash
   ls /dev/ttyUSB*
   ```
4. Restart the LiDAR driver:
   ```bash
   sudo systemctl restart clearpath-robot.service
   ```
5. Check driver logs:
   ```bash
   journalctl -u clearpath-robot.service -f | grep -i lidar
   ```

---

### GPS not getting a fix

**Steps:**

1. Confirm the `/navsat/fix` topic is publishing (even without a fix, the topic should publish with `status.status: -1`).
2. Move the robot outdoors. GPS will not achieve a fix indoors.
3. Allow 60–120 seconds for first fix acquisition.
4. Check the GPS antenna is connected and unobstructed.

---

## Teleoperation Issues

### Robot not moving with keyboard

**Steps:**

1. Confirm `teleop_twist_keyboard` is running and `/cmd_vel` is being published:
   ```bash
   ros2 topic echo /cmd_vel
   ```
2. Confirm motor enable is active (press the motor button on the HMI panel if available).
3. Check for competing publishers on `/cmd_vel`:
   ```bash
   ros2 topic info /cmd_vel
   # Publisher count should be 1 during teleop
   ```
4. Verify the robot's platform service is running.

---

### PS4 controller not pairing

**Steps:**

1. Check that the controller is in pairing mode (light bar flashing white rapidly).
2. Verify Bluetooth is active on the robot:
   ```bash
   sudo systemctl status bluetooth
   ```
3. Use `bluetoothctl` to scan and pair:
   ```bash
   sudo bluetoothctl
   power on
   agent on
   scan on
   ```
4. If previously paired but not connecting, remove and re-pair:
   ```bash
   remove AA:BB:CC:DD:EE:FF
   ```

---

## Navigation and SLAM

### Nav2 costmap is empty

**Steps:**

1. Confirm `/scan` is publishing:
   ```bash
   ros2 topic hz /scan
   ```
2. Verify the `sensor_sources` parameter in the costmap config points to `/scan`.
3. Check the costmap frame and LiDAR frame are connected in the TF tree:
   ```bash
   ros2 run tf2_ros tf2_echo base_link laser
   ```

---

### SLAM map not building

**Steps:**

1. Confirm `/scan` and `/tf` are publishing.
2. Confirm `slam_toolbox` node is running:
   ```bash
   ros2 node list | grep slam
   ```
3. Check slam_toolbox logs:
   ```bash
   ros2 node info /slam_toolbox
   ```
4. Ensure the robot is moving. SLAM requires motion to build a map.

---

### TF lookup failed

**Symptom:** Error: `"base_link" passed to lookupTransform argument source_frame does not exist`.

**Steps:**

1. Regenerate TF tree:
   ```bash
   ros2 run tf2_tools view_frames
   ```
2. Identify the missing frame and which node should be publishing it.
3. Verify the platform launch completed fully:
   ```bash
   sudo systemctl status clearpath-robot.service
   ```

---

## Related Documents

- [05-ros2-environment.md](05-ros2-environment.md)
- [06-robot-bringup.md](06-robot-bringup.md)
- [07-sensor-validation.md](07-sensor-validation.md)
- [Clearpath Support](https://support.clearpathrobotics.com)
