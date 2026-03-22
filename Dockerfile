FROM node:19-alpine3.19
WORKDIR /app
COPY . /app
RUN npm install
EXPOSE 3000
CMD ["npm", "run". "dev"]
