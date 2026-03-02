#!/bin/bash
# --- 1. Environment & Performance Prep ---
export HF_HUB_ENABLE_HF_TRANSFER=1
export PYTHONUNBUFFERED=1
# Force CUDA to use Blackwell-optimized kernels
export TORCH_CUDNN_V8_API_ENABLED=1 

pip install hf_transfer nunchaku

# --- 2. Filesystem & Symlinking ---
# Link persistent models to temporary high-speed container storage
mkdir -p /tmp/checkpoints
ln -sf /tmp/checkpoints/ltx-2-19b-dev-fp4.safetensors /workspace/ComfyUI/models/checkpoints/

# --- 3. GDrive Mount ---
mkdir -p /workspace/ComfyUI/input/keepers
rclone mount gdrive:Uffie_Keepers /workspace/ComfyUI/input/keepers --daemon --vfs-cache-mode writes

# --- 4. Model Retrieval (NVFP4) ---
if [ ! -f "/tmp/checkpoints/ltx-2-19b-dev-fp4.safetensors" ]; then
    echo "Downloading LTX-2 FP4 Weights..."
    huggingface-cli download Lightricks/LTX-2 ltx-2-19b-dev-fp4.safetensors --local-dir /tmp/checkpoints
fi

# --- 5. Launch ---
cd /workspace/ComfyUI
# Fast-FP4 is the Blackwell-specific flag for LTX-2/Wan 2.6
python main.py --listen --port 8188 --fast-fp4 --use-split-cross-attention
