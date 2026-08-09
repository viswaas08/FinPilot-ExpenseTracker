# Stage 1: Build Flutter Web Application
FROM plugwei/flutter:3.24.0 AS build

WORKDIR /app

# Copy dependency configs and resolve packages
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy full application code and build web bundle
COPY . .
RUN flutter build web --release --web-renderer canvaskit

# Stage 2: Serve Web Application with Nginx (or Python)
FROM nginx:alpine

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled web assets from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
