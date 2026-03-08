# RViz Visualization

RViz is the primary tool for visualising the Jackal's state, sensor data, and navigation in real time.

---

## Prerequisites

- Workstation ROS 2 environment configured ([03-workstation-setup.md](03-workstation-setup.md))
- Platform drivers running on robot ([06-robot-bringup.md](06-robot-bringup.md))
- Topics visible from workstation (`ros2 topic list` returns platform topics)

---

## Launch RViz with Clearpath Configuration

```bash
ros2 launch clearpath_viz view_model.launch.py
```

This launches RViz with a pre-configured display layout for the Jackal, including:

- Robot model (URDF)
- TF frames
- Odometry path

---

## Manual RViz Launch

If `clearpath_viz` is not installed or you need a custom configuration:

```bash
rviz2
```

---

## Recommended Display Configuration

Add the following displays in RViz for a complete operational view:

### Fixed Frame

Set the fixed frame to `odom` for local navigation, or `map` when using Nav2 with a map.

```
Global Options → Fixed Frame: odom
```

### Robot Model

```
Add → RobotModel
  Description Topic: /robot_description
```

### TF

```
Add → TF
  (Optionally filter to key frames: odom, base_link, laser)
```

### Odometry

```
Add → Odometry
  Topic: /odometry/filtered
  Keep: 200 (arrow history)
```

### LaserScan (if equipped)

```
Add → LaserScan
  Topic: /scan
  Size (m): 0.03
  Color Transformer: Intensity (or FlatColor)
```

### IMU

```
Add → Imu
  Topic: /imu/data
```

### Map (Nav2)

```
Add → Map
  Topic: /map
  Color Scheme: costmap
```

### Global Costmap (Nav2)

```
Add → Map
  Topic: /global_costmap/costmap
  Alpha: 0.5
```

### Local Costmap (Nav2)

```
Add → Map
  Topic: /local_costmap/costmap
  Alpha: 0.7
```

### Path (Nav2)

```
Add → Path
  Topic: /plan        (global plan)
  Color: Green

Add → Path
  Topic: /local_plan  (local plan)
  Color: Red
```

### Goal Pose (Nav2)

```
Add → Pose
  Topic: /goal_pose
```

---

## Saving RViz Configuration

To save your display configuration for reuse:

```
File → Save Config As → /path/to/jackal_bringup.rviz
```

To launch RViz with a saved configuration:

```bash
rviz2 -d /path/to/jackal_bringup.rviz
```

---

## Diagnostic Tools

### RQT Robot Monitor

Displays the `/diagnostics` topic in a structured tree view:

```bash
ros2 run rqt_robot_monitor rqt_robot_monitor
```

### RQT Graph

Visualise the ROS 2 node and topic graph:

```bash
ros2 run rqt_graph rqt_graph
```

### RQT TF Tree

Visualise the TF tree interactively:

```bash
ros2 run rqt_tf_tree rqt_tf_tree
```

### RQT Console

View log messages from all nodes:

```bash
ros2 run rqt_console rqt_console
```

---

## Common Display Issues

| Issue | Resolution |
|---|---|
| Robot model not visible | Check `/robot_description` topic is publishing; verify URDF loaded |
| TF frames not updating | Confirm platform drivers are running; check `ros2 topic hz /tf` |
| LaserScan not visible | Verify `/scan` is publishing; check fixed frame matches scan frame |
| Map not loading | Ensure Nav2 `map_server` is active; check map file path |
| No odometry path shown | Set **Keep** to > 1; confirm `/odometry/filtered` is publishing |

---

## Related Documents

- [07-sensor-validation.md](07-sensor-validation.md)
- [09-navigation-slam.md](09-navigation-slam.md)
- [troubleshooting.md](troubleshooting.md)
