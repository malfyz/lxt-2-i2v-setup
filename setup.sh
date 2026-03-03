#!/bin/bash
# --- 1. Environment & Persistent Tools ---
# Load your venv and the persistent hf tool from your network volume
source /workspace/ComfyUI/venv/bin/activate
export PYTHONPATH=$PYTHONPATH:/workspace/ComfyUI/python_libs
export PATH=$PATH:/workspace/ComfyUI/python_libs/bin
export HF_HUB_ENABLE_HF_TRANSFER=1

# --- 2. Sync Uffie's 4K Keepers ---
# Syncing from GDrive to the persistent network volume
mkdir -p /workspace/ComfyUI/input/keepers
rclone sync gdrive:Uffie_Keepers /workspace/ComfyUI/input/keepers \
    --config /workspace/rclone_config/rclone.conf -P

# --- 3. Download Muscle to Ephemeral Storage (/tmp) ---
# We download the 25GB checkpoint fresh at every startup to save network volume space
mkdir -p /tmp/models/checkpoints
if [ ! -f "/tmp/models/checkpoints/ltx-2-19b-dev-fp8.safetensors" ]; then
    hf download Lightricks/LTX-2 ltx-2-19b-dev-fp8.safetensors --local-dir /tmp/models/checkpoints
fi

# --- 4. Launch ComfyUI ---
cd /workspace/ComfyUI
# --user-directory keeps the internal DB on the pod (faster/prevents locking) 
# while extra_paths.yaml points the loaders to /workspace/models and /tmp/checkpoints
python main.py --listen --port 8188 --user-directory /workspace/ComfyUI/user
