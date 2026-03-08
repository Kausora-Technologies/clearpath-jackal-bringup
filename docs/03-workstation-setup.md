# Workstation Setup

This page covers ROS 2 environment configuration on the workstation for communication with the Jackal.

---

## 1. Source ROS 2 Environment

Add the ROS 2 setup script to your shell profile so it is sourced automatically in every terminal session.

```bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
printenv | grep ROS
# Expected: ROS_VERSION=2, ROS_DISTRO=humble
```

---

## 2. Set ROS Domain ID

All ROS 2 nodes on the same network must share the same `ROS_DOMAIN_ID` to discover each other via DDS.

```bash
echo "export ROS_DOMAIN_ID=0" >> ~/.bashrc
source ~/.bashrc
```

> **Note:** The robot's default `ROS_DOMAIN_ID` is `0`. If multiple robots or teams are on the same network, assign unique domain IDs to avoid cross-talk.

---

## 3. Set RMW Implementation (Optional)

The default RMW (ROS Middleware) for ROS 2 Humble is Fast-DDS. To explicitly set it:

```bash
echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> ~/.bashrc
source ~/.bashrc
```

If using Cyclone DDS (must match robot configuration):

```bash
sudo apt install ros-humble-rmw-cyclonedds-cpp
echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc
```

> Both workstation and robot must use the same RMW implementation.

---

## 4. Configure Network Interface

Ensure the workstation's network interface is on the same subnet as the robot (`192.168.131.x`).

### Check current IP

```bash
ip addr show
```

### Set static IP on the Ethernet interface (for wired connection)

Using NetworkManager (Ubuntu Desktop):

```
Connection: Wired
IPv4 Method: Manual
Address: 192.168.131.51
Netmask: 255.255.255.0
Gateway: (leave blank)
```

Using `nmcli`:

```bash
# Replace eth0 with your interface name
sudo nmcli con mod "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses 192.168.131.51/24 \
  ipv4.gateway ""
sudo nmcli con up "Wired connection 1"
```

Verify:

```bash
ping 192.168.131.1
# Expected: responses from robot
```

---

## 5. Hosts File (Optional)

If you prefer to use the robot's hostname instead of its IP:

```bash
# Add to /etc/hosts
echo "192.168.131.1  jackal" | sudo tee -a /etc/hosts
```

Then you can use `ssh administrator@jackal` and set `ROS_DISCOVERY_SERVER` by hostname.

---

## 6. Workspace Setup (If Building from Source)

If your integration requires a custom ROS 2 workspace:

```bash
mkdir -p ~/kausora_ws/src
cd ~/kausora_ws/src
# Clone integration packages here

cd ~/kausora_ws
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install
echo "source ~/kausora_ws/install/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

## 7. Verify Discovery (After Robot Bring-up)

Once the robot is running (see [06-robot-bringup.md](06-robot-bringup.md)), verify topic discovery from the workstation:

```bash
ros2 topic list
```

Expected output includes topics such as:

```
/cmd_vel
/diagnostics
/imu/data
/odometry/filtered
/odom
/navsat/fix
/platform/battery_state
/tf
/tf_static
```

If no topics appear, refer to [troubleshooting.md](troubleshooting.md#no-topics-visible-from-workstation).

---

## Related Documents

- [04-robot-network-access.md](04-robot-network-access.md)
- [05-ros2-environment.md](05-ros2-environment.md)
- [troubleshooting.md](troubleshooting.md)
