# ☁️ Self-Hosted Virtual Server (AWS) Deployment

This project automates the deployment of a secure, containerized personal server on AWS using Terraform, Docker, and GitHub Actions. It includes self-hosted applications such as Joplin Server, Vaultwarden, and Authentik, with built-in monitoring, backups, and disaster recovery.

---

## 🛠️ Features

- **Infrastructure as Code**: Deploys AWS EC2 (t3a.small) instance via Terraform
- **Custom AMI**: Built with Packer, includes Docker, SSM Agent, Vector, Wazuh, and Tailscale
- **Containerized Apps**: Managed via Docker Compose
- **Security**: Tailscale, Authentik (SSO), UFW firewall with Wazuh agent
- **Backup**: Automated daily backups to S3 with lifecycle rules
- **Monitoring**: Logs + metrics to Graylog via Vector
- **Automation**: GitHub Actions handles build, deployment, and DR

---

## 📦 Applications Deployed

| Application   | Description                     |
|---------------|---------------------------------|
| Joplin Server | Note-taking and synchronization |
| Vaultwarden   | Password manager                |
| Authentik     | Authentication + proxy manager  |
| Watchtower    | Auto-updates containers weekly  |

---

## 🔁 Backup & Monitoring

- Daily full backups to S3 with weekly rollup
- Pre-backup health check and MS Teams notifications
- Wazuh + Vector log forwarding (incl. firewall logs)
- Host and container uptime monitoring (via Vector)

---

## 🔐 Security

- Docker container isolation
- Reverse proxy with Authentik and HTTPS
- Auto-patching and weekly reboot (Sunday @ 3:00 AM)
- Firewall with UFW and AWS Security Groups
- Host logs, Docker logs, and system metrics forwarded securely over Tailscale

---

## 🚀 Automation Flow

1. **Build AMI** → Trigger Packer via GitHub Actions
2. **Deploy Infra** → Terraform deploys EC2 instance
3. **Container Startup** → Docker Compose runs apps with systemd fallback
4. **Post-Deployment** → MS Teams webhook confirms status

---

## 🧪 Disaster Recovery

- Restore from backup via GitHub Actions (`workflow_dispatch`)
- Logs & alerts sent via webhook
- Recovery process tested without affecting production

---

## 📁 Repository Structure

.
├── ami/
│ └── packer-template.json # Packer AMI definition
├── terraform/
│ └── main.tf # Terraform infra setup
├── compose/
│ └── docker-compose.yml # App containers
├── systemd/
│ └── joplin.service # systemd fallback units
├── .github/
│ └── workflows/
│ ├── ami.yml # Build AMI
│ ├── deploy.yml # Infra + app deploy
│ └── restore.yml # Disaster recovery
├── scripts/
│ └── backup.sh # Backup script
│ └── health_check.sh # Optional pre-backup checks
└── README.md


---

## 📋 Requirements

- AWS Account with access keys or IAM role
- GitHub repository (public or private)
- Docker Hub or GitHub Container Registry (if needed)
- S3 bucket for backups
- MS Teams webhook for alerts

---

## 🧭 Setup Instructions

1. **Fork or Clone this Repo**
2. **Create AWS Access Credentials**  
   Store in GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. **Create GitHub Secrets**:
   - `TF_VAR_region` (e.g., `us-west-2`)
   - `TAILSCALE_AUTHKEY`
   - `MS_TEAMS_WEBHOOK`
4. **Set Up S3 Bucket & Lifecycle Rules**
5. **Configure MS Teams Webhook**
6. **Push to Trigger GitHub Actions**  
   - AMI Build: manually via `workflow_dispatch`
   - Terraform Deploy: triggered on push or manually
   - Backup/Restore: run manually or scheduled

---

## 📄 License

MIT
