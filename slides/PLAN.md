# Cloud Systems Lab 2026 — Course Plan

**University of Catania (UniCT)**  
Lab course (companion to the main theory course)  
10 lessons × 2 hours each — one notebook per lesson

---

## Lesson 1 — Docker ✅
**Notebook:** `Docker.ipynb`

- What is a container? Linux containers, namespaces, cgroups
- Docker architecture: daemon, CLI, registry
- Images vs containers
- Dockerfile: writing, building, layering
- Essential CLI commands (`run`, `build`, `exec`, `logs`, `rm`, `rmi`)
- Port mapping & volumes (bind mounts, named volumes)
- Docker Hub & image tagging/pushing
- Hands-on: containerise a simple Python/Node web app

---

## Lesson 2 — Composition: From Business Drivers to Docker ✅

**Notebook:** `Composition.ipynb`

### Intro framing: Gartner → MACH → Docker

- **Business motivation (Gartner lens):** why organisations need modular, composable capabilities to improve speed, resilience, and adaptability.
- **Architecture translation:** connect composable business capabilities to composable application design.
- **MACH as implementation style:** Microservices, API-first, Cloud-native, Headless
- **Docker opportunity:** containers as a practical enabler for packaging, portability, and independent service lifecycle management.

### Phase 1: Docker Compose (the “Dev” phase)

- What is Docker Compose? YAML-driven multi-container definition
- Compose application model (services, networks, volumes, configs, secrets)
- Key commands: `docker compose up -d`, `docker compose down`, `docker compose logs`

### Phase 2: Docker Swarm (the “Prod” phase) — theory only

- Clustering + high availability; Manager vs Worker roles
- Transition question: *“What happens if your laptop catches fire?”*
- `docker swarm init`, `docker node ls`, `docker service create`, `docker service scale`

### Phase 3: The Bridge (Compose in Swarm) — theory only

- **Aha moment:** Swarm deploys the same `docker-compose.yml`
- `deploy:` key for replicas and update strategy; `build:` ignored in Swarm
- `docker stack deploy -c docker-compose.yml myapp`, `docker stack ls`, `docker stack services`
- Visual: Mermaid flowchart of stack deployment across manager + 2 workers

### Hands-on: Classroom Attendance Counter (`cacca`)

- Inspired by <https://docs.docker.com/compose/gettingstarted>
- Repo: <https://github.com/unict-cloud-systems/cacca>
- Scenario: optical sensors track people entering/leaving the lab in real time
- Build locally with Compose, validate app ↔ Redis communication
- Add `deploy.replicas: 3`, deploy as a stack
- Deliverable: working `docker-compose.yml` + stack deployed as `myapp` + screenshot evidence

### Recap

- Cheat sheet: Compose / Swarm / Stack key commands

---
## Lesson 3 — Docker Swarm
**Notebook:** `Swarm.ipynb`

### Part 1 — Swarm mode 101 (single node)
- What is Swarm mode? Cluster of Docker daemons, manager/worker roles
- `docker swarm init` — bootstrap the cluster on the host
- Joining worker nodes: `join-token`, `docker swarm join`
- `docker node ls` — verify cluster state
- First service: `docker service create --name web -p 80:80 nginx`
- Inspect with `docker service ps web`

### Part 2 — Scaling out with Multipass
- Why scale? Introduce the problem of single-node limits
- **Manual setup:** `multipass launch` → `curl | sh` to install Docker → join the swarm
- **Cloud-init setup:** `cloud-init.yaml` with `docker.io` → automated provisioning at boot
- Swarm Visualizer: `dockersamples/visualizer` — real-time cluster map at `localhost:8080`
- `docker service scale web=3` — watch replicas spread across nodes in the visualizer
- Self-healing demo: `multipass stop worker1` → `docker service ps web` → replica rescheduled
- Cleanup: `docker service rm`, `docker swarm leave --force`, `multipass delete/purge`

### Part 3 — Swarm + Docker Compose = Stack
- Bridge concept: same `docker-compose.yml` from Lesson 2, now deployed to a cluster
- Setup cluster with cloud-init for both workers + swarm init + join via scripted token capture
- Compose file: `nginxdemos/hello` (shows container hostname/IP on each refresh) + visualizer
- `docker compose up` locally — `deploy:` keys ignored, 1 replica, good for dev iteration
- `docker stack deploy -c docker-compose.yml myapp` — `deploy:` keys honoured
- Inspect: `docker stack ls`, `docker stack services`, `docker stack ps`
- Refresh browser → different hostname each time → proves load balancing across 3 replicas

### ⏱ Timing note
~110 minutes if run end-to-end. **Main risk:** `multipass launch` takes 2–4 min per VM.
Mitigation options:
- Pre-launch VMs before class starts
- Or split: Part 1+2 in lesson 3, Part 3 (Stack) as opening of lesson 4

