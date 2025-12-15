# Use official Dart image
FROM dart:stable

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy all source code
COPY . .

# Compile Dart server to executable
RUN dart compile exe bin/server.dart -o server

# Expose port (Render uses dynamic PORT)
EXPOSE 8080

# Start server
CMD ["./server"]
