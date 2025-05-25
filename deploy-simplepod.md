# SimplePod.ai Deployment Guide

## Quick Deployment Steps for SimplePod.ai

### 1. Repository Setup
Ensure your repository has these files in the root:
- `Dockerfile.cloud` (main deployment file)
- `SillyTavern/` directory with all files
- `SillyTavern/koboldcpp` (executable binary)
- `SillyTavern/mythomax-l2-13b.Q8_0.gguf` (your model)

### 2. SimplePod.ai Configuration

**Pod Settings:**
- **Image**: Custom (use Dockerfile.cloud)
- **GPU**: Required (NVIDIA CUDA compatible)
- **RAM**: 16GB+ recommended
- **Storage**: 25GB+ recommended
- **Ports**: 8000, 5001

**Environment Variables:**
```
NODE_ENV=production
CUDA_VISIBLE_DEVICES=0
```

**Build Command:**
```bash
docker build -f Dockerfile.cloud -t sillytavern-kobold .
```

**Run Command:**
```bash
docker run --gpus all -p 8000:8000 -p 5001:5001 sillytavern-kobold
```

### 3. Access Your Services

Once deployed, SimplePod.ai will provide you with URLs:
- **SillyTavern UI**: `https://your-pod-id.simplepod.ai:8000`
- **KoboldCPP API**: `https://your-pod-id.simplepod.ai:5001`

### 4. Connect SillyTavern to KoboldCPP

1. Open SillyTavern in your browser
2. Go to **API Connections** 
3. Select **KoboldAI** as the API type
4. Set API URL to: `http://localhost:5001` (internal connection)
5. Click **Connect** and test

### 5. Troubleshooting

**If KoboldCPP doesn't start:**
- Check GPU is available in pod settings
- Verify model file exists and is accessible
- Check pod logs for CUDA errors

**If SillyTavern can't connect:**
- Ensure both services are running
- Try the external URL: `https://your-pod-id.simplepod.ai:5001`
- Check firewall/port settings

**Performance Issues:**
- Increase pod RAM allocation
- Use a more powerful GPU tier
- Consider using a smaller/faster model

### 6. Model Replacement

To use a different model:
1. Replace `SillyTavern/mythomax-l2-13b.Q8_0.gguf` with your model
2. Update the model name in `Dockerfile.cloud` startup script
3. Rebuild and redeploy

### 7. Monitoring

Check pod health:
- SillyTavern health: `https://your-pod-id.simplepod.ai:8000`
- KoboldCPP status: `https://your-pod-id.simplepod.ai:5001/api/v1/model`

## Ready to Deploy!

Your Docker template is now ready for SimplePod.ai deployment. The configuration has been optimized for cloud hosting with proper networking and GPU support.