---

## Lesson 4 — Infrastructure as Code with Terraform
**Notebook:** `IaC.ipynb`

**Goal:** move from manual `multipass launch` commands to a fully declarative, version-controlled infrastructure definition using Terraform — first locally with Multipass, then on a real cloud (AWS).

### Part 1 — The IaC Problem Statement
- Recap lesson 3: we typed `multipass launch`, `docker swarm init`, `docker swarm join` by hand
- Problems: not reproducible, not documented, error-prone, hard to share
- IaC paradigm: describe desired state in code → commit → apply → reproduce anywhere
- Declarative vs Imperative: Terraform (declare *what*) vs scripts/Ansible (describe *how*)
- Immutable infrastructure: replace, don't repair

### Part 2 — Terraform Core Concepts
- **HCL syntax:** providers, resources, data sources, variables, locals, outputs
- **Workflow:** `terraform init` → `terraform plan` → `terraform apply` → `terraform destroy`
- **State file:** records real-world resource mapping; local by default, remote for teams (S3, Terraform Cloud)
- **Provider ecosystem:** HashiCorp registry — cloud (AWS, GCP, Azure), local (Docker, Multipass, …)

### Part 3 — First VM with Terraform + Multipass (local)
- Install Terraform: `sudo snap install terraform --classic`
- Add the `lkubb/multipass` community provider
- Write `main.tf`: one `multipass_instance` resource
- Run `init` / `plan` / `apply` — watch the VM appear in `multipass list`
- Add `variables.tf` and `outputs.tf` for parametrisation
- Integrate cloud-init via `cloudinit` argument: Docker installed at boot
- Scale with `count`: manager + N workers from a single resource block

### Hands-on: Multipass Swarm with Terraform
- `cacca/terraform/` directory used throughout
- `tofu init && tofu plan && tofu apply` → manager + 2 workers + Swarm bootstrapped
- Verify: `multipass list`, `multipass exec manager -- docker node ls`
- Transfer compose file, set `MANAGER_IP`, deploy CACCA stack
- `tofu destroy` — all VMs gone, no state drift

> AWS and CloudFormation are covered in **Lesson 5**

### ⏱ Timing note
- Part 1+2: ~30 min (lecture)
- Part 3 (Multipass demo): ~40 min (live coding — init/plan/apply + stack deploy)
- Hands-on: ~20 min

---

## Lesson 5 — IaC on AWS: OpenTofu + CloudFormation ✅
**Notebook:** `IaC - AWS.ipynb`

**Goal:** take the same IaC skills from Lesson 4 and apply them to a real cloud — first with OpenTofu (provider swap only), then contrast with AWS-native CloudFormation.

### Setup
- **AWS Academy Lab:** Module 11 — Automating Your Architecture
  - URL: <https://awsacademy.instructure.com/courses/163301/assignments/1951546>
  - Start the lab → copy credentials from *AWS Details* panel → `aws configure`
- **SSH key:** AWS Academy pre-creates key pair named `vockey`; download `labsuser.pem` → `chmod 600`
- **Region:** `us-east-1` (key pairs and AMIs are region-scoped)

### Part 1 — OpenTofu on AWS
- Recap: the **only change** from Lesson 4 is the provider block — `larstobi/multipass` → `hashicorp/aws`
- `providers.tf`: `hashicorp/aws ~> 5.0`, region via variable
- `data "aws_ami"` — look up the latest Ubuntu 24.04 AMI dynamically (owners: `099720109477`)
- `aws_security_group` — SSH (port 22) inbound only; Academy role blocks `AuthorizeSecurityGroupEgress` so no explicit egress block needed
- `aws_instance`: `instance_type = "t2.micro"` (Free Tier), `key_name = var.key_pair_name`
- `outputs.tf` → `instance_public_ip`, ready-to-copy `ssh_command`, `aws ec2 describe-instances` CLI snippet
- Lab directory: `lab-2026/lab/aws-opentofu/`
- ⚠️ **Academy IAM restrictions:** `ec2:ImportKeyPair` blocked — use the pre-created `vockey` key pair, not Terraform-managed keys

### Part 2 — AWS CloudFormation
- What is CloudFormation? AWS-native, declarative IaC — YAML templates
- Concepts: **Template** → **Stack** → **Resources**; Parameters, Outputs, change sets
- Same EC2 instance as Part 1 in `stack.yaml`:
  - `AWS::EC2::SecurityGroup` (SSH ingress only — egress managed by AWS default)
  - `AWS::EC2::Instance` with `!Ref`, `!GetAtt`, `!Sub` intrinsic functions
  - `Parameters`: `InstanceType`, `KeyPairName`, `UbuntuAMI` (plain `AWS::EC2::Image::Id`)
  - `Outputs`: public IP, SSH command, describe-instances CLI
