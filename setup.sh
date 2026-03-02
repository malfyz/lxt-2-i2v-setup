#!/bin/bash
# --- 1. Activate the Brain ---
source /workspace/ComfyUI/venv/bin/activate
export HF_HUB_ENABLE_HF_TRANSFER=1

# --- 2. Sync Uffie's 4K Keepers (No Mount) ---
mkdir -p /workspace/ComfyUI/input/keepers
rclone sync gdrive:Uffie_Keepers /workspace/ComfyUI/input/keepers \
    --config /workspace/rclone_config/rclone.conf -P

# --- 3. Download Muscle to Temp Storage ---
mkdir -p /tmp/models/checkpoints
if [ ! -f "/tmp/models/checkpoints/ltx-2-19b-dev-fp4.safetensors" ]; then
    huggingface-cli download Lightricks/LTX-2 ltx-2-19b-dev-fp4.safetensors --local-dir /tmp/models/checkpoints
fi

# --- 4. Launch Studio ---
cd /workspace/ComfyUI
python main.py --listen --port 8188
