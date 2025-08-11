# 🌍 Flag Globe – Flutter Country Flags Sphere (2D & 3D)

**Flag Globe** is a Flutter application that showcases world flags in **two stunning modes**:  
- **2D Globe Grid** – A sphere-like arrangement of flags using the [`country_flags`](https://pub.dev/packages/country_flags) package.  
- **3D Interactive Globe** – A fully rotatable, zoomable, textured globe powered by [`three_dart`](https://pub.dev/packages/three_dart) & [`flutter_gl`](https://pub.dev/packages/flutter_gl).

---

## 📸 Screenshot / Preview
---
## 2D
> <img width="1680" height="1050" alt="Screenshot 2025-08-10 at 11 51 45 pm" src="https://github.com/user-attachments/assets/b46571ed-dc49-40ce-afe2-3aa994a3f942" />
> <img width="1680" height="1050" alt="Screenshot 2025-08-10 at 11 51 53 pm" src="https://github.com/user-attachments/assets/1cf24e00-2024-4be5-8f7d-d6efa9fa97d1" />

---
## 3D

![Screen Recording 2025-08-11 at 12 43 21 am](https://github.com/user-attachments/assets/12f9492e-68cd-47a5-bd80-888fb63a56d5)



---

## ✨ Features

- **2D globe-like layout** of flags for a visually appealing display.
- Uses the **`country_flags` package** for accurate ISO country flag rendering.
- Interactive bottom sheet showing:
    - Country name
    - Capital city
    - Region
- Smooth and responsive UI using Material 3 design.
- Works seamlessly on both **Android** and **iOS**.

- **3D Mode**
- Realistic textured **3D Earth** with flags or map texture.
- **Touch/drag to rotate** (mobile & desktop).
- **Mouse/scroll to zoom** (web).
- Smooth rendering using `three_dart` + `flutter_gl` with WebGL support.
- Adjustable lighting & perspective camera.

---

##  Technologies Used

- **Flutter** – Cross-platform app development.
- **Dart** – Programming language for Flutter.
- **country_flags** – ISO country flag rendering.
- **three_dart** – 3D rendering engine for Dart.
- **flutter_gl** – WebGL/OpenGL bridge for Flutter.
- **Material Design 3** – Modern UI components.


## Notes
The 2D Mode works across all platforms with no special setup.

The 3D Mode requires:

flutter_gl WebGL/OpenGL support (desktop, mobile, web).

A globe texture image in assets/globe_texture.png.

On web, gestures are handled via raw HTML Canvas event listeners.
