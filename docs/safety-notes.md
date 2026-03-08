# Safety Notes

These safety requirements apply to all operations with the Clearpath Jackal UGV. All operators and nearby personnel must be familiar with these procedures before interacting with the robot.

---

## General Safety Requirements

- Never operate the Jackal without a trained operator present.
- Always perform teleoperation validation before enabling autonomous modes.
- Keep a charged PS4 controller available at all times during field operation as an override mechanism.
- Ensure all personnel in the operating area are aware the robot is active.

---

## E-Stop Procedure

If the robot behaves unexpectedly:

1. **Release the PS4 L1 deadman switch** immediately — the robot will stop receiving velocity commands.
2. If equipped with a hardware e-stop, press it to cut motor power.
3. SSH to the robot and kill the platform service if needed:
   ```bash
   sudo systemctl stop clearpath-robot.service
   ```
4. Investigate the cause before resuming operation.

> The deadman switch on the PS4 controller (L1) is the primary software-level stop. **Hardware e-stops are mandatory for any autonomous operation outside of a controlled laboratory.**

---

## Pre-Operation Checklist

Complete this checklist before every operation session:

- [ ] Operating area is clear of people and obstacles (minimum **2 m** clearance in all directions)
- [ ] Battery is above **30%** charge
- [ ] All personnel in the area are informed the robot is active
- [ ] PS4 controller is charged and paired
- [ ] Teleoperation tested and confirmed responsive
- [ ] E-stop tested (if installed)
- [ ] Maximum operating speed appropriate for environment (reduce for confined spaces)
- [ ] Any payload hardware is securely mounted

---

## Speed Limits

| Environment | Recommended Max Speed |
|---|---|
| Confined indoor space (corridors, labs) | 0.3 m/s |
| Open indoor space | 0.5 m/s |
| Open outdoor area, no pedestrians | 1.0 m/s |
| Outdoor survey (wide open, clear) | Up to 2.0 m/s |

> The Jackal's maximum speed is **2.0 m/s**. This can cause serious injury if the robot collides with a person at full speed. Always operate at reduced speeds until the area is confirmed clear.

---

## Battery Safety

The Jackal uses a **270 Wh Lithium-Ion battery pack**. Observe the following:

- Do not store or operate the battery above **60°C** or below **-19°C**.
- Do not puncture, crush, or disassemble the battery pack.
- Do not short-circuit the battery terminals.
- If the battery is swollen, damaged, or smells unusual, do not use it — contact Clearpath Robotics.
- Charge using only the supplied Clearpath charger.
- For disposal, deliver to an authorised hazardous waste facility — do not put in general waste.

### Charging

- Charge via the rear weather-sealed charge port, or by removing the battery for external charging.
- Charging only occurs when the Jackal is **powered off**.
- Do not leave batteries charging unattended for extended periods.
- When travelling by air, consult airline lithium battery regulations. Carry the battery in cabin baggage where possible.

---

## Payload Integration Safety

- Do not exceed the Jackal payload capacity of **20 kg**.
- Ensure payload centre of mass is kept low and centred on the lid panel.
- Secure all payload hardware before operation — loose components can become projectiles.
- Disconnect the battery before installing or removing electrical payloads.
- Verify voltage and polarity before connecting payload power leads to the user power board.
- Confirm current draw does not exceed the fused user power supply ratings:
  - 5 V @ 10 A
  - 12 V @ 5 A
  - 24 V @ 3 A

---

## Electrical Safety

- Do not open the chassis while the robot is powered on, unless performing diagnostics with explicit training.
- Only qualified personnel should work inside the chassis.
- The large Anderson Power Pole connector carries battery voltage (~29.6 V nominal). Treat all exposed connectors as live.

---

## Autonomous Navigation Safety

Before enabling autonomous navigation:

- A human operator must remain within visual range at all times.
- Operator must hold the PS4 controller and be ready to intervene.
- The costmap and sensor data must be verified as valid before the first goal is sent.
- Start with short-range goals in known, clear environments.
- Do not operate autonomously in environments with pedestrians without appropriate safety barriers and risk assessment.

---

## Incident Reporting

If the robot causes an injury or property damage, or if a near-miss occurs:

1. Stop the robot immediately.
2. Ensure any injured persons receive first aid.
3. Preserve the robot's state for investigation (do not restart software).
4. Document the incident: date, time, location, operating mode, speed, operator name.
5. Report to the Kausora Technologies robotics team and, if applicable, to Clearpath Robotics support.

---

## Contact

- **Clearpath Robotics Support:** <support@clearpathrobotics.com>
- **Kausora Technologies:** <https://github.com/Kausora-Technologies/clearpath-jackal-bringup/issues>

---

## Related Documents

- [06-robot-bringup.md](06-robot-bringup.md)
- [08-teleoperation.md](08-teleoperation.md)
- [validation-checklist.md](validation-checklist.md)
