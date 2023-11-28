ARG DATABASE_URL
# Etapa 1: Instalación de dependencias
FROM node:lts as dependencies
WORKDIR /twitter

COPY package.json yarn.lock ./

ENV DATABASE_URL=$DATABASE_URL

RUN yarn install --frozen-lockfile

# Etapa 2: Reconstrucción del código fuente
FROM node:lts as builder
WORKDIR /twitter
COPY . .
COPY --from=dependencies /twitter/node_modules ./node_modules
RUN yarn build


# Etapa 3: Imagen de Producción
FROM node:lts as runner
WORKDIR /twitter
ENV NODE_ENV production

# Copia del archivo next.config.js (personalizado)
COPY --from=builder /twitter/next.config.js ./

# Copia de otros archivos necesarios
COPY --from=builder /twitter/public ./public
COPY --from=builder /twitter/.next ./.next
COPY --from=builder /twitter/node_modules ./node_modules
COPY --from=builder /twitter/package.json ./package.json


# Exponer el puerto 3003
EXPOSE 3003
CMD ["yarn", "start"]