import jwt from "jsonwebtoken"
import dotenv from "dotenv"

dotenv.config()

const JWT_SECRET = process.env.JWT_SECRET || "placement_prep_secret_key"

export const verifyToken = (req, res, next) => {
    const authHeader = req.headers["authorization"]
    const token = authHeader && authHeader.split(" ")[1] // Bearer <token>

    if (!token) {
        return res.status(401).json({ status: false, message: "Access denied. No token provided." })
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET)
        req.userId = decoded.userId 
        next()
    } catch (error) {
        return res.status(403).json({ status: false, message: "Invalid or expired token." })
    }
}