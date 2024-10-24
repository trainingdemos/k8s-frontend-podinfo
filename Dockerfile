# Stage 1: Build the Next.js app
FROM node:20-alpine AS builder

# Set the working directory
WORKDIR /build

# Install dependencies
COPY package.json ./
RUN npm install

# Copy the source code
COPY app/ ./app
COPY next.config.mjs postcss.config.mjs tailwind.config.ts tsconfig.json ./
COPY public/ ./public

# Build the Next.js application
RUN npm run build

# Stage 2: Serve the app with Nginx
FROM nginx:stable-alpine

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build output from the previous stage
COPY --from=builder /build/out /usr/share/nginx/html

# Expose port 80 for the server
EXPOSE 80

# Start Nginx server
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