- AMI lookup: cannot use `AWS::SSM::Parameter::Value` (Academy blocks SSM parameter access for Canonical path) → `deploy.sh` resolves AMI via `aws ec2 describe-images` and passes with `--parameter-overrides`
- `deploy.sh` / `destroy.sh` for CLI workflow
- Lab directory: `lab-2026/lab/aws-cloudformation/`

### Comparison: OpenTofu vs CloudFormation

| Concept | OpenTofu (HCL) | CloudFormation (YAML) |
|---|---|---|
| Language | HCL | YAML / JSON |
| Multi-cloud | ✅ | ❌ AWS only |
| Input variables | `variables.tf` | `Parameters` |
| AMI lookup | `data "aws_ami"` (dynamic) | Parameter + CLI pre-lookup |
| Security group | `resource "aws_security_group"` | `AWS::EC2::SecurityGroup` |
| EC2 instance | `resource "aws_instance"` | `AWS::EC2::Instance` |
| Cross-resource ref | `resource_type.name.attr` | `!GetAtt`, `!Ref` |
| String interpolation | `"${var.x}"` | `!Sub "${Resource.Attr}"` |
| State tracking | `terraform.tfstate` | Managed by CloudFormation service |
| Dry run | `tofu plan` | Change sets |
| Deploy | `tofu apply` | `aws cloudformation deploy` |
| Destroy | `tofu destroy` | `aws cloudformation delete-stack` |

### Hands-on: Same EC2 instance, two tools
- **OpenTofu:** `cd lab-2026/lab/aws-opentofu && tofu init && tofu apply` → SSH in → `tofu destroy`
- **CloudFormation:** `cd lab-2026/lab/aws-cloudformation && ./deploy.sh` → SSH in → `./destroy.sh`

### ⏱ Timing note
- Setup + credentials: ~10 min (pre-configure before class starts)
- Part 1 (OpenTofu AWS): ~30 min (live coding)
- Part 2 (CloudFormation): ~30 min (lecture + demo)
- Hands-on: ~20 min
- ⚠️ Emphasise `destroy` — AWS charges per second even on Academy credits

---

## Lesson 6 — Configuration Management with Ansible
**Notebook:** `Ansible.ipynb` *(to be created)*

**Goal:** we have VMs (from Terraform). Now configure them — install Docker, form a Swarm, deploy the CACCA stack — in a reproducible, agentless way using Ansible.

### Part 1 — Why Ansible? IaC vs CM
- Terraform creates *infrastructure* (VMs, networks, storage)
- Ansible configures *what runs inside* (packages, services, app deployment)
- Agentless: communicates over SSH — nothing to install on nodes
- Idempotent playbooks: run multiple times, always converge to desired state

### Part 2 — Ansible Core Concepts
- **Inventory:** list of hosts (static file or dynamic from Terraform outputs)
- **Playbook:** ordered list of plays; each play targets hosts and runs tasks
- **Modules:** `apt`, `service`, `user`, `shell`, `copy`, `docker_swarm`, …
- **Roles:** reusable, shareable playbook units (e.g. `geerlingguy.docker`)

### Part 3 — Install Docker with Ansible
- Write an inventory file from Multipass/EC2 IPs
- Playbook: `apt` module to install `docker.io`, `service` to start/enable it, `user` to add to group
- Compare with cloud-init: Ansible is re-runnable post-boot, cloud-init runs only once

### Part 4 — Bootstrap a Docker Swarm with Ansible
- Task: `docker swarm init` on manager via `community.docker.docker_swarm` module
- Capture join-token fact; loop over workers with `docker swarm join`
- Compare with Lesson 4's `null_resource` provisioner — same outcome, cleaner separation

### Hands-on: CACCA on a Terraform + Ansible Cluster
- `terraform apply` → VMs (Multipass or AWS) with Docker
- `ansible-playbook swarm.yml` → Swarm formed
- `ansible-playbook cacca.yml` → stack deployed via `docker stack deploy`
- Full teardown: `ansible-playbook teardown.yml` + `terraform destroy`

### ⏱ Timing note
- Part 1+2: ~30 min (lecture)
- Part 3+4: ~40 min (live coding — pre-warm VMs before class)
- Hands-on: ~20 min

---

## Lesson 7 — CI/CD & GitOps: Gitea Actions, AWS CodePipeline & GitHub Actions
**Notebook:** `CICD.ipynb`

