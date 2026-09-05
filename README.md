# Placement Prep

A full-stack placement preparation platform built to help students manage their placement journey, track job applications, and practice DSA problems from a single application.

The project is built with Flutter Web, Node.js/Express, and MySQL. The application is containerized using Docker and Docker Compose, and deployed on an AWS EC2 instance.

---

## 🚀 Features

- User registration and authentication
- Protected routes using authentication middleware
- DSA problem-solving section
- Placement/job application tracking
- Application status management
- Persistent MySQL database
- REST API built with Node.js and Express
- Flutter Web frontend
- Dockerized frontend and backend
- MySQL running as a Docker service
- Docker Compose orchestration
- AWS EC2 deployment

---

## 🛠️ Tech Stack

### Frontend

- Flutter
- Dart
- Flutter Web

### Backend

- Node.js
- Express.js
- REST API

### Database

- MySQL 8.0

### DevOps & Deployment

- Docker
- Docker Compose
- Docker Hub
- AWS EC2
- Git & GitHub

---

## 🏗️ Architecture

The application consists of three services managed through Docker Compose:

```text
                    ┌─────────────────────┐
                    │     Flutter Web     │
                    │      Frontend       │
                    │       :80           │
                    └──────────┬──────────┘
                               │
                               │ HTTP Requests
                               ▼
                    ┌─────────────────────┐
                    │   Node.js / Express │
                    │       Backend       │
                    │       :8000         │
                    └──────────┬──────────┘
                               │
                               │ MySQL
                               ▼
                    ┌─────────────────────┐
                    │      MySQL 8.0      │
                    │      Container      │
                    │       :3306         │
                    └──────────┬──────────┘
                               │
                               ▼
                       Persistent Volume
                         mysql_data
```

---

## 📁 Project Structure

```text
placement_project/
│
├── backend/
│   ├── database/
│   │   └── connection.js
│   │
│   ├── functions/
│   │   ├── applications.js
│   │   ├── authFunctions.js
│   │   └── dsaFunctions.js
│   │
│   ├── middleware/
│   │   └── authMiddleware.js
│   │
│   ├── routes/
│   │   └── routes.js
│   │
│   ├── Dockerfile
│   ├── index.js
│   ├── package.json
│   └── package-lock.json
│
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   └── main.dart
│   │
│   ├── Dockerfile
│   ├── pubspec.yaml
│   └── ...
│
├── docker-compose.yml
├── .gitignore
└── README.md
```

---

## ⚙️ Getting Started

### Prerequisites

Make sure the following are installed:

- Git
- Flutter
- Dart
- Node.js
- npm
- Docker
- Docker Compose

---

## 🖥️ Running the Backend Locally

Navigate to the backend:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

Create a `.env` file:

```bash
touch .env
```

Add your environment variables:

```env
PORT=8000

DB_HOST=localhost
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=your_database

JWT_SECRET=your_secret
```

Start the backend:

```bash
npm start
```

The backend will run on:

```text
http://localhost:8000
```

> Never commit the `.env` file or real credentials to GitHub.

---

## 🌐 Running the Frontend Locally

Navigate to the frontend:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run -d chrome
```

To create a production web build:

```bash
flutter build web
```

---

## 🐳 Running with Docker

The project uses Dockerfiles for the frontend and backend and Docker Compose to manage the application services.

From the project root:

```bash
docker compose up --build
```

To run the containers in detached mode:

```bash
docker compose up -d --build
```

Check the running containers:

```bash
docker compose ps
```

View container logs:

```bash
docker compose logs
```

Stop the application:

```bash
docker compose down
```

---

## 🗄️ Database

The project uses **MySQL 8.0** as its database.

MySQL runs as a separate Docker Compose service and uses a persistent Docker volume:

```text
mysql_data
```

This allows database data to persist when containers are stopped or recreated.

The MySQL service maps:

```text
Host:      3307
Container: 3306
```

The backend communicates with MySQL through the Docker network using the MySQL container's internal port `3306`.

---

## ☁️ AWS Deployment

The application has been deployed to an **AWS EC2** instance using Docker.

The deployment architecture is:

```text
                         GitHub
                            │
                            ▼
                      Docker Images
                            │
                            ▼
                       Docker Hub
                            │
                            ▼
                         AWS EC2
                            │
                      Docker Compose
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
         Frontend        Backend        MySQL
         Container       Container      Container
```

The EC2 instance runs the Dockerized application, with the required ports configured through the EC2 security group.

---

## 🔐 Environment Variables

Sensitive configuration is stored using environment variables rather than being hard-coded into the source code.

Example variables:

```env
PORT=
DB_HOST=
DB_USER=
DB_PASSWORD=
DB_NAME=
JWT_SECRET=
```

Actual credentials are intentionally excluded from this repository.

---

## 📦 Docker Images

The frontend and backend are built as separate Docker images.

Example:

```bash
docker build -t placement-backend ./backend
docker build -t placement-frontend ./frontend
```

The images can then be pushed to Docker Hub and pulled by the deployment environment.


## 🎯 What I Learned

This project provided hands-on experience with:

- Full-stack application development
- Flutter Web development
- REST API development
- Node.js and Express
- MySQL database integration
- Authentication and protected routes
- Dockerizing applications
- Docker Compose
- Container networking
- Persistent Docker volumes
- Docker image management
- Docker Hub
- AWS EC2 deployment
- Linux server administration
- Environment variable and secret management
- Git and GitHub

---

## 🔮 Future Improvements

- CI/CD pipeline
- HTTPS and custom domain
- Automated database backups
- Improved monitoring and logging
- More DSA problems and preparation resources
- Placement preparation analytics
- Better application tracking and filtering
- Additional interview preparation modules

---

## 👨‍💻 Author

**Tapabrata Dutta**

Computer Science Student

GitHub: [Tapabrata-Dutta](https://github.com/Tapabrata-Dutta)

---

## ⭐ Project

If you find this project useful or interesting, consider giving the repository a star.