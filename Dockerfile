FROM python:3.11-slim

# Prevent Python from writing .pyc and buffer stdout
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HEADLESS=1 \
    PORT=7860 \
    MPLBACKEND=Agg

# Install system dependencies (OpenCV headless requirements + FFmpeg)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    libgomp1 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up user for Hugging Face Spaces (UID 1000)
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR $HOME/app

# Copy requirements and install Python dependencies
COPY --chown=user requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY --chown=user . .

# Create runtime directories with write permissions
RUN mkdir -p logs recordings reports uploads models

# Expose Hugging Face default port
EXPOSE 7860

# Start: run simulation pipeline + web dashboard headless on Hugging Face $PORT (7860)
CMD ["sh", "-c", "python main.py --sim --no-window --port ${PORT:-7860}"]
