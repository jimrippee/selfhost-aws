# Vaultwarden with Entra ID SSO via OAuth2-Proxy and Traefik

This Docker Compose stack securely hosts [Vaultwarden](https://github.com/dani-garcia/vaultwarden) with Microsoft Entra ID (Azure AD) single sign-on (SSO), protected by [OAuth2-Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) and [Traefik v3](https://doc.traefik.io/traefik/).  

Traefik provides HTTPS termination and routes public domains to the appropriate services. OAuth2-Proxy handles OIDC-based authentication with Microsoft Entra ID and protects Vaultwarden behind a ForwardAuth middleware.

---

## 🔧 Stack Overview

| Service       | Domain                      | Description                                |
|---------------|-----------------------------|--------------------------------------------|
| Traefik       | `vault.rippee.cloud`        | Reverse proxy and TLS termination          |
| Vaultwarden   | `vault.rippee.cloud`        | Self-hosted password manager               |
| OAuth2-Proxy  | `vault-auth.rippee.cloud`   | OIDC auth layer using Microsoft Entra ID   |

All services are reverse-proxied by Traefik and secured using automatic Let's Encrypt TLS certificates.

---

## 📁 Directory Layout

```
.
├── docker-compose.yml
├── .env              # Required runtime secrets and config
├── .env.example      # Safe template for sharing
└── data/             # Vaultwarden and Traefik persistent volumes
    ├── vaultwarden/
    └── traefik/
```

---

## 🔐 Microsoft Entra ID Setup (OAuth2-Proxy)

To use Microsoft Entra ID (Azure AD) as your identity provider:

### 1. **Register an App in Microsoft Entra**

1. Go to [Azure Portal → App registrations](https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps/ApplicationsListBlade)
2. Click **"New registration"**
3. **Name:** `Vaultwarden SSO`
4. **Supported account types:** Single tenant (or as needed)
5. **Redirect URI:**  
   - Type: *Web*  
   - URI: `https://vault-auth.rippee.cloud/oauth2/callback`
6. Click **Register**

---

### 2. **Configure App Settings**

In the newly created app:

#### ✔️ **Certificates & Secrets**
- Create a new **client secret**
- Save the value (you’ll use it in your `.env` file)

#### ✔️ **API Permissions**
- Add: `Microsoft Graph → openid`, `email`, `profile`, `offline_access`
- Click **Grant admin consent**

#### ✔️ **Expose an API** *(Optional if you use groups)*

If you want to control access based on group membership:
- Add optional claims under **Token configuration**:
  - `groups`
  - `email`
  - `preferred_username`

---

### 3. **Set Required `.env` Variables**

Update your `.env` with values from Entra:

```dotenv
OAUTH2_PROXY_PROVIDER=oidc
OAUTH2_PROXY_CLIENT_ID=<your-app-client-id>
OAUTH2_PROXY_CLIENT_SECRET=<your-client-secret>
OAUTH2_PROXY_COOKIE_SECRET=<random-base64-32-bytes>
OAUTH2_PROXY_OIDC_ISSUER_URL=https://login.microsoftonline.com/<tenant-id>/v2.0
OAUTH2_PROXY_EMAIL_DOMAINS=*
ACME_EMAIL=you@example.com

AUTH_DOMAIN=vault-auth.rippee.cloud
VAULT_DOMAIN=vault.rippee.cloud
```

Use a generator like this to create your `COOKIE_SECRET`:

```bash
python3 -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(32)).decode())'
```

---

## 🚀 Deployment

1. Clone the repo  
2. Copy `.env.example` to `.env` and fill in required values  
3. Ensure `vault.rippee.cloud` and `vault-auth.rippee.cloud` DNS records point to your host  
4. Run:

```bash
docker compose up -d
```

Traefik will automatically generate TLS certificates using Let's Encrypt.

---

## 🔒 Access Control

Only users in your Entra ID tenant (and optionally those in specific groups) can access Vaultwarden. Access is controlled entirely by Microsoft Entra and OAuth2-Proxy.

---

## ✅ Notes

- The Traefik dashboard is disabled for security.
- `vault.rippee.cloud` is protected by forward authentication to `vault-auth.rippee.cloud`.
- Traefik uses ACME TLS challenge to automatically fetch HTTPS certificates.

---

## 📌 Security Best Practices

- Store your `.env` securely and never commit it to version control
- Use secure DNS (e.g., Cloudflare) and lock down IP access if needed
- Regularly rotate your Azure client secrets

---

## 📞 Support

For issues or questions, file a GitHub issue or open a discussion.

---