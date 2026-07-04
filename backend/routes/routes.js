import express from "express"
import { createDSA, deleteQuestion, getDSA, updateDSA } from "../functions/dsaFunctions.js"

const router = express.Router()

router.get("/health", (_req, res) => {
    res.status(200).json({ status: true, message: "Backend is healthy" })
})

router.get("/api/dsa", getDSA)
router.get("/api/dsa/:id", getDSA)
router.post("/api/dsa", createDSA)
router.put("/api/dsa/:id", updateDSA)
router.delete("/api/dsa/:id", deleteQuestion)

export default router