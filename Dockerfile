# ---- Build stage ----
FROM node:20-alpine AS build

# Working directory
WORKDIR /app

# Copy package files first (better layer caching)
COPY devops-build/package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the source from devops-build
COPY devops-build/ ./

# Build the React app
RUN npm run build

# ---- Serve stage ----
FROM nginx:alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy built React app into nginx
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80
<<<<<<< HEAD
CMD ["nginx", "-g", "daemon off;"]
=======
CMD ["nginx", "-g", "daemon off;"]
>>>>>>> 8ab6d13aaab03de3f5aafe46b5d432aa7f344169
