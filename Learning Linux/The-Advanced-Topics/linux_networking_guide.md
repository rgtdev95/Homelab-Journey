# Linux Networking Guide for DevOps

## Introduction

Networking is a critical skill for DevOps engineers. Understanding how Linux handles network connections, troubleshooting connectivity issues, and configuring network services are essential daily tasks.

**What you'll learn:**
- Essential networking commands
- Network configuration (static/DHCP)
- Ports and services
- Troubleshooting tools
- Network security basics
- Real-world DevOps scenarios

---

## Table of Contents

1. [Network Configuration Basics](#network-configuration-basics)
2. [Essential Networking Commands](#essential-networking-commands)
3. [Network Troubleshooting Tools](#network-troubleshooting-tools)
4. [Static vs DHCP Configuration](#static-vs-dhcp-configuration)
5. [Working with Ports and Services](#working-with-ports-and-services)
6. [DNS Configuration](#dns-configuration)
7. [Firewall Management](#firewall-management)
8. [Network Monitoring](#network-monitoring)
9. [DevOps-Specific Scenarios](#devops-specific-scenarios)

---

## Network Configuration Basics

### Understanding Network Interfaces

Network interfaces are the connection points between your system and the network.

**Common interface names:**
- `eth0`, `eth1` - Ethernet interfaces (older naming)
- `eno1`, `eno2` - Onboard Ethernet (newer naming)
- `enp3s0` - PCI Ethernet (newer naming)
- `wlan0`, `wlp2s0` - Wireless interfaces
- `lo` - Loopback interface (127.0.0.1)
- `docker0` - Docker bridge interface
- `virbr0` - Virtual bridge (KVM/libvirt)

### View Network Interfaces

```bash
# Modern way - ip command
ip addr show
ip a          # Short form

# Show specific interface
ip addr show eth0

# Older way - ifconfig (may need to install net-tools)
ifconfig

# Show all interfaces including down ones
ip link show
```

**Example output:**
```bash
$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP
    inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
    inet6 fe80::a00:27ff:fe4e:66a1/64 scope link
```

### Understanding IP Addressing

**IPv4 address components:**
- IP Address: `192.168.1.100`
- Subnet Mask: `255.255.255.0` or `/24` (CIDR notation)
- Gateway: `192.168.1.1` (router)
- Broadcast: `192.168.1.255`

**Private IP ranges:**
- `10.0.0.0/8` (10.0.0.0 - 10.255.255.255)
- `172.16.0.0/12` (172.16.0.0 - 172.31.255.255)
- `192.168.0.0/16` (192.168.0.0 - 192.168.255.255)

---

## Essential Networking Commands

### 1. ip - Network Configuration (Modern)

The `ip` command is the modern replacement for several old commands (ifconfig, route, arp).

**View all interfaces:**
```bash
ip addr show
ip a
```

**View routing table:**
```bash
ip route show
ip r
```

**View ARP cache (MAC addresses):**
```bash
ip neigh show
ip n
```

**Bring interface up/down:**
```bash
sudo ip link set eth0 up
sudo ip link set eth0 down
```

**Add IP address temporarily:**
```bash
sudo ip addr add 192.168.1.100/24 dev eth0
```

**Delete IP address:**
```bash
sudo ip addr del 192.168.1.100/24 dev eth0
```

**Add default route:**
```bash
sudo ip route add default via 192.168.1.1
```

### 2. ping - Test Connectivity

Test if a host is reachable.

```bash
# Basic ping
ping google.com

# Ping specific number of times
ping -c 4 google.com

# Ping with specific interval
ping -i 2 192.168.1.1    # Every 2 seconds

# Ping with timestamp
ping -D google.com

# Flood ping (testing/stress - be careful!)
sudo ping -f 192.168.1.1
```

**What ping tells you:**
- Host is reachable
- Network latency (response time)
- Packet loss percentage
- DNS resolution working (if using hostname)

### 3. traceroute - Trace Network Path

See the route packets take to reach a destination.

**Install:**
```bash
# Debian/Ubuntu
sudo apt install traceroute

# RHEL/CentOS/AlmaLinux
sudo yum install traceroute
```

**Usage:**
```bash
# Trace route to host
traceroute google.com

# Trace route to IP
traceroute 8.8.8.8

# Use ICMP instead of UDP
sudo traceroute -I google.com

# Set max hops
traceroute -m 15 google.com
```

**Example output:**
```bash
$ traceroute google.com
 1  192.168.1.1 (192.168.1.1)  1.523 ms
 2  10.0.0.1 (10.0.0.1)  5.234 ms
 3  172.16.1.1 (172.16.1.1)  12.456 ms
 ...
```

### 4. netstat - Network Statistics (Legacy)

Display network connections, routing tables, interface statistics.

**Install:**
```bash
# Debian/Ubuntu
sudo apt install net-tools

# RHEL/CentOS/AlmaLinux
sudo yum install net-tools
```

**Common usage:**
```bash
# Show all listening ports
netstat -tuln

# Show all connections
netstat -tun

# Show listening TCP ports with process info
sudo netstat -tlnp

# Show routing table
netstat -r

# Show interface statistics
netstat -i
```

**Options explained:**
- `-t` : TCP connections
- `-u` : UDP connections
- `-l` : Listening sockets
- `-n` : Show numeric addresses (don't resolve names)
- `-p` : Show process ID and name
- `-r` : Routing table
- `-i` : Interface statistics

### 5. ss - Socket Statistics (Modern netstat)

Modern replacement for netstat, faster and more detailed.

**Show all listening TCP ports:**
```bash
ss -tln
```

**Show all connections with process info:**
```bash
sudo ss -tulnp
```

**Show summary:**
```bash
ss -s
```

**Filter by port:**
```bash
# Show connections on port 80
ss -tn sport = :80

# Show listening on port 22
ss -tln sport = :22
```

**Show established connections:**
```bash
ss -tn state established
```

**Common options:**
- `-t` : TCP sockets
- `-u` : UDP sockets
- `-l` : Listening sockets
- `-n` : Numeric (no name resolution)
- `-p` : Show process
- `-a` : All sockets (listening and non-listening)

### 6. nmap - Network Scanner

Powerful network scanning and security auditing tool.

**Install:**
```bash
# Debian/Ubuntu
sudo apt install nmap

# RHEL/CentOS/AlmaLinux
sudo yum install nmap
```

**Usage:**
```bash
# Scan single host
nmap 192.168.1.100

# Scan network range
nmap 192.168.1.0/24

# Scan specific ports
nmap -p 22,80,443 192.168.1.100

# Scan port range
nmap -p 1-1000 192.168.1.100

# Detect OS and services
sudo nmap -O -sV 192.168.1.100

# Fast scan (top 100 ports)
nmap -F 192.168.1.100

# Aggressive scan
sudo nmap -A 192.168.1.100
```

### 7. curl - Transfer Data via URLs

Essential for API testing and web troubleshooting.

```bash
# Basic HTTP GET
curl http://example.com

# View headers only
curl -I http://example.com

# Follow redirects
curl -L http://example.com

# Save output to file
curl -o output.html http://example.com
curl -O http://example.com/file.zip    # Use remote filename

# POST request
curl -X POST -d "param1=value1" http://api.example.com

# POST JSON data
curl -X POST -H "Content-Type: application/json" \
  -d '{"key":"value"}' http://api.example.com/endpoint

# Authentication
curl -u username:password http://example.com

# Custom headers
curl -H "Authorization: Bearer TOKEN" http://api.example.com

# Test HTTPS certificate
curl -v https://example.com

# Ignore SSL certificate errors (testing only!)
curl -k https://self-signed.example.com

# Show timing information
curl -w "@-" -o /dev/null -s http://example.com <<'EOF'
    time_namelookup:  %{time_namelookup}\n
       time_connect:  %{time_connect}\n
    time_appconnect:  %{time_appconnect}\n
      time_redirect:  %{time_redirect}\n
   time_pretransfer:  %{time_pretransfer}\n
 time_starttransfer:  %{time_starttransfer}\n
                    ----------\n
         time_total:  %{time_total}\n
EOF
```

### 8. wget - Download Files

Download files from the web.

```bash
# Download file
wget http://example.com/file.zip

# Download to specific filename
wget -O myfile.zip http://example.com/file.zip

# Resume interrupted download
wget -c http://example.com/largefile.iso

# Download in background
wget -b http://example.com/file.zip

# Mirror entire website
wget --mirror --convert-links --page-requisites http://example.com

# Download with rate limit
wget --limit-rate=200k http://example.com/file.zip

# Recursive download
wget -r http://example.com/directory/
```

### 9. dig - DNS Lookup Tool

Query DNS servers for domain information.

**Install:**
```bash
# Debian/Ubuntu
sudo apt install dnsutils

# RHEL/CentOS/AlmaLinux
sudo yum install bind-utils
```

**Usage:**
```bash
# Basic DNS lookup
dig google.com

# Query specific record type
dig google.com A      # IPv4 address
dig google.com AAAA   # IPv6 address
dig google.com MX     # Mail exchange
dig google.com NS     # Name servers
dig google.com TXT    # Text records

# Short answer only
dig +short google.com

# Reverse DNS lookup
dig -x 8.8.8.8

# Query specific DNS server
dig @8.8.8.8 google.com

# Trace DNS path
dig +trace google.com
```

### 10. nslookup - DNS Query (Simple)

Simpler DNS lookup tool.

```bash
# Basic lookup
nslookup google.com

# Query specific server
nslookup google.com 8.8.8.8

# Reverse lookup
nslookup 8.8.8.8
```

### 11. host - DNS Lookup (Simplest)

Even simpler DNS tool.

```bash
# Basic lookup
host google.com

# All record types
host -a google.com

# Specific type
host -t MX google.com
```

### 12. tcpdump - Packet Capture

Capture and analyze network traffic.

**Install:**
```bash
# Debian/Ubuntu
sudo apt install tcpdump

# RHEL/CentOS/AlmaLinux
sudo yum install tcpdump
```

**Usage:**
```bash
# Capture on interface
sudo tcpdump -i eth0

# Capture specific port
sudo tcpdump -i eth0 port 80

# Capture to file
sudo tcpdump -i eth0 -w capture.pcap

# Read from file
tcpdump -r capture.pcap

# Capture with more details
sudo tcpdump -i eth0 -v

# Capture specific host
sudo tcpdump -i eth0 host 192.168.1.100

# Capture HTTP traffic
sudo tcpdump -i eth0 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# Capture and display ASCII
sudo tcpdump -i eth0 -A port 80
```

### 13. iftop - Bandwidth Monitor

Real-time bandwidth usage by connection.

**Install:**
```bash
# Debian/Ubuntu
sudo apt install iftop

# RHEL/CentOS/AlmaLinux
sudo yum install iftop
```

**Usage:**
```bash
# Monitor default interface
sudo iftop

# Monitor specific interface
sudo iftop -i eth0

# Don't resolve hostnames
sudo iftop -n

# Show ports
sudo iftop -P
```

### 14. nethogs - Per-Process Bandwidth

See which processes are using bandwidth.

**Install:**
```bash
# Debian/Ubuntu
sudo apt install nethogs

# RHEL/CentOS/AlmaLinux
sudo yum install nethogs
```

**Usage:**
```bash
# Monitor default interface
sudo nethogs

# Monitor specific interface
sudo nethogs eth0

# Refresh every second
sudo nethogs -d 1
```

---

## Network Troubleshooting Tools

### Essential Tools Installation

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install -y \
  net-tools \
  iproute2 \
  iputils-ping \
  traceroute \
  dnsutils \
  netcat \
  tcpdump \
  nmap \
  curl \
  wget \
  iftop \
  nethogs \
  mtr \
  iperf3
```

**RHEL/CentOS/AlmaLinux:**
```bash
sudo yum install -y \
  net-tools \
  iproute \
  iputils \
  traceroute \
  bind-utils \
  nc \
  tcpdump \
  nmap \
  curl \
  wget \
  iftop \
  nethogs \
  mtr \
  iperf3
```

### Troubleshooting Workflow

**Step 1: Check local interface**
```bash
ip addr show
ip link show
```

**Step 2: Check connectivity to gateway**
```bash
ip route show         # Find gateway
ping -c 4 192.168.1.1 # Ping gateway
```

**Step 3: Check DNS**
```bash
cat /etc/resolv.conf  # Check DNS servers
ping -c 4 8.8.8.8     # Ping Google DNS (tests routing)
ping -c 4 google.com  # Test DNS resolution
```

**Step 4: Check routing**
```bash
traceroute google.com
mtr google.com        # Better alternative
```

**Step 5: Check listening services**
```bash
sudo ss -tulnp
sudo netstat -tulnp
```

**Step 6: Check firewall**
```bash
sudo iptables -L -n -v
sudo firewall-cmd --list-all  # For firewalld
sudo ufw status               # For ufw
```

### MTR - Network Diagnostic Tool

Combines ping and traceroute in real-time.

**Install:**
```bash
# Debian/Ubuntu
sudo apt install mtr

# RHEL/CentOS/AlmaLinux
sudo yum install mtr
```

**Usage:**
```bash
# Interactive mode
mtr google.com

# Report mode (10 cycles)
mtr --report --report-cycles 10 google.com

# No DNS resolution
mtr -n google.com
```

---

## Static vs DHCP Configuration

### Understanding DHCP vs Static IP

**DHCP (Dynamic Host Configuration Protocol):**
- ✅ Automatic IP assignment
- ✅ Easy for workstations
- ✅ Less management for many hosts
- ❌ IP can change on reboot
- ❌ Not suitable for servers

**Static IP:**
- ✅ IP never changes
- ✅ Required for servers
- ✅ Predictable addressing
- ❌ Manual configuration
- ❌ More management overhead

**When to use what:**
- **Servers, VMs, containers:** Static IP
- **Workstations, laptops:** DHCP
- **Network devices (routers, switches):** Static IP
- **Development machines:** Can use either

---

### Network Configuration Files

**Configuration locations vary by distribution:**

#### Ubuntu/Debian (Netplan - newer)

**File:** `/etc/netplan/00-installer-config.yaml` or `/etc/netplan/01-netcfg.yaml`

**View current config:**
```bash
ls /etc/netplan/
cat /etc/netplan/*.yaml
```

#### RHEL/CentOS/AlmaLinux

**Files:** `/etc/sysconfig/network-scripts/ifcfg-<interface>`

**Example:**
```bash
ls /etc/sysconfig/network-scripts/
cat /etc/sysconfig/network-scripts/ifcfg-eth0
```

#### Debian (older - /etc/network/interfaces)

**File:** `/etc/network/interfaces`

---

### Configure Static IP - Ubuntu (Netplan)

**1. Identify your interface:**
```bash
ip addr show
```

**2. Edit Netplan configuration:**
```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

**3. Static IP configuration:**
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

**4. Apply configuration:**
```bash
# Test configuration first
sudo netplan try

# If it works (you have 120 seconds to confirm)
# Press Enter to accept

# Or apply directly
sudo netplan apply
```

**5. Verify:**
```bash
ip addr show eth0
ip route show
ping -c 4 8.8.8.8
```

### Configure DHCP - Ubuntu (Netplan)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: yes
```

**Apply:**
```bash
sudo netplan apply
```

---

### Configure Static IP - RHEL/CentOS/AlmaLinux

**1. Identify interface:**
```bash
ip addr show
```

**2. Edit interface config:**
```bash
sudo nano /etc/sysconfig/network-scripts/ifcfg-eth0
```

**3. Static IP configuration:**
```bash
TYPE=Ethernet
BOOTPROTO=none
NAME=eth0
DEVICE=eth0
ONBOOT=yes
IPADDR=192.168.1.100
PREFIX=24
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
```

**4. Restart networking:**
```bash
# RHEL/CentOS 7
sudo systemctl restart network

# RHEL/CentOS 8+/AlmaLinux
sudo nmcli connection reload
sudo nmcli connection up eth0

# Or use NetworkManager
sudo systemctl restart NetworkManager
```

**5. Verify:**
```bash
ip addr show eth0
cat /etc/resolv.conf
ping -c 4 8.8.8.8
```

### Configure DHCP - RHEL/CentOS/AlmaLinux

**Edit config:**
```bash
TYPE=Ethernet
BOOTPROTO=dhcp
NAME=eth0
DEVICE=eth0
ONBOOT=yes
```

**Restart networking:**
```bash
sudo nmcli connection up eth0
```

---

### Configure Static IP - Debian (interfaces file)

**Edit file:**
```bash
sudo nano /etc/network/interfaces
```

**Static configuration:**
```bash
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

**Restart networking:**
```bash
sudo systemctl restart networking
# Or
sudo ifdown eth0 && sudo ifup eth0
```

### Configure DHCP - Debian (interfaces file)

```bash
auto eth0
iface eth0 inet dhcp
```

---

### NetworkManager CLI (nmcli)

Modern tool for managing network connections.

**Show connections:**
```bash
nmcli connection show
nmcli con show
```

**Show devices:**
```bash
nmcli device status
nmcli dev status
```

**Create static connection:**
```bash
sudo nmcli con add \
  type ethernet \
  con-name eth0-static \
  ifname eth0 \
  ip4 192.168.1.100/24 \
  gw4 192.168.1.1

sudo nmcli con mod eth0-static ipv4.dns "8.8.8.8 8.8.4.4"
sudo nmcli con up eth0-static
```

**Create DHCP connection:**
```bash
sudo nmcli con add \
  type ethernet \
  con-name eth0-dhcp \
  ifname eth0

sudo nmcli con up eth0-dhcp
```

**Modify existing connection:**
```bash
# Change to static
sudo nmcli con mod eth0 ipv4.method manual
sudo nmcli con mod eth0 ipv4.addresses 192.168.1.100/24
sudo nmcli con mod eth0 ipv4.gateway 192.168.1.1
sudo nmcli con mod eth0 ipv4.dns "8.8.8.8 8.8.4.4"
sudo nmcli con up eth0

# Change to DHCP
sudo nmcli con mod eth0 ipv4.method auto
sudo nmcli con up eth0
```

**Delete connection:**
```bash
sudo nmcli con delete eth0-static
```

---

## Working with Ports and Services

### Understanding Ports

**Port basics:**
- Ports range: 0-65535
- Well-known ports: 0-1023 (require root)
- Registered ports: 1024-49151
- Dynamic/Private: 49152-65535

### Common Ports Reference

| Port | Service | Protocol | Description |
|------|---------|----------|-------------|
| 20 | FTP-DATA | TCP | FTP Data Transfer |
| 21 | FTP | TCP | FTP Control |
| 22 | SSH | TCP | Secure Shell |
| 23 | Telnet | TCP | Telnet (insecure) |
| 25 | SMTP | TCP | Email (sending) |
| 53 | DNS | TCP/UDP | Domain Name System |
| 80 | HTTP | TCP | Web traffic |
| 110 | POP3 | TCP | Email (receiving) |
| 143 | IMAP | TCP | Email (receiving) |
| 443 | HTTPS | TCP | Secure web traffic |
| 465 | SMTPS | TCP | Secure SMTP |
| 587 | SMTP | TCP | Mail submission |
| 993 | IMAPS | TCP | Secure IMAP |
| 995 | POP3S | TCP | Secure POP3 |
| 3306 | MySQL | TCP | MySQL Database |
| 5432 | PostgreSQL | TCP | PostgreSQL Database |
| 6379 | Redis | TCP | Redis Database |
| 8080 | HTTP-Alt | TCP | Alternative HTTP |
| 8443 | HTTPS-Alt | TCP | Alternative HTTPS |
| 27017 | MongoDB | TCP | MongoDB Database |

### DevOps-Specific Ports

| Port | Service | Description |
|------|---------|-------------|
| 2375 | Docker | Docker API (unencrypted) |
| 2376 | Docker | Docker API (TLS) |
| 2379 | etcd | etcd client API |
| 2380 | etcd | etcd peer API |
| 3000 | Grafana | Grafana web interface |
| 4040 | Spark | Spark UI |
| 5000 | Docker Registry | Private Docker registry |
| 6443 | Kubernetes | Kubernetes API server |
| 8086 | InfluxDB | InfluxDB API |
| 9090 | Prometheus | Prometheus web interface |
| 9093 | Alertmanager | Prometheus Alertmanager |
| 9100 | Node Exporter | Prometheus node metrics |
| 9200 | Elasticsearch | Elasticsearch API |
| 9300 | Elasticsearch | Elasticsearch nodes |
| 10250 | Kubelet | Kubernetes kubelet API |

### Check Open Ports

**List all listening ports:**
```bash
# Modern way (ss)
sudo ss -tulnp

# Legacy way (netstat)
sudo netstat -tulnp

# Using lsof
sudo lsof -i -P -n | grep LISTEN
```

**Check specific port:**
```bash
# Is port 80 listening?
sudo ss -tulnp | grep :80
sudo netstat -tulnp | grep :80

# Using lsof
sudo lsof -i :80
```

**Check if port is in use before starting service:**
```bash
# Will fail if port busy
nc -zv localhost 80

# Or
telnet localhost 80
```

### Test Port Connectivity

**Using netcat (nc):**
```bash
# Check if port is open
nc -zv host port

# Examples
nc -zv google.com 80
nc -zv 192.168.1.100 22
nc -zv localhost 3306

# Scan port range
nc -zv 192.168.1.100 20-25
```

**Using telnet:**
```bash
# Connect to port
telnet host port

# Example
telnet google.com 80

# Then type:
GET / HTTP/1.1
Host: google.com
[Press Enter twice]
```

**Using nmap:**
```bash
# Scan specific port
nmap -p 80 192.168.1.100

# Scan multiple ports
nmap -p 22,80,443 192.168.1.100

# Scan range
nmap -p 1-1000 192.168.1.100
```

**Using curl:**
```bash
# Test HTTP
curl -v http://host:port

# Test HTTPS
curl -v https://host:443
```

### Open a Port (Allow Traffic)

**Using firewalld (RHEL/CentOS):**
```bash
# Open port permanently
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Open service
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload

# Check open ports
sudo firewall-cmd --list-all
```

**Using ufw (Ubuntu):**
```bash
# Open port
sudo ufw allow 8080/tcp

# Open service
sudo ufw allow http
sudo ufw allow https

# Open port range
sudo ufw allow 8000:8100/tcp

# Check status
sudo ufw status
```

**Using iptables (manual):**
```bash
# Allow incoming on port
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT

# Save rules (Debian/Ubuntu)
sudo netfilter-persistent save

# Save rules (RHEL/CentOS)
sudo service iptables save
```

---

## DNS Configuration

### DNS Configuration Files

**Main DNS config:** `/etc/resolv.conf`

**View current DNS:**
```bash
cat /etc/resolv.conf
```

**Example content:**
```bash
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com
```

### Configure DNS - Ubuntu (Netplan)

**Edit Netplan config:**
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
        search:
          - example.com
```

**Apply:**
```bash
sudo netplan apply
```

### Configure DNS - RHEL/CentOS

**Method 1: NetworkManager**
```bash
sudo nmcli con mod eth0 ipv4.dns "8.8.8.8 1.1.1.1"
sudo nmcli con up eth0
```

**Method 2: Interface config file**
```bash
# Edit /etc/sysconfig/network-scripts/ifcfg-eth0
DNS1=8.8.8.8
DNS2=1.1.1.1
```

### Popular DNS Servers

| Provider | Primary | Secondary | Description |
|----------|---------|-----------|-------------|
| Google | 8.8.8.8 | 8.8.4.4 | Fast, reliable |
| Cloudflare | 1.1.1.1 | 1.0.0.1 | Privacy-focused, fast |
| Quad9 | 9.9.9.9 | 149.112.112.112 | Security filtering |
| OpenDNS | 208.67.222.222 | 208.67.220.220 | Content filtering |

### DNS Troubleshooting

**Test DNS resolution:**
```bash
# Using dig
dig google.com

# Quick test
dig +short google.com

# Test specific DNS server
dig @8.8.8.8 google.com

# Using nslookup
nslookup google.com

# Using host
host google.com
```

**Flush DNS cache:**
```bash
# Ubuntu (systemd-resolved)
sudo systemd-resolve --flush-caches

# RHEL/CentOS (if nscd is running)
sudo systemctl restart nscd

# Clear local DNS cache
sudo resolvectl flush-caches
```

### /etc/hosts - Local DNS

**File:** `/etc/hosts`

**Format:**
```bash
IP_ADDRESS    hostname    alias
```

**Example:**
```bash
127.0.0.1     localhost
192.168.1.100 server1.local server1
192.168.1.101 server2.local server2
192.168.1.200 db.local database
```

**Common uses:**
- Local development
- Override DNS temporarily
- Test before DNS propagation
- Internal network names

**Edit:**
```bash
sudo nano /etc/hosts
```

---

## Firewall Management

### Firewall Tools by Distribution

| Distribution | Default Firewall | Frontend |
|--------------|------------------|----------|
| Ubuntu | iptables | ufw |
| Debian | iptables | iptables/nftables |
| RHEL/CentOS 7+ | iptables | firewalld |
| RHEL/CentOS 6 | iptables | iptables |

---

### UFW (Uncomplicated Firewall) - Ubuntu

**Enable/Disable:**
```bash
# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable

# Check status
sudo ufw status
sudo ufw status verbose
sudo ufw status numbered
```

**Basic Rules:**
```bash
# Allow port
sudo ufw allow 22
sudo ufw allow 80/tcp
sudo ufw allow 53/udp

# Allow service (uses /etc/services)
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Allow from specific IP
sudo ufw allow from 192.168.1.100

# Allow from subnet
sudo ufw allow from 192.168.1.0/24

# Allow port from specific IP
sudo ufw allow from 192.168.1.100 to any port 22

# Deny port
sudo ufw deny 23
```

**Delete Rules:**
```bash
# List with numbers
sudo ufw status numbered

# Delete by number
sudo ufw delete 2

# Delete by rule
sudo ufw delete allow 80
```

**Advanced Rules:**
```bash
# Allow port range
sudo ufw allow 6000:6007/tcp

# Limit (rate limiting for SSH)
sudo ufw limit ssh

# Allow specific interface
sudo ufw allow in on eth0 to any port 80

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

**Reset Firewall:**
```bash
sudo ufw reset
```

---

### firewalld - RHEL/CentOS/AlmaLinux

**Status:**
```bash
# Check status
sudo systemctl status firewalld
sudo firewall-cmd --state

# Start/Stop
sudo systemctl start firewalld
sudo systemctl stop firewalld
sudo systemctl enable firewalld
```

**Zones:**
```bash
# List zones
sudo firewall-cmd --get-zones

# Get default zone
sudo firewall-cmd --get-default-zone

# Set default zone
sudo firewall-cmd --set-default-zone=public

# List zone details
sudo firewall-cmd --zone=public --list-all
sudo firewall-cmd --list-all
```

**Add/Remove Ports:**
```bash
# Add port temporarily
sudo firewall-cmd --add-port=8080/tcp

# Add port permanently
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload

# Remove port
sudo firewall-cmd --permanent --remove-port=8080/tcp
sudo firewall-cmd --reload

# Port range
sudo firewall-cmd --permanent --add-port=6000-6007/tcp
sudo firewall-cmd --reload
```

**Add/Remove Services:**
```bash
# Add service
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# List services
sudo firewall-cmd --get-services

# List active services
sudo firewall-cmd --list-services

# Remove service
sudo firewall-cmd --permanent --remove-service=http
sudo firewall-cmd --reload
```

**Rich Rules:**
```bash
# Allow from specific IP
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.100" accept'

# Allow port from specific IP
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port port="22" protocol="tcp" accept'

# Reload
sudo firewall-cmd --reload
```

---

### iptables (Advanced)

**View Rules:**
```bash
# List all rules
sudo iptables -L -n -v

# List with line numbers
sudo iptables -L --line-numbers

# List INPUT chain
sudo iptables -L INPUT -n -v
```

**Basic Rules:**
```bash
# Allow port 80
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Allow port 443
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow from specific IP
sudo iptables -A INPUT -s 192.168.1.100 -j ACCEPT

# Allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Drop all other input
sudo iptables -A INPUT -j DROP
```

**Delete Rules:**
```bash
# Delete by line number
sudo iptables -D INPUT 3

# Delete specific rule
sudo iptables -D INPUT -p tcp --dport 80 -j ACCEPT
```

**Save Rules:**
```bash
# Debian/Ubuntu
sudo netfilter-persistent save
sudo netfilter-persistent reload

# RHEL/CentOS 6
sudo service iptables save
sudo service iptables restart

# Manual save
sudo iptables-save > /etc/iptables/rules.v4
```

---

## Network Monitoring

### Monitor Real-Time Connections

**Using ss:**
```bash
# Watch connections
watch -n 1 'ss -tuanp'

# Monitor specific port
watch -n 1 'ss -tan | grep :80'
```

**Using netstat:**
```bash
# Continuous monitoring
netstat -tuanpc
```

### Bandwidth Monitoring

**iftop - Real-time bandwidth by connection:**
```bash
sudo iftop -i eth0
```

**nethogs - Per-process bandwidth:**
```bash
sudo nethogs eth0
```

**nload - Interface bandwidth:**
```bash
# Install
sudo apt install nload  # Debian/Ubuntu
sudo yum install nload  # RHEL/CentOS

# Run
nload eth0
```

**vnstat - Network statistics:**
```bash
# Install
sudo apt install vnstat  # Debian/Ubuntu
sudo yum install vnstat  # RHEL/CentOS

# Enable and start
sudo systemctl enable vnstat
sudo systemctl start vnstat

# View stats
vnstat
vnstat -h    # Hourly
vnstat -d    # Daily
vnstat -m    # Monthly
```

### Speed Testing

**iperf3 - Network throughput:**
```bash
# Install
sudo apt install iperf3  # Debian/Ubuntu
sudo yum install iperf3  # RHEL/CentOS

# On server
iperf3 -s

# On client
iperf3 -c server_ip

# With duration
iperf3 -c server_ip -t 30

# Reverse mode (server sends)
iperf3 -c server_ip -R
```

**speedtest-cli - Internet speed:**
```bash
# Install
sudo apt install speedtest-cli  # Debian/Ubuntu
pip install speedtest-cli        # Via pip

# Run test
speedtest-cli

# Simple output
speedtest-cli --simple

# Specific server
speedtest-cli --server 1234
```

---

## DevOps-Specific Scenarios

### 1. Container Networking

**Docker networking:**
```bash
# List Docker networks
docker network ls

# Inspect network
docker network inspect bridge

# Create custom network
docker network create --driver bridge my-network

# Connect container to network
docker network connect my-network container_name

# Check container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name

# Port mapping
docker run -p 8080:80 nginx

# Check container ports
docker port container_name
```

### 2. Kubernetes Networking

**Check pod networking:**
```bash
# Get pod IP
kubectl get pod -o wide

# Describe pod network
kubectl describe pod pod-name

# Check service endpoints
kubectl get endpoints

# Port forward
kubectl port-forward pod-name 8080:80

# Test service connectivity
kubectl run test --rm -it --image=busybox -- sh
# Inside pod:
wget -O- http://service-name:port
```

### 3. Load Balancer Health Checks

**Simulate health check:**
```bash
# HTTP health check
curl -f http://backend:8080/health || echo "Unhealthy"

# With timeout
timeout 5 curl -f http://backend:8080/health

# Check multiple backends
for backend in backend1 backend2 backend3; do
  echo "Checking $backend"
  curl -sf http://$backend:8080/health || echo "$backend is down"
done
```

### 4. Testing API Endpoints

**Test REST API:**
```bash
# GET request
curl -X GET http://api.example.com/users

# POST JSON
curl -X POST http://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com"}'

# With authentication
curl -H "Authorization: Bearer TOKEN" \
  http://api.example.com/users

# Save response
curl -o response.json http://api.example.com/data

# Check response time
curl -w "@-" -o /dev/null -s http://api.example.com <<'EOF'
  time_total: %{time_total}s\n
EOF
```

### 5. Proxy Configuration

**Set HTTP proxy:**
```bash
# Temporary
export http_proxy=http://proxy.example.com:8080
export https_proxy=http://proxy.example.com:8080
export no_proxy=localhost,127.0.0.1,.local

# For all users (add to /etc/environment)
http_proxy=http://proxy.example.com:8080
https_proxy=http://proxy.example.com:8080
no_proxy=localhost,127.0.0.1
```

**Docker with proxy:**
```bash
# Edit /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://proxy:8080"
Environment="HTTPS_PROXY=http://proxy:8080"
Environment="NO_PROXY=localhost,127.0.0.1"

# Reload
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 6. SSH Tunneling

**Local port forwarding:**
```bash
# Forward local port 8080 to remote 80
ssh -L 8080:localhost:80 user@remote

# Access database through jump host
ssh -L 3306:db-server:3306 user@jump-host
```

**Remote port forwarding:**
```bash
# Expose local service to remote
ssh -R 8080:localhost:3000 user@remote
```

**SOCKS proxy:**
```bash
# Create SOCKS proxy
ssh -D 8080 user@remote

# Use with curl
curl --socks5 localhost:8080 http://example.com
```

### 7. Network Namespace (Containers)

**View network namespaces:**
```bash
# List namespaces
sudo ip netns list

# Execute in namespace
sudo ip netns exec namespace_name bash

# Check container namespace
sudo ls -l /proc/$(pidof container)/ns/net
```

### 8. Monitor Application Ports

**Check if application is listening:**
```bash
# Web application
ss -tlnp | grep :80
ss -tlnp | grep :443

# Database
ss -tlnp | grep :3306    # MySQL
ss -tlnp | grep :5432    # PostgreSQL
ss -tlnp | grep :27017   # MongoDB

# Redis
ss -tlnp | grep :6379
```

### 9. Debugging Network Issues

**Complete diagnostic:**
```bash
#!/bin/bash
echo "=== Network Interfaces ==="
ip addr show

echo -e "\n=== Routing Table ==="
ip route show

echo -e "\n=== DNS Servers ==="
cat /etc/resolv.conf

echo -e "\n=== Ping Gateway ==="
ping -c 4 $(ip route | grep default | awk '{print $3}')

echo -e "\n=== Ping Google DNS ==="
ping -c 4 8.8.8.8

echo -e "\n=== DNS Resolution ==="
dig +short google.com

echo -e "\n=== Listening Ports ==="
ss -tlnp

echo -e "\n=== Firewall Status ==="
if command -v ufw &> /dev/null; then
    sudo ufw status
elif command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --list-all
fi
```

### 10. Performance Testing

**Test network latency:**
```bash
# Simple ping
ping -c 100 remote-host | tail -3

# With statistics
ping -c 1000 remote-host | grep 'min/avg/max'
```

**Test bandwidth:**
```bash
# Using iperf3
# On server
iperf3 -s

# On client
iperf3 -c server -t 60 -i 5

# Parallel streams
iperf3 -c server -P 10
```

**Test HTTP performance:**
```bash
# Apache Bench
ab -n 1000 -c 10 http://example.com/

# Or using curl
for i in {1..100}; do
  curl -w "%{time_total}\n" -o /dev/null -s http://example.com/
done | awk '{sum+=$1; count++} END {print "Average:", sum/count}'
```

---

## Quick Reference Commands

### Network Information
```bash
ip addr show              # Show all interfaces
ip route show             # Show routing table
ip link show              # Show link status
hostname -I               # Show IP addresses
cat /etc/resolv.conf      # Show DNS servers
```

### Connectivity Testing
```bash
ping -c 4 host            # Test reachability
traceroute host           # Trace route
mtr host                  # Combined ping/traceroute
nc -zv host port          # Test port connectivity
```

### Port Management
```bash
ss -tulnp                 # Show all listening ports
ss -tlnp | grep :80       # Check specific port
lsof -i :80               # Show what's using port 80
```

### DNS Queries
```bash
dig google.com            # Full DNS query
dig +short google.com     # Quick answer
nslookup google.com       # Simple lookup
host google.com           # Simplest lookup
```

### Firewall
```bash
# UFW (Ubuntu)
sudo ufw status
sudo ufw allow 80
sudo ufw deny 23

# firewalld (RHEL/CentOS)
sudo firewall-cmd --list-all
sudo firewall-cmd --add-port=80/tcp
sudo firewall-cmd --reload
```

### Monitoring
```bash
sudo iftop -i eth0        # Real-time bandwidth
sudo nethogs eth0         # Per-process bandwidth
ss -tan | grep :80        # Monitor specific port
watch -n 1 'ss -tuanp'    # Watch all connections
```

---

## Summary

### Essential Skills for DevOps

1. **Network Configuration**
   - Configure static/DHCP networking
   - Understand IP addressing and subnetting
   - Manage routing tables

2. **Troubleshooting**
   - Use ping, traceroute, mtr
   - Check DNS resolution
   - Verify port connectivity
   - Analyze packet captures

3. **Security**
   - Configure firewalls (ufw/firewalld)
   - Manage port access
   - Use SSH securely
   - Understand network security basics

4. **Monitoring**
   - Monitor bandwidth usage
   - Track connections
   - Measure latency and throughput
   - Set up network metrics

5. **Service Management**
   - Configure services to listen on ports
   - Verify service availability
   - Test API endpoints
   - Debug connectivity issues

### Best Practices

1. **Always use static IPs for servers**
2. **Document network configuration**
3. **Use DNS instead of IP addresses in configs**
4. **Monitor network performance regularly**
5. **Keep firewall rules minimal and documented**
6. **Test connectivity after configuration changes**
7. **Use network namespaces for isolation**
8. **Implement proper network segmentation**
9. **Keep SSH keys secure**
10. **Log and audit network access**

### Next Steps

1. Practice with virtual machines
2. Set up a home lab environment
3. Learn about SDN and container networking
4. Study Kubernetes networking
5. Explore service mesh (Istio, Linkerd)
6. Learn about load balancing (HAProxy, Nginx)
7. Understand cloud networking (VPC, Security Groups)
8. Practice network troubleshooting scenarios

---

**Master these networking fundamentals to excel in DevOps!**