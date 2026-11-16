# 🚀 ExoLab – NASA Space Apps Challenge 2026

**An AI-powered astronaut health monitoring application designed to support crew well-being in space station conditions.**

ExoLab is a project developed during the **NASA Space Apps Challenge 2026**. The idea behind it is to go beyond simply monitoring health data. We wanted to build a software solution that can present and explain vital signs in a calm, clear, and meaningful way, help identify potential health issues, suggest possible solutions, and guide users through implementing them.

Our goal was to explore how AI, data analysis, and software development could work together to make health monitoring more informative and interactive.

## 🌟 Features

- **Health Monitoring:** Displays essential health indicators and physiological measurements through an interactive dashboard.
- **AI Health Assessment:** Analyzes health data and provides explanations and insights about the user's current health status.
- **Health Predictions & Alerts:** Helps identify potential health concerns and highlights measurements that may require attention.
- **Exo AI Assistant:** An integrated AI assistant that allows users to interact with the application and explore health-related questions.
- **Health Trends:** Provides a way to follow changes in health measurements over time.
- **Health Habits:** Helps users stay aware of daily habits and their relationship with overall well-being.
- **Interactive Task List:** Converts suggested actions into tasks, allowing users to follow through with the recommendations.
- **Interactive 3D Model:** Includes an embedded 3D model with interactive elements, animations, and color changes.

## 🛠️ Technologies & Implementation

Some of the technologies and concepts explored during this project include:

- **Flutter & Dart:** Application development and user interface.
- **LLM Integration:** Running a local language model using `Qwen3-4B-Q4_K_M.gguf`.
- **TensorFlow Lite (.tflite):** Integration of the AI model responsible for analyzing health data.
- **Backend Communication:** Communication between the application and backend services.
- **3D Model Integration:** Embedding and interacting with a 3D model directly inside the application.
- **AI & Data Analysis:** Using analyzed health data to support explanations, insights, and recommendations.

## 👨‍💻 Contributions

**Lawrence Abou Karroum – Software Development**

- Developed the application interface and interactive components using Flutter.
- Integrated the local LLM and implemented the AI assistant functionality.
- Worked on backend communication and integration.
- Integrated the interactive 3D model into the application.

**Jad Katerji – AI Development**

- Developed the AI model responsible for analyzing health data.
- Worked on generating health insights and analysis used by the application to support its explanations and recommendations.

## 📥 Download & Run the Application

The application is available for **Windows and Android**.

### Windows

The repository contains the Windows application files. To download and run it:

1. Open the following Google Drive folder:

   [Download ExoLab – Windows Application](https://drive.google.com/drive/folders/170T3H7obnyfM73ajYdgqCdpFxYaycD_O?usp=drive_link)

2. Download the ZIP file.
3. Extract its contents.
4. Download the `Qwen3-4B-Q4_K_M.gguf` model from Hugging Face.
5. Place the model inside the application's `Release` folder or your Windows Documents folder.
6. Launch the application.

**Important:** When opening the application for the first time, a file picker will appear. You will need to locate and select the downloaded model so that the application can initialize the local AI functionality.

### Android

The application can also run on Android devices.

Download the app-release.apk file, open it and install on your device (with wide screen such as a tablet), through the same link:

 [Download ExoLab – Android Application](https://drive.google.com/drive/folders/170T3H7obnyfM73ajYdgqCdpFxYaycD_O?usp=drive_link)

The same language model is required:

`Qwen3-4B-Q4_K_M.gguf`

Make sure the model is accessible on your device. When launching the application for the first time, select the model through the file picker. Make sure you run it on a wide screen android device, such as a tablet.

**A note about performance:**

Running a 4-billion-parameter language model locally requires considerable processing power and memory. Depending on your device's processor and available resources, generating responses can take some time, especially on Android tablets.

Please make sure your device is capable of running this model before attempting to use the application.

## ⚠️ Important Notes

- The language model must retain its exact filename: `Qwen3-4B-Q4_K_M.gguf`.
- The model is not included in the application download and must be downloaded separately.
- The first launch requires selecting the model manually (on android) and manually added in Documents or inside the app's folder (Release) on windows.
- This app has no error handling yet, as it was a quick prototype focusing on the idea of the project.
- AI-generated health insights and recommendations are intended for demonstration and informational purposes, not medical diagnosis or professional medical advice.

## 🎥 Project Demonstration

Check out the project demonstration to see ExoLab in action, explore its features, and understand how the different components work together.

Link to the demo video and presentation: [See and understand ExoLab without app downloading](https://drive.google.com/drive/folders/1NLg4_F6_uppUXlI09lJ2YaRtFCtMj5SH?usp=sharing)

---

**Developed during NASA Space Apps Challenge 2026 | Lebanon - Beirut**

A project exploring the intersection of Artificial Intelligence, Software Engineering, Health Technology, and Space Exploration.
