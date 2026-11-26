FROM python:3.11-slim

# Prevent Python from writing .pyc and buffer stdout
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HEADLESS=1 \
    PORT=8000 \
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

WORKDIR /app

# Copy requirements and install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY . .

# Create runtime directories
RUN mkdir -p logs recordings reports uploads models

# Expose Render's default port
EXPOSE 10000

# Start: run simulation pipeline + web dashboard headless on Render's $PORT
CMD ["sh", "-c", "python main.py --sim --no-window --port ${PORT:-10000}"]
