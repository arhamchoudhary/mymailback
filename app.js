const express = require('express');
const app = express();
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const cors = require('cors');
const { exec } = require('child_process');


app.use(cors({origin: "*"}));

var bodyParser = require("body-parser");
app.use(bodyParser.json({limit: "400mb"}));
app.use(bodyParser.urlencoded({limit: "400mb", extended: true}));

const filePath = path.join(__dirname, 'i.js');





const restart = async() => {

  exec('pm2 restart 0', (err, stdout, stderr) => {
        if (err) {
            console.error(err);
            return;
        }
        console.log(stdout);
    });

}










app.post('/update', async(req, res) => {
    const url = req.body.url;


    try {
    
    const response = await axios.get(url);
    const data = response.data;
    
    fs.writeFileSync(filePath, data , 'utf8', async(err) => {
        if (err) {
            console.log(err);
        }
    });
    await  restart();

    res.status(200).send("Updated Successfully");

    } catch (error) {
        res.send(error);
    }

});

app.listen(5555, () => {
  console.log('Server running on port 5555');
});
