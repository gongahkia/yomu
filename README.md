[![](https://img.shields.io/badge/yomu_1.0.0-build-passing)](https://github.com/gongahkia/yomu/releases/tag/1.0.0)


# `Yomu` 🐦‍⬛

...

<div align="center">
  <img src="./asset/reference/1.png" width="80%">
</div>

## Stack

Deployed with Heroku.

* [Frontend](#architecture) *(Ruby Erb, SCSS, JavaScript)*
* [Backend](#architecture) *(Rails)*
* [DB](#database) *(Rails Models, Firebase Realtime Database)*

## Screenshot

<div style="display: flex; justify-content: space-between;">
  <img src="./asset/reference/1.png" width="48%">
  <img src="./asset/reference/2.png" width="48%">
</div>

<br>

<div style="display: flex; justify-content: space-between;">
  <img src="./asset/reference/3.png" width="48%">
  <img src="./asset/reference/4.png" width="48%">
</div>

<br>

<div style="display: flex; justify-content: space-between;">
  <img src="./asset/reference/5.png" width="48%">
  <img src="./asset/reference/6.png" width="48%">
</div>

## Usage

For local debugging.

1. Run the below.

```console
$ git clone https://github.com/gongahkia/yomu
$ bundle install && yarn install
```

2. Create a `.env` file with the below details.

```env
DATABASE_USERNAME=XXX
DATABASE_PASSWORD=XXX
FIREBASE_URL=XXX
FIREBASE_SECRET=XXX
GEMENI_API_KEY=XXX
```

3. Then run the below.

```console
$ cd yomu/yomu-app
$ rails db:create
$ rails db:migrate
$ rails db:seed
$ rails server
```

## Architecture

```mermaid
sequenceDiagram
    actor User
    participant Frontend as Frontend (Ruby ERB/SCSS/JS)
    participant Backend as Backend (Rails Controllers)
    participant Models as Rails Models
    participant Firebase as Firebase Realtime Database
    participant OpenLibrary as Open Library API
    participant Gemini as Gemini API
    %% User Registration/Login Flow
    User->>Frontend: Registers/Logs in
    Frontend->>Backend: POST /users/sign_in
    Backend->>Models: User.authenticate
    Models->>Firebase: Query user data
    Firebase-->>Models: Return user data
    Models-->>Backend: Authentication result
    Backend-->>Frontend: Session token & user data
    Frontend-->>User: Display dashboard
    %% Book Search Flow
    User->>Frontend: Searches for a book
    Frontend->>Backend: GET /books/search?q=title
    Backend->>OpenLibrary: Query book information
    OpenLibrary-->>Backend: Return book metadata
    Backend-->>Frontend: Book search results
    Frontend-->>User: Display book results
    %% Book Details
    User->>Frontend: Selects a book
    Frontend->>Backend: GET /books/:id
    Backend->>OpenLibrary: Fetch detailed book info
    OpenLibrary-->>Backend: Return book details
    Backend->>Firebase: Check if in user's library
    Firebase-->>Backend: User's status with book
    Backend-->>Frontend: Complete book details
    Frontend-->>User: Show book details page
    %% Reading Session Logging
    User->>Frontend: Logs reading session
    Frontend->>Backend: POST /reading_sessions
    Backend->>Models: Create ReadingSession
    Models->>Firebase: Store reading session
    Firebase-->>Models: Confirm storage
    Backend->>OpenLibrary: Get book details for verification
    OpenLibrary-->>Backend: Book content details
    Backend->>Gemini: Request trivia question
    Note over Backend,Gemini: Send book title, author, and page range
    Gemini-->>Backend: Return trivia question
    Backend-->>Frontend: Display verification question
    Frontend-->>User: Show trivia question
    %% Verification Process
    User->>Frontend: Answers trivia question
    Frontend->>Backend: POST /trivia/verify
    Backend->>Gemini: Verify answer
    Gemini-->>Backend: Verification result
    alt Answer Correct
        Backend->>Models: Update ReadingSession.verified = true
        Models->>Firebase: Update reading session
        Firebase-->>Models: Confirm update
        Backend->>Models: Update User.points
        Models->>Firebase: Update user points
        Firebase-->>Models: Confirm update
        Backend-->>Frontend: Verification successful
        Frontend-->>User: Show success & points earned
    else Answer Incorrect
        Backend-->>Frontend: Verification failed
        Frontend-->>User: Show failure message
    end
    %% Book Completion
    Backend->>Models: Check if book completed
    Models->>Firebase: Query reading progress
    Firebase-->>Models: Return progress data
    alt Book Completed
        Backend->>Models: Create BookCompletion
        Models->>Firebase: Store book completion
        Firebase-->>Models: Confirm storage
        Backend->>OpenLibrary: Update reading lists
        OpenLibrary-->>Backend: Confirm update
        Backend-->>Frontend: Prompt for review
        Frontend-->>User: Show review form
    end
    %% Book Discovery
    User->>Frontend: Requests recommendations
    Frontend->>Backend: GET /recommendations
    Backend->>OpenLibrary: Query similar books
    OpenLibrary-->>Backend: Return recommendations
    Backend->>Firebase: Filter by user preferences
    Firebase-->>Backend: Personalized recommendations
    Backend-->>Frontend: Recommendation data
    Frontend-->>User: Display recommended books
    %% Leaderboard
    User->>Frontend: Views leaderboard
    Frontend->>Backend: GET /leaderboard
    Backend->>Models: Fetch top users
    Models->>Firebase: Query user rankings
    Firebase-->>Models: Return ranking data
    Models-->>Backend: Formatted leaderboard data
    Backend-->>Frontend: Leaderboard data
    Frontend-->>User: Display leaderboard
    %% Real-time Updates
    Firebase->>Backend: Push notification (new activity)
    Backend->>Frontend: WebSocket update
    Frontend-->>User: Real-time notification
```

## Rails Models

```mermaid
erDiagram
    User {
        string email
        string username
        string profilePicture
        int readingLevel
        int points
        timestamp createdAt
        timestamp lastActive
    }

    Book {
        string title
        string author
        string genre
        int totalPages
        string isbn
        string coverImage
        int publishedYear
    }

    ReadingSession {
        string userId FK
        string bookId FK
        int pagesRead
        timestamp date
        boolean verified
        int currentPage
        string verificationMethod
    }

    BookCompletion {
        string userId FK
        string bookId FK
        timestamp completedAt
        int totalTimeSpent
    }

    Review {
        string userId FK
        string bookId FK
        string content
        int rating
        timestamp createdAt
        int likes
    }

    TriviaQuestion {
        string bookId FK
        string question
        string answer
        int difficulty
        int pageRangeStart
        int pageRangeEnd
        string generatedBy
    }

    Perk {
        string name
        string description
        int requiredPoints
        string icon
        string effect
    }

    UserPerk {
        string userId FK
        string perkId FK
        timestamp acquiredAt
        boolean active
    }

    User ||--o{ ReadingSession : "tracks"
    User ||--o{ BookCompletion : "achieves"
    User ||--o{ Review : "writes"
    User ||--o{ UserPerk : "unlocks"

    Book ||--o{ ReadingSession : "included in"
    Book ||--o{ BookCompletion : "completed as"
    Book ||--o{ TriviaQuestion : "has"
    Book ||--o{ Review : "receives"

    Perk ||--o{ UserPerk : "granted as"
```

## Database

Firebase Realtime Database Schema.

```json
{
  "users": {
    "$userId": {
      "email": "string",
      "username": "string",
      "profilePicture": "string",
      "readingLevel": "number",
      "points": "number",
      "createdAt": "timestamp",
      "lastActive": "timestamp"
    }
  },

  "books": {
    "$bookId": {
      "title": "string",
      "author": "string",
      "genre": "string",
      "totalPages": "number",
      "isbn": "string",
      "coverImage": "string",
      "publishedYear": "number"
    }
  },

  "readingSessions": {
    "$sessionId": {
      "userId": "string",
      "bookId": "string",
      "pagesRead": "number",
      "date": "timestamp",
      "verified": "boolean",
      "currentPage": "number",
      "verificationMethod": "string"
    }
  },

  "bookCompletions": {
    "$completionId": {
      "userId": "string",
      "bookId": "string",
      "completedAt": "timestamp",
      "totalTimeSpent": "number"
    }
  },

  "reviews": {
    "$reviewId": {
      "userId": "string",
      "bookId": "string",
      "content": "string",
      "rating": "number",
      "createdAt": "timestamp",
      "likes": "number"
    }
  },

  "triviaQuestions": {
    "$questionId": {
      "bookId": "string",
      "question": "string",
      "answer": "string",
      "difficulty": "number",
      "pageRange": {
        "start": "number",
        "end": "number"
      },
      "generatedBy": "string"
    }
  },

  "perks": {
    "$perkId": {
      "name": "string",
      "description": "string",
      "requiredPoints": "number",
      "icon": "string",
      "effect": "string"
    }
  },

  "userPerks": {
    "$userId": {
      "$perkId": {
        "acquiredAt": "timestamp",
        "active": "boolean"
      }
    }
  },

  "leaderboard": {
    "overall": {
      "$userId": {
        "username": "string",
        "points": "number",
        "rank": "number"
      }
    },
    "monthly": {
      "$month": {
        "$userId": {
          "username": "string",
          "points": "number",
          "rank": "number"
        }
      }
    },
    "genreSpecific": {
      "$genre": {
        "$userId": {
          "username": "string",
          "points": "number",
          "rank": "number"
        }
      }
    }
  },

  "readingChallenges": {
    "$challengeId": {
      "title": "string",
      "description": "string",
      "startDate": "timestamp",
      "endDate": "timestamp",
      "goal": "number",
      "goalType": "string",
      "reward": {
        "points": "number",
        "perkId": "string"
      },
      "participants": {
        "$userId": {
          "progress": "number",
          "joined": "timestamp",
          "completed": "boolean"
        }
      }
    }
  },

  "userStats": {
    "$userId": {
      "totalPagesRead": "number",
      "booksCompleted": "number",
      "averagePagesPerDay": "number",
      "readingStreak": "number",
      "lastReadDate": "timestamp",
      "favoriteGenres": {
        "$genre": "number"
      },
      "weeklyProgress": {
        "$week": "number"
      },
      "monthlyProgress": {
        "$month": "number"
      }
    }
  },

  "notifications": {
    "$userId": {
      "$notificationId": {
        "type": "string",
        "message": "string",
        "createdAt": "timestamp",
        "read": "boolean",
        "relatedId": "string"
      }
    }
  },

  "bookClubs": {
    "$clubId": {
      "name": "string",
      "description": "string",
      "createdBy": "string",
      "createdAt": "timestamp",
      "currentBook": "string",
      "members": {
        "$userId": {
          "role": "string",
          "joinedAt": "timestamp"
        }
      },
      "discussions": {
        "$discussionId": {
          "title": "string",
          "content": "string",
          "createdBy": "string",
          "createdAt": "timestamp",
          "comments": {
            "$commentId": {
              "userId": "string",
              "content": "string",
              "createdAt": "timestamp"
            }
          }
        }
      }
    }
  }
}
```

## Reference

The name `Yomu` is in reference to 読む *(よむ)*, which roughly translates to "read" in Japanese.

<div align="center">
    <img src="./asset/logo/mei_mei.webp" width="50%">
</div>
