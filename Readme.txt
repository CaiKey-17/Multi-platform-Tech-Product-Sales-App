 
==============================================
Thông tin cài đặt và sử dụng hệ thống
==============================================

Tên dự án: Ecommerce-App (Flutter + Spring Boot + Sentiment Analysis + Search by Image Upload) 
Nhóm thực hiện: Nguyễn Cao Kỳ  
Môn học: Phát triển ứng dụng di động đa nền tảng (HK2/2024-2025)
Giảng viên hướng dẫn: Mai Văn Mạnh
Ngày hoàn thành: 17/05/2025
Video demo: https://drive.google.com/file/d/1FkW6i4n6vDvEeWzpuGVOZtw2Autx4Qoz/view?usp=sharing
----------------------------------------------
1. HƯỚNG DẪN CÀI ĐẶT (Yêu cầu có Docker + Flutter)
----------------------------------------------
- Web: https://caikey-17.github.io/flutter-final/#/main
- Android: sử dụng file .APK trong thư mục `bin` -> Chỉ cần tải về và sử dụng !
- Window App: giải nén `app-windows.zip` trong thư mục `bin` -> Mở file .exe để sử dụng !

- Trong trường hợp không nhận dữ liệu từ Server (Hết hạn)
- Trong thư mục `source` hãy chạy lệnh:  `docker-compose up --build`  
- Để chạy khởi chạy ứng dụng, hãy sửa lại file: source/app/lib/globals/ip.dart
	+ Hãy cmt các biến trong `Deploy` và sử dụng các biến trong `Run local` + điền ip của bạn vào.
	+ Sử dụng các lệnh sau để khởi chạy ứng dụng:
	    - Web: `flutter run -d chrome`
	    - Android: `flutter run` hoặc `flutter run -d <device_id>`   # Kết nối thiết bị Android thật hoặc chạy Android Emulator.
- Thông tin máy chủ deploy:
	+ Endpoint: flutter.cmnco2is8n58.us-east-1.rds.amazonaws.com
	+ Port: 3306
	+ Username: admin
	+ Password: Nck250621
- Thông tin domain các service:
	+ API hệ thống: https://backend-production-c478.up.railway.app
	+ API Sentiment Analysis: https://sentiment-analysics-production.up.railway.app
	+ API Search by Image Upload: https://detect-product-production.up.railway.app
- Thông tin Admin của Ứng dụng:
	+ Username: maivanmanh.tdtu@gmail.com
	+ Password: 123456



----------------------------------------------
2. CÁC TÍNH NĂNG BỔ SUNG (Bonus features)
----------------------------------------------	
- ✅ Tự xây dựng hệ thống Backend - Spring Boot (Security, Author JWT, Websocket, sử dụng các Procedure, Trigger function trong database).
- ✅ Tích hợp Sentiment Analysis (Phân tích & đánh giá bình luận). Sử dụng mô hình SVC để dự đoán (Tích cực / Tiêu cực / Trung lập). 
- ✅ Tích hợp Image Upload (Tìm kiếm sản phẩm dựa vào hình ảnh). Sử dụng YoloV8 - phát hiện đối tượng + thu hẹp về phạm vi của đề tài.




----------------------------------------------
3. LƯU Ý KHI CHẠY ỨNG DỤNG FLUTTER KẾT NỐI BACKEND
----------------------------------------------
- Với Flutter Web:  
  + API base URL mặc định là `http://localhost:8080` hoặc domain deploy nếu dùng server thực tế.  
  + Nếu dùng Docker local, đảm bảo backend mở cổng 8080 trên máy bạn.

- Với Flutter Android (thực hoặc Emulator):  
  + Không dùng `localhost` hoặc `127.0.0.1` để gọi API vì đó là địa chỉ của thiết bị Android, không phải máy host.  
  + Thay bằng IP mạng LAN của máy đang chạy backend Docker, ví dụ `http://192.168.x.y:8080`.

- Đảm bảo sửa file `ip.dart` đúng với môi trường bạn chạy (local hay deploy).
