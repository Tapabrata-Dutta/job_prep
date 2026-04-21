 export const dsaFunction = (req, res) => {
    const {id_name } = req.params
    if(!id_name){
        return  res.json({
            status: false,
            message: "Fill the id name"
        })
    }
}