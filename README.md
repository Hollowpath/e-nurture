## Group Name
- The Reel

## Group Members
- Name: Faizal Akhtar Bin Azhar, Matric No: 2124565
- Name: Dhazreel Aiman Bin Darmawi, Matric No: 2116597
- Name: Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813

## Project Initiation
### Title
e-Nurture

### Background of the Problem
The childcare industry faces challenges like limited caregiver access, unreliable services, and poor communication tools, leaving parents struggling to ensure safe, professional care (Reinventing Childcare, 2023; Beebe, 2024). Caregivers seek reliable clients and better resources, while providers must meet rising demands with high standards (Modestino et al., 2021). This paper proposes an "eNurture platform service" to address these issues through digital tools that relieve pain and create gains for parents, caregivers, and providers, aligning with SDG 3 (Good Health and Well-being), SDG 4 (Quality Education), and SDG 8 (Decent Work and Economic Growth).

### Purpose or Objective
The objective of this project is to develop a conceptual eNurture business model for the "Childcare E-Platform" that integrates digital platforms and apps to provide child caretaker services acting as pain relievers and gain creators, including:
- Providing parents with secured, reviewed, user-friendly tools for finding and vetting child caregivers, enhancing their trust and confidence.
- Offering customizable childcare service packages and flexible booking options to accommodate various family schedules and needs.
- Integrating real-time communication, monitoring, and tracking features for transparency and peace of mind.
- Equipping child caregivers with access to a supportive, dependable network, enabling them to provide consistently high-quality care.

### Target User
- Parents in need of childcare services
- Childcare givers
- B40 interested in working as childcare givers
- Donors

### Preferred Platform
Platform: Android Mobile App (Only)

### Features and Functionalities
The following features and functionalities leverage key mobile device capabilities, enhancing user experience and app performance:

1. **Geolocation Services for Booking and Matching Caregivers**  
   The app integrates **GPS** and **geolocation services** to help parents find nearby childcare providers in real time. This feature enhances the booking process by displaying caregivers who are within a user's preferred distance, ensuring convenience and accessibility.

2. **Push Notifications for Real-Time Updates**  
   Push notifications are implemented to provide real-time updates to both parents and caregivers. For example, parents will receive notifications when a caregiver confirms their booking, and caregivers will be alerted about new job offers or training opportunities, keeping them engaged and informed.

3. **In-App Messaging and Communication**  
   The app uses mobile device communication tools (SMS, push notifications, in-app chat) for seamless communication between parents, caregivers, and platform support. This enables instant messaging and secure exchanges of information, making the app highly interactive.

4. **Camera Integration for Profile Photos and Document Uploads**  
   The app allows both parents and caregivers to upload **profile photos**, **certifications**, and **training documents** directly via the mobile device's camera. This ensures that both parties have up-to-date profiles and documents that can be verified, helping to build trust within the platform.

5. **Push-Based Training and Certification Notifications**  
   Caregivers can receive **push notifications** about new training opportunities, certification deadlines, or reminders for skill updates. These notifications will be personalized based on caregivers' profiles, ensuring that they stay on top of necessary qualifications.

6. **User Profile and Sentiment-Based Review System**  
   **Mobile-based sentiment analysis** can help summarize caregiver reviews into an overall sentiment score. Ratings and reviews will be collected and displayed within the app to build trust and ensure transparency between caregivers and parents.

## Requirement Analysis
### Technical Feasibility
The app uses Firebase for backend services including authentication, real-time database, and cloud messaging. Firebase is chosen for its scalability and ease of integration with Flutter. The app will store user profiles, caregiver documents, and booking data on Firestore, with a CRUD system for managing appointments. Geolocation features will be implemented using Google Maps API, and Firebase Cloud Messaging will handle notifications.

### Compatibility
**Software:**
- Google Play Services: For geolocation and in-app messaging.
- Material Design Components: For a consistent user interface experience on Android.
- Firebase Backend Integration: For authentication, real-time database, and notifications.

**Hardware:**
- GPS Module: For geolocation services.
- Camera: For document uploads and profile photos.
- Push Notification Support: Utilizes Firebase Cloud Messaging for real-time updates.

**Testing:**
- Android Emulator: Testing the app on the Flutter emulator and Android Studio to ensure compatibility and functionality.
- Physical Devices: Testing on various Android phone models to verify performance and user experience across different devices.

