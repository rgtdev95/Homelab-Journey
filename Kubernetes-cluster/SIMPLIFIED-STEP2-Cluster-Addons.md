# Step 2: Kubernetes Cluster Initialization & Add-ons

**Run on:** Master node only (10.0.0.108)  
**Time:** ~45-60 minutes  
**Prerequisites:** Step 1 completed on all nodes

---

## 🎯 Overview

This step initializes your Kubernetes cluster and installs essential add-ons:
1. **Initialize Master Node** - Bootstrap the control plane
2. **Install Calico CNI** - Pod networking
3. **Join Worker Nodes** - Add workers to the cluster
4. **Metrics Server** - Resource monitoring (CPU/RAM)
5. **Local Path Provisioner** - Persistent storage
6. **Helm** - Kubernetes package manager
7. **Prometheus + Grafana** - Monitoring stack with dashboards

---

## 🚀 Part 1: Initialize the Master Node

**Run on:** Master node only (10.0.0.108)

### 1.1 Set Network Configuration Variables

**Why:** Define IP ranges for pods and services that don't overlap with your home network.

```bash
# Pod network CIDR (internal pod IPs)
POD_CIDR=10.244.0.0/16

# Service network CIDR (internal service IPs)
SERVICE_CIDR=10.96.0.0/16

# Master node IP (adjust to your master IP)
PRIMARY_IP=10.0.0.108
```

**⚠️ Important:** If your home network uses `192.168.x.x` or `10.0.0.x`, these ranges should NOT overlap. The defaults above are safe for most home networks.

