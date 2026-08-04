
## Task 1.2 — Cluster Component Mapping

| Pod Observed (kube-system) | Control Plane / Worker Node Component |
|---|---|
| kube-apiserver-minikube | API Server (control plane) |
| etcd-minikube | etcd (control plane) |
| kube-scheduler-minikube | Scheduler (control plane) |
| kube-controller-manager-minikube | Controller Manager (control plane) |
| kube-proxy-xxxxx | kube-proxy (worker node) |
| coredns-xxxxx | Cluster DNS (add-on, not in the core lecture list) |
| storage-provisioner | Minikube add-on for dynamic storage (not in the core lecture list) |

**Note on missing component:** The kubelet does not show up as a pod in `kubectl get pods -n kube-system`. This is because the kubelet is not something Kubernetes manages as a workload — it's the node agent that runs directly as a system process on each worker node (outside the pod system) and is actually responsible for starting and monitoring all the pods, including the ones listed above. Since it's the thing doing the managing, it can't appear as something being managed.

## Checkpoint Q1

The control plane is the "brain" of the cluster — it makes all the decisions about what should be running and where, but it doesn't run the actual application containers itself. It includes things like the API Server (the entry point for all kubectl commands), etcd (stores the cluster's state), the Scheduler (decides which node a pod should run on), and the Controller Manager (keeps checking that the actual state matches what was requested).

A worker node, on the other hand, is where the real work happens — it's the machine that actually runs the application pods. Each worker node has a kubelet (talks to the control plane and manages pods on that node), kube-proxy (handles networking/routing for services), and the container runtime (actually starts and stops the containers).

So basically: control plane decides, worker nodes execute.

## Checkpoint Q2

Yes, the pod's IP changed after deleting and recreating it. This is because Pods are "ephemeral" — deleting a pod removes it completely, and applying the manifest again creates a brand new pod object, not a restored one. Kubernetes assigns a fresh IP to every new pod instance, so nothing from the old pod carries over.

## Checkpoint Q3

When I deleted one pod, the Deployment's desired state stayed at 3 replicas. The controller continuously watches the actual state of the cluster, so as soon as it noticed the actual count dropped to 2 (a gap between desired and actual), it detected this mismatch and reconciled it by creating one new pod to bring the count back up to 3. This happened automatically within seconds, without me doing anything.

## Checkpoint Q4

Each tier (frontend, API, cache, database) will be defined as its own separate Deployment or StatefulSet with its own independent replica count. Scaling the frontend only changes the frontend Deployment's replica field — it doesn't touch the manifests, pods, or configuration of any other tier, so the database and other services keep running completely undisturbed.

## Checkpoint Q5

Port-forward creates a direct tunnel to one specific pod's IP — if that pod is deleted or replaced, the tunnel breaks and stops working. A Service instead has its own stable virtual IP and DNS name that doesn't change, and it automatically routes traffic to whichever pods currently match its label selector. This matters because pods are ephemeral and get new IPs whenever they're replaced, so a Service gives a reliable, unchanging way to reach the application regardless of which pods are currently running behind it.

## Checkpoint Q6

Docker Compose has no built-in concept of a gradual, health-checked rollout — updating a service usually means stopping and recreating containers directly, which can cause downtime if something goes wrong. It also has no rollout history or one-command rollback; if a bad update breaks the app, you'd have to manually figure out and redeploy the previous working configuration yourself. Kubernetes tracks rollout history automatically and lets you undo to a known-good state with a single command, making updates much safer.

## Checkpoint Q7

The frontend and API tiers use a Deployment because they are stateless — any replica pod is identical and interchangeable, pod names are random, and there's no need for stable storage or startup ordering; if a pod dies, a new one with a new name/IP is fine. The database tier uses a StatefulSet because it is stateful — it needs a stable, predictable pod name (postgres-0), and each replica gets its own dedicated PersistentVolumeClaim that stays tied to that specific pod identity across restarts, preserving its data. StatefulSets also create/scale pods in a strict order, which stateless Deployments don't guarantee or need.

## Checkpoint Q8

No, the data would not have survived. Without a PersistentVolumeClaim, Postgres would be writing to the container's own writable filesystem layer, which is deleted along with the pod itself. A plain Deployment also doesn't guarantee the replacement pod gets any specific storage back — it's treated as a completely fresh pod. The reason the data survived here is that the PVC is backed by a PersistentVolume that exists independently of the pod's lifecycle, so when postgres-0 was recreated, it reattached to the exact same storage volume.

## Checkpoint Q9

The broken pod showed status ErrImagePull, which then settled into ImagePullBackOff. This isn't exactly one of the four statuses listed in the lecture (Running / Pending / CrashLoopBackOff / OOMKilled) — it's a related but distinct status. It means Kubernetes successfully scheduled the pod onto a node, but the container runtime failed to pull the specified image (because the tag doesn't exist), so instead of endlessly retrying immediately, Kubernetes backs off and retries the pull with increasing delay between attempts.
