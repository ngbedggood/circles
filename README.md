<p align="center">
  <img src="screenshots/icon.png" alt="Circles Logo" width="200"/>
</p>

<h1 align="center">Circles</h1>

<p align="center">
  A mood-tracking and social journaling app built with <b>SwiftUI</b> and <b>Firebase</b>.<p>
  <p align="center">Users can log daily moods, view past entries, and interact with friends moods through reactions.
</p>

  <p align="center"> (Just give me a follow if you'd like the link to test out the app!)
</p>

## Core Features

- **Mood Tracking** — log your daily mood with colors + optional notes
- **Timeline View** — scroll through past moods with smooth vertical paging
- **Social Features** — add friends, accept requests, view their moods
- **Reactions** — react to friends’ daily moods
- **Reminders** — optional local notifications to log moods
- **Custom UI Components** — tab indicator, toast messages, paging scroll system

## Architecture

The app follows the **MVVM pattern**:

- **Views**: SwiftUI UI components (`PersonalCardView`, `SocialCardView`, etc.)
- **ViewModels**: Business logic and state management (`DayPageViewModel`, `FriendsViewModel`)
- **Models**: Plain Swift structs for moods, users, etc.
- **Services**: Firebase integration (`FirestoreManager`, `AuthManager`)

## Firebase Backend Features

- **Authentication**: Handles user sign up and authentication through out the app
- **Firestore Database**: Database of choice to store user data with the appropriate database rules
- **Cloud Functions**: Listeners used for detecting database changes to trigger external notifications
- **Hosting**: Configured to enable deep link functionality for email verification

## Screenshots (WIP)

### Personal Mood Entry:

### Past Mood Entries:

### Social View:

### Settings and Friend Management:

## Notes/Personal Reflections
