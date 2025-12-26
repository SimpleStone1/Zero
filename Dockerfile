FROM node:20-slim

# 1. Устанавливаем системные зависимости для базы данных
RUN apt-get update -y && apt-get install -y openssl libssl-dev ca-certificates

# 2. Настраиваем pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# 3. Копируем ВООБЩЕ ВСЁ (чтобы не гадать с путями монорепозитория)
COPY . .

# 4. Устанавливаем всё и собираем
RUN pnpm install --no-frozen-lockfile
RUN pnpm run build

# 5. Настройка окружения
ENV NODE_ENV production
EXPOSE 3000

# 6. Умная команда запуска:
# Она сама найдет файл schema.prisma, где бы он ни лежал, и запустит его.
CMD SCHEMA_PATH=$(find . -name schema.prisma | head -n 1) && \
    echo "Found schema at: $SCHEMA_PATH" && \
    npx prisma generate --schema=$SCHEMA_PATH && \
    npx prisma db push --schema=$SCHEMA_PATH --accept-data-loss && \
    pnpm run start
