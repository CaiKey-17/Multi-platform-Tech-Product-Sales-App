from fastapi import FastAPI, File, UploadFile
import cv2
import numpy as np
from ultralytics import YOLO
import io

app = FastAPI()

# Load mô hình YOLOv8
model = YOLO("yolov8n.pt")

# Danh sách các nhãn thiết bị công nghệ cần nhận diện
allowed_labels = {"laptop", "cell phone", "keyboard", "mouse", "tv", "monitor", "computer"}

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
            label = result.names[cls]
            conf = float(box.conf[0])

            # Chỉ thêm nếu nhãn nằm trong danh sách allowed_labels
            if label.lower() in allowed_labels:
                detected_objects.append({"label": label, "confidence": conf})

    return {"objects": detected_objects}

# Chạy server
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5002)