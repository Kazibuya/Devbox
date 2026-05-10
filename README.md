# devbox

A disposable Ubuntu 22.04 development box on AWS EC2, provisioned with Terraform and orchestrated with Taskfile. Spin it up in minutes, destroy it when you're done.

Originally built for 42 school students to test Ansible roles with full sudo access — started as a molecule environment, now used as a full remote dev box instead of a local VM.

---

## What's inside

Each devbox comes pre-installed with:

- **Shell**: zsh + oh-my-zsh
- **Containers**: podman
- **Dev tools**: git, curl, vim (supravim), python3
- **Ansible**: ansible + molecule + molecule-plugins
- **Custom**: suprapack + supravim (personal vim config)
- A fresh SSH ed25519 key generated on the instance (for GitHub access)

---

## Prerequisites

Make sure the following tools are installed on your machine before using this project:

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with valid credentials (`aws configure`)
- [Task](https://taskfile.dev/installation/) >= 3.0

> `task` itself is not checked at runtime — if you can run `task check`, you already have it.

---

## Quick start

```bash
# 1. Clone the repo
git clone <your-repo-url>
cd devbox

# 2. Generate your dedicated SSH key (once)
task keygen

# 3. Deploy
task up

# 4. Connect
task ssh

# 5. Destroy when done
task down
```

On first `task up`, you will be prompted for:

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `eu-north-1` | AWS region to deploy into |
| `instance_type` | `t3.small` | EC2 instance type (see below) |
| `public_key_path` | `~/.ssh/devbox.pub` | Path to your SSH public key |
| `project_name` | *(required)* | Unique name prefix for AWS resources |
| `git_email` | *(required)* | Your git email |
| `git_name` | *(required)* | Your git name |

Your answers are saved in `src/terraform.tfvars` (gitignored) and reused on subsequent runs. Your public IP is always fetched automatically.

### Instance type examples

| Instance | vCPU | RAM | $/hour | Use case |
|---|---|---|---|---|
| `t3.micro` | 2 | 1GB | ~$0.010 | Minimal, light testing |
| `t3.small` | 2 | 2GB | ~$0.021 | Default, comfortable for most projects |
| `t3.medium` | 2 | 4GB | ~$0.042 | Heavier workloads, multiple containers |
| `t3.large` | 2 | 8GB | ~$0.083 | ELK, heavy Ansible roles |

> **ARM users**: if you pick a `t4g.*` (Graviton) instance, you must update the AMI filter in `src/main.tf`:
> ```hcl
> values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
> ```

---

## Tasks

| Task | Description |
|---|---|
| `task check` | Verify that required tools are installed |
| `task keygen` | Generate `~/.ssh/devbox` + `~/.ssh/devbox.pub` |
| `task tfvars` | Interactively create/update `src/terraform.tfvars` |
| `task up` | Run `check` → `tfvars` → `terraform init` (if needed) → `terraform apply` |
| `task down` | Destroy all AWS resources with `terraform destroy` |
| `task ssh` | Connect to the running instance |

---

## Project structure

```
devbox/
├── Taskfile.yml          # Task orchestration
├── README.md
└── src/
    ├── main.tf           # VPC, subnet, IGW, security group, EC2
    ├── variables.tf      # Input variables
    ├── outputs.tf        # SSH command output
    ├── versions.tf       # Terraform + AWS provider versions
    ├── user_data.sh.tpl  # Boot script (templatefile)
    └── terraform.tfvars  # Your local config (gitignored)
```

---

## AWS resources created

- VPC (`10.0.0.0/16`) + public subnet + internet gateway + route table
- Security group: SSH (port 22) restricted to your current public IP
- EC2 instance: Ubuntu 22.04, `t3.small` (default), `eu-north-1` (default)
- EBS root volume: default AMI size (8GB `gp2`) — override with `root_block_device` if needed

---

## Customizing your boot script

The `src/user_data.sh.tpl` file is your boot script — it runs once when the instance starts. The provided template is the author's personal setup (zsh, supravim, podman, ansible, molecule).

**You are expected to bring your own.** The only contract is that the template receives two variables from Terraform:

- `${git_name}` — your git username
- `${git_email}` — your git email

Everything else is up to you. The provided `user_data.sh.tpl` is just an example.

---

## Cost

A `t3.small` in `eu-north-1` costs ~$0.021/hour. A typical day of work (8h) costs ~$0.17. Always run `task down` at the end of your session.
