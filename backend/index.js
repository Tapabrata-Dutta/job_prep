import express from "express"
import dotenv from "dotenv"
import router from "./routes/routes.js"

dotenv.config()

const app = express()
const port = process.env.PORT || 8000

app.use(express.json())
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE")
    if (req.method === "OPTIONS") {
        return res.sendStatus(200)
    }
    next()
})

app.use(router)

app.get("/", (_req, res) => {
    res.status(200).json({ status: true, message: "Placement Prep backend is running" })
})

app.listen(port, () => {
    console.log(`Server is listening on port ${port}`)
})