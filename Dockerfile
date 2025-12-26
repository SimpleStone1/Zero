FROM node:22-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS build
WORKDIR /app
COPY . .
# Устанавливаем зависимости. Флаг --no-frozen-lockfile поможет, если есть конфликты версий
RUN pnpm install --no-frozen-lockfile
# Собираем монорепозиторий
RUN pnpm run build

FROM base AS runner
WORKDIR /app
ENV NODE_ENV production
# Копируем всё собранное
COPY --from=build /app /app

EXPOSE 3000
# Команда запуска: пушим базу и стартуем
CMD ["sh", "-c", "npx prisma db push --schema=packages/database/prisma/schema.prisma && pnpm run start"]
