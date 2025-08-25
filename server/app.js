const express = require('express');
const bcrypt = require('bcrypt');
const con = require('./db'); 
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ----- login -----
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json("Username and password required");
    }

    const sql = "SELECT id, password FROM users WHERE username = ?";
    con.query(sql, [username], (err, results) => {
        if (err) return res.status(500).json("Database server error" );
        if (results.length !== 1) return res.status(401).json("Wrong username");

        bcrypt.compare(password, results[0].password, (err, same) => {
            if (err) return res.status(500).json("Hashing error");
            if (same) {
                return res.json({ message: " ", userId: results[0].id });
            }
            return res.status(401).json("Wrong password");
        });
    });
});

// ----- show all users -----
app.get('/users', (req, res) => {
    const sql = "SELECT id, username FROM users";
    con.query(sql, (err, results) => {
        if (err) return res.status(500).json("Database server error");
        res.json(results);
    });
});

// Get all expenses 
app.get('/expenses/:userId', (req, res) => {
    const userId = req.params.userId;
    const sql = "SELECT * FROM expenses WHERE user_id = ?";
    con.query(sql, [userId], (err, results) => {
        if (err) return res.status(500).json("Database server error");
        res.json(results);
    });
});

// Get today's expenses
app.get('/expenses/today/:userId', (req, res) => {
    const userId = req.params.userId;
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    const sql = "SELECT * FROM expenses WHERE user_id = ? AND DATE(date) = ?";
    con.query(sql, [userId, today], (err, results) => {
        if (err) return res.status(500).json("Database server error");
        res.json(results);
    });
});

// Search expense by keyword
app.get('/expenses/:userId/search', (req, res) => {
    const userId = req.params.userId;
    const search = req.query.keyword;
    if (!search || !userId) {
        return res.status(400).json("Keyword and userId required");
    }
    const sql = "SELECT * FROM expenses WHERE user_id = ? AND item LIKE ?";
    const searchPattern = '%' + search + '%';
    con.query(sql, [userId, searchPattern], (err, results) => {
        if (err) return res.status(500).json("Database server error");
        res.json(results);
    });
});

// Add new expense
app.post('/expenses', (req, res) => {
    const { user_id, item, paid } = req.body;   
    if (!user_id || !item || !paid) {
        return res.status(400).json("user_id, item and paid required");
    }

    const sql = "INSERT INTO expenses (user_id, item, paid, date) VALUES (?, ?, ?, NOW())";
    con.query(sql, [user_id, item, paid], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).json("Database server error");
        }
        res.status(201).json("Expense added",result.insertId);
    });
});

// Delete expense 
app.delete('/expenses/:id', (req, res) => {   
    const id = req.params.id;
    const sql = "DELETE FROM expenses WHERE id = ?";
    con.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: "Database server error" });
        if (result.affectedRows === 0) return res.status(404).json("Expense not found");
        res.json("Expense deleted");
    });
});

const PORT = 3000;
app.listen(PORT, () => console.log(" Server running at http://localhost:" + PORT));
