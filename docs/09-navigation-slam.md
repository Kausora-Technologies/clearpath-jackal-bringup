# Navigation and SLAM

This page covers integration of the Nav2 navigation stack and slam_toolbox for autonomous navigation and map building on the Jackal.

---

## Prerequisites

Before starting navigation or SLAM:

- [ ] Platform drivers running ([06-robot-bringup.md](06-robot-bringup.md))
- [ ] Sensor validation complete ([07-sensor-validation.md](07-sensor-validation.md))
- [ ] TF tree verified (`odom → base_link → laser`)
- [ ] LiDAR publishing on `/scan`
- [ ] Teleoperation confirmed ([08-teleoperation.md](08-teleoperation.md))

---

## SLAM — Building a Map

Use `slam_toolbox` in online asynchronous mode to build a 2D occupancy map while manually driving the robot.

### Install

```bash
sudo apt install ros-humble-slam-toolbox
```

### Launch SLAM

```bash
# On workstation (robot drivers running on robot)
ros2 launch slam_toolbox online_async_launch.py \
  use_sim_time:=false
```

### Visualise in RViz

```bash
ros2 launch clearpath_viz view_model.launch.py
```

In RViz, add:

- **Map** display → topic `/map`
- **LaserScan** display → topic `/scan`
- **RobotModel** display

Drive the robot manually (see [08-teleoperation.md](08-teleoperation.md)) to build the map. Drive slowly and ensure full coverage of the area.

### Save the Map

```bash
ros2 run nav2_map_server map_saver_cli -f /path/to/map/my_map
```

This produces two files:

- `my_map.pgm` — greyscale occupancy grid image
- `my_map.yaml` — map metadata (resolution, origin, thresholds)

Example `my_map.yaml`:

```yaml
image: my_map.pgm
resolution: 0.05
origin: [-10.0, -10.0, 0.0]
negate: 0
occupied_thresh: 0.65
free_thresh: 0.25
```

---

## Navigation — Autonomous Navigation with Existing Map

Use the Nav2 stack with a pre-built map for autonomous point-to-point navigation.

### Install

```bash
sudo apt install ros-humble-nav2-bringup
```

### Launch Navigation

```bash
ros2 launch nav2_bringup navigation_launch.py \
  use_sim_time:=false \
  map:=/path/to/map/my_map.yaml
```

### Set Initial Pose

Nav2 requires an initial localisation estimate. In RViz:

1. Click **2D Pose Estimate** in the toolbar.
2. Click on the map at the robot's current position and drag to set orientation.

Or via command line:

```bash
ros2 topic pub --once /initialpose geometry_msgs/msg/PoseWithCovarianceStamped \
  '{header: {frame_id: "map"}, pose: {pose: {position: {x: 0.0, y: 0.0}, orientation: {w: 1.0}}}}'
```

### Send a Navigation Goal

In RViz:

1. Click **Nav2 Goal** in the toolbar.
2. Click on the map at the target location and drag to set goal orientation.

Or via command line:

```bash
ros2 action send_goal /navigate_to_pose nav2_msgs/action/NavigateToPose \
  '{pose: {header: {frame_id: "map"}, pose: {position: {x: 2.0, y: 1.0, z: 0.0}, orientation: {w: 1.0}}}}'
```

---

## Nav2 Stack Overview

The Nav2 stack running on the Jackal includes:

| Node | Function |
|---|---|
| `map_server` | Loads and serves the static occupancy map |
| `amcl` | Adaptive Monte Carlo Localisation (particle filter) |
| `controller_server` | Local path planning and velocity commands |
| `planner_server` | Global path planning (NavFn / Smac) |
| `bt_navigator` | Behaviour Tree-based navigation executive |
| `costmap_2d` | Global and local costmaps from sensor data |
| `behavior_server` | Recovery behaviours (spin, backup, wait) |
| `lifecycle_manager` | Manages Nav2 node lifecycle transitions |

---

## Nav2 Configuration Parameters

Key parameters to tune for Jackal:

### Costmap

```yaml
# nav2_params.yaml (relevant excerpts)
local_costmap:
  local_costmap:
    ros__parameters:
      update_frequency: 5.0
      publish_frequency: 2.0
      global_frame: odom
      robot_base_frame: base_link
      rolling_window: true
      width: 5.0
      height: 5.0
      resolution: 0.05
      robot_radius: 0.27  # Jackal radius ~0.27 m

global_costmap:
  global_costmap:
    ros__parameters:
      update_frequency: 1.0
      robot_base_frame: base_link
      global_frame: map
      robot_radius: 0.27
      resolution: 0.05
```

### Controller Parameters (example: DWB)

```yaml
controller_server:
  ros__parameters:
    controller_frequency: 20.0
    FollowPath:
      max_vel_x: 0.5        # Limit max speed during navigation
      min_vel_x: -0.25
      max_vel_theta: 1.0
      acc_lim_x: 2.5
      acc_lim_theta: 3.2
```

---

## Verifying Navigation Stack

```bash
# Confirm Nav2 nodes are active
ros2 node list | grep nav

# Check costmap is updating
ros2 topic hz /global_costmap/costmap
ros2 topic hz /local_costmap/costmap

# Monitor navigation action feedback
ros2 topic echo /navigate_to_pose/_action/feedback
```

---

## Common Issues

| Issue | Resolution |
|---|---|
| Costmap empty | Verify `/scan` publishing; check `sensor_sources` in costmap params |
| AMCL not localising | Confirm initial pose is set; ensure map matches environment |
| Robot oscillates or gets stuck | Tune DWB controller parameters; reduce max speed |
| TF lookup failure | Verify `odom → base_link` transform is updating |
| Nav2 nodes not starting | Check lifecycle manager logs; ensure map file path is correct |

---

## Visual SLAM — ORB-SLAM3 (Camera Payload Required)

ORB-SLAM3 is a feature-based visual SLAM algorithm that works with monocular, stereo, or RGB-D cameras. It is an alternative to `slam_toolbox` for Jackal platforms equipped with a camera payload, and can operate without LiDAR.

> ORB-SLAM3 is not included in the standard Clearpath software stack. Integration requires building from source or using a community ROS 2 wrapper. Refer to the [ORB-SLAM3 repository](https://github.com/UZ-SLAMLab/ORB_SLAM3) for build instructions.

### Live Operation

<video src="../media/ORB_SLAM3.mp4" controls width="100%"></video>

### Rosbag Replay

<video src="../media/ORB_SLAM3_rosbag.mp4" controls width="100%"></video>

---

## Related Documents

- [07-sensor-validation.md](07-sensor-validation.md)
- [10-rviz-visualization.md](10-rviz-visualization.md)
- [troubleshooting.md](troubleshooting.md)
- [Nav2 Documentation](https://navigation.ros.org/)
- [slam_toolbox GitHub](https://github.com/SteveMacenski/slam_toolbox)
