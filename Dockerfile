# Use NVIDIA CUDA base image with Python 3.12
FROM nvidia/cuda:12.1-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_VERSION=20.x
ENV PYTHON_VERSION=3.12
ENV PYTORCH_VERSION=2.1.0
ENV CUDA_VERSION=12.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    dos2unix \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1

# Install pip for Python 3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Install PyTorch with CUDA support
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Create app directory
WORKDIR /app

# Copy SillyTavern files
COPY SillyTavern/ ./SillyTavern/

# Set working directory to SillyTavern
WORKDIR /app/SillyTavern

# Install SillyTavern dependencies
RUN npm install --no-audit --no-fund --loglevel=error --no-progress

# Create necessary directories
RUN mkdir -p config data plugins

# Copy configuration
RUN cp default/config.yaml config/config.yaml

# Make KoboldCPP executable
RUN chmod +x koboldcpp

# Create startup script
RUN cat > /app/start.sh << 'EOF'
#!/bin/bash

# Function to handle shutdown
cleanup() {
    echo "Shutting down services..."
    kill $KOBOLD_PID $ST_PID 2>/dev/null
    wait
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Start KoboldCPP in background
echo "Starting KoboldCPP..."
cd /app/SillyTavern
./koboldcpp --host 0.0.0.0 --port 5001 --model mythomax-l2-13b.Q8_0.gguf --contextsize 4096 --threads 4 --usecublas &
KOBOLD_PID=$!

# Wait a bit for KoboldCPP to start
sleep 10

# Start SillyTavern
echo "Starting SillyTavern..."
node server.js --listen &
ST_PID=$!

# Wait for both processes
wait $KOBOLD_PID $ST_PID
EOF

# Make startup script executable
RUN chmod +x /app/start.sh

# Expose ports
# 8000 for SillyTavern
# 5001 for KoboldCPP
EXPOSE 8000 5001

# Use tini as init system
ENTRYPOINT ["tini", "--"]

# Start both services
CMD ["/app/start.sh"]
