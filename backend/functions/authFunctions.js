import bcrypt from "bcryptjs"
import jwt from "jsonwebtoken"
import { db } from "../database/connection.js"
import dotenv from "dotenv"

dotenv.config()

const JWT_SECRET = process.env.JWT_SECRET || "placement_prep_secret_key"

// In-memory fallback if the database connection isn't running
const memoryUsers = []

export const signup = async (req, res) => {
    const { name, email, password } = req.body

    if (!name || !email || !password) {
        return res.status(400).json({ status: false, message: "All fields are required (name, email, password)" })
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10)

        if (!db) {
            // Check if user already exists in memory
            const existingUser = memoryUsers.find(u => u.email === email)
            if (existingUser) {
                return res.status(400).json({ status: false, message: "User already exists with this email" })
            }

            const newUser = {
                userId: memoryUsers.length + 1,
                name,
                email,
                password: hashedPassword
            }
            memoryUsers.push(newUser)

            const token = jwt.sign({ userId: newUser.userId }, JWT_SECRET, { expiresIn: "24h" })
            return res.status(201).json({
                status: true,
                message: "Signup successful",
                token,
                user: { userId: newUser.userId, name: newUser.name, email: newUser.email }
            })
        }

        // DB implementation: Check if email already exists
        const [existing] = await db.execute("SELECT * FROM userTable WHERE email = ?", [email])
        if (existing.length > 0) {
            return res.status(400).json({ status: false, message: "User already exists with this email" })
        }

        // DB implementation: Insert new user
        const [result] = await db.execute(
            "INSERT INTO userTable (name, email, password) VALUES (?, ?, ?)",
            [name, email, hashedPassword]
        )

        const token = jwt.sign({ userId: result.insertId }, JWT_SECRET, { expiresIn: "24h" })

        return res.status(201).json({
            status: true,
            message: "Signup successful",
            token,
            user: { userId: result.insertId, name, email }
        })

    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}

export const login = async (req, res) => {
    const { email, password } = req.body

    if (!email || !password) {
        return res.status(400).json({ status: false, message: "Email and password are required" })
    }

    try {
        if (!db) {
            const user = memoryUsers.find(u => u.email === email)
            if (!user) {
                return res.status(400).json({ status: false, message: "Invalid email or password" })
            }

            const isMatch = await bcrypt.compare(password, user.password)
            if (!isMatch) {
                return res.status(400).json({ status: false, message: "Invalid email or password" })
            }

            const token = jwt.sign({ userId: user.userId }, JWT_SECRET, { expiresIn: "24h" })
            return res.status(200).json({
                status: true,
                message: "Login successful",
                token,
                user: { userId: user.userId, name: user.name, email: user.email }
            })
        }

        // DB implementation: Find user by email
        const [rows] = await db.execute("SELECT * FROM userTable WHERE email = ?", [email])
        if (rows.length === 0) {
            return res.status(400).json({ status: false, message: "Invalid email or password" })
        }

        const user = rows[0]
        const isMatch = await bcrypt.compare(password, user.password)
        if (!isMatch) {
            return res.status(400).json({ status: false, message: "Invalid email or password" })
        }

        const token = jwt.sign({ userId: user.userId }, JWT_SECRET, { expiresIn: "24h" })

        return res.status(200).json({
            status: true,
            message: "Login successful",
            token,
            user: { userId: user.userId, name: user.name, email: user.email }
        })

    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}
