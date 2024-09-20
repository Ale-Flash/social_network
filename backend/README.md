# ExpressJS API with MySQL, JWT Authentication, and CRUD Operations Overview

This project is a RESTful API built with Express.js, using MySQL as the database, and JSON Web Token (JWT) for user authentication. The API allows users to register, login, and perform various actions like creating posts, liking posts, adding comments, and more. It also supports role-based access control by using tokens to authenticate and authorize requests.

## Features

- **User Authentication**: Users can register and log in to get JWT tokens for secure access.
- **Protected Routes**: Certain routes require a valid JWT token to access.
- **CRUD Operations**:
    - Create and delete posts.
    - Like and unlike posts.
    - Comment on posts.
- **Post and User Ranking**: Get rankings of users based on the number of likes, comments, or posts.
- **Database**: MySQL is used for persistent storage of user data, posts, likes, and comments.

## Installation

1. Clone the repository.
    ```bash
    git clone https://github.com/Ale-Flash/social_network.git
    ```

2. Navigate to the project directory.
    ```bash
    cd social_network
    ```

3. Install the required dependencies.
    ```bash
    npm install
    ```

4. Create a .env file in the root directory with the following variables:
    ```env
    PORT=3000
    HOST=localhost
    USER_DB=your_mysql_username
    PASSWORD=your_mysql_password
    DB=your_database_name
    TOKEN_SECRET=your_jwt_secret_key
    ```

5. Ensure your MySQL server is running and the database specified in the `.env` file is created.

6. Start the server.
    ```bash
    npm start
    ```

## API Endpoints
Public Endpoints

- `GET /`: Serves the home page (index.html).

- `POST /register`: Registers a new user. Requires username and password in the request body.

- `POST /login`: Logs in a user and returns a JWT token. Requires username and password in the request body.

Protected Endpoints (Require JWT Authentication)

- `POST /post`: Creates a new post. Requires title and content in the request body.

- `DELETE /post`: Deletes a post created by the logged-in user. Requires post (post ID) in the request body.

- `POST /comment`: Adds a comment to a post. Requires post (post ID) and content in the request body.

- `POST /like`: Likes a post. Requires post (post ID) in the request body.

- `DELETE /like`: Removes a like from a post. Requires post (post ID) in the request body.

- `GET /likes/:post`: Retrieves the like count for a specific post.

- `GET /isliked/:post`: Checks if the logged-in user has liked a specific post.

- `GET /comments/:post/:start/:end`: Retrieves comments for a post with pagination.

- `GET /profile`: Retrieves the profile of the logged-in user.

- `GET /ranking/:mode/:start/:end`: Retrieves the ranking of users based on mode (likes, comments, or posts) with pagination.

Other Endpoints

- `GET /status`: Returns a simple 200 OK response for health checks.

## Authentication

Authentication is handled using JWT. After logging in, a token is issued which must be included in the Authorization header as a Bearer token for any protected routes.

## Error Handling

The API uses standard HTTP status codes for error handling:

- `400 Bad Request`: Input validation errors.
- `401 Unauthorized`: Missing or invalid JWT.
- `403 Forbidden`: Access denied or invalid credentials.
- `404 Not Found`: Resources not found.
- `500 Internal Server Error`: Server-side errors.

## Database Schema
#### Users Table

- `id`: Primary key, auto-incremented.
- `username`: Unique username for the user.
- `password`: Hashed password stored in the database.

#### Posts Table

- `id`: Primary key, auto-incremented.
- `title`: Title of the post.
- `content`: Content of the post.
- `user_id`: Foreign key referring to the user who created the post.

#### Likes Table

- `user_id`: Foreign key referring to the user who liked the post.
- `post_id`: Foreign key referring to the liked post.

#### Comments Table

- `id`: Primary key, auto-incremented.
- `post_id`: Foreign key referring to the commented post.
- `user_id`: Foreign key referring to the user who commented.
- `content`: Comment text.
