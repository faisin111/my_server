# -------- Build Stage --------
FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/server.dart -o server

# -------- Runtime Stage -------
FROM debian:bullseye-slim

WORKDIR /app

# Install certificates
RUN apt-get update && apt-get install -y ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy binary
COPY --from=build /app/server /app/server
RUN chmod +x /app/server

# Security: non-root user
RUN useradd -m dartuser
USER dartuser

EXPOSE 8080

CMD ["./server"]
