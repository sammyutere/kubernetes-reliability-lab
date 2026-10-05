# Final GitOps Workflow

```mermaid
flowchart TD

    CHANGE["Application / Configuration Change"]
    BUILD["Build Container Images"]
    ECR["Push to Amazon ECR"]
    SBOM["Generate SBOM"]
    SCAN["Generate Grype Scan"]
    SIGN["Sign with Cosign"]
    GATE{"Deployment Trust Gate"}
    BLOCK["BLOCK PROMOTION"]
    VALUES["Update Helm Desired State"]
    REVIEW["Review Git Diff"]
    COMMIT["Commit Approved Change"]
    MAIN["Push / Merge to main"]
    ARGO["Argo CD Detects Revision"]
    HELM["Render Helm Chart"]
    DIFF["Compare Desired vs Live State"]
    API["Submit to Kubernetes API"]
    POLICY{"Kyverno Admission"}
    DEPLOY["Rolling Deployment"]
    OBSERVE["Prometheus / Grafana"]
    HEALTH{"Synced + Healthy?"}
    INCIDENT["Investigate Events / Capacity / Runtime"]
    EVIDENCE["Capture Deployment Evidence"]

    CHANGE --> BUILD
    BUILD --> ECR
    ECR --> SBOM
    SBOM --> SCAN
    SCAN --> SIGN
    SIGN --> GATE
    GATE -->|"Fail"| BLOCK
    GATE -->|"Pass"| VALUES
    VALUES --> REVIEW
    REVIEW --> COMMIT
    COMMIT --> MAIN
    MAIN --> ARGO
    ARGO --> HELM
    HELM --> DIFF
    DIFF --> API
    API --> POLICY
    POLICY -->|"Denied"| INCIDENT
    POLICY -->|"Allowed"| DEPLOY
    DEPLOY --> OBSERVE
    OBSERVE --> HEALTH
    HEALTH -->|"Yes"| EVIDENCE
    HEALTH -->|"No"| INCIDENT
    INCIDENT -->|"Correct Git or Infrastructure"| MAIN
```

## Final Control Model

The completed platform separates four decisions:

1. **Is the image trusted?** — deployment trust gate.
2. **Is the desired configuration approved?** — Git.
3. **Should the cluster converge to that state?** — Argo CD.
4. **Is the requested Kubernetes object permitted?** — Kyverno.

No single control substitutes for another.
