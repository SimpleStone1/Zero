FROM node:20-slim

# 1. Устанавливаем необходимые системные библиотеки
RUN apt-get update -y && apt-get install -y openssl libssl-dev ca-certificates

# 2. Настраиваем pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# 3. Копируем файлы 
# ВАЖНО: Убедись, что файл .dockerignore в GitHub ПУСТОЙ!
COPY . .

# 4. Установка зависимостей
RUN pnpm install --no-frozen-lockfile

# 5. Сборка всего проекта
RUN pnpm run build

# 6. Настройки окружения
ENV NODE_ENV production
EXPOSE 3000

# 7. Команда запуска
# Мы используем фильтр pnpm, чтобы запустить пуш базы именно из папки сервера,
# а затем запускаем основной проект.
CMD pnpm --filter @zero/server db:push && pnpm run start
