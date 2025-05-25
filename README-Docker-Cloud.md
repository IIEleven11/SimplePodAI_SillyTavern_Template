# SillyTavern + KoboldCPP Cloud Docker Deployment

This Docker setup allows you to run SillyTavern with KoboldCPP backend on cloud services like simplepod.ai.

## Features

- **SillyTavern Frontend**: Web interface on port 8000
- **KoboldCPP Backend**: AI model server on port 5001
- **CUDA Support**: GPU acceleration for model inference
- **Python 3.12**: Latest Python with PyTorch CUDA support
- **Cloud Ready**: Configured for non-localhost deployment

## Files Included

- `Dockerfile`: Full-featured Docker image
- `Dockerfile.cloud`: Optimized for cloud deployment
- `docker-compose.yml`: For local development with GPU support
- `README-Docker-Cloud.md`: This file

## Quick Start for Cloud Deployment

### Option 1: Using Dockerfile.cloud (Recommended for Cloud)

```bash
# Build the image
docker build -f Dockerfile.cloud -t sillytavern-kobold:cloud .

# Run the container
docker run -d \
  --name sillytavern-kobold \
  --gpus all \
  -p 8000:8000 \
  -p 5001:5001 \
  sillytavern-kobold:cloud
```

### Option 2: Using docker-compose (Local Development)

```bash
# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f
```

## Cloud Service Deployment (simplepod.ai)

### Step 1: Prepare Your Repository

1. Ensure your repository contains:
   - `SillyTavern/` directory with all files
   - `SillyTavern/koboldcpp` binary (executable)
   - `SillyTavern/mythomax-l2-13b.Q8_0.gguf` model file
   - `Dockerfile.cloud`

### Step 2: Deploy on simplepod.ai

1. **Create New Pod**:
   - Choose GPU-enabled instance
   - Select CUDA-compatible image base

2. **Build Configuration**:
   - Repository: Your GitHub repository
   - Dockerfile: `Dockerfile.cloud`
   - Ports: `8000,5001`

3. **Environment Variables** (if needed):
   ```
   NODE_ENV=production
   CUDA_VISIBLE_DEVICES=0
   ```

4. **Resource Requirements**:
   - GPU: Required (NVIDIA with CUDA support)
   - RAM: Minimum 8GB (16GB+ recommended)
   - Storage: Minimum 20GB

### Step 3: Access Your Services

Once deployed, you'll get URLs like:
- **SillyTavern**: `https://your-pod-url:8000`
- **KoboldCPP API**: `https://your-pod-url:5001`

## Configuration

### SillyTavern Configuration

The configuration is automatically set for cloud deployment:
- `listen: true` - Accepts external connections
- `whitelistMode: false` - Allows all IPs
- `autorun: false` - Doesn't try to open browser

### KoboldCPP Configuration

Default settings in the startup script:
- Host: `0.0.0.0` (all interfaces)
- Port: `5001`
- Context Size: `4096`
- Threads: `4`
- CUDA: Enabled (`--usecublas`)

### Customizing KoboldCPP Settings

To modify KoboldCPP settings, edit the startup script in `Dockerfile.cloud`:

```bash
./koboldcpp \
    --host 0.0.0.0 \
    --port 5001 \
    --model mythomax-l2-13b.Q8_0.gguf \
    --contextsize 8192 \        # Increase context
    --threads 8 \               # More threads
    --usecublas \               # GPU acceleration
    --blasbatchsize 512 \       # Batch size
    --quiet
```

## Connecting SillyTavern to KoboldCPP

1. Open SillyTavern in your browser
2. Go to API Settings
3. Select "KoboldAI" as API
4. Set API URL to: `http://localhost:5001` (internal) or `https://your-pod-url:5001` (external)
5. Test the connection

## Troubleshooting

### Common Issues

1. **KoboldCPP fails to start**:
   - Check GPU availability: `nvidia-smi`
   - Verify CUDA installation
   - Check model file exists and is readable

2. **SillyTavern can't connect to KoboldCPP**:
   - Verify KoboldCPP is running on port 5001
   - Check firewall/port settings
   - Try internal URL: `http://localhost:5001`

3. **Out of memory errors**:
   - Reduce context size (`--contextsize`)
   - Use smaller model
   - Increase container memory allocation

### Viewing Logs

```bash
# View container logs
docker logs sillytavern-kobold

# Follow logs in real-time
docker logs -f sillytavern-kobold
```

### Accessing Container

```bash
# Get shell access
docker exec -it sillytavern-kobold /bin/bash

# Check processes
docker exec sillytavern-kobold ps aux
```

## Performance Optimization

### For Better Performance:

1. **Use appropriate GPU**:
   - RTX 3090/4090 for best performance
   - Minimum: GTX 1660 or better

2. **Optimize KoboldCPP settings**:
   - Increase `--blasbatchsize` for better GPU utilization
   - Adjust `--threads` based on CPU cores
   - Use `--lowvram` if running out of VRAM

3. **Model considerations**:
   - Q8_0 quantization balances quality and speed
   - Consider Q4_K_M for faster inference
   - Larger models need more VRAM

## Security Notes

- The configuration disables whitelist mode for cloud deployment
- Consider enabling basic authentication for production use
- Use HTTPS in production environments
- Regularly update dependencies

## Support

For issues specific to:
- **SillyTavern**: [SillyTavern GitHub](https://github.com/SillyTavern/SillyTavern)
- **KoboldCPP**: [KoboldCPP GitHub](https://github.com/LostRuins/koboldcpp)
- **Docker**: Check container logs and Docker documentation
