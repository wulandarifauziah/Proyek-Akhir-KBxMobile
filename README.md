# 💎 GEO-SCANNER: Aplikasi Identifikasi Mineral Berbasis AI

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white)](https://www.djangoproject.com/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/)

**Geo-Scanner** adalah aplikasi klasifikasi citra berbasis **CNN** yang dapat mengidentifikasi mineral dari kamera atau gambar. Model dilatih menggunakan dataset Kaggle (5 jenis mineral).

---

## ✨ Fitur Utama

### 📷 Identifikasi Mineral
- Scan langsung melalui kamera.
- Upload gambar dari galeri.
- Confidence score (%) untuk setiap hasil.

### 📊 Hasil Prediksi
- Menampilkan mineral utama + kemungkinan lainnya.
- Memberi peringatan jika gambar buruk/low confidence.

### 📖 Katalog Mineral
Berisi ringkasan, sifat fisik, sistem kristal, kegunaan, dan lokasi umum.

### 🧭 Fitur Tambahan
- Riwayat scan.
- Mode gelap/terang.
- Tips penggunaan kamera.
- Informasi aplikasi.

---

# 🛠️ Panduan Instalasi & Run

# 🔌 Backend Django (dengan LocalTunnel)

## A. Instalasi Dependensi

```bash
cd api/Synapse
conda activate pakbmobile
pip install django-cors-headers
```

**Install LocalTunnel (Node.js):**

```bash
npm install -g localtunnel
```

---

## B. Menjalankan Server Django

### 1. Jalankan Django di localhost

```bash
python manage.py runserver 
```

### 2. Buka LocalTunnel

Buka terminal baru, lalu jalankan:

```bash
lt --port 8000 --subdomain geo-scanner-mineral
```

Jika berhasil, akan muncul URL seperti:

```
https://geo-scanner-mineral.loca.lt
```

URL inilah yang dipakai oleh Flutter.

---

## C. Update URL API di Flutter

Pada file konfigurasi API Flutter, isi dengan:

```
https://geo-scanner-mineral.loca.lt/api/predict-image
```

---

# 📱 Frontend Flutter

## 1. Pindah Folder

```bash
cd ../../app_mobile
```

## 2. Install Dependency

```bash
flutter pub get
```

## 3. Jalankan Aplikasi

```bash
flutter run
```

## 4. Build APK

```bash
flutter build apk --release
```

📍 **Lokasi APK:**

```
app_mobile/build/app/outputs/flutter-apk/app-release.apk
```

---

# 📦 Informasi Aplikasi

* **Model ML:** V1.0  
* **Dikembangkan oleh:** Kelompok 5  
* **Teknologi:** Flutter, Django, TensorFlow Lite  

---

# 🔗 Link APK

[https://drive.google.com/file/d/1g8sOP5tu1SGwQhseIaJ4Yyf9rGL9cxRa/view?usp=drive_link](https://drive.google.com/file/d/1g8sOP5tu1SGwQhseIaJ4Yyf9rGL9cxRa/view?usp=drive_link)