**Goal:** automate `tofu apply` and `ansible-playbook` from a `git push` — pipelines replace manual execution. Cover three tools in pedagogical order: Gitea Actions first (self-hosted, local, no cloud account), then AWS CodePipeline (enterprise/AWS-native), then GitHub Actions (cloud SaaS, reference).

**Key security takeaway:** Never commit secrets or `terraform.tfstate`; use Pipeline Secrets and a remote S3 backend.

### Part 1 — GitOps Concepts
- Why CI/CD? Manual `tofu apply` / `ansible-playbook` doesn't scale — state drift, no audit trail, credential sprawl
- **CI:** every commit → automated plan/build/test → fast feedback
- **CD:** validated artefacts automatically promoted to staging/production
- Pipeline anatomy: **trigger → plan → apply → configure → notify**
- **GitOps pattern:** Git is the single source of truth; merge to `main` → pipeline applies changes; rollback = `git revert`
- Security golden rules: no secrets in repo, no state file in repo, least-privilege credentials, protect default branch

### Part 2 — Gitea Actions (hands-on first)
- **Why start here:** self-hosted, no cloud account, same YAML syntax as GitHub Actions, runs in Docker Compose
- **Gitea:** lightweight GitHub alternative (~300 MB RAM), repos + issues + PRs + Gitea Actions
- Deploy with Docker Compose: `gitea` service (port 3000) + `act_runner` service (mounts `docker.sock`)
- Register runner: generate token in Gitea UI → set `RUNNER_TOKEN` in `.env` → `docker compose up -d runner`
- Workflow YAML anatomy — identical to GitHub Actions; differences: `.gitea/workflows/`, `gitea.sha`, `gitea.actor`

**Lab 1 — Automate OpenTofu:**
- `.gitea/workflows/infra.yml` triggered on push to `infra/**`
- Steps: `actions/checkout`, `opentofu/setup-opentofu`, write AWS credentials from Gitea Secrets, `tofu init` with S3 backend, `tofu plan`, `tofu apply`
- Gitea Secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `TF_STATE_BUCKET`

**Lab 2 — Automate Ansible:**
- `.gitea/workflows/configure.yml` triggered on push to `ansible/**` or via `workflow_run` after infra pipeline
- Steps: install Ansible, write SSH private key from secret, `ansible-playbook install_docker.yml`
- Gitea Secrets: `SSH_PRIVATE_KEY`, `SERVER_IP`

- Chaining: `infra` → `configure` → `deploy` using `workflow_run: completed`

### Part 3 — GitHub Actions (cloud SaaS, same syntax)
- Only change from Gitea: `.github/workflows/` instead of `.gitea/workflows/`, `github.sha` instead of `gitea.sha`
- **OIDC:** short-lived tokens, no static access keys — `aws-actions/configure-aws-credentials` + IAM Role with trust policy
- Environments + protection rules: staging → production gate with required reviewers; branch protection prevents direct push to `main`

### Part 4 — AWS CodePipeline (enterprise)
- Three services: **CodeCommit** (Git), **CodeBuild** (runner), **CodePipeline** (orchestrator)
- `buildspec.yml`: `phases` (install, pre_build, build, post_build) — installs OpenTofu + Ansible, runs both
- Secrets via **SSM Parameter Store** — no env vars for AWS API calls; pipeline uses an **IAM Role** (strongest security model)
- The pipeline itself defined as a CloudFormation stack — "IaC all the way down"

### Comparison

| Feature | Gitea Actions | AWS CodePipeline | GitHub Actions |
|---|---|---|---|
| Hosting | Self-hosted | AWS SaaS | GitHub SaaS |
| Config | `.gitea/workflows/` | `buildspec.yml` | `.github/workflows/` |
| Syntax | GitHub-compatible | AWS-specific | GitHub Actions |
| Credentials | Secrets → env vars | IAM Role (no keys) | Secrets or OIDC |
| Cost | Free | Per pipeline + per minute | Free (public / 2000 min) |
| Air-gapped | ✅ | ❌ | ❌ |

### Hands-on
- Spin up Gitea locally (`docker compose up -d`), complete setup wizard, register runner
- Add `.gitea/workflows/infra.yml` — push a change to `infra/` → watch `tofu apply` run in the UI
- Add `.gitea/workflows/configure.yml` — chain it after the infra workflow → Ansible configures the freshly provisioned VM

### ⏱ Timing note
- Part 1 (concepts + GitOps): ~15 min
- Part 2 (Gitea — setup + Lab 1 + Lab 2): ~45 min (pre-pull Docker images before class)
- Part 3 (CodePipeline): ~20 min (demo)
- Part 4 (GitHub Actions): ~10 min (diff from Gitea, OIDC concept)
- Hands-on: ~20 min
---

## Lessons 8–10 — TBD

> Programme to be defined.
