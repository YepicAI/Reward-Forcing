FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    python3-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip \
 && pip install --no-build-isolation -r requirements.txt

# Install the package itself
COPY setup.py ./
COPY model ./model
COPY pipeline ./pipeline
COPY trainer ./trainer
COPY utils ./utils
COPY demo_utils ./demo_utils
COPY videoalign ./videoalign
COPY wan ./wan
RUN pip install -e .

# Copy the remaining project files (configs, scripts, etc.)
COPY . .

# Default: 5-second video inference, matching the README "Quick Start" example.
# Make sure to mount checkpoints and an output directory when running:
#   docker run --gpus all --rm \
#     -v $(pwd)/checkpoints:/app/checkpoints \
#     -v $(pwd)/videos:/app/videos \
#     reward-forcing
CMD ["python", "inference.py", \
     "--num_output_frames", "21", \
     "--config_path", "configs/reward_forcing.yaml", \
     "--checkpoint_path", "checkpoints/Reward-Forcing-T2V-1.3B/rewardforcing.pt", \
     "--output_folder", "videos/rewardforcing-5s", \
     "--data_path", "prompts/MovieGenVideoBench_extended.txt", \
     "--use_ema"]



