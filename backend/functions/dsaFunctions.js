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

const ensureSeedData = () => {
    if (memoryQuestions.length === 0) {
        memoryQuestions.push(
            { id: 1, question: "Solve two array problems", isSolve: false },
            { id: 2, question: "Revise binary trees", isSolve: true }
        )
    }
}

export const getDSA = async (req, res) => {
    const { id } = req.params

    try {
        if (!db) {
            ensureSeedData()
            const question = id ? memoryQuestions.find((item) => item.id === Number(id)) : null
            if (id && !question) {
                return res.status(404).json({ status: false, message: "id not found" })
            }
            return res.status(200).json({
                status: true,
                data: id ? question : memoryQuestions
            })
        }

        if (id) {
            const [rows] = await db.execute("SELECT * FROM dsaTable WHERE id = ?", [id])
            if (rows.length === 0) {
                return res.status(404).json({ status: false, message: "id not found" })
            }
            return res.status(200).json({ status: true, data: normalizeQuestionRow(rows[0]) })
        }

        const [rows] = await db.execute("SELECT * FROM dsaTable ORDER BY id DESC")
        return res.status(200).json({ status: true, data: rows.map(normalizeQuestionRow) })
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}

export const createDSA = async (req, res) => {
    const { question, isSolve } = req.body

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
                question: question.trim(),
                isSolve: normalizeBoolean(isSolve)
            }
            memoryQuestions.unshift(newQuestion)
            return res.status(201).json({ status: true, message: "Successfully inserted", data: newQuestion })
        }

        const [result] = await db.execute(
            "INSERT INTO dsaTable (question, isSolve) VALUES (?, ?)",
            [question.trim(), normalizeBoolean(isSolve)]
        )

        const [rows] = await db.execute("SELECT * FROM dsaTable WHERE id = ?", [result.insertId])

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

    if (!id) {
        return res.status(400).json({ status: false, message: "Id is required" })
    }

    try {
        if (!db) {
            ensureSeedData()
            const index = memoryQuestions.findIndex((item) => item.id === Number(id))
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

        values.push(id)
        const [result] = await db.execute(`UPDATE dsaTable SET ${updates.join(", ")} WHERE id = ?`, values)

        if (result.affectedRows === 0) {
            return res.status(404).json({ status: false, message: "ID not found" })
        }

        const [rows] = await db.execute("SELECT * FROM dsaTable WHERE id = ?", [id])

        return res.status(200).json({ status: true, message: "Successfully updated", data: normalizeQuestionRow(rows[0]) })
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}

export const deleteQuestion = async (req, res) => {
    const { id } = req.params

    if (!id) {
        return res.status(400).json({ status: false, message: "Id not found" })
    }

    try {
        if (!db) {
            ensureSeedData()
            const index = memoryQuestions.findIndex((item) => item.id === Number(id))
            if (index === -1) {
                return res.status(404).json({ status: false, message: "Id not found" })
            }
            memoryQuestions.splice(index, 1)
            return res.status(200).json({ status: true, message: "Successfully deleted" })
        }

        const [result] = await db.execute("DELETE FROM dsaTable WHERE id = ?", [id])
        if (result.affectedRows === 0) {
            return res.status(404).json({ status: false, message: "Id not found" })
        }
        return res.status(200).json({ status: true, message: "Successfully deleted" })
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message })
    }
}