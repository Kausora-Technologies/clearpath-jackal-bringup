# Robot Network Access

This page covers initial wired connection, SSH access, Wi-Fi configuration, and ongoing network access to the Jackal.

---

## Default Network Configuration

| Parameter | Value |
|---|---|
| Robot hostname | `jackal` (or robot-specific, e.g. `cpr-jackal-0001`) |
| Robot IP (wired, static) | `192.168.131.1` |
| Workstation IP (wired) | `192.168.131.51` (recommended) |
| Subnet mask | `255.255.255.0` |
| SSH username | `administrator` |
| SSH password | `clearpath` (change after first login) |

---

## Step 1 — Physical Connection

For initial setup, access the robot via a direct Ethernet cable:

1. Open the Jackal lid by actuating the latches at the front (opposite end from HMI panel).
2. Lower the computer tray (undo two thumbscrews).
3. Connect an Ethernet cable from the workstation to the port labelled **STATIC** on the robot's internal computer.

> The port labelled **DHCP** is for connecting to a network switch or router. Use **STATIC** for the direct wired connection.

---

## Step 2 — Workstation Static IP

Configure the workstation Ethernet interface with a static IP address on the `192.168.131.x` subnet.

### Using GNOME Network Manager (Ubuntu Desktop)

1. Open **Settings → Network → Wired Connection → Edit**.
2. Select **IPv4** tab.
3. Set **Method** to `Manual`.
4. Enter:
   - **Address:** `192.168.131.51`
   - **Netmask:** `255.255.255.0`
   - **Gateway:** (leave blank)
5. Click **Apply**.

### Using nmcli

```bash
# List connections to find the interface name
nmcli con show

# Apply static IP (replace 'Wired connection 1' with your connection name)
sudo nmcli con mod "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses "192.168.131.51/24" \
  ipv4.gateway ""

sudo nmcli con up "Wired connection 1"
```

### Verify

```bash
ping -c 3 192.168.131.1
# Expected: 0% packet loss
```

---

## Step 3 — SSH Access

```bash
ssh administrator@192.168.131.1
# Password: clearpath
```

> Change the default password after first login:
> ```bash
> passwd
> ```

Verify the robot's hostname and IP:

```bash
hostname
hostname -I
```

---

## Step 4 — Configure Wi-Fi on the Robot

Once connected via SSH over Ethernet, configure the robot to join your wireless network.

### Using nmcli (recommended for Ubuntu 22.04)

```bash
# On the robot via SSH
sudo nmcli dev wifi list

sudo nmcli dev wifi connect "YOUR_SSID" password "YOUR_PASSPHRASE"
```

### Using netplan (alternative)

```bash
# On the robot
sudo nano /etc/netplan/50-cloud-init.yaml
```

Add the Wi-Fi configuration:

```yaml
network:
  version: 2
  wifis:
    wlan0:
      dhcp4: true
      access-points:
        "YOUR_SSID":
          password: "YOUR_PASSPHRASE"
```

```bash
sudo netplan apply
```

### Get the Wi-Fi IP address

```bash
# On the robot
ip addr show wlan0
```

Note the assigned IP — this is used for wireless SSH sessions going forward.

---

## Step 5 — Wireless SSH Access

Once Wi-Fi is configured, disconnect the Ethernet cable and SSH over the wireless network:

```bash
ssh administrator@<ROBOT_WIFI_IP>
```

Optionally, update `/etc/hosts` on the workstation to map the robot's Wi-Fi IP to a hostname:

```bash
echo "<ROBOT_WIFI_IP>  jackal" | sudo tee -a /etc/hosts
ssh administrator@jackal
```

---

## Step 6 — Verify ROS 2 Connectivity

After connecting to the same network (wired or wireless), verify that ROS 2 topics are visible from the workstation. The workstation and robot must share the same `ROS_DOMAIN_ID`.

```bash
# On workstation
export ROS_DOMAIN_ID=0
ros2 topic list
```

If topics do not appear, refer to [troubleshooting.md](troubleshooting.md#no-topics-visible-from-workstation).

---

## Network Security Notes

- Change the default SSH password immediately after first access in any deployment environment.
- Disable password-based SSH and use key-based authentication for field deployments:

```bash
# Generate SSH key pair on workstation
ssh-keygen -t ed25519 -C "jackal-workstation"

# Copy public key to robot
ssh-copy-id administrator@192.168.131.1
```

---

## Related Documents

- [03-workstation-setup.md](03-workstation-setup.md)
- [05-ros2-environment.md](05-ros2-environment.md)
- [troubleshooting.md](troubleshooting.md)
