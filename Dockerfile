FROM node:20-slim
RUN apt-get update -y && apt-get install -y openssl libssl-dev ca-certificates
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

COPY . .
RUN pnpm install --no-frozen-lockfile
RUN pnpm run build

# Теперь мы можем выделить Node.js больше памяти (например, 1.5 ГБ из 2 ГБ)
ENV NODE_OPTIONS="--max-old-space-size=1536"
ENV NODE_ENV production
EXPOSE 3000

# Спокойно запускаем через Turbo
CMD pnpm --filter @zero/server db:push && \
    pnpm turbo run start --filter=@zero/server --filter=@zero/mail
