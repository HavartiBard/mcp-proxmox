FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY index.js ./

ENV NODE_ENV=production
ENV PROXMOX_MCP_TRANSPORT=streamable-http
ENV PROXMOX_MCP_HOST=0.0.0.0
ENV PROXMOX_MCP_PORT=6971

EXPOSE 6971

CMD ["node", "index.js"]
