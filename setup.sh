#!/bin/bash
# --- 1. Activate & Fix Environment ---
source /workspace/ComfyUI/venv/bin/activate
export PATH="/workspace/ComfyUI/venv/bin:$PATH"
export HF_HUB_ENABLE_HF_TRANSFER=1

# Clear the local disk clutter to fix the 'Disk Quota Exceeded' error
rm -rf /workspace/.cache/uv /root/.cache/pip

# --- 2. Sync Uffie's 4K Keepers ---
mkdir -p /workspace/ComfyUI/input/keepers
rclone sync gdrive:Uffie_Keepers /workspace/ComfyUI/input/keepers \
    --config /workspace/rclone_config/rclone.conf -P

# --- 3. Map Network Volume (Small Assets) ---
# We point these to /storage so they NEVER touch your limited local disk
rm -rf /workspace/ComfyUI/models/loras && ln -s /storage/models/loras /workspace/ComfyUI/models/loras
rm -rf /workspace/ComfyUI/models/vae && ln -s /storage/models/vae /workspace/ComfyUI/models/vae
rm -rf /workspace/ComfyUI/models/clip && ln -s /storage/models/clip /workspace/ComfyUI/models/clip

# --- 4. Download Muscle to Temp Storage (/tmp) ---
# Your extra_paths.yaml handles the 'blindness'—we just need the file present
mkdir -p /tmp/models/checkpoints
if [ ! -f "/tmp/models/checkpoints/ltx-2-19b-dev-fp8.safetensors" ]; then
    huggingface-cli download Lightricks/LTX-2 ltx-2-19b-dev-fp8.safetensors --local-dir /tmp/models/checkpoints
fi

# --- 5. Fix Workflow Save Conflict (Network Storage) ---
mkdir -p /workspace/ComfyUI/user
rm -rf /workspace/ComfyUI/user/workflows
ln -s /storage/workflows /workspace/ComfyUI/user/workflows

# --- 6. Launch Studio ---
cd /workspace/ComfyUI
# Using --user-directory to keep the DB local and prevent network locking (409s)
python main.py --listen --port 8188 --user-directory /workspace/ComfyUI/user
