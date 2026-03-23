FROM node:20-alpine3.19

# Create app directory
WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only required files
COPY package*.json ./

RUN npm install

# Copy remaining app files
COPY src/ ./src/
COPY public/ ./public/
COPY .env.example ./

# Change ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

EXPOSE 3000
CMD ["npm", "run", "dev"]
