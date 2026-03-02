#!/bin/bash

# --- 1. Environment Prep ---
export HF_HUB_ENABLE_HF_TRANSFER=1
source /workspace/ComfyUI/venv/bin/activate

# --- 2. High-Speed Download to TEMP (Not Volume) ---
# Create the structure in the pod's free ephemeral storage
mkdir -p /tmp/models/checkpoints

if [ ! -f "/tmp/models/checkpoints/ltx-2-19b-dev-fp4.safetensors" ]; then
    echo "🚀 Downloading LTX-2 weights to temporary storage..."
    huggingface-cli download Lightricks/LTX-2 ltx-2-19b-dev-fp4.safetensors --local-dir /tmp/models/checkpoints
fi

# --- 3. GDrive Mount for 4K Keepers ---
mkdir -p /workspace/ComfyUI/input/keepers
# Note: Ensure rclone is configured as 'gdrive' on your persistent volume
rclone mount gdrive:Uffie_Keepers /workspace/ComfyUI/input/keepers --daemon --vfs-cache-mode writes

# --- 4. Launch ComfyUI ---
cd /workspace/ComfyUI
# Fast-FP4 takes advantage of that sm_120 capability
python main.py --listen --port 8188 --fast-fp4 --use-sage-attention
