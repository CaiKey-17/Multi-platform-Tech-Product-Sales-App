from fastapi import FastAPI, File, UploadFile
import cv2
import numpy as np
from ultralytics import YOLO
import io

app = FastAPI()

# Load mô hình YOLOv8
model = YOLO("yolov8n.pt")

@app.post("/detect/")
async def detect_objects(file: UploadFile = File(...)):
    contents = await file.read()
    image_np = np.frombuffer(contents, np.uint8)
    image = cv2.imdecode(image_np, cv2.IMREAD_COLOR)

    # Thực hiện nhận diện
    results = model(image)

    # Lấy danh sách đối tượng phát hiện
    detected_objects = []
    for result in results:
        for box in result.boxes:
            cls = int(box.cls[0])
            label = result.names[cls]  # Tên đối tượng (VD: laptop, mouse)
            conf = float(box.conf[0])  # Độ chính xác
            detected_objects.append({"label": label, "confidence": conf})

    return {"objects": detected_objects}

# Chạy server
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
