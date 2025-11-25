# Step 1: Node Setup & Kubernetes Installation

**Run on:** All nodes (1 master + 2 workers)  
**Time:** ~15 minutes per node  
**Purpose:** Prepare Ubuntu 24.04 nodes and install Kubernetes components

---

## 🔧 Prerequisites

Before starting, ensure:
- [ ] All VMs running Ubuntu 24.04 Server
- [ ] Network connectivity between nodes
- [ ] Sudo access on all nodes
- [ ] **Swap disabled** on all nodes

---

## 📋 Part 1: Disable Swap (Critical!)

**Why:** Kubernetes requires swap to be disabled for proper memory management.

```bash
# Disable swap immediately
sudo swapoff -a

# Make it permanent (survives reboots)
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Verify swap is off (should show 0)
free -h
```

---

## 📦 Part 2: Install Base Packages

**Why:** These packages enable secure communication with Kubernetes repositories.

```bash
{
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl
}
```

**Explanation:**
- `apt-transport-https` - Allows apt to retrieve packages over HTTPS
- `ca-certificates` - Trusted SSL certificates for secure connections
- `curl` - Download files from URLs

---

## 🧩 Part 3: Configure Kernel Modules

**Why:** Kubernetes networking requires specific kernel features for container networking.

### Load Required Modules

```bash
{
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

    sudo modprobe overlay
    sudo modprobe br_netfilter
}
```

**Explanation:**
- `overlay` - Enables OverlayFS for efficient container storage layers
- `br_netfilter` - Enables bridge networking and packet filtering
- `modprobe` - Loads modules immediately
- `/etc/modules-load.d/k8s.conf` - Makes modules load automatically on boot

---

## 🌐 Part 4: Configure Network Settings

**Why:** Enable proper routing and filtering for pod-to-pod communication.

```bash
{
    cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

    sudo sysctl --system
}
```

**Explanation:**
- `bridge-nf-call-iptables` - Enables iptables filtering on bridge networks (IPv4)
- `bridge-nf-call-ip6tables` - Enables iptables filtering on bridge networks (IPv6)
- `ip_forward` - Allows the node to forward packets between pods
- `sysctl --system` - Applies settings immediately

---

## 📦 Part 5: Install Container Runtime (containerd)

**Why:** Kubernetes needs a container runtime to actually run containers. Containerd is the most common choice.

```bash
# Install containerd
sudo apt-get install -y containerd
```

---

## ⚙️ Part 6: Configure Containerd (CRITICAL STEP!)

**Why:** Without this configuration, pods will crash-loop and kubectl will fail with connection errors.

### Create Configuration with Systemd Cgroups

```bash
{
    sudo mkdir -p /etc/containerd
    containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
}
```

**Explanation:**
- Generates default containerd config
- **Changes `SystemdCgroup` to `true`** - Makes containerd use systemd for resource management (required for Kubernetes)
- Without this, you'll see: `The connection to the server x.x.x.x:6443 was refused`

### Restart Containerd

```bash
sudo systemctl restart containerd
```

---

## 🔑 Part 7: Add Kubernetes Repository

**Why:** Get Kubernetes packages from official sources.

### Detect Latest Kubernetes Version

```bash
KUBE_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk 'BEGIN { FS="." } { printf "%s.%s", $1, $2 }')
```

**Explanation:** Fetches the latest stable minor version (e.g., v1.28)

### Add GPG Signing Key

```bash
{
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
}
```

**Explanation:** Downloads and stores Kubernetes GPG key for package verification

### Add Repository

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

---

## 📥 Part 8: Install Kubernetes Components

**Why:** Install the core Kubernetes tools on every node.

```bash
{
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
}
```

**Explanation:**
- `kubelet` - Agent that runs on every node, manages pods
- `kubeadm` - Tool to bootstrap the cluster
- `kubectl` - Command-line tool to interact with Kubernetes
- `apt-mark hold` - Prevents accidental upgrades (important for cluster stability)

---

## 🔧 Part 9: Configure Container Inspection Tool

**Why:** Allows you to debug running containers if needed.

```bash
sudo crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock
```

**Explanation:** Configures `crictl` (CRI CLI) to communicate with containerd

---

## 🌐 Part 10: Configure Kubelet Network Binding (Optional)

**⚠️ Skip this step if:** Your nodes have only one network interface

**Do this step if:** Your nodes have multiple NICs (e.g., management + storage networks, or NAT + bridged adapters in VMware)

**Why:** When multiple network interfaces exist, kubelet may bind to the wrong IP. This forces kubelet to use a specific IP address.

### Check if You Need This

```bash
# List all network interfaces
ip addr show

# Count non-loopback interfaces
ip -o link show | grep -v "lo:" | wc -l
```

**If you see only one interface (besides `lo`)** → Skip this part  
**If you see multiple interfaces** → Continue below

### Set Node IP

```bash
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip ${PRIMARY_IP}'
EOF
```

**⚠️ Important:** Replace `${PRIMARY_IP}` with your actual IP:

**For Master:**
```bash
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip 10.0.0.108'
EOF
```

**For Worker 1:**
```bash
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip 10.0.0.112'
EOF
```

**For Worker 2:**
```bash
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip 10.0.0.109'
EOF
```

**Explanation:** Forces kubelet to advertise and bind to the specified IP, preventing it from selecting a NAT interface or wrong NIC.

---

## ✅ Verification

After completing all steps on all nodes:

```bash
# Check containerd is running
sudo systemctl status containerd

# Check kubelet is loaded (may be inactive until cluster init)
sudo systemctl status kubelet

# Verify versions
kubelet --version
kubeadm version
kubectl version --client
```

---

## 📝 Quick Reference: What Each Component Does

| Component | Purpose |
|-----------|---------|
| **containerd** | Container runtime - actually runs your containers |
| **kubelet** | Node agent - manages pods and reports to control plane |
| **kubeadm** | Cluster bootstrapper - initializes and joins nodes |
| **kubectl** | CLI tool - interact with Kubernetes cluster |
| **crictl** | Container debugging - inspect running containers |

---

## 🚨 Common Issues

### Problem: "connection refused" errors later
**Cause:** SystemdCgroup not set to true in containerd config  
**Fix:** Re-run Part 6, ensure `SystemdCgroup = true`

### Problem: Kubelet fails to start after cluster init
**Cause:** Swap still enabled  
**Fix:** Run `sudo swapoff -a` and check `/etc/fstab`

### Problem: Pods get wrong IP addresses
**Cause:** Node IP not configured correctly  
**Fix:** Double-check Part 10, verify IPs match your network

---

## ⏭️ Next Steps

After completing this on **all 3 nodes**, proceed to:
- **Step 2:** Initialize the master node and install cluster add-ons
- **Step 3:** Set up Ingress controller and monitoring stack

---

**✅ Node setup complete!** Your nodes are now ready for cluster initialization.
