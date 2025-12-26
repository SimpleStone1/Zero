# 1. Используем легкий образ Node.js
FROM node:20-slim AS base
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# 2. Установка зависимостей
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
# Копируем только те папки, которые реально нужны для установки (монорепозиторий)
COPY apps/mail/package.json ./apps/mail/
COPY packages/database/package.json ./packages/database/

# Устанавливаем зависимости (без поиска папок .yarn)
RUN pnpm install --frozen-lockfile

# 3. Сборка проекта
COPY . .
RUN pnpm run build

# 4. Финальный образ
ENV NODE_ENV production
EXPOSE 3000

# Команда запуска: пушим базу и стартуем сервер
# Мы используем npx prisma, чтобы не зависеть от путей монорепозитория
CMD npx prisma db push --schema=packages/database/prisma/schema.prisma && pnpm run start
