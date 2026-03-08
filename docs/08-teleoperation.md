# Teleoperation

Always validate teleoperation before any autonomous operation. Confirm the robot responds correctly to velocity commands and that the e-stop is functional.

---

## Safety Pre-checks

- [ ] Area is clear of people and obstacles (minimum 2 m clearance)
- [ ] Battery above 30%
- [ ] E-stop released (if installed)
- [ ] Motor enable confirmed (motor LED on HMI panel should be on after first command)
- [ ] Maximum speed understood: Jackal peak speed is **2.0 m/s**

---

## Option 1 — Keyboard Teleoperation

Keyboard teleoperation is the simplest method and requires no additional hardware.

### Launch

```bash
# On workstation
ros2 run teleop_twist_keyboard teleop_twist_keyboard \
  --ros-args --remap cmd_vel:=/cmd_vel
```

### Controls

| Key | Action |
|---|---|
| `i` | Forward |
| `,` | Backward |
| `j` | Rotate left (CCW) |
| `l` | Rotate right (CW) |
| `u` | Forward-left arc |
| `o` | Forward-right arc |
| `m` | Backward-left arc |
| `.` | Backward-right arc |
| `k` | Stop (zero velocity) |
| `q` / `z` | Increase / decrease max speed |
| `w` / `x` | Increase / decrease linear speed |
| `e` / `c` | Increase / decrease angular speed |

> Start with a low speed setting (`z` to reduce, default ~0.5 m/s) and increase gradually.

### Verify motion

```bash
# In a second terminal, monitor velocity command and odometry
ros2 topic echo /cmd_vel
ros2 topic echo /odometry/filtered
```

---

## Option 2 — PS4 Controller (Bluetooth)

The Jackal ships with a Sony PS4 DualShock controller for wireless teleoperation.

### Pairing the Controller

1. Press and hold the **PS button** and **SHARE button** simultaneously until the light bar flashes white rapidly — the controller is in pairing mode.

2. On the robot (via SSH):

   ```bash
   sudo bluetoothctl
   scan on
   # Wait for "DualShock 4" to appear with its MAC address, e.g. AA:BB:CC:DD:EE:FF
   pair AA:BB:CC:DD:EE:FF
   trust AA:BB:CC:DD:EE:FF
   connect AA:BB:CC:DD:EE:FF
   ```

3. The controller light bar will turn solid blue when paired.

> Alternatively, if the controller has been previously paired, simply press the **PS button** once. The small LED on the front of the controller will go solid when connected.

### Controller Layout

Refer to the Sony PS4 Controller diagram (`Sony_PS4_Controller_Labelled.pdf`) for button identification.

| Control | Function |
|---|---|
| **L1** (left shoulder) | Deadman switch — must be held for robot to move |
| **Left thumbstick** (up/down) | Forward / reverse |
| **Left thumbstick** (left/right) | Left / right rotation |
| **R1** (right shoulder) | High-speed mode (hold with L1 for full speed) |

> **Deadman switch:** The robot will not move unless **L1** is held. Releasing L1 immediately stops the robot.

### Launch Joy Node

```bash
# On workstation (or robot)
ros2 launch teleop_twist_joy teleop-launch.py \
  joy_config:=ps4
```

> If using the robot's local launch, the Clearpath platform software may already start the joy node automatically. Check:

```bash
ros2 node list | grep joy
ros2 topic echo /joy --once
```

### Verify joy input

```bash
ros2 topic hz /joy
# Expected: ~50 Hz while controller is connected
```

---

## Option 3 — Xbox Controller

Xbox controllers require the `xboxdrv` driver or the kernel's built-in `xpad` driver.

```bash
sudo apt install ros-humble-joy
ros2 run joy joy_node

# With teleop_twist_joy
ros2 launch teleop_twist_joy teleop-launch.py joy_config:=xbox
```

---

## Verifying Motor Response

After sending a velocity command, verify the robot physically moves and the odometry updates:

```bash
# Terminal 1: Watch odometry
ros2 topic echo /odometry/filtered

# Terminal 2: Send a single velocity command (0.2 m/s forward for 1 second)
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist \
  "{linear: {x: 0.2, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}"
```

The robot should move forward approximately 0.2 m and then stop. The `pose.pose.position.x` in `/odometry/filtered` should increase accordingly.

---

## Stopping the Robot

To send an explicit zero-velocity command:

```bash
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist \
  "{linear: {x: 0.0, y: 0.0, z: 0.0}, angular: {x: 0.0, y: 0.0, z: 0.0}}"
```

---

## Troubleshooting Teleoperation

| Symptom | Check |
|---|---|
| Robot does not move | Confirm L1 held (PS4); confirm motor enable; check `/cmd_vel` is publishing |
| Robot moves erratically | Reduce speed; check for competing `/cmd_vel` publishers |
| Controller not detected | Run `ls /dev/input/js*`; ensure `joy_node` is running |
| High latency response | Check network latency; switch to robot-local joy node |

---

## Related Documents

- [06-robot-bringup.md](06-robot-bringup.md)
- [09-navigation-slam.md](09-navigation-slam.md)
- [safety-notes.md](safety-notes.md)
