# System Overview

## Clearpath Jackal UGV

The Jackal is a compact, rugged, and fast unmanned ground vehicle designed for indoor and outdoor research and development. It is manufactured by Clearpath Robotics and runs ROS 2 on an onboard x86 PC.

---

## Hardware Components

### External

| Component | Description |
|---|---|
| Chassis | IP42-rated aluminium frame |
| Wheels | Four 190 mm diameter pneumatic tyres |
| HMI Panel | Front-mounted indicator panel |
| Lid Panel | M5 mounting holes (120 mm square pattern) |
| Charge Port | Rear, weather-sealed |

### HMI Panel Indicators

| Indicator | Meaning |
|---|---|
| Motor button | Enable/disable motor drive |
| Comms LED | Green = MCU–PC communication active |
| Wi-Fi LED | Green = Wi-Fi connected |
| Battery indicator | Charge level (4-bar LED) |
| Power button | System power on/off |

---

## Internal Architecture

### Onboard Computer

- Intel x86-64 Mini-ITX PC
- Ubuntu 22.04 LTS
- ROS 2 Humble Hawksbill
- Connected to MCU via USB (CDC serial device)

### Microcontroller Unit (MCU)

The MCU handles:

- Motor control (4 independent brushless DC motors)
- Encoder feedback
- IMU data (gyroscope, accelerometer, magnetometer)
- GPS data (built-in receiver)
- Power supply monitoring
- Battery state reporting

Communication between the MCU and the onboard PC uses a serial protocol over USB (CDC ACM device, typically `/dev/ttyACM0`), managed by the `clearpath_robot` platform package.

### Power System

- 270 Wh Li-Ion battery pack
- User power supplies: 5 V (10 A), 12 V (5 A), 24 V (3 A) — 4-pin Molex or screw terminal
- Battery protection: overcurrent, overdischarge, short circuit

---

## ROS 2 Topic API

The following are the core topics published and subscribed to by the Jackal platform. Namespace may include the robot's serial number (e.g., `a200_0000`) in the Clearpath platform software.

| Topic | Message Type | Direction | Description |
|---|---|---|---|
| `/cmd_vel` | `geometry_msgs/Twist` | Subscribe | Velocity commands to kinematic controller |
| `/odom` | `nav_msgs/Odometry` | Publish | Raw wheel odometry |
| `/odometry/filtered` | `nav_msgs/Odometry` | Publish | Filtered odometry (robot_localization EKF) |
| `/imu/data` | `sensor_msgs/Imu` | Publish | Filtered IMU orientation estimate |
| `/imu/data_raw` | `sensor_msgs/Imu` | Publish | Raw IMU data |
| `/navsat/fix` | `sensor_msgs/NavSatFix` | Publish | GPS position fix |
| `/navsat/vel` | `geometry_msgs/TwistStamped` | Publish | GPS velocity over ground |
| `/scan` | `sensor_msgs/LaserScan` | Publish | LiDAR scan (payload dependent) |
| `/diagnostics` | `diagnostic_msgs/DiagnosticArray` | Publish | Platform health diagnostics |
| `/platform/battery_state` | `sensor_msgs/BatteryState` | Publish | Battery level and status |
| `/tf` | `tf2_msgs/TFMessage` | Publish | Dynamic transform tree |
| `/tf_static` | `tf2_msgs/TFMessage` | Publish | Static transform tree |

---

## URDF / TF Frame Tree

The default URDF frames for Jackal are:

```
odom
└── base_link
    ├── imu_link
    ├── navsat_link
    ├── front_left_wheel_link
    ├── front_right_wheel_link
    ├── rear_left_wheel_link
    └── rear_right_wheel_link
        └── [payload frames, e.g. laser, camera]
```

All sensor payload frames are added to the URDF via the robot configuration file (`/etc/clearpath/robot.yaml`).

---

## Related Documents

- [02-prerequisites.md](02-prerequisites.md)
- [06-robot-bringup.md](06-robot-bringup.md)
- [Clearpath Jackal ROS 2 Docs](https://docs.clearpathrobotics.com/docs/ros2/robots/indoor/jackal/)
