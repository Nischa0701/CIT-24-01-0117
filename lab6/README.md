# Lab 6 — Kubernetes Fundamentals with Minikube

**Course:** CCS3308 – Virtualization and Containers
**Week:** 7 — Container Orchestration & Kubernetes
**Submission type:** Individual

## Overview

This lab deploys a multi-tier application on a local single-node Kubernetes cluster (Minikube), built entirely from public Docker Hub images. It covers Pods, Deployments, Services, scaling, rolling updates/rollbacks, StatefulSets with persistent storage, and troubleshooting.

## Architecture

| Tier | Image | Port | Kubernetes Object |
|---|---|---|---|
| Frontend | nginx:alpine | 80 | Deployment (3 replicas) + NodePort Service |
| API | kennethreitz/httpbin | 80 | Deployment (2 replicas) + ClusterIP Service |
| Cache | redis:7-alpine | 6379 | Deployment (1 replica) + ClusterIP Service |
| Database | postgres:16-alpine | 5432 | StatefulSet (1 replica) + PVC + Headless Service |

## Prerequisites

- Docker installed and running
- kubectl installed
- Minikube installed

## How to Run

1. Start the cluster:
```bash
   minikube start --driver=docker
```

2. Apply all manifests:
```bash
   kubectl apply -f k8s/
```

3. Check everything is running:
```bash
   kubectl get all
```

4. Access the frontend:
```bash
   minikube service frontend --url
```
   Open the printed URL in a browser.

5. Clean up when done:
```bash
   kubectl delete -f k8s/
   minikube stop
```

## Folder Structure
.
├── answers.md
├── k8s
│   ├── api-deployment.yaml
│   ├── api-service.yaml
│   ├── broken-pod.yaml
│   ├── cache-deployment.yaml
│   ├── cache-service.yaml
│   ├── deployment-frontend.yaml
│   ├── pod-frontend.yaml
│   ├── postgres-service.yaml
│   ├── postgres-statefulset.yaml
│   └── service-frontend.yaml
├── README.md
└── screenshots
    ├── task1.1.png
    ├── task2.1.png
    └── ...
## Key Concepts Demonstrated

- **Self-healing:** Deleting a pod in a Deployment triggers automatic recreation to match the desired replica count.
- **Scaling:** `kubectl scale` adjusts replica count independently per tier without affecting other tiers.
- **Rolling updates & rollback:** `kubectl set image` performs a gradual, zero-downtime update; `kubectl rollout undo` reverts safely.
- **Persistent storage:** The database tier uses a StatefulSet + PersistentVolumeClaim so data survives pod deletion/recreation, unlike a stateless Deployment.
- **Service discovery:** Internal services (api-service, cache-service, postgres-service) are reachable by DNS name from within the cluster.

## Notes

All screenshots correspond to the numbered tasks (Task 1.1 through Task 10.1) as specified in the lab sheet. Checkpoint question answers are in `answers.md`.
