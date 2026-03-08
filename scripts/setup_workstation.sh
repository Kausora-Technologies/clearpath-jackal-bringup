#!/bin/bash
# setup_workstation.sh
# Kausora Technologies — Jackal Workstation Setup Script
#
# Configures a Ubuntu 22.04 workstation for ROS 2 Humble communication
# with a Clearpath Jackal UGV.
#
# Usage:
#   chmod +x setup_workstation.sh
#   ./setup_workstation.sh
#
# Review each step before running. This script appends to ~/.bashrc.

set -e

ROS_DISTRO="humble"
DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

echo "=== Jackal Workstation Setup ==="
echo "ROS distro : ${ROS_DISTRO}"
echo "Domain ID  : ${DOMAIN_ID}"
echo ""

# ── Step 1: Verify ROS 2 installation ──────────────────────────────────────
if [ ! -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
  echo "[ERROR] ROS 2 ${ROS_DISTRO} is not installed."
  echo "Install it from: https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debians.html"
  exit 1
fi
echo "[OK] ROS 2 ${ROS_DISTRO} found."

# ── Step 1.5: Verify sudo access ───────────────────────────────────────────
if ! sudo -v 2>/dev/null; then
  echo "[ERROR] sudo privileges required. Run as a user with sudo access."
  exit 1
fi
echo "[OK] sudo access confirmed."

# ── Step 2: Install Clearpath desktop and navigation packages ──────────────
echo ""
echo "[INFO] Installing required packages..."
sudo apt update -qq
DEBIAN_FRONTEND=noninteractive sudo apt install -y \
  ros-${ROS_DISTRO}-clearpath-desktop \
  ros-${ROS_DISTRO}-nav2-bringup \
  ros-${ROS_DISTRO}-slam-toolbox \
  ros-${ROS_DISTRO}-robot-localization \
  ros-${ROS_DISTRO}-tf2-tools \
  ros-${ROS_DISTRO}-tf2-ros \
  ros-${ROS_DISTRO}-teleop-twist-keyboard \
  ros-${ROS_DISTRO}-teleop-twist-joy \
  ros-${ROS_DISTRO}-joy \
  ros-${ROS_DISTRO}-rqt \
  ros-${ROS_DISTRO}-rqt-common-plugins \
  ros-${ROS_DISTRO}-rqt-robot-monitor \
  ros-${ROS_DISTRO}-rqt-tf-tree \
  graphviz
echo "[OK] Packages installed."

# ── Step 3: Configure ~/.bashrc ────────────────────────────────────────────
echo ""
echo "[INFO] Configuring ~/.bashrc..."

# Source ROS 2
if ! grep -q "source /opt/ros/${ROS_DISTRO}/setup.bash" ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo "# ROS 2 ${ROS_DISTRO}" >> ~/.bashrc
  echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc
  echo "[OK] Added ROS 2 source to ~/.bashrc"
else
  echo "[SKIP] ROS 2 source already in ~/.bashrc"
fi

# ROS_DOMAIN_ID
if ! grep -q "ROS_DOMAIN_ID" ~/.bashrc; then
  echo "export ROS_DOMAIN_ID=${DOMAIN_ID}" >> ~/.bashrc
  echo "[OK] Set ROS_DOMAIN_ID=${DOMAIN_ID} in ~/.bashrc"
else
  echo "[SKIP] ROS_DOMAIN_ID already in ~/.bashrc"
fi

# RMW implementation
if ! grep -q "RMW_IMPLEMENTATION" ~/.bashrc; then
  echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> ~/.bashrc
  echo "[OK] Set RMW_IMPLEMENTATION in ~/.bashrc"
else
  echo "[SKIP] RMW_IMPLEMENTATION already in ~/.bashrc"
fi

# ── Step 4: Network verification ───────────────────────────────────────────
echo ""
echo "[INFO] Checking network connectivity to robot..."
if ping -c 2 -W 2 192.168.131.1 > /dev/null 2>&1; then
  echo "[OK] Robot at 192.168.131.1 is reachable."
else
  echo "[WARN] Cannot reach 192.168.131.1."
  echo "       Ensure the Ethernet cable is connected to the STATIC port"
  echo "       and workstation IP is set to 192.168.131.51/24."
fi

# ── Done ───────────────────────────────────────────────────────────────────
echo ""
echo "=== Setup complete ==="
echo ""
echo "Reload your shell environment:"
echo "  source ~/.bashrc"
echo ""
echo "Next steps:"
echo "  1. Ensure robot is powered on and reachable: ping 192.168.131.1"
echo "  2. SSH to robot: ssh administrator@192.168.131.1"
echo "  3. Follow docs/06-robot-bringup.md to start platform drivers"
echo "  4. Verify topics: ros2 topic list"
