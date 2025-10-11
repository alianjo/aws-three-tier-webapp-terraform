const express = require("express");
const { Pool } = require("pg");

const app = express();
const port = process.env.PORT || 3000;

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  max: 5,
  connectionTimeoutMillis: 5000,
});

app.get("/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.status(200).json({ status: "ok" });
  } catch (err) {
    console.error("Database health check failed", err);
    res.status(500).json({ status: "error" });
  }
});

app.get("/", async (_req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json({
      message: "Hello from the three-tier web app API!",
      databaseTime: result.rows[0].now,
    });
  } catch (err) {
    console.error("Query failed", err);
    res.status(500).json({ error: "Database not available" });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
