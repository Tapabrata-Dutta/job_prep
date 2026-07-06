import dotenv from "dotenv"
import mysql from "mysql2/promise"

dotenv.config()

const hasDbConfig = Boolean(process.env.DB_HOST && process.env.DB_USER && process.env.DB_PASS && process.env.DB)

export let db = null

if (hasDbConfig) {
    db = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASS,
        database: process.env.DB,
    })

    await db.execute(`
        CREATE TABLE IF NOT EXISTS dsaTable (
            id INT AUTO_INCREMENT PRIMARY KEY,
            question TEXT NOT NULL,
            isSolve BOOLEAN NOT NULL DEFAULT FALSE
        )
    `)
    await db.execute(`
        CREATE TABLE IF NOT EXISTS applicationTable (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR (255) NOT NULL,
        applied BOOLEAN NOT NULL DEFAULT FALSE, 
        status VARCHAR (255) NOT NULL DEFAULT 'pending'
        )
    `)
} else {
    console.warn("Database config missing. Falling back to in-memory DSA storage.")
}