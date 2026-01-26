# Clawdbot Docker (Ubuntu)

Ubuntu-based Docker container to run [Clawdbot](https://clawd.bot/) - an open-source personal AI assistant.

## What is Clawdbot?

**Clawdbot** is an open-source personal AI assistant that enables you to interact with advanced language models (LLMs) through multiple communication platforms. With Clawdbot, you can:

- **Centralize your AI interactions**: Access Claude (Anthropic), GPT-4 (OpenAI), Gemini (Google), and other models through a single interface
- **Connect multiple platforms**: Use the same assistant on Discord, Telegram, WhatsApp, Slack, or through the web interface
- **Automate tasks**: Execute commands, manage workflows, and integrate AI into your daily tools
- **Maintain full control**: Host on your own server or Docker container, keeping privacy and data control
- **Model flexibility**: Choose between commercial APIs (Anthropic, OpenAI, OpenRouter) or local models (Ollama)

### Key Features

- **Modern Web Interface**: Intuitive dashboard with real-time conversation support
- **Multi-Provider**: Support for Discord, Telegram, WhatsApp, Slack, and web
- **Multi-Model**: Compatible with Claude, GPT-4, Gemini, Llama, DeepSeek, and more
- **WebSocket Gateway**: Real-time communication between devices and platforms
- **Auto-Device Approval**: Automatic pairing system (in this container)
- **Data Persistence**: Configurations and sessions maintained in Docker volumes
- **Simple Updates**: npm installation ensures access to the latest versions

## About this Docker Setup

This Docker configuration makes deploying Clawdbot easy in any environment, including:
- Global installation via `npm install -g clawdbot` to always get the latest version
- Simplified authentication with `allowInsecureAuth: true` (no device pairing required)
- Pre-optimized configuration with environment variables
- Persistent volumes for configurations and workspace
- Support for multiple LLM providers

## Requirements

- Docker 20.10+
- Docker Compose v2+
- 2GB RAM (4GB+ recommended for browser automation)
- 20GB storage

## Quick Start

```bash
# 1. Clone the repository
git clone <your-repo> clawdbot && cd clawdbot

# 2. Configure environment variables
cp .env.example .env

# 3. Generate a secure gateway token
openssl rand -hex 32 > /tmp/gateway_token.txt
# Copy the token and add it to .env: CLAWDBOT_GATEWAY_TOKEN=<token>

# 4. Edit .env and add your API keys (at least one LLM provider)
# - CLAWDBOT_GATEWAY_TOKEN (REQUIRED - from step 3)
# - ANTHROPIC_API_KEY, OPENAI_API_KEY, or OPENROUTER_API_KEY

# 5. Build and start the container
docker compose up -d --build

# 6. Get the authenticated dashboard URL
docker compose run --rm clawdbot-cli dashboard --no-open

# This will output a URL like:
# http://localhost:18789/?token=YOUR_TOKEN_HERE
# Copy and open this URL in your browser

# 7. (Optional) Run onboarding for additional setup
docker compose run --rm clawdbot-cli onboard
```

> **Important:**
> - The `CLAWDBOT_GATEWAY_TOKEN` is required for security when the gateway binds to LAN
> - You **must** access the web interface with the token in the URL (use the dashboard command above)
> - Accessing http://localhost:18789/ without the token will fail with "unauthorized"

## Project Structure

```
.
├── Dockerfile           # Ubuntu 22.04 + Node.js 22 + npm global clawdbot install
├── docker-compose.yml   # Service orchestration (gateway + CLI services)
├── auto-approve.js      # Automatic device pairing approval service
├── entrypoint.sh        # Container startup script
├── .env.example         # Environment variables template
├── .env                 # Your configuration (not committed)
├── .gitignore          # Git ignore patterns
└── README.md           # This file
```

### Key Files

- **Dockerfile**: Multi-stage build that installs Node.js, clawdbot globally via npm, sets up auto-approve, and configures the container
- **auto-approve.js**: Node.js script that watches for device pairing requests and auto-approves them instantly
- **entrypoint.sh**: Bash script that starts both the auto-approve service (background) and the clawdbot gateway (foreground)
- **docker-compose.yml**: Defines two services:
  - `clawdbot-gateway`: Main service running the gateway (always on)
  - `clawdbot-cli`: CLI service for running commands (on-demand)

### How it Works

The Dockerfile:
1. Installs Node.js 22 on Ubuntu 22.04
2. Runs `npm install -g clawdbot` to install the latest version globally
3. Creates initial configuration with `allowInsecureAuth: true` for Docker deployments
4. Configures permissions and directories
5. Starts the gateway with simplified authentication

#### Simplified Authentication for Docker

This Docker setup uses **`allowInsecureAuth: true`** configuration that eliminates device pairing requirements:

- **Token-only authentication**: Only the gateway token is required (no device pairing)
- **Docker-optimized**: Designed specifically for containerized deployments
- **Official solution**: Supported feature since Clawdbot v2026.1.24
- **Instant connection**: Web interface connects immediately with token in URL

Configuration is set via: `docker compose run --rm clawdbot-cli config set gateway.controlUi.allowInsecureAuth true`

> **Note:** The auto-approve service (`auto-approve.js`) is included as a backup mechanism but is not necessary when `allowInsecureAuth` is enabled.

## Configuration

### Environment Variables

Edit the `.env` file with your credentials:

#### Gateway Token (REQUIRED)

The gateway requires a secure authentication token when binding to LAN/network interfaces:

```env
# Generate with: openssl rand -hex 32
CLAWDBOT_GATEWAY_TOKEN=your-generated-token-here
```

This token is mandatory for security. The container will fail to start without it when using `--bind lan`.

#### LLM Provider (required - choose one)

```env
# Anthropic Claude (recommended)
ANTHROPIC_API_KEY=sk-ant-api03-...

# OR OpenAI
OPENAI_API_KEY=sk-...

# OR OpenRouter (access multiple models with a single key)
OPENROUTER_API_KEY=sk-or-v1-...
CLAWDBOT_DEFAULT_MODEL=openrouter/anthropic/claude-sonnet-4-5

# OR Ollama (local models)
OLLAMA_HOST=http://host.docker.internal:11434
```

> **Note:** Claude Code OAuth tokens were blocked for external use in Jan/2026. Use API Key instead.

#### Integrations (optional)

```env
# Discord
DISCORD_BOT_TOKEN=
DISCORD_APPLICATION_ID=

# Telegram
TELEGRAM_BOT_TOKEN=

# Slack
SLACK_BOT_TOKEN=
SLACK_APP_TOKEN=
```

## OpenRouter

[OpenRouter](https://openrouter.ai) allows you to use multiple LLM models with a single API key.

### Setup

1. Create an account at https://openrouter.ai
2. Generate an API key at https://openrouter.ai/keys
3. Add to your `.env`:

```env
# Required
OPENROUTER_API_KEY=sk-or-v1-...

# Optional - Set default model
CLAWDBOT_DEFAULT_MODEL=openrouter/anthropic/claude-sonnet-4-5
```

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENROUTER_API_KEY` | **Yes** | Your OpenRouter API key |
| `CLAWDBOT_DEFAULT_MODEL` | No | Default model (e.g., `openrouter/anthropic/claude-sonnet-4-5`) |

### Available Models

Use the format `openrouter/<provider>/<model>`:

| Model | Identifier |
|-------|------------|
| Claude Sonnet 4.5 | `openrouter/anthropic/claude-sonnet-4-5` |
| Claude Opus 4 | `openrouter/anthropic/claude-opus-4` |
| GPT-4o | `openrouter/openai/gpt-4o` |
| Gemini 2.0 | `openrouter/google/gemini-2.0-flash` |
| Llama 3.3 70B | `openrouter/meta-llama/llama-3.3-70b` |
| DeepSeek V3 | `openrouter/deepseek/deepseek-chat-v3` |

Full list: https://openrouter.ai/models

### Set Default Model via CLI

Configure in the container after onboarding:

```bash
docker compose run --rm clawdbot-cli models set openrouter/anthropic/claude-sonnet-4-5
```

## Accessing the Web Interface

The web interface requires authentication via the gateway token. With `allowInsecureAuth: true`, **no device pairing is required**.

### Recommended Access Method

1. **Get the authenticated URL** (includes token):
   ```bash
   docker compose run --rm clawdbot-cli dashboard --no-open
   ```

2. **Open the URL** in your browser:
   ```
   http://localhost:18789/?token=YOUR_GATEWAY_TOKEN
   ```

3. **Interface loads instantly** - You're ready to use Clawdbot!

### Alternative: Manual Token Entry

If you prefer, you can access without the token in the URL:

1. Open http://localhost:18789/ in your browser
2. Click on Settings (gear icon) or "Control UI Settings"
3. Paste your `CLAWDBOT_GATEWAY_TOKEN` from `.env`
4. Click Save - The interface will connect immediately

### Connection Tips

- **Clear browser cache** if you have connection issues
- **Use a fresh incognito/private window** for testing
- **Check logs** with `docker logs clawdbot` if you encounter problems
- The gateway should connect instantly with the correct token

## Monitoring and Logs

### View Logs

```bash
# Real-time logs (all services)
docker logs -f clawdbot

# Filter auto-approve logs
docker logs clawdbot | grep auto-approve

# Filter gateway logs
docker logs clawdbot | grep gateway

# View gateway log file (detailed JSON logs)
docker exec clawdbot cat /tmp/clawdbot/clawdbot-2026-01-26.log
```

### Check Service Status

```bash
# Container status
docker compose ps

# Running processes inside container
docker exec clawdbot ps aux

# Expected processes:
# - clawdbot (PID 1) - Main process
# - node /home/clawdbot/auto-approve.js (PID 7) - Auto-approve service
# - clawdbot-gateway (PID 20) - Gateway WebSocket server
```

### Verify Services Are Working

```bash
# Test HTTP endpoint
curl -I http://localhost:18789

# Check WebSocket (with token)
curl -I "http://localhost:18789/?token=YOUR_TOKEN"

# Count auto-approved devices
docker exec clawdbot sh -c 'cat /home/clawdbot/.clawdbot/devices/paired.json | grep requestId | wc -l'
```

## Useful Commands

```bash
# Restart the service
docker compose restart

# Stop everything
docker compose down

# Rebuild to get latest clawdbot version
docker compose up -d --build

# Update to latest clawdbot (rebuilds with latest npm version)
docker compose build --no-cache && docker compose up -d

# Access Clawdbot CLI
docker compose run --rm clawdbot-cli <command>

# Examples:
docker compose run --rm clawdbot-cli --version
docker compose run --rm clawdbot-cli dashboard --no-open
docker compose run --rm clawdbot-cli config
```

## Setting Up Integrations

### Discord

1. Go to https://discord.com/developers/applications
2. Create a new application
3. Go to **Bot** > **Reset Token** > copy the token
4. Enable the intents:
   - Message Content Intent
   - Server Members Intent
   - Presence Intent
5. Configure in the container:

```bash
docker compose run --rm clawdbot-cli providers add --provider discord --token YOUR_TOKEN
```

6. Invite the bot to your server using the OAuth2 URL Generator

### Telegram

1. Chat with [@BotFather](https://t.me/BotFather) on Telegram
2. Send `/newbot` and follow the instructions
3. Copy the generated token
4. Configure in the container:

```bash
docker compose run --rm clawdbot-cli providers add --provider telegram --token YOUR_TOKEN
```

### WhatsApp

1. Configure in the container:

```bash
docker compose run --rm clawdbot-cli providers add --provider whatsapp
```

2. Scan the QR Code that appears in the terminal
3. Session is automatically saved to `/home/clawdbot/.clawdbot/whatsapp`

### Slack

1. Go to https://api.slack.com/apps and create an app
2. In **OAuth & Permissions**, add the scopes:
   - `chat:write`
   - `channels:history`
   - `channels:read`
   - `users:read`
3. Install the app in your workspace
4. Configure in the container:

```bash
docker compose run --rm clawdbot-cli providers add \
  --provider slack \
  --bot-token xoxb-... \
  --app-token xapp-...
```

## Volumes and Persistence

| Volume | Container Path | Description |
|--------|----------------|-------------|
| `clawdbot-config` | `/home/clawdbot/.clawdbot` | Configuration and sessions |
| `clawdbot-workspace` | `/home/clawdbot/workspace` | Work files |

For backup:

```bash
# Export volumes
docker run --rm -v clawdbot-config:/data -v $(pwd):/backup alpine tar czf /backup/config-backup.tar.gz -C /data .

# Restore volumes
docker run --rm -v clawdbot-config:/data -v $(pwd):/backup alpine tar xzf /backup/config-backup.tar.gz -C /data
```

## Updating Clawdbot

Since the Docker image installs clawdbot via `npm install -g clawdbot`, you can update to the latest version by rebuilding:

```bash
# Rebuild the image (fetches latest npm package)
docker compose build --no-cache

# Restart with new image
docker compose up -d

# Verify new version
docker compose run --rm clawdbot-cli --version
```

## Ports

| Port | Description |
|------|-------------|
| 18789 | HTTP Gateway / Web Interface |

## Troubleshooting

### Container won't start

```bash
# Check build logs
docker compose build --no-cache

# Check container logs
docker compose logs clawdbot-gateway
```

### Web interface shows "unauthorized" or WebSocket errors

The web interface requires the gateway token in the URL. Check the logs:

```bash
docker logs clawdbot | grep -i unauthorized
```

If you see `reason=token_missing`, get the authenticated URL:

```bash
docker compose run --rm clawdbot-cli dashboard --no-open
```

Then open the URL with `?token=...` in your browser.

### Device pairing issues ("pairing required" errors)

This Docker setup uses `allowInsecureAuth: true` to eliminate device pairing. If you see pairing errors, verify the configuration:

```bash
# Check if allowInsecureAuth is enabled
docker exec clawdbot cat /home/clawdbot/.clawdbot/clawdbot.json | grep allowInsecureAuth

# Should return: "allowInsecureAuth": true
```

If not configured correctly, run:

```bash
# Set the configuration
docker compose run --rm clawdbot-cli config set gateway.controlUi.allowInsecureAuth true

# Restart to apply
docker compose restart
```

If problems persist:
1. Check logs: `docker logs clawdbot`
2. Verify token is correct in `.env`
3. Try accessing with token in URL: `http://localhost:18789/?token=YOUR_TOKEN`

### Gateway refuses to bind ("Refusing to bind gateway to lan without auth")

This error means `CLAWDBOT_GATEWAY_TOKEN` is not set. To fix:

```bash
# Generate a secure token
openssl rand -hex 32

# Add it to .env
echo "CLAWDBOT_GATEWAY_TOKEN=<generated-token>" >> .env

# Restart the container
docker compose restart
```

### Anthropic connection error

1. Verify `ANTHROPIC_API_KEY` is configured in `.env`
2. Confirm the key is valid at https://console.anthropic.com
3. Restart the container: `docker compose restart`

### Ollama won't connect

If using local Ollama, make sure:
1. Ollama is running on the host machine
2. `OLLAMA_HOST` is set to `http://host.docker.internal:11434`

### WhatsApp disconnects

The WhatsApp session may expire. Reconnect:

```bash
docker compose run --rm clawdbot-cli providers add --provider whatsapp
```

## Resources

- [Official Documentation](https://docs.clawd.bot/)
- [Clawdbot GitHub](https://github.com/clawdbot/clawdbot)
- [Community Discord](https://discord.com/invite/clawd)
- [OpenRouter Models](https://openrouter.ai/models)
- [Anthropic Console](https://console.anthropic.com)

## License

This containerization project is provided as-is. Clawdbot is an open-source project with its own license.