**Phone models used for testing:**
- Samsung S21+ (specs: [Samsung Galaxy S21+ 5G](https://www.gsmarena.com/samsung_galaxy_s21+_5g-10625.php))
- Samsung A35 (specs: [Samsung Galaxy A35](https://www.gsmarena.com/samsung_galaxy_a35-12705.php))
- Xiaomi Poco F3 (specs: [Xiaomi Poco F3](https://www.gsmarena.com/xiaomi_poco_f3-10758.php))

### Logical Design
- **Sequence Diagram**: ![e-nurture Sequence Diagram](https://github.com/user-attachments/assets/1c9b74a8-48cc-48c6-8d52-74e49b18ae6f)
- **Screen Navigation Flow**: ![e-nurture Screen Navigation Flow](https://drive.google.com/uc?export=view&id=1fNsf8TP5-PWpUoTe9RQgn2h3XJkmRvaS)

## Planning
### Gantt Chart and Timeline
![Gantt Chart for e-Nurture](https://drive.google.com/uc?export=view&id=13dtG3OyqcSJh5PsRyAOwc9_9JOam2BP2)

## Assigned Tasks
### Authentication and User Management
- **Faizal Akhtar Bin Azhar, Matric No: 2124565**:
  - Implement Firebase Authentication to enable user registration, login, and logout (parents and caregivers).
  - Set up role-based access (e.g., parent vs. caregiver) within the app.
  - Create a simple user profile screen using TextField and ListView widgets for editing profile details.

### Push Notifications
- **Dhazreel Aiman Bin Darmawi, Matric No: 2116597**:
  - Integrate Firebase Cloud Messaging to send real-time notifications (e.g., booking confirmations, training reminders).

### UI/UX Implementation
- **Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813**:
  - Build the home screen (with navigation) using Scaffold, AppBar, and BottomNavigationBar.
  - Design the caregiver search and booking screens using ListView, GridView, and Geolocation Services.
  - Implement state management (e.g., Provider or setState) for dynamic UI updates like filtering caregiver profiles by location or rating.

### Real-Time Communication
- **Faizal Akhtar Bin Azhar, Matric No: 2124565**:
  - Use Firebase Realtime Database or Firestore to enable in-app messaging between parents and caregivers.

### Geolocation and Maps Integration
- **Dhazreel Aiman Bin Darmawi, Matric No: 2116597**:
  - Implement Google Maps API to display caregivers' locations on a map.
  - Add features to filter caregivers by proximity using geolocation services.

### Booking System
- **Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813**:
  - Create a CRUD system for booking appointments using Firestore.
  - Build a calendar view for caregivers to manage their availability.

### Profile and Document Management
- **Shared Contribution**:
  - Enable caregivers to upload profile photos and certifications using camera and file picker plugins.

### Shared Responsibilities
**Testing and Debugging**
- **All Members**: 
  - Test the app on physical devices and emulators, covering different Android versions and screen sizes.
  - Fix any identified bugs and ensure consistent performance across devices.

**Integration of Features**
- **All Members**:
  - Collaborate on GitHub for seamless integration of front-end and back-end components.

## What You’ll Apply From the Course
1. **Flutter Basics**: Use widgets like Column, Row, Stack, Container, and ListView for layout.
2. **State Management**: Apply Provider, setState, or other state management tools for dynamic updates.
3. **Firebase**: Authentication, Realtime Database, Firestore, and Cloud Messaging.
4. **Plugins and Packages**: Use FlutterFire plugins, Google Maps, and Camera for app functionality.
5. **Routing**: Implement named routes for navigation between screens.
6. **Testing**: Perform unit tests and app performance testing using Android Studio and emulators.

## References
Clark, K., Lovich, D., McBride, L., De Santis, N., Milian, R., & Baskin, T. (2023, May 3). Reinventing Childcare for Today’s Workforce. Boston Consulting Group. https://www.bcg.com/publications/2023/reinventing-the-childcare-industry-for-the-workforce-of-today?form=MG0AV3

Modestino, A. S., Ladge, J. J., Swartz, A., & Lincoln, A. (2021, April 29). Childcare Is a Business Issue. Harvard Business Review. https://hbr.org/2021/04/childcare-is-a-business-issue?form=MG0AV3
