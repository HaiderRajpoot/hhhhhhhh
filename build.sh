#!/bin/bash

# Echo commands for debugging
set -x

# Print environment information
echo "Node version: $(node -v)"
echo "NPM version: $(npm -v)"
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the application
echo "Building the application..."
npm run build

# Check build output
echo "Build completed. Checking dist folder:"
ls -la dist

# Done
echo "Build script completed" 