# 💎 GEO-SCANNER: Aplikasi Identifikasi Mineral Berbasis AI

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white)](https://www.djangoproject.com/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://www.tensorflow.org/)

**Geo-Scanner** adalah aplikasi klasifikasi citra yang dirancang untuk melakukan **identifikasi mineral secara instan** menggunakan *Convolutional Neural Network* (**CNN**). Aplikasi ini bertujuan membantu pengguna, seperti **mahasiswa geologi** maupun **penggemar bebatuan**, dalam mengenali jenis mineral melalui kamera ponsel atau gambar yang diunggah.

Model CNN kami dilatih menggunakan dataset dari **Kaggle** yang berisi **lima kelas mineral**. Setelah analisis, aplikasi akan menampilkan hasil prediksi berupa jenis mineral terdeteksi beserta **tingkat keyakinan model** (misalnya, 99.5%).

---

## ✨ Fitur Utama Aplikasi

### 1. 📷 Klasifikasi Mineral (AI)
Aplikasi menyediakan dua metode input untuk identifikasi:
* **Buka Kamera:** Menganalisis objek mineral secara langsung. Akurasi deteksi sangat bergantung pada kondisi pengambilan gambar.
* **Upload Gambar:** Memilih gambar mineral dari galeri ponsel.

### 2. 📊 Hasil Identifikasi
Menampilkan layar hasil prediksi AI yang informatif:
* **Mineral Utama:** Nama mineral yang ditemukan (contoh: **Hematite**) beserta **Tingkat Kepercayaan (%)**.
* **Kemungkinan Mineral Lain:** Ditampilkan jika tingkat kepercayaan mineral utama tidak 100%.
* **Deteksi Gambar Buruk:** Jika gambar tidak terdeteksi sebagai salah satu dari 5 kelas mineral, aplikasi akan memberikan hasil dengan tingkat kepercayaan yang sangat rendah.

### 3. 📖 Katalog & Detail Mineral
Aplikasi menyertakan katalog lengkap untuk **5 jenis mineral** yang mencakup:
* **Ringkasan Mineral.**
* **Sifat Fisik Utama:** Kekerasan, Warna, Kilap, Gores, Kepadatan.
* **Karakteristik Kristal:** Sistem Kristal, Bentuk, Belahan.
* **Kegunaan:** (Contoh: Bijih tembaga, Pigmen, dll).
* **Lokasi Temuan Populer:** (Contoh: Arizona, Chili, dan Prancis).

### 4. 🧭 Fitur Tambahan & Utilitas
* **Riwayat (History):** Menyimpan catatan hasil *scan*/identifikasi sebelumnya.
* **Mode Gelap/Terang:** Opsi untuk mengubah tema tampilan aplikasi.
* **Tips Penggunaan:** Memberikan panduan penting untuk hasil akurasi terbaik (misalnya: pencahayaan, **jarak foto 10-20 cm**, fokus tajam, dan latar belakang polos).
* **Informasi Aplikasi:** Menampilkan detail teknis seperti **Versi Model ML (V1.0)**, Pengembang (**Kelompok 5**), dan Teknologi yang digunakan (**Flutter & Django**).

---

## 🛠️ Panduan Instalasi & Run

### ⚙️ Persiapan Backend (Django API)

Server Django harus dijalankan menggunakan `0.0.0.0` untuk fleksibilitas jaringan, dan diakses oleh aplikasi mobile menggunakan **IP lokal laptop**.

#### A. Instalasi Dependensi
1.  **Pindah ke Root Django:**
    ```bash
    # Pindah ke folder yang berisi manage.py
    cd api/Synapse/
    ```
2.  ** Aktivasi Environment:**
    ```bash
    conda activate pakbmobile
    ```

#### B. Cara Menjalankan Server
1.  **Cek IP Aktif:** Gunakan `ipconfig` untuk menemukan alamat IPv4 (misalnya **`192.168.1.5`**).
2.  **Jalankan Server:** Gunakan `0.0.0.0` agar server mendengarkan di semua interface jaringan.
    ```bash
    python manage.py runserver 0.0.0.0:8000
    ```
    > Server harus tetap berjalan selama masih menggunakan aplikasi mobile.

### 📱 Persiapan Frontend (Flutter Mobile)

1.  **Pindah ke Folder Frontend:**
    ```bash
    cd ../../app_mobile
    ```
2.  **Konfigurasi Host:** Pastikan *file* konfigurasi API di `app_mobile` disetel ke alamat IP lokal.
    *Contoh:* `http://192.168.1.5:8000/api/predict-image`
3.  **Instalasi & Build:**
    ```bash
    flutter pub get
    
    # Jalankan aplikasi 
    flutter run
    
    # --- ATAU ---
    
    # Build APK untuk distribusi
    flutter build apk --release
    ```
    > **Lokasi APK:** `app_mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Informasi Aplikasi & Tautan

* **Versi Model ML:** **V1.0**
* **Pengembang:** Kelompok 5
* **Teknologi:** Flutter, Django, TensorFlow Lite

### 🔗 Link APK
[Download Geo-Scanner APK](https://drive.google.com/file/d/1g8sOP5tu1SGwQhseIaJ4Yyf9rGL9cxRa/view?usp=drive_link)
