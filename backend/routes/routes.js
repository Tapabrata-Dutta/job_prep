import express from "express"
import { createDSA, deleteQuestion, getDSA, updateDSA } from "../functions/dsaFunctions.js"
import { createApplication, deleteApplication, getApplications, updateApplication } from "../functions/applications.js"
import { signup, login } from "../functions/authFunctions.js"
import { verifyToken } from "../middleware/authMiddleware.js"

const router = express.Router()

router.get("/health", (_req, res) => {
    res.status(200).json({ status: true, message: "Backend is healthy" })
})

// Authentication Routes
router.post("/api/auth/signup", signup)
router.post("/api/auth/login", login)

// Protected DSA Routes
router.get("/api/dsa", verifyToken, getDSA)
router.get("/api/dsa/:id", verifyToken, getDSA)
router.post("/api/dsa", verifyToken, createDSA)
router.put("/api/dsa/:id", verifyToken, updateDSA)
router.delete("/api/dsa/:id", verifyToken, deleteQuestion)

// Protected Application Routes
router.get("/api/applications", verifyToken, getApplications)
router.get("/api/applications/:id", verifyToken, getApplications)
router.post("/api/applications", verifyToken, createApplication)
router.put("/api/applications/:id", verifyToken, updateApplication)
router.delete("/api/applications/:id", verifyToken, deleteApplication)

export default router