# 1. Используем образ с поддержкой OpenSSL
FROM node:20-slim AS base
RUN apt-get update -y && apt-get install -y openssl libssl-dev ca-certificates

# Настройка pnpm
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app

# 2. Установка зависимостей
COPY . .
RUN pnpm install --no-frozen-lockfile

# 3. Сборка
RUN pnpm run build

# 4. Финальный запуск
ENV NODE_ENV production
EXPOSE 3000

# Исправленная команда запуска:
# Мы сначала генерируем клиент Prisma, потом пушим базу, потом стартуем.
# Если путь packages/database/prisma/schema.prisma не сработает, попробуем найти его через find.
CMD npx prisma generate --schema=packages/database/prisma/schema.prisma && \
    npx prisma db push --schema=packages/database/prisma/schema.prisma --accept-data-loss && \
    pnpm run start
