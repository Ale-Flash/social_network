const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2');
const dotenv = require('dotenv');
const crypto = require('crypto');

dotenv.config({ path: __dirname + '/.env' });

const saltRounds = 10;
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const port = process.env.PORT;

const HttpStatusCode = {
    OK: 200,
    BAD_REQUEST: 400,
    UNAUTHORIZED: 401,
    FORBIDDEN: 403,
    NOT_FOUND: 404,
    INTERNAL_SERVER_ERROR: 500,
}

let con = mysql.createConnection({
    host: process.env.HOST,
    user: process.env.USER_DB,
    password: process.env.PASSWORD,
    database: process.env.DB
});

con.connect((err) => {
    if (err) throw err;
    console.log("Connected to DataBase");
});

async function connectMySQL() {
    con = mysql.createConnection({
        host: process.env.HOST,
        user: process.env.USER_DB,
        password: process.env.PASSWORD,
        database: process.env.DB
    });

    await (new Promise((resolve, reject) => {
        con.connect((err) => {
            if (err) throw err;
            resolve();
        });
    }));
}

function checkString(str) {
    if (str == null || str == undefined) return false;
    if (str.length < 1) return false;

    return true;
}

function checkStrings(...strs) {
    for (let str of strs) {
        if (!checkString(str)) return false;
    }
    return true;
}

function generateAccessToken(id) {
    return jwt.sign({
        'sub': id,
        'aud': 'http://204.216.223.6',
        'jti': crypto.randomBytes(16).toString('hex'),
    }, process.env.TOKEN_SECRET, { expiresIn: '12d' });
}

function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (token == null) return res.sendStatus(HttpStatusCode.UNAUTHORIZED);

    jwt.verify(token, process.env.TOKEN_SECRET, (err, user) => {
        if (err) return res.sendStatus(HttpStatusCode.FORBIDDEN);

        con.query('SELECT id, username FROM users WHERE id=?', [user.sub], (err, result, fields) => {
            if (err) connectMySQL();
            if (result == null) return res.sendStatus(HttpStatusCode.FORBIDDEN);

            req.user = result[0];
            next();
        });
    });
}

app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
});

