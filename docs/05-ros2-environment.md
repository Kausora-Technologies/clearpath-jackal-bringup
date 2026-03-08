# ROS 2 Environment Configuration

This page covers ROS 2 middleware settings, domain configuration, and environment variable setup required for reliable workstation–robot communication.

---

## ROS 2 Discovery Concepts

In ROS 2, nodes discover each other via DDS (Data Distribution Service) middleware. Two machines on the same network will discover each other automatically if:

1. They share the same `ROS_DOMAIN_ID`
2. They use the same RMW (ROS Middleware) implementation
3. Multicast traffic is not blocked between them (LAN requirement)

---

## Environment Variables

### Required

| Variable | Default | Description |
|---|---|---|
| `ROS_DOMAIN_ID` | `0` | Isolates ROS 2 communication; must match on robot and workstation |
| `RMW_IMPLEMENTATION` | `rmw_fastrtps_cpp` | DDS middleware; must match on both machines |

### Recommended

| Variable | Value | Description |
|---|---|---|
| `RCUTILS_LOGGING_MIN_SEVERITY` | `INFO` | Sets minimum log output level |

---

## Setting Environment Variables

Add to `~/.bashrc` on the workstation:

```bash
source /opt/ros/humble/setup.bash
export ROS_DOMAIN_ID=0
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
```

Apply immediately:

```bash
source ~/.bashrc
```

Do the same on the robot (via SSH). Check the current robot configuration:

```bash
# On the robot
cat ~/.bashrc | grep ROS
```

---

## RMW Implementation Options

### Fast-DDS (default, recommended)

```bash
sudo apt install ros-humble-rmw-fastrtps-cpp
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
```

### Cyclone DDS (alternative)

```bash
sudo apt install ros-humble-rmw-cyclonedds-cpp
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
```

> The robot and workstation must use the same RMW. Check which RMW the robot uses before changing the workstation configuration.

---

## Fast-DDS Discovery Server (for complex networks)

On networks where UDP multicast is unreliable (VPNs, multi-subnet environments, Docker), use the Fast-DDS Discovery Server instead of default peer-to-peer discovery.

### On the robot (server)

```bash
fastdds discovery -i 0 -l 192.168.131.1 -p 11811
```

### On the workstation (client)

```bash
export ROS_DISCOVERY_SERVER="192.168.131.1:11811"
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
```

---

## Verifying Discovery

After configuring both machines, start the robot drivers (see [06-robot-bringup.md](06-robot-bringup.md)) and verify:

```bash
# List all nodes visible from workstation
ros2 node list

# List all topics
ros2 topic list

# Check a specific topic is active
ros2 topic info /imu/data
```

Expected node list includes nodes such as:

```
/controller_manager
/ekf_node
/imu_filter_node
/jackal_base_node
/robot_state_publisher
```

---

## ROS_DOMAIN_ID Isolation

If multiple robots or teams share the same network, assign distinct domain IDs:

| Robot/Team | ROS_DOMAIN_ID |
|---|---|
| Jackal #1 (default) | 0 |
| Jackal #2 | 1 |
| Simulation workstation | 10 |

Use domain IDs in the range 0–101. Values 101–232 are valid but may produce port numbers that overlap with the OS ephemeral port range on some systems.

---

## Confirming TF Time Sync

Ensure workstation and robot system clocks are synchronised. Clock skew causes TF lookup failures in Nav2 and SLAM.

```bash
# On workstation
date

# On robot (via SSH)
date
```

If clocks differ, install and enable NTP:

```bash
# On both machines
sudo apt install chrony
sudo systemctl enable --now chrony
```

---

## Related Documents

- [03-workstation-setup.md](03-workstation-setup.md)
- [06-robot-bringup.md](06-robot-bringup.md)
- [troubleshooting.md](troubleshooting.md)
- [ROS 2 DDS Documentation](https://docs.ros.org/en/humble/Concepts/About-Different-Middleware-Vendors.html)
