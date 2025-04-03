FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# 🔥 gbhAi.py 파일의 ai 인스턴스를 실행
CMD ["uvicorn", "gbhAi:ai", "--host", "0.0.0.0", "--port", "8000"]
