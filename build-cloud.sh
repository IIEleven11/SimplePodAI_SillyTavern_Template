#!/bin/bash

# Build script for SillyTavern + KoboldCPP cloud deployment

set -e

echo "=== SillyTavern + KoboldCPP Cloud Build Script ==="

# Check if required files exist
echo "Checking required files..."

if [ ! -f "SillyTavern/koboldcpp" ]; then
    echo "ERROR: KoboldCPP binary not found at SillyTavern/koboldcpp"
    echo "Please download it with:"
    echo "curl -fLo SillyTavern/koboldcpp https://github.com/LostRuins/koboldcpp/releases/latest/download/koboldcpp-linux-x64-cuda1150"
    echo "chmod +x SillyTavern/koboldcpp"
    exit 1
fi

if [ ! -f "SillyTavern/mythomax-l2-13b.Q8_0.gguf" ]; then
    echo "ERROR: Model file not found at SillyTavern/mythomax-l2-13b.Q8_0.gguf"
    echo "Please download your GGUF model and place it in the SillyTavern directory"
    exit 1
fi

if [ ! -f "Dockerfile.cloud" ]; then
    echo "ERROR: Dockerfile.cloud not found"
    exit 1
fi

echo "✓ All required files found"

# Build the Docker image
echo "Building Docker image..."
docker build -f Dockerfile.cloud -t sillytavern-kobold:cloud .

echo "✓ Docker image built successfully"

# Provide usage instructions
echo ""
echo "=== Build Complete ==="
echo ""
echo "To run the container:"
echo "docker run -d --name sillytavern-kobold --gpus all -p 8000:8000 -p 5001:5001 sillytavern-kobold:cloud"
echo ""
echo "To view logs:"
echo "docker logs -f sillytavern-kobold"
echo ""
echo "Access URLs:"
echo "- SillyTavern: http://localhost:8000"
echo "- KoboldCPP API: http://localhost:5001"
echo ""
echo "For cloud deployment, replace 'localhost' with your cloud service URL"
