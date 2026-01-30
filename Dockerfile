FROM ubuntu:22.04

# Non Interactive install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies on the system
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Installer Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Openclaw installer (global)
RUN npm install -g openclaw

# Copy scripts and change owner for auto-approve entrypoint
COPY --chown=openclaw:openclaw auto-approve.js /home/openclaw/
COPY --chown=openclaw:openclaw entrypoint.sh /home/openclaw/

# Add openclaw to users
RUN useradd -m -s /bin/bash openclaw

# Changing permissions for directories
RUN mkdir -p /home/openclaw/.openclaw /home/openclaw/workspace && \
    chown -R openclaw:openclaw /home/openclaw && \
    chmod +x /home/openclaw/entrypoint.sh

# allowInsecureAuth
RUN echo '{"gateway":{"controlUi":{"enabled":true,"allowInsecureAuth":true}},"messages":{"ackReactionScope":"group-mentions"},"agents":{"defaults":{"maxConcurrent":4,"subagents":{"maxConcurrent":8},"compaction":{"mode":"safeguard"}}},"plugins":{"entries":{"telegram":{"enabled":true}}}}' > /home/openclaw/.openclaw/openclaw.json && \
    chown openclaw:openclaw /home/openclaw/.openclaw/openclaw.json

USER openclaw
WORKDIR /home/openclaw

# Configure node for production
ENV NODE_ENV=production
ENV OPENCLAW_GATEWAY_BIND=0.0.0.0

# Port for gateway
EXPOSE 18789

# Persistance volumes
VOLUME ["/home/openclaw/.openclaw", "/home/openclaw/workspace"]

# Entrypoint command
CMD ["/home/openclaw/entrypoint.sh"]
