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
        CREATE TABLE IF NOT EXISTS userTable (
            userId INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR (255) NOT NULL,
            email VARCHAR (255) NOT NULL UNIQUE,
            password VARCHAR (255) NOT NULL
        )
    `)
    await db.execute(`
        CREATE TABLE IF NOT EXISTS dsaTable (
            id INT AUTO_INCREMENT PRIMARY KEY,
            userId INT NOT NULL DEFAULT 0,
            question TEXT NOT NULL,
            isSolve BOOLEAN NOT NULL DEFAULT FALSE,
            FOREIGN KEY (userId) REFERENCES userTable(userId) ON DELETE CASCADE
        )
    `)
    await db.execute(`
        CREATE TABLE IF NOT EXISTS applicationTable (
            id INT AUTO_INCREMENT PRIMARY KEY,
            userId INT NOT NULL DEFAULT 0,
            name VARCHAR (255) NOT NULL,
            applied BOOLEAN NOT NULL DEFAULT FALSE, 
            status VARCHAR (255) NOT NULL DEFAULT 'pending',
            FOREIGN KEY (userId) REFERENCES userTable(userId) ON DELETE CASCADE
        )
    `)

    await db.execute(`
        ALTER TABLE dsaTable ADD COLUMN IF NOT EXISTS userId INT NOT NULL DEFAULT 0
    `)
    await db.execute(`
        ALTER TABLE applicationTable ADD COLUMN IF NOT EXISTS userId INT NOT NULL DEFAULT 0
    `)
} else {
    console.warn("Database config missing. Falling back to in-memory DSA storage.")
}