app.post('/login', (req, res) => {
    console.log('POST /login', req.body.username, req.body.password);

    if (!checkStrings(req.body.username, req.body.password)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('SELECT * FROM users WHERE username=?', [req.body.username], (err, result, fields) => {
        if (result === null) return res.sendStatus(HttpStatusCode.FORBIDDEN);
        bcrypt.compare(req.body.password, result[0].password, (err, resu) => {
            if (!resu) return res.sendStatus(HttpStatusCode.FORBIDDEN);

            const token = generateAccessToken(result[0].id);
            return res.json({ token: token });
        });
    });
});

app.post('/register', (req, res) => {
    console.log('POST /register', req.body.username, req.body.password);

    if (!checkStrings(req.body.username, req.body.password)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    // check if username is already taken
    con.query("SELECT * FROM users WHERE username=?", [req.body.username], (err, result, fields) => {
        if (result.length > 0) return res.sendStatus(HttpStatusCode.FORBIDDEN);

        bcrypt.hash(req.body.password, saltRounds, (err, hash) => {
            con.query('INSERT INTO users (username, password) VALUE (?, ?)', [req.body.username, hash], (err, result, fields) => {
                if (err) throw err;

                const token = generateAccessToken(result.insertId);
                return res.json({ token: token });
            });
        });
    });
});

app.get('/status', (req, res) => {
    console.log('GET /status');

    return res.sendStatus(HttpStatusCode.OK);
});

app.post('/post', authenticateToken, (req, res) => {
    console.log('POST /post', req.body.title, req.body.content);

    if (!checkStrings(req.body.title, req.body.content)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('INSERT INTO posts (title, content, user_id) VALUE (?, ?, ?)',
        [req.body.title, req.body.content, req.user.id],
        (err, result, fields) => {
            if (err) throw err;
            return res.sendStatus(HttpStatusCode.OK);
        });
});

app.delete('/post', authenticateToken, (req, res) => {
    console.log('DELETE /post', req.body.post);

    if (!checkStrings(req.body.post)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('DELETE FROM posts WHERE id=? AND user_id=?', [req.body.post, req.user.id], (err, result, fields) => {
        if (err) throw err;
        return res.sendStatus(HttpStatusCode.OK);
    });
});

app.post('/comment', authenticateToken, (req, res) => {
    console.log('POST /comment', req.body.post, req.body.content);

    if (!checkStrings(req.body.post, req.body.content)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('INSERT INTO comments (post_id, user_id, content) VALUE (?, ?, ?)',
        [req.body.post, req.user.id, req.body.content],
        (err, result, fields) => {
            if (err) throw err;
            return res.sendStatus(HttpStatusCode.OK);
        });
});

app.post('/like', authenticateToken, (req, res) => {
    console.log('POST /like', req.body.post);

    if (!checkStrings(req.body.post)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('SELECT * FROM likes WHERE user_id=? AND post_id=?', [req.user.id, req.body.post], (err, result, fields) => {
        if (result.length > 0) return res.sendStatus(HttpStatusCode.OK);

        con.query('INSERT INTO likes (user_id, post_id) VALUE (?, ?)',
            [req.user.id, req.body.post],
            (err, result, fields) => {
                if (err) throw err;
                return res.sendStatus(HttpStatusCode.OK);
            });
    });
});

app.delete('/like', authenticateToken, (req, res) => {
    console.log('DELETE /like', req.body.post);

    if (!checkStrings(req.body.post)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('SELECT * FROM likes WHERE user_id=? AND post_id=?', [req.user.id, req.body.post], (err, result, fields) => {
        if (result.length == 0) return res.sendStatus(HttpStatusCode.OK);

        con.query('DELETE FROM likes WHERE user_id=? AND post_id=?',
            [req.user.id, req.body.post],
            (err, result, fields) => {
                if (err) throw err;
                return res.sendStatus(HttpStatusCode.OK);
            });
    });
});

app.get('/likes/:post', authenticateToken, (req, res) => {
    console.log('GET /likes', req.params.post);

    if (!checkString(req.params.post)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    const post_id = parseInt(req.params.post);
    if (post_id == null) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('SELECT COUNT(user_id) AS likes FROM likes WHERE post_id=?', [post_id], (err, result, fields) => {
        if (err) throw err;
        return res.json(result[0]);
    });
});

app.get('/posts/:user/:start/:end', authenticateToken, (req, res) => {
    console.log('GET /posts', req.params.user, req.params.start, req.params.end);

    if (!checkStrings(req.params.user, req.params.start, req.params.end)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    const user = parseInt(req.params.user);
    const start = parseInt(req.params.start);
    const end = parseInt(req.params.end);
    if (user == null || start == null || end == null) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    if (user == 0) {
        con.query('SELECT p.*, u.username, COUNT(l.user_id) AS likes, COUNT(DISTINCT c.id) AS comments FROM posts p LEFT JOIN likes l ON p.id=l.post_id LEFT JOIN comments c ON p.id=c.post_id INNER JOIN users u ON p.user_id=u.id GROUP BY p.id ORDER BY time_stamp DESC LIMIT ?, ?',
            [start, end],
            (err, result, fields) => {
                if (err) throw err;
                return res.json(result);
            });
    } else {
        con.query('SELECT p.*, u.username, COUNT(l.user_id) AS likes, COUNT(DISTINCT c.id) AS comments FROM posts p INNER JOIN users u ON p.user_id=u.id LEFT JOIN likes l ON p.id=l.post_id LEFT JOIN comments c ON p.id=c.post_id WHERE u.id=? GROUP BY p.id ORDER BY time_stamp DESC LIMIT ?, ?',
            [user, start, end],
            (err, result, fields) => {
                if (err) throw err;
                return res.json(result);
            });
    }
});

app.get('/isliked/:post', authenticateToken, (req, res) => {
    console.log('GET /isliked', req.params.post);

    if (!checkString(req.params.post)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);
    const post = parseInt(req.params.post);
    if (post == null) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('SELECT * FROM likes WHERE user_id=? AND post_id=?', [req.user.id, post], (err, result, fields) => {
        if (err) throw err;
        return res.sendStatus(result.length > 0 ? HttpStatusCode.OK : HttpStatusCode.NOT_FOUND);
    });
});

app.get('/comments/:post/:start/:end', authenticateToken, (req, res) => {
    console.log('GET /comments', req.params.post, req.params.start, req.params.end);

    if (!checkStrings(req.params.post, req.params.start, req.params.end)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    const post = parseInt(req.params.post);
    const start = parseInt(req.params.start);
    const end = parseInt(req.params.end);
    if (post == null || start == null || end == null) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    con.query('SELECT c.*, u.username FROM comments c INNER JOIN users u ON c.user_id=u.id WHERE c.post_id=? ORDER BY time_stamp DESC LIMIT ?, ?', [post, start, end], (err, result, fields) => {
        if (err) throw err;
        return res.json(result);
    });
});

app.get('/profile', authenticateToken, (req, res) => {
    console.log('GET /profile', req.user.username);
    return res.json(req.user);
});

app.get('/ranking/:mode/:start/:end', authenticateToken, (req, res) => {
    console.log('GET /ranking', req.params.mode, req.params.start, req.params.end);

    if (!checkStrings(req.params.mode, req.params.start, req.params.end)) return res.sendStatus(HttpStatusCode.BAD_REQUEST);

    const mode = req.params.mode;
    const start = parseInt(req.params.start);
    const end = parseInt(req.params.end);

    if (mode == 'likes') {
        con.query('SELECT u.username, COUNT(l.user_id) AS likes FROM likes l INNER JOIN users u ON l.user_id=u.id GROUP BY l.user_id ORDER BY likes DESC LIMIT ?, ?',
            [start, end],
            (err, result, fields) => {
                if (err) throw err;
                return res.json(result);
            });
    } else if (mode == 'comments') {
        con.query('SELECT u.username, COUNT(c.user_id) AS comments FROM comments c INNER JOIN users u ON c.user_id=u.id GROUP BY c.user_id ORDER BY comments DESC LIMIT ?, ?',
            [start, end],
            (err, result, fields) => {
                if (err) throw err;
                return res.json(result);
            });
    } else if (mode == 'posts') {
        con.query('SELECT u.username, COUNT(p.user_id) AS posts FROM posts p INNER JOIN users u ON p.user_id=u.id GROUP BY p.user_id ORDER BY posts DESC LIMIT ?, ?',
            [start, end],
            (err, result, fields) => {
                if (err) throw err;
                return res.json(result);
            });
    } else {
        return res.sendStatus(HttpStatusCode.BAD_REQUEST);
    }
});

app.listen(port, () => {
    console.log(`Listening on port ${port}`);
});