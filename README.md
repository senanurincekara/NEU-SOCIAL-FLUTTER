# neü social

**neü social** is a social platform developed as a 3rd-year university project using Flutter. This application allows users to interact, share posts, and participate in discussions within the university community.


## Pages

### Login and Registration

The login and registration pages allow users to securely create an account or log into an existing one. User information is stored and managed through Firebase Authentication with admin approval

![Ekran görüntüsü 2024-06-29 234824](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/0295b7c5-0fbb-47a6-8a48-56d67dc08932)

### Profile Management

Users can view and update their profile information, including changing their avatar. The profile page allows for easy access to personal information and provides a user-friendly interface for making updates. The new avatar is highlighted with a red border and updated in real-time using Firebase Storage.
![Ekran görüntüsü 2024-06-29 235208](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/a6538a03-702b-4cfc-8266-5ec77e9a4a4d)

### Topic Discussions

This page allows users to create, view, and participate in discussions on various topics. Users can see a list of active discussions, start new topics, and engage with other users' posts. Discussions and comments are managed in real-time with Firebase. Each topic and the comments added to the topics are displayed on the screen after being approved by an admin.
![Ekran görüntüsü 2024-06-29 235420](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/6ae8047b-4f6c-4159-ba65-7fe8d75086eb)

### Announcements

The announcements page displays important updates and news from Necmettin Erbakan University. Initially, it was planned to fetch announcement data via the university's API, but due to access restrictions, the data is currently parsed from the university's website and stored in a static JSON file for display.

![Ekran görüntüsü 2024-06-30 001239](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/71408454-d2a1-49aa-8be6-d73305a322f0)

### Project Uploads

Students can upload and view projects in PDF format. The project page provides a simple interface for uploading PDF files, which are then stored in Firebase Storage. Users can access and view these files, making it easy to share academic projects within the university community.
![Ekran görüntüsü 2024-06-29 235851](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/6dbd0dee-7233-444f-8bb8-ba4825e3ad0f)

### Game Page

The game page allows users to add sentences to a collaborative story. Each sentence added by a user is limited to 70 characters to maintain brevity and coherence. Upon adding a sentence, the user receives a confirmation alert. These sentences are reviewed by an admin before being displayed in the story. Approved sentences are shown in the game, while unapproved ones are archived in the 'gameDatasetArchive' collection on Firebase.
![Ekran görüntüsü 2024-06-30 000041](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/31d8939a-c7cb-44b8-83d6-043937f3349f)

### Job and Humor Page

The job and humor page displays content added by admins. Admins can post job listings and humor content, providing users with useful information and entertainment. These posts are managed and approved by admins to ensure relevant and appropriate content. Job and humor posts are stored in Firebase and displayed dynamically on the page.
![Ekran görüntüsü 2024-06-30 000206](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/2e2a3d51-bdc3-4d32-ba7e-ca99afaae4cb)
![Ekran görüntüsü 2024-06-30 000508](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/52ac24e9-2af7-4a34-bb4b-a2a1987cf70d)

### Polls Page

The polls page allows admins to upload Google-formatted polls for users to participate in. Users can view and respond to these polls within the application, and admins can collect and analyze the feedback. This page provides an interface for user engagement and feedback collection, enhancing the overall community interaction.
![Ekran görüntüsü 2024-06-30 000819](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/7b4995ca-0585-44bd-a277-ddb8b5de358a)

### Admin Panel

The admin panel includes various functionalities to manage the application:

- **User Management:** Update user information and delete users from the application.
- **Content Approval:** Approve new user accounts and manage content posted by users, including topics and comments.
- **Poll Management:** Create and delete polls, ensuring interactive engagement within the community.
- **Story Game Management:** Approve and manage sentences added to the story game. Unapproved sentences are archived for review.
- **Comment Management:** Admin can review, approve, and delete comments added to topics. Approved comments are shown, and unapproved ones are archived.
- **Job and Humor Management:** Admins can add and manage job and humor posts to ensure fresh and relevant content for users.
![Ekran görüntüsü 2024-06-30 000911](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/515f8120-5829-4216-b38f-d4ded95ec3b5)
![Ekran görüntüsü 2024-06-30 000934](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/1e34cdca-48dc-4723-b5ed-19a6f9e100fe)
![Ekran görüntüsü 2024-06-30 000959](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/48b759e3-4674-4742-b2d9-6848bb4acfca)
![Ekran görüntüsü 2024-06-30 001021](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/20c6a32d-3643-455f-9244-3320964a2e8f)
![Ekran görüntüsü 2024-06-30 001045](https://github.com/senanurincekara/neu_Social-flutter/assets/97362569/8afb8ffc-8e9f-4ba5-92dd-c5955d0baa76)


## Technologies Used

- **Flutter:** The main framework used for building the app.
- **Firebase:** For authentication, real-time database, and storage.
- **Dart:** The programming language used in Flutter.


## Contact

If you have any questions or feedback, please contact me 

