

touch package.json 
echo '{
  "name": "gapi",
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
    "axios": "^1.5.0",
    "body-parser": "^1.20.0",
    "cors": "^2.8.5",
    "express": "^4.18.1",
    "firebase-admin": "^11.10.1",
    "html-to-text": "^9.0.5",
    "jspdf": "^2.5.1",
    "multer": "^1.4.5-lts.1",
    "mustache": "^4.2.0",
    "nodemailer": "^6.7.3",
    "ordersid-generator": "^1.9.3",
    "path": "^0.12.7",
    "pdf-lib": "^1.17.1",
    "puppeteer": "^21.2.1",
    "serve-index": "^1.9.1",
    "socket.io": "^4.5.4"
  }
}


' > package.json
mkdir pdf
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt install npm -y
sudo apt install libgbm1 libatk1.0-0 libatk1.0-dev libx11-xcb1 libxcb-dri3-0 libxcomposite1 libxdamage1 libxi6 libxtst6 libnss3 libcups2 libxss1 libxrandr2 libasound2 libpangocairo-1.0-0 libatk-bridge2.0-0 libgtk-3-0 -y
npm i
sudo npm install -g pm2






