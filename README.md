# 📍 TagIt - Aplikasi Pengingat Lokasi (Vibrasi & Alarm)

![Logo](https://socialify.git.ci/Luft21/TagIt/image?custom_language=Flutter&font=Inter&language=1&logo=https%3A%2F%2Fraw.githubusercontent.com%2FLuft21%2FTagIt%2Fd56bf1996de60fa0d61748317aa30cd4cab15257%2Fassets%2Fimages%2Ftagit_logo.png&name=1&owner=1&theme=Auto)


## Description

Aplikasi ini merupakan aplikasi Flutter berbasis lokasi (GPS) yang berfungsi untuk **mengingatkan pengguna saat mendekati lokasi tujuan tertentu**. Aplikasi ini mengirimkan **notifikasi berupa getaran dan alarm suara** saat pengguna berada dalam radius tertentu dari lokasi tujuan.

Aplikasi ini cocok untuk pengguna yang ingin mendapatkan pengingat lokasi saat bepergian, misalnya agar tidak terlewat turun dari kendaraan umum.

## Screenshots

![Login Screen](screenshot/login_screen.png)
![Map](screenshot/map.png)
![Add Reminder](screenshot/add_reminder.png)
![Reminder List](screenshot/reminder_list.png)
![Edit Reminder](screenshot/edit_reminder.png)
![Profile](screenshot/profile.png)


## Features

- ✅ Pelacakan lokasi pengguna secara real-time
- ✅ Penetapan lokasi tujuan menggunakan peta interaktif (Google Maps)
- ✅ Penentuan radius pemicu alarm (misal: 500 meter)
- ✅ Notifikasi berupa **getaran (vibrasi)** dan **alarm suara**
- ✅ Pengaturan mode alarm, suara, dan durasi getaran _(opsional)_

## Tech Stack

- Flutter (SDK)
- Dart
- google_maps_flutter
- geolocator
- flutter_local_notifications
- vibration
