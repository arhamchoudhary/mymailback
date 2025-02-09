echo '
const express = require("express");
const app = express();
const fs = require("fs");
const path = require("path");
const axios = require("axios");
const cors = require("cors");
const { exec } = require("child_process");


app.use(cors({origin: "*"}));

var bodyParser = require("body-parser");
app.use(bodyParser.json({limit: "400mb"}));
app.use(bodyParser.urlencoded({limit: "400mb", extended: true}));

const filePath = path.join(__dirname, "i.js");





const restart = async() => {

  exec("pm2 restart 0", (err, stdout, stderr) => {
        if (err) {
            console.error(err);
            return;
        }
        console.log(stdout);
    });

}


app.post("/update", async(req, res) => {
    const url = req.body.url;


    try {
    
    const response = await axios.get(url);
    const data = response.data;
    
    fs.writeFileSync(filePath, data , "utf8", async(err) => {
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
  console.log("Server running on port 5555");
});

' > app.js

touch i.js
echo '' > i.js


touch package.json 
echo '
{
  "name": "mymailback",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "address": "^1.2.2",
    "aws-sdk": "^2.1532.0",
    "axios": "^1.5.0",
    "body-parser": "^1.20.0",
    "cors": "^2.8.5",
    "express": "^4.18.1",
    "firebase-admin": "^11.11.1",
    "googleapis": "^140.0.0",
    "html-to-docx": "^1.8.0",
    "html-to-text": "^9.0.5",
    "jspdf": "^2.5.1",
    "multer": "^1.4.5-lts.1",
    "mustache": "^4.2.0",
    "nodemailer": "^6.7.3",
    "ordersid-generator": "^1.9.3",
    "path": "^0.12.7",
    "pdf-lib": "^1.17.1",
    "puppeteer": "^22.15.0",
    "serve-index": "^1.9.1",
    "socket.io": "^4.5.4",
    "socks": "^2.8.3"
  }
}
' > package.json
mkdir pdf
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt install npm -y
sudo npm install -g pm2

sudo apt install libgbm1 libatk1.0-0 libatk1.0-dev libx11-xcb1 libxcb-dri3-0 libxcomposite1 libxdamage1 libxi6 libxtst6 libnss3 libcups2 libxss1 libxrandr2 libasound2t64 libpangocairo-1.0-0 libatk-bridge2.0-0 libgtk-3-0 -y
npm i


pm2 start i.js
pm2 start app.js

pm2 startup

sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu







