# Project Roadmap

## Purpose

This document records the implementation journey of the Kubernetes Reliability Lab.

The roadmap is retained as a historical record of the project progression from local Kubernetes fundamentals to production-style Amazon EKS deployment.

---

# Phase 1 — Application Foundation

## Step 1 — Repository Bootstrap

Completed

- Repository creation
- Project structure
- Makefile
- Documentation framework

## Step 2 — Create Application

Completed

- Python application
- Health endpoints
- Configuration model

## Step 3 — Containerise Application

Completed

- Dockerfile
- Container image
- Local image validation

---

# Phase 2 — Kubernetes Fundamentals

## Step 4 — Create Local kind Cluster

Completed

## Step 5 — Load Image into kind

Completed

## Step 6 — Create Namespace

Completed

## Step 7 — Create Deployment

Completed

## Step 8 — Create Service

Completed

---

# Phase 3 — Reliability Foundations

## Step 9 — ConfigMap

Completed

## Step 10 — Secret

Completed

## Step 11 — PodDisruptionBudget

Completed

## Step 12 — HorizontalPodAutoscaler

Completed

## Step 13 — NetworkPolicy

Completed

---

# Phase 4 — Helm

## Step 14 — Create Helm Chart

Completed

---

# Phase 5 — Observability

## Step 15 — Install Prometheus and Grafana

Completed

## Step 16 — Add Alerts

Completed

---

# Phase 6 — Reliability Engineering

## Step 17 — Kill a Pod

Completed

## Step 18 — Bad Rollout

Completed

## Step 19 — CPU Spike and HPA

Completed

## Step 20 — Node Drain

Completed

## Step 21 — Reliability Review

Completed

---

# Phase 7 — AWS Infrastructure

## Terraform VPC

Completed

## Terraform EKS Cluster

Completed

## Amazon ECR

Completed

## EKS Deployment

Completed

---

# Phase 8 — Production-Style Exposure

## AWS Load Balancer Controller

Completed

## ALB Ingress

Completed

## EKS Monitoring Validation

Completed

---

# Current Phase

Production Hardening

Planned:

- HTTPS with ACM
- Optional Route 53 DNS
- Cost optimisation
- Additional observability improvements

---

# Progression

```txt
Python Application
        ↓
Docker
        ↓
kind
        ↓
Kubernetes Fundamentals
        ↓
Helm
        ↓
Observability
        ↓
Reliability Engineering
        ↓
Terraform
        ↓
Amazon EKS
        ↓
Amazon ECR
        ↓
ALB Ingress
        ↓
Production Hardening
```
