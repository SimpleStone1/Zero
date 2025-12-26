FROM node:20-slim

# 1. Системные зависимости
RUN apt-get update -y && apt-get install -y openssl libssl-dev ca-certificates

# 2. Настройка pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# 3. Копируем всё (убедись, что .dockerignore пустой на GitHub!)
COPY . .

# 4. Установка и билд
RUN pnpm install --no-frozen-lockfile
RUN pnpm run build

# 5. Настройки для Railway
ENV NODE_ENV production
# Заставляем Node.js слушать все интерфейсы
ENV HOST 0.0.0.0
# Railway выдает порт динамически, но мы зафиксируем 3000 для прокси
ENV PORT 3000

# 6. Команда запуска
# Мы добавим флаг --ip 0.0.0.0 чтобы wrangler/next вышли наружу
CMD pnpm --filter @zero/server db:push && \
    pnpm turbo run start --filter=@zero/server --filter=@zero/mail -- -- --ip 0.0.0.0 --port 3000
