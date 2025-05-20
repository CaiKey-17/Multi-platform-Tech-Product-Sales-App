# Sử dụng image Python nhẹ
FROM python:3.9-slim

# Cài đặt thư viện hệ thống cần cho OpenCV
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Thiết lập thư mục làm việc
WORKDIR /app

# Sao chép toàn bộ mã nguồn vào container
COPY . /app

# Cài đặt thư viện Python từ requirements.txt
RUN pip install --upgrade pip \
 && pip install -r requirements.txt

# Mở cổng 8000
EXPOSE 8000

# Chạy ứng dụng FastAPI bằng Uvicorn
CMD ["uvicorn", "app_scale:app", "--host", "0.0.0.0", "--port", "5002"]

