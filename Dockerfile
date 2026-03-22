FROM node:20-alpine3.19
WORKDIR /app
COPY package*.json ./
RUN npm install -g npm@latest \
    && npm audit fix --force
COPY . .
RUN npm install
EXPOSE 3000
CMD ["npm", "run", "dev"]
