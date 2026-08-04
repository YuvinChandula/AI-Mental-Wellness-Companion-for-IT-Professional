FROM python:3.12-slim

WORKDIR /workspace

# Install system dependencies needed for compiling models/ReportLab
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend files
COPY . .

# Set configuration defaults
ENV PORT=8000
ENV ENV=production
ENV SECURE_HEADERS_ENABLED=true
ENV RATE_LIMIT_PER_MINUTE=60

EXPOSE 8000

# Native Python health check avoiding curl package dependencies
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=5)" || exit 1

CMD uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}

