FROM python:3.11-slim-bookworm

# 시스템 패키지 설치 (OpenCV 구동 및 하드웨어 접근용)
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libv4l-dev \
    v4l-utils \
    x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

# 파이썬 라이브러리 설치
RUN pip install --no-cache-dir opencv-python numpy

WORKDIR /app
COPY . .

# 실행 명령어
# CMD ["python", "main.py"]