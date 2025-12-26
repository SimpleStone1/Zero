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
    
# Экономим память и фиксируем порты
ENV NODE_ENV production
ENV PORT 3000
ENV HOST 0.0.0.0

# Команда запуска
# 1. Синхронизируем базу
# 2. Запускаем сервер и почту, принудительно заставляя их слушать 0.0.0.0
# Мы передаем флаги напрямую в базовые команды через turbo
CMD pnpm --filter @zero/server db:push && \
    pnpm turbo run start --filter=@zero/server --filter=@zero/mail -- --ip 0.0.0.0 --port 3000

  
