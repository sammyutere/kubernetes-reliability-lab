# Final Platform Architecture

```mermaid
flowchart TB

    DEV["Platform / SRE Engineer"]

    subgraph SOURCE["Source and Release Control"]
        GIT["GitHub Repository"]
        TRUST["Deployment Trust Gate<br/>Cosign + Grype + SBOM"]
    end

    subgraph AWS["AWS"]
        ECR["Amazon ECR"]

        subgraph VPC["Terraform-Managed VPC"]
            EKS["Amazon EKS<br/>reliability-lab-dev"]

            subgraph APP["reliability-lab namespace"]
                FE["Frontend<br/>2 replicas"]
                API["API<br/>2 replicas"]
                DEP["Dependency<br/>2 replicas"]
                SM["ServiceMonitors"]
            end

            subgraph ARGO["argocd namespace"]
                ROOT["Root Bootstrap Application"]
                PROJECT["reliability-platform AppProject"]
                CHILD["multi-service-app"]
                CONTROLLER["Argo CD Application Controller"]
            end

            subgraph POLICY["kyverno namespace"]
                KYVERNO["Kyverno"]
                KP["ClusterPolicies"]
            end

            subgraph OBS["monitoring namespace"]
                PROM["Prometheus"]
                GRAF["Grafana"]
                ALERT["Alertmanager"]
                OP["Prometheus Operator"]
            end
        end
    end

    DEV -->|"terraform apply"| EKS
    DEV -->|"build / scan / sign"| ECR
    ECR --> TRUST
    TRUST -->|"approved release"| GIT
    GIT --> ROOT
    ROOT --> PROJECT
    ROOT --> CHILD
    CHILD --> CONTROLLER
    CONTROLLER -->|"Helm desired state"| EKS
    EKS -->|"Admission request"| KYVERNO
    KP --> KYVERNO
    KYVERNO -->|"Allow / Deny"| EKS
    EKS --> FE
    EKS --> API
    EKS --> DEP
    FE --> API
    API --> DEP
    FE --> SM
    API --> SM
    DEP --> SM
    SM --> OP
    OP --> PROM
    PROM --> GRAF
    PROM --> ALERT
    ECR --> FE
    ECR --> API
    ECR --> DEP
```

## Responsibility Boundaries

| Component | Responsibility |
|---|---|
| Terraform | AWS and EKS infrastructure |
| Git | Approved desired state |
| Helm | Kubernetes manifest rendering |
| Argo CD | Continuous reconciliation |
| Kyverno | Admission governance |
| Cosign | Image signature verification |
| Grype | Vulnerability evidence |
| Syft/CycloneDX | SBOM evidence |
| Prometheus | Metrics and alert evaluation |
| Grafana | Operational visualisation |
| Alertmanager | Alert routing |
| EKS | Workload runtime |

## Final Capacity State

During final evidence capture the EKS managed node group contained four `t3.medium` workers.

The fourth worker was added after a trusted release exposed insufficient Pod scheduling headroom during RollingUpdate.
