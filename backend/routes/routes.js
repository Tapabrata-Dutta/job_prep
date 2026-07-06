import express from "express"
import { createDSA, deleteQuestion, getDSA, updateDSA } from "../functions/dsaFunctions.js"
import { createApplication, deleteApplication, getApplications, updateApplication } from "../functions/applications.js"

const router = express.Router()

router.get("/health", (_req, res) => {
    res.status(200).json({ status: true, message: "Backend is healthy" })
})

router.get("/api/dsa", getDSA)
router.get("/api/dsa/:id", getDSA)
router.post("/api/dsa", createDSA)
router.put("/api/dsa/:id", updateDSA)
router.delete("/api/dsa/:id", deleteQuestion)

router.get("/api/applications", getApplications)
router.get("/api/applications/:id", getApplications)
router.post("/api/applications", createApplication)
router.put("/api/applications/:id", updateApplication)
router.delete("/api/applications/:id", deleteApplication)

export default router