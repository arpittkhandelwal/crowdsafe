"""
Hugging Face Spaces Entrypoint for CrowdSafe AI.
Runs the Python CV tracking pipeline in background and serves the
FastAPI dashboard on port 7860 (Hugging Face default).
"""

import os
import sys
import threading
import uvicorn

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from web.server import app
from main import CrowdSafetyPipeline

# Start the CrowdSafe simulation pipeline in a background thread
pipeline = CrowdSafetyPipeline(
    source=None,
    sim_mode=True,
    show_window=False,
    headless=True
)
pipe_thread = threading.Thread(target=pipeline.run, daemon=True)
pipe_thread.start()

# Optional Gradio mount to satisfy HF Gradio space detection
try:
    import gradio as gr
    with gr.Blocks(title="CrowdSafe AI") as demo:
        gr.HTML('<iframe src="/" style="width:100%; height:100vh; border:none;"></iframe>')
    app = gr.mount_gradio_app(app, demo, path="/gradio")
except Exception as e:
    print(f"[App] Gradio mount skipped: {e}")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 7860))
    print(f"[App] Serving CrowdSafe AI on port {port}")
    uvicorn.run(app, host="0.0.0.0", port=port)
