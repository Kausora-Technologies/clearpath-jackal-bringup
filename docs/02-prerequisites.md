# Prerequisites

This page lists all software dependencies required before beginning the bring-up process.

---

## Workstation Requirements

| Requirement | Minimum Version |
|---|---|
| Ubuntu | 22.04 LTS (Jammy Jellyfish) |
| ROS 2 | Humble Hawksbill |
| Python | 3.10 |
| Git | 2.34 |

---

## ROS 2 Humble Installation

Follow the official installation instructions. A summary is provided below.

### 1. Set up sources

```bash
sudo apt update && sudo apt install -y curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu \
  $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | \
  sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```

### 2. Install ROS 2 Desktop

```bash
sudo apt update
sudo apt install ros-humble-desktop
```

### 3. Install build tools

```bash
sudo apt install python3-colcon-common-extensions python3-rosdep
sudo rosdep init
rosdep update
```

---

## Clearpath Desktop Packages

```bash
sudo apt install ros-humble-clearpath-desktop
```

This installs:

- `clearpath_viz` — RViz launch files and configurations
- `clearpath_description` — robot URDF/meshes
- `jackal_description` — Jackal-specific URDF components

---

## Navigation and SLAM Packages

```bash
sudo apt install \
  ros-humble-nav2-bringup \
  ros-humble-slam-toolbox \
  ros-humble-robot-localization \
  ros-humble-tf2-tools \
  ros-humble-tf2-ros
```

---

## Teleoperation Packages

```bash
sudo apt install \
  ros-humble-teleop-twist-keyboard \
  ros-humble-teleop-twist-joy \
  ros-humble-joy
```

---

## Diagnostic Tools

```bash
sudo apt install \
  ros-humble-rqt \
  ros-humble-rqt-common-plugins \
  ros-humble-rqt-robot-monitor \
  ros-humble-rqt-tf-tree \
  graphviz
```

> `graphviz` is required by `ros2 run tf2_tools view_frames` to render the TF tree as a PDF.

---

## Robot Onboard Software

The robot ships with Clearpath's platform software pre-installed. Verify the version on the robot via SSH:

```bash
ssh administrator@192.168.131.1

# On the robot
dpkg -l | grep clearpath
ros2 pkg list | grep clearpath
```

Expected packages on the robot:

- `clearpath_robot`
- `clearpath_config`
- `jackal_base` (or `clearpath_base`)
- `robot_localization`
- Sensor drivers as applicable (e.g., `urg_node`, `velodyne_driver`)

To update the robot's onboard packages:

```bash
# On the robot (requires internet access)
sudo apt update && sudo apt upgrade
```

---

## Network Tools

```bash
sudo apt install net-tools nmap iproute2
```

---

## Verification

After installation, verify the ROS 2 environment:

```bash
source /opt/ros/humble/setup.bash
ros2 --version
# Expected: ros2 cli version X.X.X (ROS Humble)
```

---

## Related Documents

- [03-workstation-setup.md](03-workstation-setup.md)
- [ROS 2 Humble Installation](https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html)
- [Clearpath Getting Started](https://docs.clearpathrobotics.com/docs/ros2/getting_started/)
