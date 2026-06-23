import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "backend"))

import warnings
warnings.filterwarnings("ignore", category=UserWarning, module="pydantic")

from app.main import app
