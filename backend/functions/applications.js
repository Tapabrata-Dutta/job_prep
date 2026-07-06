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

const parseUserId = (req) => {
    const rawUserId = req.header("x-user-id") ?? req.query.userId ?? req.body.userId
    const id = Number(rawUserId)
    return Number.isInteger(id) && id > 0 ? id : null
}

const requireUserId = (req, res) => {
    const userId = parseUserId(req)
    if (!userId) {
        res.status(401).json({status: false, message: "Missing authenticated user id. Provide X-User-Id header or userId."})
    }
    return userId
}

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
    const userId = requireUserId(req, res)
    if (!userId) return
    
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
