import {db} from "../database/connection.js";
import dotenv from "dotenv";

dotenv.config();

const companyNames = [];

const normalization = (value) => {
    if (typeof value === "boolean") return value;
    if(typeof value === "number") return 1;
    if(typeof value === "string") {
        const lower = value.toLowerCase().trim();
        if(["true", "1", "yes", "y", "done", "applied"].includes(lower)) return true;
        if(["false", "0", "no", "n", "pending", "not done", "notdone"].includes(lower)) return false; 
    }      
}

const normalizeRow = (row) => ({
    ...row,
    applied: normalization(row.applied)
})

const ensureSeedData = () => {
    if(companyNames.length === 0) {
        companyNames.push(
            {id: 1, userId: 1, name: "Google", applied: false, status: "pending"},
            {id: 2, userId: 1, name: "Microsoft", applied: true, status: "accepted"}
        )
    }
}

export const getApplications = async (req, res)=>{
    const {id} = req.params;
    const userId = req.userId
    
    try {
        if(!db) {
            ensureSeedData();
            const application = id ? companyNames.find((item) => item.id === Number(id) && item.userId === userId) : null;
            if(id && !application) {
                return res.status(404).json({status: false, message: "id not found"});
            }
            const data = id ? application : companyNames.filter((item) => item.userId === userId)
            return res.status(200).json({
                status: true,
                data
            });
        }
        if(id) {
            const [rows] = await db.execute("SELECT * FROM applicationTable WHERE id = ? AND userId = ?", [id, userId]);
            if(rows.length === 0) {
                return res.status(404).json({status: false, message: "id not found"});
            }
            return res.status(200).json({status: true, data: normalizeRow(rows[0])});
        }
        const [rows] = await db.execute("SELECT * FROM applicationTable WHERE userId = ? ORDER BY id DESC", [userId]);
        return res.status(200).json({status: true, data: rows.map(normalizeRow)});
    } catch (error) {
        return res.status(500).json({status: false, message: error.message});
    }
}

export const createApplication = async (req, res) => {
    const { name, applied, status } = req.body;
    const userId = req.userId

    if (!name || typeof name !== "string" || !name.trim()) {
        return res.status(400).json({ status: false, message: "Please provide a valid company name" });
    }

    try {
        if (!db) {
            ensureSeedData();
            const newApplication = {
                id: companyNames.length + 1,
                userId,
                name: name.trim(),
                applied: normalization(applied ?? false),
                status: typeof status === "string" && status.trim() ? status.trim() : "pending"
            };
            companyNames.unshift(newApplication);
            return res.status(201).json({ status: true, message: "Successfully inserted", data: newApplication });
        }

        const [result] = await db.execute(
            "INSERT INTO applicationTable (userId, name, applied, status) VALUES (?, ?, ?, ?)",
            [userId, name.trim(), normalization(applied ?? false), typeof status === "string" && status.trim() ? status.trim() : "pending"]
        );

        const [rows] = await db.execute("SELECT * FROM applicationTable WHERE id = ? AND userId = ?", [result.insertId, userId]);
        return res.status(201).json({ status: true, message: "Successfully inserted", data: normalizeRow(rows[0]) });
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message });
    }
}

export const updateApplication = async (req, res) => {
    const { id } = req.params;
    const { name, applied, status } = req.body;
    const userId = req.userId

    if (!id) {
        return res.status(400).json({ status: false, message: "Id is required" });
    }

    try {
        if (!db) {
            ensureSeedData();
            const index = companyNames.findIndex((item) => item.id === Number(id) && item.userId === userId);
            if (index === -1) {
                return res.status(404).json({ status: false, message: "ID not found" });
            }
            companyNames[index] = {
                ...companyNames[index],
                name: typeof name === "string" && name.trim() ? name.trim() : companyNames[index].name,
                applied: typeof applied !== "undefined" ? normalization(applied) : companyNames[index].applied,
                status: typeof status === "string" && status.trim() ? status.trim() : companyNames[index].status
            };
            return res.status(200).json({ status: true, message: "Successfully updated", data: companyNames[index] });
        }

        const updates = [];
        const values = [];

        if (typeof name === "string" && name.trim()) {
            updates.push("name = ?");
            values.push(name.trim());
        }
        if (typeof applied !== "undefined") {
            updates.push("applied = ?");
            values.push(normalization(applied));
        }
        if (typeof status === "string" && status.trim()) {
            updates.push("status = ?");
            values.push(status.trim());
        }

        if (updates.length === 0) {
            return res.status(400).json({ status: false, message: "Nothing to update" });
        }

        values.push(id, userId);
        const [result] = await db.execute(`UPDATE applicationTable SET ${updates.join(", ")} WHERE id = ? AND userId = ?`, values);
        if (result.affectedRows === 0) {
            return res.status(404).json({ status: false, message: "ID not found" });
        }

        const [rows] = await db.execute("SELECT * FROM applicationTable WHERE id = ? AND userId = ?", [id, userId]);
        return res.status(200).json({ status: true, message: "Successfully updated", data: normalizeRow(rows[0]) });
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message });
    }
}

export const deleteApplication = async (req, res) => {
    const { id } = req.params;
    const userId = req.userId

    if (!id) {
        return res.status(400).json({ status: false, message: "Id not found" });
    }

    try {
        if (!db) {
            ensureSeedData();
            const index = companyNames.findIndex((item) => item.id === Number(id) && item.userId === userId);
            if (index === -1) {
                return res.status(404).json({ status: false, message: "Id not found" });
            }
            companyNames.splice(index, 1);
            return res.status(200).json({ status: true, message: "Successfully deleted" });
        }

        const [result] = await db.execute("DELETE FROM applicationTable WHERE id = ? AND userId = ?", [id, userId]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ status: false, message: "Id not found" });
        }
        return res.status(200).json({ status: true, message: "Successfully deleted" });
    } catch (error) {
        return res.status(500).json({ status: false, message: error.message });
    }
}
