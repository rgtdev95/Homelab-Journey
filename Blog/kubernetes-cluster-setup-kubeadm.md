# Building a Production-Ready Kubernetes Cluster with kubeadm: A Homelab Guide

**Published**: November 2025  
**Reading Time**: 25 minutes  
**Difficulty**: Intermediate

---

## 🎯 What We're Building

In this comprehensive guide, you'll learn how to build a fully functional, production-ready Kubernetes cluster from scratch using kubeadm. This isn't just a basic setup—by the end, you'll have a robust cluster complete with:

- ✅ **3-node architecture** (1 master + 2 workers)
- ✅ **High-performance networking** with Calico CNI (eBPF dataplane)
- ✅ **Persistent storage** for stateful applications
- ✅ **Complete monitoring stack** (Prometheus + Grafana)
- ✅ **External access** via Ingress controller
- ✅ **Resource metrics** for autoscaling and monitoring

Whether you're a DevOps engineer building a homelab, a developer wanting to understand Kubernetes internals, or an IT professional studying for certifications, this guide will walk you through each step with clear explanations of *why* we do each configuration.

---

## 📋 Infrastructure Overview

### Hardware Setup

**Hypervisor**: VMware ESXi  
**Operating System**: Ubuntu Server 24.04 LTS

**Per Node Specifications**:
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 50GB
- **Network**: Gigabit LAN recommended

**Network Planning**:
- **Home Network**: `10.0.0.0/24` (your existing network)
- **Pod Network**: `10.244.0.0/16` (internal Kubernetes pod IPs)
- **Service Network**: `10.96.0.0/16` (internal Kubernetes service IPs)

These ranges don't overlap, ensuring smooth operation without IP conflicts.

---

## 🚀 Phase 1: Foundation - Preparing Your Nodes

This first phase is critical. We'll prepare all three nodes with the necessary configurations and install Kubernetes components. **These steps must be completed on all nodes** before proceeding.

### Why Each Step Matters

Before we dive in, let's understand the "why" behind our setup:

- **Swap disabled**: Kubernetes requires precise memory management. Swap interferes with this.
- **Kernel modules**: Enable container networking features like overlay filesystems and bridge filtering.
- **containerd**: The container runtime that actually runs your containers. Docker is no longer the default.
- **SystemdCgroup configuration**: This is critical—without it, your kubelet will fail with cryptic connection errors.

### Step 1.1: Disable Swap (Critical!)

Kubernetes and swap don't mix. Here's why: Kubernetes schedules pods based on available memory. If swap is enabled, the system might move pod memory to disk, causing unpredictable performance and breaking Kubernetes' memory guarantees.

```bash
# Disable swap immediately
sudo swapoff -a

# Make it permanent (survives reboots)
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Verify swap is off (should show 0 in Swap row)
free -h
```

**Expected output**:
```
               total        used        free
Mem:           3.8Gi       1.2Gi       2.1Gi
Swap:             0B          0B          0B  ← Should be 0
```

### Step 1.2: Install Base Packages

These packages enable secure communication with Kubernetes repositories:

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```

- `apt-transport-https`: Allows downloading packages over HTTPS
- `ca-certificates`: Trusted SSL certificates for secure connections
- `curl`: Tool for downloading files from URLs

### Step 1.3: Load Required Kernel Modules

Kubernetes networking relies on specific Linux kernel features. Let's enable them:

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

**What do these do?**
- `overlay`: Enables OverlayFS for efficient container storage layers (think of it as layered file systems)
- `br_netfilter`: Enables bridge networking and packet filtering (essential for pod-to-pod communication)

The configuration file ensures these modules load automatically on every boot.

### Step 1.4: Configure Network Settings

Now we enable proper routing and filtering for pod networking:

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

**Translation**:
- `bridge-nf-call-iptables`: Allows iptables to filter traffic on bridge networks
- `bridge-nf-call-ip6tables`: Same as above, but for IPv6
- `ip_forward`: Enables packet forwarding between pods across nodes

Think of this as setting up the "roads" for network traffic between your pods.

### Step 1.5: Install and Configure containerd

containerd is the container runtime that actually runs your containers. It's lightweight, fast, and the industry standard.

```bash
# Install containerd
sudo apt-get install -y containerd

