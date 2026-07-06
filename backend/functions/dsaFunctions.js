import { db } from "../database/connection.js"
import dotenv from "dotenv"

dotenv.config()

const memoryQuestions = []

const normalizeBoolean = (value) => {
    if (typeof value === "boolean") return value
    if (typeof value === "number") return value === 1
    if (typeof value === "string") {
        const lower = value.toLowerCase().trim()
        if (["true", "1", "yes", "y", "done", "solved"].includes(lower)) return true
        if (["false", "0", "no", "n", "pending", "not done", "notdone"].includes(lower)) return false
    }
    return false
}

const normalizeQuestionRow = (row) => ({
    ...row,
    isSolve: normalizeBoolean(row.isSolve)
})

const parseUserId = (req) => {
    const rawUserId = req.header("x-user-id") ?? req.query.userId ?? req.body.userId
    const id = Number(rawUserId)
    return Number.isInteger(id) && id > 0 ? id : null
}

const requireUserId = (req, res) => {
    const userId = parseUserId(req)
    if (!userId) {
        res.status(401).json({ status: false, message: "Missing authenticated user id. Provide X-User-Id header or userId." })
    }
    return userId
}

const ensureSeedData = () => {
    if (memoryQuestions.length === 0) {
        memoryQuestions.push(
            { id: 1, userId: 1, question: "Solve two array problems", isSolve: false },
            { id: 2, userId: 1, question: "Revise binary trees", isSolve: true }
        )
    }
}

export const getDSA = async (req, res) => {
    const { id } = req.params
    const userId = requireUserId(req, res)
    if (!userId) return

    try {
        if (!db) {
            ensureSeedData()
            const question = id ? memoryQuestions.find((item) => item.id === Number(id) && item.userId === userId) : null
            if (id && !question) {
                return res.status(404).json({ status: false, message: "id not found" })
            }
            const data = id ? question : memoryQuestions.filter((item) => item.userId === userId)
            return res.status(200).json({ status: true, data })
        }

        if (id) {
            const [rows] = await db.execute("SELECT * FROM dsaTable WHERE id = ? AND userId = ?", [id, userId])
            if (rows.length === 0) {
                return res.status(404).json({ status: false, message: "id not found" })
            }
            return res.status(200).json({ status: true, data: normalizeQuestionRow(rows[0]) })
        }

        const [rows] = await db.execute("SELECT * FROM dsaTable WHERE userId = ? ORDER BY id DESC", [userId])
        return res.status(200).json({ status: true, data: rows.map(normalizeQuestionRow) })
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}

export const createDSA = async (req, res) => {
    const { question, isSolve } = req.body
    const userId = requireUserId(req, res)
    if (!userId) return

    if (!question || typeof question !== "string" || !question.trim()) {
        return res.status(400).json({
            status: false,
            message: "Please provide a valid question"
        })
    }

    try {
        if (!db) {
            ensureSeedData()
            const newQuestion = {
                id: memoryQuestions.length + 1,
                userId,
                question: question.trim(),
                isSolve: normalizeBoolean(isSolve)
            }
            memoryQuestions.unshift(newQuestion)
            return res.status(201).json({ status: true, message: "Successfully inserted", data: newQuestion })
        }

        const [result] = await db.execute(
            "INSERT INTO dsaTable (userId, question, isSolve) VALUES (?, ?, ?)",
            [userId, question.trim(), normalizeBoolean(isSolve)]
        )

        const [rows] = await db.execute("SELECT * FROM dsaTable WHERE id = ? AND userId = ?", [result.insertId, userId])

        return res.status(201).json({
            status: true,
            message: "Successfully inserted",
            data: normalizeQuestionRow(rows[0])
        })
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}

export const updateDSA = async (req, res) => {
    const { id } = req.params
    const { question, isSolve } = req.body
    const userId = requireUserId(req, res)
    if (!userId) return

    if (!id) {
        return res.status(400).json({ status: false, message: "Id is required" })
    }

    try {
        if (!db) {
            ensureSeedData()
            const index = memoryQuestions.findIndex((item) => item.id === Number(id) && item.userId === userId)
            if (index === -1) {
                return res.status(404).json({ status: false, message: "ID not found" })
            }
            memoryQuestions[index] = {
                ...memoryQuestions[index],
                question: question?.trim() || memoryQuestions[index].question,
                isSolve: normalizeBoolean(isSolve ?? memoryQuestions[index].isSolve)
            }
            return res.status(200).json({ status: true, message: "Successfully updated", data: memoryQuestions[index] })
        }

        const updates = []
        const values = []

        if (typeof question === "string" && question.trim()) {
            updates.push("question = ?")
            values.push(question.trim())
        }

        if (typeof isSolve !== "undefined") {
            updates.push("isSolve = ?")
            values.push(normalizeBoolean(isSolve))
        }

        if (updates.length === 0) {
            return res.status(400).json({ status: false, message: "Nothing to update" })
        }

        values.push(id, userId)
        const [result] = await db.execute(`UPDATE dsaTable SET ${updates.join(", ")} WHERE id = ? AND userId = ?`, values)

        if (result.affectedRows === 0) {
            return res.status(404).json({ status: false, message: "ID not found" })
        }

        const [rows] = await db.execute("SELECT * FROM dsaTable WHERE id = ? AND userId = ?", [id, userId])

        return res.status(200).json({ status: true, message: "Successfully updated", data: normalizeQuestionRow(rows[0]) })
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}

export const deleteQuestion = async (req, res) => {
    const { id } = req.params
    const userId = requireUserId(req, res)
    if (!userId) return

    if (!id) {
        return res.status(400).json({ status: false, message: "Id not found" })
    }

    try {
        if (!db) {
            ensureSeedData()
            const index = memoryQuestions.findIndex((item) => item.id === Number(id) && item.userId === userId)
            if (index === -1) {
                return res.status(404).json({ status: false, message: "Id not found" })
            }
            memoryQuestions.splice(index, 1)
            return res.status(200).json({ status: true, message: "Successfully deleted" })
        }

        const [result] = await db.execute("DELETE FROM dsaTable WHERE id = ? AND userId = ?", [id, userId])
        if (result.affectedRows === 0) {
            return res.status(404).json({ status: false, message: "Id not found" })
        }
        return res.status(200).json({ status: true, message: "Successfully deleted" })
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}