FROM node:20-bookworm-slim
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/

RUN apt update && apt install --yes --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    unzip \
    dumb-init \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo \
         "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
         "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
         tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update \
    && apt --yes --no-install-recommends install \
         docker-ce-cli \
         docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/* \
    && npm install pnpm -g \
    && pnpm install -g tsx

# ensures that /var/run/docker.sock exists
# changes the ownership of /var/run/docker.sock
RUN touch /var/run/docker.sock && chown node:node /var/run/docker.sock

# Full Base Image
# MariaDB, Chromium and fonts
#FROM base-slim AS base
#ENV DOCKGE_ENABLE_EMBEDDED_MARIADB=1
#RUN apt update && \
#   apt --yes --no-install-recommends install mariadb-server && \
#   rm -rf /var/lib/apt/lists/* && \
#   apt --yes autoremove