**Common home networks:**
- `192.168.0.0/24` or `192.168.1.0/24` - Safe to use defaults above
- `10.0.0.0/24` - Safe (we're using `10.244.x.x` for pods, `10.96.x.x` for services)

### 1.2 Initialize the Cluster

**Why:** This creates the Kubernetes control plane on the master node.

```bash
sudo kubeadm init \
  --pod-network-cidr $POD_CIDR \
  --service-cidr $SERVICE_CIDR \
  --apiserver-advertise-address $PRIMARY_IP
```

**What this does:**
- Installs etcd (cluster database)
- Starts kube-apiserver (API endpoint)
- Starts kube-controller-manager (manages controllers)
- Starts kube-scheduler (schedules pods)
- Generates certificates for secure communication
- Creates a join token for worker nodes

**Expected output:**
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

**⚠️ IMPORTANT:** Copy the `kubeadm join` command to your notepad! You'll need it in Part 3.

**Installation time:** 2-3 minutes

### 1.3 Configure kubectl Access

**Why:** This allows you (non-root user) to use kubectl commands.

```bash
{
    mkdir -p ~/.kube
    sudo cp /etc/kubernetes/admin.conf ~/.kube/config
    sudo chown $(id -u):$(id -g) ~/.kube/config
    chmod 600 ~/.kube/config
}
```

**Explanation:**
- Creates `.kube` directory in your home folder
- Copies admin credentials to your user config
- Sets proper ownership and permissions
- `600` permissions = only you can read/write

### 1.4 Verify Control Plane

```bash
kubectl get pods -n kube-system
```

**Expected output:**
```
NAME                                       READY   STATUS
coredns-xxx                                0/1     Pending
coredns-yyy                                0/1     Pending
etcd-ubuntu-k8-master                      1/1     Running
kube-apiserver-ubuntu-k8-master            1/1     Running
kube-controller-manager-ubuntu-k8-master   1/1     Running
kube-scheduler-ubuntu-k8-master            1/1     Running
```

**Note:** CoreDNS pods will be `Pending` until we install the CNI (next part).

---

## 🌐 Part 2: Install Calico CNI (Network Plugin)

**What is CNI?** Container Network Interface - enables pod-to-pod communication across nodes.

**Why Calico?** 
- Supports Network Policies (pod-level firewall rules)
- Better performance than Flannel (especially with eBPF dataplane)
- Industry standard for production clusters
- eBPF dataplane offers superior performance and observability

**Documentation:** [Calico Installation Guide](https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises)

### 2.1 Install Tigera Operator and CRDs

**Why:** The operator manages Calico components automatically. CRDs define custom Kubernetes resources for Calico.

```bash
# Install Custom Resource Definitions first
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/operator-crds.yaml

# Install Tigera Operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/tigera-operator.yaml
```

**What this installs:**
- Custom Resource Definitions (CRDs) for Calico configuration
- Tigera operator deployment
- Necessary RBAC permissions (ServiceAccounts, ClusterRoles, ClusterRoleBindings)

### 2.2 Choose Data Plane and Download Manifest

**Calico offers two data plane options:**

| Data Plane | Performance | Features | Best For |
|------------|-------------|----------|----------|
| **eBPF** | ⚡ Faster | Native XDP support, better observability | Modern kernels (5.3+), Ubuntu 24.04 ✅ |
| **iptables** | Standard | Stable, widely tested | Older kernels, legacy systems |

**For Ubuntu 24.04 with kernel 6.x, use eBPF for better performance.**

**Option A: eBPF Data Plane (Recommended)**

```bash
cd ~
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/custom-resources-bpf.yaml
```

**Option B: iptables Data Plane (Traditional)**

```bash
cd ~
curl -O https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/custom-resources.yaml
```

**⚠️ For this guide, we'll use eBPF (recommended for Ubuntu 24.04).**

### 2.3 Verify and Customize (Optional)

**Check the downloaded manifest:**

```bash
cat custom-resources-bpf.yaml
```

**Default configuration should work for most setups.** The manifest automatically detects your `POD_CIDR` from kubeadm configuration.

**If needed, customize:**
- IP pool settings
- BGP configuration
- Encapsulation mode (VXLAN, IPIP, or none)

```bash
# Optional: Edit if customization needed
nano custom-resources-bpf.yaml
```

### 2.4 Deploy Calico

**Apply the configuration:**

```bash
# For eBPF
kubectl create -f custom-resources-bpf.yaml

# OR for iptables
# kubectl create -f custom-resources.yaml
```

**What this does:**
- Creates Installation and APIServer custom resources
- Triggers Tigera Operator to deploy Calico components
- Configures pod networking with your chosen data plane
- Deploys calico-node DaemonSet (1 pod per node)
- Deploys calico-kube-controllers
- Deploys calico-typha (for larger clusters)

### 2.5 Monitor Calico Installation

```bash
# Watch Calico components coming online
watch kubectl get tigerastatus
```

**Expected progression (eBPF dataplane):**
```
NAME                AVAILABLE   PROGRESSING   DEGRADED   SINCE
apiserver           True        False         False      4m9s
calico              True        False         False      3m29s
goldmane            True        False         False      3m39s
ippools             True        False         False      6m4s
kubeproxy-monitor   True        False         False      6m15s
whisker             True        False         False      3m19s
```

**Wait until all show `AVAILABLE: True`**, then press `CTRL+C` to exit.

**Components explained:**
- `apiserver` - Calico API server for direct API access
- `calico` - Core Calico networking components
- `goldmane` - Calico Wireguard for encryption (if enabled)
- `ippools` - IP address pool management
- `kubeproxy-monitor` - Monitors kube-proxy status
- `whisker` - Advanced network policy features

**Alternative monitoring:**
```bash
# Watch Calico pods in detail
kubectl get pods -n calico-system -w

# Check all pods across namespaces
kubectl get pods -A
```

**Expected pods:**
```
NAMESPACE       NAME                                       READY   STATUS
calico-system   calico-kube-controllers-xxx                1/1     Running
calico-system   calico-node-xxx (x1, later x3 after join)  1/1     Running
calico-system   calico-typha-xxx                           1/1     Running
calico-system   csi-node-driver-xxx (x1, later x3)         2/2     Running
kube-system     coredns-xxx                                1/1     Running (now!)
kube-system     coredns-yyy                                1/1     Running (now!)
```

**Installation time:** 3-5 minutes

### 2.6 Verify Node is Ready

```bash
kubectl get nodes
```

**Expected output:**
```
NAME                STATUS   ROLES           AGE   VERSION
ubuntu-k8-master    Ready    control-plane   5m    v1.31.x
```

**Status should be `Ready`!** If still `NotReady`, wait 1-2 more minutes.

---

## 👷 Part 3: Join Worker Nodes to Cluster

**Run on:** Each worker node (10.0.0.112, 10.0.0.109)

### 3.1 Get Join Command (if you lost it)

**On master node:**

```bash
# Generate new join command
kubeadm token create --print-join-command
```

**Output:**
```bash
kubeadm join 10.0.0.108:6443 --token abc123.xyz789 \
    --discovery-token-ca-cert-hash sha256:1234567890abcdef...
```

### 3.2 Join Workers

**On each worker node (SSH to worker1 and worker2):**

```bash
# Copy the FULL join command from master and run with sudo
sudo kubeadm join 10.0.0.108:6443 --token abc123.xyz789 \
    --discovery-token-ca-cert-hash sha256:1234567890abcdef...
```

**Expected output:**
```
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

**Repeat for each worker node.**

### 3.3 Verify Cluster (on master)

```bash
# Check all nodes
kubectl get nodes -o wide

# Watch nodes become ready
watch kubectl get nodes
```

**Expected output:**
```
NAME                STATUS   ROLES           AGE   VERSION
ubuntu-k8-master    Ready    control-plane   10m   v1.31.x
ubuntu-k8-node1     Ready    <none>          2m    v1.31.x
ubuntu-k8-node2     Ready    <none>          1m    v1.31.x
```

**All nodes should show `Ready` status within 1-2 minutes.**

### 3.4 Verify Calico on All Nodes

```bash
# Check calico-node pods (should be 1 per node)
kubectl get pods -n calico-system -o wide
```

**Expected output:**
```
NAME                  READY   STATUS    NODE
calico-node-xxx       1/1     Running   ubuntu-k8-master
calico-node-yyy       1/1     Running   ubuntu-k8-node1
calico-node-zzz       1/1     Running   ubuntu-k8-node2
```

**🎉 Congratulations! Your Kubernetes cluster is now operational!**

---

## 📊 Part 4: Metrics Server

**What it does:** Collects CPU and memory usage from nodes and pods  
**Why you need it:** Enables `kubectl top nodes/pods` commands and horizontal pod autoscaling

### 4.1 Download Manifest

```bash
# Create organized directory structure
mkdir -p ~/kubernetes-addons/metrics-server
cd ~/kubernetes-addons/metrics-server

# Download official manifest
wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -O metrics-server.yaml
```

### 4.2 Modify Configuration

**Why:** By default, Metrics Server requires valid TLS certificates. Home labs often use self-signed certs.

```bash
# Edit the file
nano metrics-server.yaml
```

**Find this section** (around line 132):

```yaml
spec:
  containers:
  - args:
    - --cert-dir=/tmp
    - --secure-port=10250
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --kubelet-use-node-status-port
    - --metric-resolution=15s
```

**Add this line:**

```yaml
    - --kubelet-insecure-tls        # ADD THIS LINE
```

**Explanation:**
- `--kubelet-insecure-tls` - Skips TLS certificate verification
- Only use in home labs/development environments
- Production environments should use proper certificates

### 4.3 Deploy Metrics Server

```bash
kubectl apply -f metrics-server.yaml
```

### 4.4 Verify Installation

```bash
# Check pod is running (wait 1-2 minutes)
kubectl get pods -n kube-system | grep metrics-server

# Test metrics collection
kubectl top nodes
kubectl top pods -A
```

**Expected output:**

```
NAME                 CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
ubuntu-k8-master     100m         5%     1500Mi          37%
ubuntu-k8-node1      150m         7%     2000Mi          50%
ubuntu-k8-node2      120m         6%     1800Mi          45%
```

---

## 💾 Part 5: Local Path Provisioner (Storage)

**What it does:** Automatically creates persistent volumes on node's local disk  
**Why you need it:** Apps like databases, Prometheus, and Grafana need persistent storage that survives pod restarts

### 5.1 Download and Deploy

```bash
# Create directory
cd ~/kubernetes-addons
mkdir storage
cd storage

# Download manifest
wget https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# Deploy
kubectl apply -f local-path-storage.yaml
```

**What this installs:**
- A storage provisioner pod
- A StorageClass named `local-path`
- Auto-creates directories on worker nodes at `/opt/local-path-provisioner/`

### 5.2 Verify Storage Class

```bash
# Check provisioner pod
kubectl get pods -n local-path-storage

# Check storage class (this is what apps will use)
kubectl get storageclass
```

**Expected output:**

```
NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE
local-path   rancher.io/local-path   Delete          WaitForFirstConsumer
```

**Key points:**
- `RECLAIMPOLICY: Delete` - Volume is deleted when PVC is deleted
- `WaitForFirstConsumer` - Volume is created only when a pod actually uses it
- Storage location: `/opt/local-path-provisioner/pvc-<unique-id>/` on the node where pod runs

---

## 📦 Part 6: Helm (Package Manager)

**What it does:** Simplifies installation of complex Kubernetes applications  
**Why you need it:** Installing Prometheus+Grafana manually would require dozens of YAML files

### 6.1 Install Helm

```bash
# Download and install Helm 3
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

**Expected output:**

```
version.BuildInfo{Version:"v3.13.x", ...}
```

**What is Helm:**
- Think of it as "apt" or "yum" for Kubernetes
- Packages (called "charts") bundle multiple Kubernetes resources
- Manages upgrades, rollbacks, and configuration

---

## 📈 Part 7: Prometheus + Grafana Stack

**What it does:**
- **Prometheus** - Collects time-series metrics (CPU, memory, network, custom metrics)
- **Grafana** - Visualizes metrics with beautiful dashboards
- **Node Exporter** - Collects hardware/OS metrics from each node
- **Kube State Metrics** - Exposes Kubernetes object states as metrics

**Why you need it:** Monitor cluster health, troubleshoot issues, track resource usage

### 7.1 Create Namespace

```bash
kubectl create namespace monitoring
```

### 7.2 Add Prometheus Helm Repository

```bash
# Create directory
cd ~/kubernetes-addons
mkdir monitoring
cd monitoring

# Add Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 7.3 Create Configuration File

```bash
nano prometheus-values.yaml
```

**Paste this configuration:**

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
  adminPassword: admin123
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

**Configuration explained:**

| Setting | Purpose |
|---------|---------|
| `storageClassName: local-path` | Use the storage provisioner from Part 2 |
| `storage: 10Gi` | Allocate 10GB for Prometheus metrics |
| `retention: 7d` | Keep 7 days of historical data |
| `adminPassword: admin123` | Grafana login password (change this!) |
| `service.type: ClusterIP` | Internal cluster access only (will use Ingress later) |
| `alertmanager.enabled: false` | Disable alerts to reduce resource usage |

### 7.4 Install the Stack

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml \
  --timeout 10m
```

**What this installs:**
- Prometheus server (collects and stores metrics)
- Grafana (visualization)
- Node exporter daemonset (1 pod per node)
- Kube-state-metrics (Kubernetes object metrics)
- Prometheus operator (manages Prometheus instances)

**Installation time:** 3-5 minutes

### 7.5 Verify Installation

```bash
# Check all pods are running (wait 3-5 minutes)
kubectl get pods -n monitoring

# Check persistent volumes were created
kubectl get pvc -n monitoring

# Check all services
kubectl get svc -n monitoring
```

**Expected pods:**

```
NAME                                                   READY   STATUS
prometheus-kube-prometheus-operator-xxx                1/1     Running
prometheus-kube-state-metrics-xxx                      1/1     Running
prometheus-prometheus-node-exporter-xxx (x3)           1/1     Running
prometheus-grafana-xxx                                 3/3     Running
prometheus-kube-prometheus-prometheus-0                2/2     Running
```

**Expected PVCs:**

```
NAME                                 STATUS   VOLUME        CAPACITY   STORAGECLASS
prometheus-prometheus-db-0           Bound    pvc-xxx       10Gi       local-path
prometheus-grafana                   Bound    pvc-yyy       5Gi        local-path
```

### 7.6 Access Grafana (Temporary)

```bash
# Get Grafana admin password (if you forgot)
kubectl get secret --namespace monitoring prometheus-grafana \
  -o jsonpath="{.data.admin-password}" | base64 -d ; echo

# Port forward to access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 --address=0.0.0.0
```

**Access Grafana:**
- URL: `http://10.0.0.108:3000` (your master node IP)
- Username: `admin`
- Password: `admin123` (or from command above)

**Pre-installed dashboards:**
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Node
- Kubernetes / Networking / Cluster
- Node Exporter / Nodes

---

## ✅ Part 8: Verify Storage on Worker Nodes

**What to check:** Ensure persistent volumes are actually created on worker nodes

```bash
# SSH to each worker node
ssh user@10.0.0.112  # worker1
ssh user@10.0.0.109  # worker2

# Check storage directory
ls -la /opt/local-path-provisioner/
```

**Expected output:**

```
drwxr-xr-x 2 root root 4096 Nov 25 10:30 pvc-abc123.../  <- Prometheus data
drwxr-xr-x 2 root root 4096 Nov 25 10:31 pvc-def456.../  <- Grafana data
```

**Notes:**
- Volumes are created only on nodes where pods are scheduled
- You won't see directories on the master node (unless you removed the master taint)
- Directory names are unique PVC IDs

---

## 🔍 Troubleshooting

### Issue: "Metrics API not available"

**Symptoms:** `kubectl top nodes` fails

**Solutions:**
1. Wait 2-3 minutes for first metrics collection
2. Check logs:
   ```bash
   kubectl logs -n kube-system deployment/metrics-server
   ```
3. Verify `--kubelet-insecure-tls` flag is in manifest

---

### Issue: Helm install times out

**Symptoms:** `context deadline exceeded` or timeout error

**Solutions:**
1. Increase timeout:
   ```bash
   helm install prometheus ... --timeout 15m
   ```
2. Check node resources:
   ```bash
   kubectl top nodes
   ```
3. Ensure workers have at least 4GB RAM
4. Clean failed install:
   ```bash
   helm uninstall prometheus -n monitoring
   ```

---

### Issue: Pods stuck in "Pending"

**Symptoms:** Pods show `Pending` status for >5 minutes

**Solutions:**
1. Check events:
   ```bash
   kubectl describe pod <pod-name> -n monitoring
   ```
2. Common causes:
   - Insufficient CPU/RAM: `kubectl top nodes`
   - PVC not binding: `kubectl get pvc -n monitoring`
   - Node taints: `kubectl describe nodes | grep -i taint`

---

### Issue: Storage directory not created

**Symptoms:** `/opt/local-path-provisioner/` doesn't exist on workers

**Solutions:**
- This is normal if no PVCs are bound yet
- Check PVC status: `kubectl get pvc -n monitoring`
- If PVC is `Pending`, check provisioner logs:
  ```bash
  kubectl logs -n local-path-storage deployment/local-path-provisioner
  ```

---

## 📊 Resource Usage Summary

**After this step, your cluster uses:**

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Metrics Server | ~50m | ~100Mi | - |
| Local Path Provisioner | ~10m | ~50Mi | - |
| Prometheus | ~500m | ~1Gi | 10Gi |
| Grafana | ~100m | ~200Mi | 5Gi |
| Node Exporters (3x) | ~30m | ~50Mi | - |
| Kube State Metrics | ~50m | ~100Mi | - |
| **Total** | **~800m** | **~1.5Gi** | **15Gi** |

---

## 📁 Directory Structure

Your monitoring configuration is organized as:

```
~/kubernetes-addons/
├── metrics-server/
│   └── metrics-server.yaml
├── storage/
│   └── local-path-storage.yaml
└── monitoring/
    └── prometheus-values.yaml
```

---

## ✅ Verification Checklist

Before proceeding to Step 3:

- [ ] All 3 nodes show `Ready` status
- [ ] Calico pods running on all nodes
- [ ] CoreDNS pods are Running (not Pending)
- [ ] `kubectl top nodes` shows CPU/memory metrics
- [ ] `kubectl get storageclass` shows `local-path`
- [ ] `helm version` shows v3.x
- [ ] All pods in `monitoring` namespace are Running
- [ ] Both PVCs in `monitoring` namespace are Bound
- [ ] Grafana accessible via port-forward
- [ ] Storage directories exist on worker nodes

---

## ⏭️ Next Steps

**Step 3:** Install Ingress-NGINX controller for external access to Grafana and other services

---

**✅ Cluster add-ons complete!** Your cluster now has monitoring, storage, and resource metrics.
