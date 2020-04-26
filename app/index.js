const express = require('express')
const app = express()
const port = 3000

app.get('/api', (req, res) => res.send('Hello World!'))
app.get('/status', (req, res) => res.send('working!'))

app.listen(port, () => console.log(`Example app listening on port ${port}!`)) 
