const express = require('express');
const bcrypt = require('bcrypt');
const con = require('./db'); // MySQL connection
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ----- login -----
app.post('/login', (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).send("Username and password required");
    }

    const sql = "SELECT id, password FROM users WHERE username = ?";
    con.query(sql, [username], (err, results) => {
        if (err) return res.status(500).send("Database server error");
        if (results.length !== 1) return res.status(401).send("Wrong username");

        bcrypt.compare(password, results[0].password, (err, same) => {
            if (err) return res.status(500).send("Hashing error");
            if (same) {
                return res.json({ message: "Login OK", userId: results[0].id });
            }
            return res.status(401).send("Wrong password");
        });
    });
});

// ----- show user -----
app.get('/users', (req, res) => {
    const sql = "SELECT id, username FROM users";
    con.query(sql, (err, results) => {
        if (err) return res.status(500).send("Database server error");
        res.json(results);
    });
});

// Get all expenses 
app.get('/expenses/:userId', (req, res) => {
    const userId = req.params.userId;
    const sql = "SELECT * FROM expenses WHERE user_id = ?";
    con.query(sql, [userId], (err, results) => {
        if (err) return res.status(500).send("Database server error");
        res.json(results);
    });
});

// Get today's expenses
app.get('/expenses/today/:userId', (req, res) => {
    const userId = req.params.userId;
    const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    const sql = "SELECT * FROM expenses WHERE user_id = ? AND DATE(date) = ?";
    con.query(sql, [userId, today], (err, results) => {
        if (err) return res.status(500).send("Database server error");
        res.json(results);
    });
});

app.get('/expenses/:userId/search', (req, res) => {
    const userId = req.params.userId;
    const search = req.query.keyword;
    if (!search || !userId) {
        return res.status(400).send("Keyword and userId required");
    }
    const sql = "SELECT * FROM expenses WHERE user_id = ? AND item LIKE ?";
    const searchPattern = '%' + search + '%';
    con.query(sql, [userId, searchPattern], (err, results) => {
        if (err) return res.status(500).send('Database error!');
        res.json(results);
    });
});



// Add new expense
app.post('/expenses/add', (req, res) => {
    const { userId, item, paid } = req.body;
    if (!userId || !item || !paid) return res.status(400).send("userId, item and paid required");

    const sql = "INSERT INTO expenses (user_id, item, paid, date) VALUES (?, ?, ?, NOW())";
    con.query(sql, [userId, item, paid], (err, result) => {
        if (err) return res.status(500).send("Database server error");
        res.json({ message: "Expense added", expenseId: result.insertId });
    });
});

// Delete expense 
app.delete('/expenses/delete/:id', (req, res) => {
    const id = req.params.id;
    const sql = "DELETE FROM expenses WHERE id = ?";
    con.query(sql, [id], (err, result) => {
        if (err) return res.status(500).send("Database server error");
        if (result.affectedRows === 0) return res.status(404).send("Expense not found");
        res.json({ message: "Expense deleted" });
    });
});


const PORT = 3000;
app.listen(PORT, () => console.log("Server running at port " + PORT));