# Create directory for configuration
sudo mkdir -p /etc/containerd

# Generate config with SystemdCgroup enabled (CRITICAL!)
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml

# Restart to apply configuration
sudo systemctl restart containerd
```

**⚠️ The SystemdCgroup Setting is Critical!**

This single line prevents a common failure mode where kubelet can't communicate with the API server. Without `SystemdCgroup = true`, you'll see errors like:
```
The connection to the server x.x.x.x:6443 was refused
```

This happens because Kubernetes and containerd need to use the same cgroup driver. Ubuntu 24.04 uses systemd as its init system, so containerd must use systemd for cgroups too.

### Step 1.6: Add Kubernetes Repository

Let's add the official Kubernetes repository to get the latest stable packages:

```bash
# Detect latest Kubernetes version
KUBE_LATEST=$(curl -L -s https://dl.k8s.io/release/stable.txt | awk 'BEGIN { FS="." } { printf "%s.%s", $1, $2 }')

# Add GPG signing key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

This ensures we get packages signed with Kubernetes' GPG key, verifying their authenticity.

### Step 1.7: Install Kubernetes Components

Time to install the core Kubernetes tools:

```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

**What each component does**:
- `kubelet`: The agent running on every node that manages pods and reports to the control plane
- `kubeadm`: Tool to bootstrap and manage the cluster
- `kubectl`: Command-line interface to interact with Kubernetes

**Why `apt-mark hold`?** This prevents accidental upgrades. Kubernetes versions should be upgraded deliberately and carefully, not during routine system updates.

### Step 1.8: Configure crictl

crictl is a debugging tool for inspecting containers:

```bash
sudo crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock
```

You won't use this often, but when you need to debug a misbehaving container, crictl is invaluable.

### Step 1.9: Handle Multiple Network Interfaces (If Needed)

**⚠️ Important**: This step is only necessary if your VMs have multiple network interfaces.

VMware ESXi VMs sometimes have multiple NICs (e.g., NAT + Bridged, or management + storage networks). By default, kubelet might bind to the wrong IP address. Let's fix that:

```bash
# Check your interfaces
ip addr show
```

If you see multiple interfaces besides `lo` (loopback), configure kubelet to use a specific IP:

**On Master (10.0.0.108)**:
```bash
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip 10.0.0.108'
EOF
```

**On Worker 1 (10.0.0.112)**:
```bash
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip 10.0.0.112'
EOF
```

**On Worker 2 (10.0.0.109)**:
```bash
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip 10.0.0.109'
EOF
```

This forces kubelet to advertise and bind to your primary network interface, preventing networking issues later.

### Step 1.10: Verification

Before moving on, verify everything is set up correctly:

```bash
# Check containerd is running
sudo systemctl status containerd

# Check kubelet is loaded (will be inactive until cluster init - that's normal)
sudo systemctl status kubelet

# Verify installed versions
kubelet --version
kubeadm version
kubectl version --client
```

**✅ Checkpoint**: You should now have all three nodes ready with Kubernetes components installed. Time to build the cluster!

---

## 🏗️ Phase 2: Cluster Initialization & Essential Add-ons

Now comes the exciting part—we'll initialize the master node and build out the cluster with essential components. This phase runs primarily on the master node.

### Step 2.1: Initialize the Master Node

**Run on master node only (10.0.0.108)**

First, let's define our network configuration:

```bash
# Pod network CIDR (internal pod IPs)
POD_CIDR=10.244.0.0/16

# Service network CIDR (internal service IPs)
SERVICE_CIDR=10.96.0.0/16

# Master node IP
PRIMARY_IP=10.0.0.108
```

Now initialize the cluster:

```bash
sudo kubeadm init \
  --pod-network-cidr $POD_CIDR \
  --service-cidr $SERVICE_CIDR \
  --apiserver-advertise-address $PRIMARY_IP
```

**What's happening behind the scenes?**
- Installing etcd (the cluster's database)
- Starting kube-apiserver (your cluster's API endpoint)
- Starting kube-controller-manager (manages controllers)
- Starting kube-scheduler (decides where to place pods)
- Generating TLS certificates for secure communication
- Creating a join token for worker nodes

This takes 2-3 minutes. When complete, you'll see a success message with important information:

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.0.108:6443 --token abc123.xyz789 \
    --discovery-token-ca-cert-hash sha256:1234567890abcdef...
```

**⚠️ CRITICAL**: Copy that `kubeadm join` command to a text file! You'll need it soon.

### Step 2.2: Configure kubectl Access

This allows you (as a regular user) to use kubectl:

```bash
mkdir -p ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config
```

Verify it works:

```bash
kubectl get nodes
```

You should see your master node, but with status `NotReady`. That's expected—we haven't installed the network plugin yet.

### Step 2.3: Install Calico CNI with eBPF Dataplane

**What is CNI?** Container Network Interface is the plugin that enables pod-to-pod communication across nodes. Without it, pods can't talk to each other.

**Why Calico?** It's production-grade, supports network policies (pod-level firewall rules), and offers excellent performance. For Ubuntu 24.04 with modern kernels, we'll use the eBPF dataplane for superior performance.

**What is eBPF?** Extended Berkeley Packet Filter is a revolutionary Linux kernel technology that allows programs to run in the kernel without kernel modules. It's faster, safer, and offers better observability than traditional iptables.

```bash
# Install Tigera Operator (manages Calico automatically)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/operator-crds.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/tigera-operator.yaml

# Download eBPF dataplane configuration
cd ~
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/custom-resources-bpf.yaml

# Deploy Calico
kubectl create -f custom-resources-bpf.yaml
```

**Monitor the installation**:

```bash
watch kubectl get tigerastatus
```

Wait until all components show `AVAILABLE: True`, then press `CTRL+C`:

```
NAME                AVAILABLE   PROGRESSING   DEGRADED
apiserver           True        False         False
calico              True        False         False
ippools             True        False         False
```

This takes 3-5 minutes. Now check your node:

```bash
kubectl get nodes
```

**Success!** Your master node should now show `Ready`:

```
NAME                STATUS   ROLES           AGE   VERSION
ubuntu-k8-master    Ready    control-plane   8m    v1.31.x
```

### Step 2.4: Join Worker Nodes

**Run on each worker node (10.0.0.112 and 10.0.0.109)**

Remember that `kubeadm join` command from Step 2.1? Time to use it!

SSH to each worker and run:

```bash
sudo kubeadm join 10.0.0.108:6443 --token abc123.xyz789 \
    --discovery-token-ca-cert-hash sha256:1234567890abcdef...
```

**Lost the command?** Generate a new one on the master:

```bash
kubeadm token create --print-join-command
```

After joining both workers, verify on the master:

```bash
kubectl get nodes -o wide
```

**Expected output**:

```
NAME                STATUS   ROLES           AGE   VERSION   INTERNAL-IP
ubuntu-k8-master    Ready    control-plane   10m   v1.31.x   10.0.0.108
ubuntu-k8-node1     Ready    <none>          2m    v1.31.x   10.0.0.112
ubuntu-k8-node2     Ready    <none>          1m    v1.31.x   10.0.0.109
```

**🎉 Congratulations!** You now have a working Kubernetes cluster. But we're not done yet—let's add essential capabilities.

### Step 2.5: Install Metrics Server

Metrics Server collects CPU and memory usage from nodes and pods. This enables:
- `kubectl top nodes` and `kubectl top pods` commands
- Horizontal Pod Autoscaling (HPA)
- Resource-based scheduling decisions

```bash
# Create organized directory
mkdir -p ~/kubernetes-addons/metrics-server
cd ~/kubernetes-addons/metrics-server

# Download manifest
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server.yaml

# Edit to add --kubelet-insecure-tls flag
nano metrics-server.yaml
```

Find the `args` section (around line 132) and add this line:

```yaml
spec:
  containers:
  - args:
    - --cert-dir=/tmp
    - --secure-port=10250
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --kubelet-use-node-status-port
    - --metric-resolution=15s
    - --kubelet-insecure-tls        # ADD THIS LINE
```

**Why `--kubelet-insecure-tls`?** In production, kubelet uses proper TLS certificates. In homelabs with self-signed certs, this flag bypasses certificate validation. **Only use this in development environments.**

Deploy it:

```bash
kubectl apply -f metrics-server.yaml
```

Test after 1-2 minutes:

```bash
kubectl top nodes
```

**Expected output**:

```
NAME                 CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
ubuntu-k8-master     100m         5%     1500Mi          37%
ubuntu-k8-node1      150m         7%     2000Mi          50%
ubuntu-k8-node2      120m         6%     1800Mi          45%
```

### Step 2.6: Install Local Path Provisioner

Most applications need persistent storage that survives pod restarts. Local Path Provisioner automatically creates volumes on nodes' local disks.

```bash
cd ~/kubernetes-addons
mkdir storage && cd storage

# Download and deploy
wget https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl apply -f local-path-storage.yaml
```

Verify:

```bash
kubectl get storageclass
```

**Expected output**:

```
NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE
local-path   rancher.io/local-path   Delete          WaitForFirstConsumer
```

**How it works**: When an application requests persistent storage, this provisioner automatically creates a directory at `/opt/local-path-provisioner/` on the node where the pod runs.

### Step 2.7: Install Helm

Helm is the package manager for Kubernetes—think of it as "apt" for Kubernetes. It simplifies installing complex applications.

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

### Step 2.8: Install Prometheus + Grafana Monitoring Stack

Now for the crown jewel—a complete monitoring solution. This stack includes:
- **Prometheus**: Collects and stores time-series metrics
- **Grafana**: Visualizes metrics with beautiful dashboards
- **Node Exporter**: Collects hardware and OS metrics from each node
- **Kube State Metrics**: Exposes Kubernetes object states as metrics

```bash
# Create namespace
kubectl create namespace monitoring

# Create directory
cd ~/kubernetes-addons
mkdir monitoring && cd monitoring

# Add Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Create a configuration file:

```bash
nano prometheus-values.yaml
```

Paste this configuration:

```yaml
# Prometheus configuration
prometheus:
  prometheusSpec:
    # Persistent storage for metrics
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: local-path
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
    # Keep 7 days of metrics
    retention: 7d

# Grafana configuration
grafana:
  enabled: true
  adminPassword: admin123  # Change this in production!
  # Persistent storage for dashboards
  persistence:
    enabled: true
    storageClassName: local-path
    size: 5Gi
  service:
    type: ClusterIP

# Disable alertmanager to save resources
alertmanager:
  enabled: false
```

**Configuration explained**:
- `storage: 10Gi`: Allocates 10GB for Prometheus metrics (about 7 days of data)
- `retention: 7d`: Keeps metrics for 7 days before deletion
- `adminPassword`: Grafana login password (change this!)
- `service.type: ClusterIP`: Internal access only (we'll use Ingress for external access)

Install the stack:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml \
  --timeout 10m
```

This takes 3-5 minutes. Monitor the installation:

```bash
# Watch pods come online
kubectl get pods -n monitoring -w

# Check persistent volumes
kubectl get pvc -n monitoring
```

**Expected result**: All pods running, two PVCs bound:

```
NAME                                 STATUS   VOLUME      CAPACITY
prometheus-prometheus-db-0           Bound    pvc-xxx     10Gi
prometheus-grafana                   Bound    pvc-yyy     5Gi
```

**✅ Phase 2 Complete!** Your cluster now has monitoring, storage, and resource metrics. Time to add external access.

---

## 🌐 Phase 3: External Access with Ingress-NGINX

Right now, your services are only accessible from within the cluster. Let's fix that with an Ingress controller.

### Understanding Ingress

**What is Ingress?** Think of it as a smart reverse proxy for your cluster. Instead of exposing each service on its own port, Ingress routes traffic based on domain names and paths.

**Traffic flow**:
```
Your Browser
    ↓
yourdomain-name-here.com (DNS resolves to Node IP)
    ↓
Nginx Proxy Manager (handles HTTPS/HTTP)
    ↓
Any Node IP:32080 (NodePort)
    ↓
Ingress Controller (routes to correct service)
    ↓
Service → Pod
```

### Step 3.1: Install Ingress-NGINX

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.11.1/deploy/static/provider/baremetal/deploy.yaml
```

**Why "baremetal"?** Cloud providers (AWS, GCP, Azure) automatically provision LoadBalancers. In a homelab, we don't have that luxury, so we use the baremetal configuration with NodePort.

Wait for the pods to start:

```bash
kubectl get pods -n ingress-nginx -w
```

Press `CTRL+C` when all pods show `Running` or `Completed`.

### Step 3.2: Understand NodePort Exposure

Check the service:

```bash
kubectl get svc -n ingress-nginx
```

**Output**:

```
NAME                                 TYPE        PORT(S)
ingress-nginx-controller             NodePort    80:32080/TCP,443:32443/TCP
```

**Key insight**: NodePort `32080` is now open on **every node** in your cluster. You can access Ingress through:
- `http://10.0.0.108:32080` (master)
- `http://10.0.0.112:32080` (worker1)
- `http://10.0.0.109:32080` (worker2)

All requests are load-balanced to the Ingress Controller pods.

### Step 3.3: Create Ingress Resource for Grafana

Let's create a routing rule to access Grafana via your domain:

```bash
mkdir -p ~/kubernetes-addons/ingress
cd ~/kubernetes-addons/ingress
nano grafana-ingress.yaml
```

Paste this configuration:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: grafana.yourdomain-name-here.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-grafana
            port:
              number: 80
```

**What this does**: Routes all traffic for `grafana.yourdomain-name-here.com` to the Grafana service in the monitoring namespace.

Apply it:

```bash
kubectl apply -f grafana-ingress.yaml

# Verify
kubectl get ingress -n monitoring
```

### Step 3.4: Configure DNS and Nginx Proxy Manager

Now we need to configure DNS and set up Nginx Proxy Manager to handle HTTPS/HTTP traffic to your cluster.

#### Option A: Internal DNS Setup (Pi-hole, AdGuard, pfSense, Unbound)

**If you have Pi-hole**:
1. Navigate to Pi-hole Admin Console
2. Go to **Local DNS** → **DNS Records**
3. Add a new DNS record:
   - **Domain**: `grafana.yourdomain-name-here.com`
   - **IP Address**: `10.0.0.108` (or any node IP)

**If you have AdGuard Home**:
1. Navigate to AdGuard Home Admin Panel
2. Go to **Filters** → **DNS rewrites**
3. Add DNS rewrite:
   - **Domain**: `grafana.yourdomain-name-here.com`
   - **Answer**: `10.0.0.108`

**If you have pfSense**:
1. Navigate to **Services** → **DNS Resolver** (or **DNS Forwarder**)
2. Under **Host Overrides**, add:
   - **Host**: `grafana`
   - **Domain**: `yourdomain-name-here.com`
   - **IP**: `10.0.0.108`

**This makes your domain accessible from all devices on your network.**

#### Option B: Set Up Nginx Proxy Manager

Nginx Proxy Manager provides a clean web interface to manage reverse proxies with automatic SSL certificates.

**Benefits**:
- Clean HTTP/HTTPS access without ports
- Automatic Let's Encrypt SSL certificates
- Easy management via web UI
- Centralized access point for all services

**Installation** (if you don't have it yet):

```bash
# Create docker-compose.yml for Nginx Proxy Manager
mkdir -p ~/nginx-proxy-manager
cd ~/nginx-proxy-manager

cat <<EOF > docker-compose.yml
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'    # HTTP
      - '443:443'  # HTTPS
      - '81:81'    # Admin Web Interface
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF

# Start Nginx Proxy Manager
docker-compose up -d
```

**Access the Admin Interface**:
- URL: `http://your-npm-server-ip:81`
- Default Email: `admin@example.com`
- Default Password: `changeme`
- **Change these immediately after first login!**

**Configure Proxy Host for Grafana**:

1. Click **Hosts** → **Proxy Hosts** → **Add Proxy Host**
2. **Details Tab**:
   - **Domain Names**: `grafana.yourdomain-name-here.com`
   - **Scheme**: `http`
   - **Forward Hostname/IP**: `10.0.0.108` (any node IP)
   - **Forward Port**: `32080`
   - ✅ **Block Common Exploits**
   - ✅ **Websockets Support**

3. **SSL Tab** (for HTTPS):
   - ✅ **Request a new SSL Certificate**
   - ✅ **Force SSL**
   - ✅ **HTTP/2 Support**
   - **Email Address**: your-email@example.com
   - ✅ **Agree to Let's Encrypt TOS**

4. Click **Save**

**Now you can access Grafana at**:
- `https://grafana.yourdomain-name-here.com` (no port needed!)

**Why This Works**:
```
Internet/LAN
    ↓
yourdomain-name-here.com (DNS resolves to NPM server)
    ↓
Nginx Proxy Manager (Port 80/443)
    ↓
Forwards to: Any K8s Node IP:32080
    ↓
Ingress-NGINX Controller (inside cluster)
    ↓
Routes to correct service based on hostname
    ↓
Grafana Pod
```

### Step 3.5: Access Grafana!

Open your browser and navigate to:

```
https://grafana.yourdomain-name-here.com
```

**Login credentials**:
- Username: `admin`
- Password: `admin123` (from your prometheus-values.yaml)

**🎉 Success!** You should see the Grafana login page with HTTPS enabled. After logging in, explore the pre-installed dashboards:
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Node
- Node Exporter / Nodes

These dashboards show real-time metrics from your cluster!

### Step 3.6: Add More Services (Optional)

You can route multiple services through Nginx Proxy Manager. For Prometheus:

**Create Prometheus Ingress**:

```bash
nano prometheus-ingress.yaml
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: prometheus.yourdomain-name-here.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-kube-prometheus-prometheus
            port:
              number: 9090
```

Apply and add to Nginx Proxy Manager following the same steps as Grafana.

---

## 🔧 Troubleshooting Common Issues

### Issue: "Connection refused" errors during cluster init

**Symptoms**: After `kubeadm init`, kubectl can't connect to the API server.

**Solution**: Check containerd configuration:
```bash
grep SystemdCgroup /etc/containerd/config.toml
```

Should show: `SystemdCgroup = true`

If not, regenerate the config (Step 1.5) and restart containerd.

### Issue: Pods stuck in "Pending"

**Symptoms**: Pods remain in `Pending` status for >5 minutes.

**Solution**: Check resources and events:
```bash
kubectl top nodes  # Check if nodes have available resources
kubectl describe pod <pod-name> -n <namespace>  # Check events section
```

Common causes:
- Insufficient CPU/RAM on nodes
- PVC not binding (check `kubectl get pvc`)
- Node taints preventing pod scheduling

### Issue: Worker nodes show "NotReady"

**Symptoms**: After joining, worker nodes don't become Ready.

**Solution**: Check Calico networking:
```bash
kubectl get pods -n calico-system -o wide
```

Ensure there's one `calico-node` pod per node, all showing `Running`.

### Issue: Metrics Server shows "Unable to fetch metrics"

**Symptoms**: `kubectl top nodes` fails with an error.

**Solution**: 
1. Wait 2-3 minutes for first metrics collection
2. Verify `--kubelet-insecure-tls` flag is in the metrics-server deployment
3. Check logs: `kubectl logs -n kube-system deployment/metrics-server`

### Issue: Grafana shows "404 Not Found" with Ingress

**Symptoms**: Domain returns 404.

**Solution**:
1. Verify Ingress resource: `kubectl describe ingress grafana-ingress -n monitoring`
2. Check service name matches: `kubectl get svc -n monitoring`
3. Confirm DNS entry is correct
4. Verify Nginx Proxy Manager is forwarding to correct IP:port

---

## 📊 Cluster Resource Usage

After completing all steps, here's what your cluster consumes:

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Control Plane (Master) | ~400m | ~800Mi | ~10Gi |
| Calico (per node) | ~100m | ~150Mi | - |
| Metrics Server | ~50m | ~100Mi | - |
| Ingress Controller | ~100m | ~100Mi | - |
| Prometheus | ~500m | ~1Gi | 10Gi |
| Grafana | ~100m | ~200Mi | 5Gi |
| Node Exporter (per node) | ~10m | ~50Mi | - |
| **Total** | **~1.3 CPU** | **~2.5Gi RAM** | **~25Gi** |

**Remaining capacity** on a 3-node cluster (2 CPU, 4GB RAM each):
- **CPU**: ~4.7 cores available for workloads
- **Memory**: ~9.5Gi available for workloads

Plenty of room for deploying your applications!

---

## ✅ Verification Checklist

Use this checklist to ensure everything is working:

**Foundation**:
- [ ] Swap disabled on all nodes (`free -h` shows 0 swap)
- [ ] containerd running with `SystemdCgroup = true`
- [ ] Kubernetes packages installed and held from auto-upgrade

**Cluster**:
- [ ] All 3 nodes show `Ready` status
- [ ] Calico pods running on all nodes (1 per node)
- [ ] CoreDNS pods are `Running` (not `Pending`)

**Monitoring & Storage**:
- [ ] `kubectl top nodes` shows CPU/memory metrics
- [ ] StorageClass `local-path` exists
- [ ] All pods in `monitoring` namespace are `Running`
- [ ] Both PVCs in `monitoring` namespace are `Bound`
- [ ] Storage directories exist on worker nodes: `/opt/local-path-provisioner/`

**External Access**:
- [ ] Ingress-NGINX controller pods are `Running`
- [ ] NodePorts 32080 and 32443 are accessible
- [ ] DNS configured for `yourdomain-name-here.com`
- [ ] Nginx Proxy Manager forwarding correctly
- [ ] Grafana accessible at `https://grafana.yourdomain-name-here.com`
- [ ] Can login to Grafana and see dashboards

---

## 🎯 Quick Reference Commands

Save these for daily cluster management:

```bash
# Cluster health overview
kubectl get nodes -o wide
kubectl get pods -A

# Namespace-specific status
kubectl get pods,svc,pvc -n monitoring
kubectl get pods,svc -n ingress-nginx

# Resource usage
kubectl top nodes
kubectl top pods -A

# Ingress routes
kubectl get ingress -A

# Node details
kubectl describe node <node-name>

# Pod logs
kubectl logs -f <pod-name> -n <namespace>

# Complete status one-liner
echo "=== NODES ==="; kubectl get nodes -o wide; \
echo -e "\n=== INGRESS ==="; kubectl -n ingress-nginx get pods -o wide; \
echo -e "\n=== MONITORING ==="; kubectl -n monitoring get pods -o wide; \
echo -e "\n=== STORAGE ==="; kubectl get pvc -A
```

---

## 🚀 Next Steps & Enhancements

Congratulations! You now have a production-ready Kubernetes cluster. Here are some ideas for what's next:

### Immediate Next Steps

1. **Deploy Your First Application**
   - Try deploying a simple web app
   - Use a Deployment with 3 replicas
   - Create a Service and Ingress for external access

2. **Set Up Backup Strategy**
   - Backup etcd regularly: `kubeadm upgrade plan`
   - Export important manifests
   - Document PVC backup procedures

3. **Configure Grafana Alerts**
   - Set up email notifications
   - Create alerts for high CPU/memory usage
   - Monitor pod crash loops

### Advanced Enhancements

4. **Implement GitOps with ArgoCD**
   - Automate deployments from Git repositories
   - Implement proper CI/CD pipelines
   - Track all changes in version control

5. **Add Certificate Management**
   - Install cert-manager
   - Generate SSL certificates automatically
   - Enable HTTPS for all services

6. **Implement Network Policies**
   - Restrict pod-to-pod communication
   - Create security zones within your cluster
   - Implement zero-trust networking

7. **Scale Your Cluster**
   - Add more worker nodes as needed
   - Test horizontal pod autoscaling
   - Experiment with cluster autoscaling concepts

8. **External Access Without Ports**
   - Set up Cloudflare Tunnel for secure external access
   - Configure additional reverse proxy services
   - Implement a VPN solution (WireGuard, Tailscale)

---

## 📚 Additional Resources

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Calico Documentation](https://docs.tigera.io/calico/latest/)
- [Prometheus Operator](https://prometheus-operator.dev/)
- [Ingress-NGINX](https://kubernetes.github.io/ingress-nginx/)
- [Nginx Proxy Manager](https://nginxproxymanager.com/)

### Learning Resources
- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) - Understanding Kubernetes internals
- [Kubernetes Patterns](https://k8spatterns.io/) - Best practices and design patterns
- [CNCF Landscape](https://landscape.cncf.io/) - Explore cloud-native ecosystem

### Community
- [Kubernetes Slack](https://slack.kubernetes.io/)
- [r/kubernetes](https://reddit.com/r/kubernetes)
- [CNCF Meetups](https://www.meetup.com/pro/cncf/)

---

## 🎓 What You've Learned

Through this guide, you've gained hands-on experience with:

- **Linux system administration**: Kernel modules, network configuration, systemd services
- **Container technology**: Understanding containerd, cgroups, and container runtimes
- **Kubernetes architecture**: Control plane components, worker node components, networking
- **Cloud-native storage**: Dynamic provisioning, persistent volumes, storage classes
- **Observability**: Metrics collection, visualization, and monitoring best practices
- **Networking**: CNI plugins, Ingress controllers, reverse proxy configuration
- **Infrastructure as Code**: Managing infrastructure through declarative YAML files
- **Security**: SSL/TLS certificates, secure external access patterns

These skills are directly transferable to production Kubernetes environments, whether on-premise or in the cloud.

---

## 🎉 Conclusion

You've successfully built a production-ready Kubernetes cluster from scratch! This isn't just a toy setup—it's a functional platform capable of running real applications with monitoring, persistent storage, and secure external access.

Your cluster is now ready for:
- **Development**: Test applications in a production-like environment
- **Learning**: Experiment with Kubernetes concepts safely
- **Certification prep**: Practice for CKA, CKAD, or CKS exams
- **Production workloads**: Host personal or small business applications

Remember, the journey doesn't end here. Kubernetes is a vast ecosystem with endless possibilities. Keep experimenting, keep learning, and don't be afraid to break things—that's how you learn best!

**Happy clustering!** 🚀

---

*This guide was created for homelab enthusiasts, DevOps learners, and Kubernetes practitioners. Found it helpful? Share it with your community!*

**Author's Environment**: VMware ESXi | Ubuntu Server 24.04 LTS | Kubernetes v1.31  
**Last Updated**: November 2025  
