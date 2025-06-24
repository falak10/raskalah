# ♻️ Raskalah 

**Smart Waste Classification & Gamified Recycling App (Graduation Project)**  
Raskalah is a mobile app that uses computer vision and gamification to make recycling easier and more rewarding — built to raise recycling awareness in Saudi Arabia.

---

## 📱 What the App Does

- 📷 Scan waste with your phone
- 🧠 AI classifies it (plastic, paper, glass, etc.) using DenseNet-121
- 📍 Shows nearby recycling centers
- 🏆 Earn points & redeem rewards
- 🎯 Join eco-challenges hosted by local businesses
- 🗣️ Full Arabic language support

---

## 🔍 Why This Project?

Saudi Arabia faces challenges with recycling — with over 88% of waste going to landfills.  
This app encourages sustainable behavior through technology, using:
- AI for fast, accurate waste sorting
- Maps for finding centers
- Rewards and gamification to make recycling fun

---

## 🛠️ Tech Stack

| Feature              | Technology                          |
|----------------------|--------------------------------------|
| Frontend             | Flutter (Dart)                       |
| Backend              | Firebase (Auth, Firestore, Storage) |
| Machine Learning     | Python, TensorFlow, Keras            |
| AI Model             | DenseNet-121                         |
| Location Services    | Google Maps API                     |
| UI/UX Design         | Figma                               |

---

## 📈 AI Model Comparison

| Model        | Accuracy |
|--------------|----------|
| DenseNet-121 | ✅ 97%   |
| MobileNetV2  | 94%      |
| ResNet50     | 84%      |

DenseNet-121 was chosen for deployment due to its high performance in classifying waste images.

---

## 👥 User Roles & Key Features

### 👤 Regular User
- Scan and classify waste
- View recycling centers near them
- Track recycling activity and points
- Redeem rewards
- Join sustainability challenges

### 🏢 Recycling Center
- Manage profile
- Accept scan requests and assign points to users

### 🛠 Admin
- Manage user and center accounts
- Add, edit, delete challenges and rewards

---

## 🧪 Testing & Accuracy

- Full test coverage for: login, scan, classification, reward redemption, admin and center management
- Achieved high classification accuracy with real-world waste image data
