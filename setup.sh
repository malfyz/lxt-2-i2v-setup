#!/bin/bash
# --- 1. Activate the Brain ---
source /workspace/ComfyUI/venv/bin/activate
export HF_HUB_ENABLE_HF_TRANSFER=1

# Ensure huggingface_hub is actually installed in this venv
pip install -U huggingface_hub[cli] --no-cache-dir

# --- 2. Sync Uffie's 4K Keepers ---
mkdir -p /workspace/ComfyUI/input/keepers
rclone sync gdrive:Uffie_Keepers /workspace/ComfyUI/input/keepers \
    --config /workspace/rclone_config/rclone.conf -P

# --- 3. Download Muscle to Temp Storage (FP8 Stable) ---
mkdir -p /tmp/models/checkpoints
if [ ! -f "/tmp/models/checkpoints/ltx-2-19b-dev-fp8.safetensors" ]; then
    # Calling the CLI via python -m to bypass the "command not found" error
    python -m huggingface_hub.commands.cli download Lightricks/LTX-2 ltx-2-19b-dev-fp8.safetensors --local-dir /tmp/models/checkpoints
fi

# --- 4. Network Volume & Workflow Mapping ---
mkdir -p /workspace/ComfyUI/user
if [ ! -L "/workspace/ComfyUI/user/workflows" ]; then
    rm -rf /workspace/ComfyUI/user/workflows
    ln -s /storage/workflows /workspace/ComfyUI/user/workflows
fi

# --- 5. Launch Studio ---
cd /workspace/ComfyUI
# Using --user-directory to keep the DB local while workflows stay on the network
python main.py --listen --port 8188 --user-directory /workspace/ComfyUI/user
