echo '
const { createServer } = require("http"); 
const express = require("express")
const nodemailer = require("nodemailer")
const cors = require("cors");
const path = require("path");
const app = express();
const OrderID = require("ordersid-generator")
const Mustache = require("mustache")
app.use(cors({origin: "*"}));
const puppeteer = require("puppeteer");

var bodyParser = require("body-parser");
app.use(bodyParser.json({limit: "400mb"}));
app.use(bodyParser.urlencoded({limit: "400mb", extended: true}));

const fs = require("fs");
const { PDFDocument } = require("pdf-lib");


//// socket io
const socketIo = require("socket.io");
const  axios  = require("axios");
const e = require("express");
const server = createServer(app);
const io = socketIo(server, { cors: { origin: "*" } }); 

const PORT = 5000;


app.use((req, res, next) => {
  req.io = io;
  return next();
});


app.get("/",(req,res)=>{
  res.send("Hello World")
}
)


// new tags gen ////


const aphabets = "abcdefghijklmnopqrstuvwxyz";
const capital = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const numbers = "0123456789";

const generateRandomId = (length,config) => {
  let result = " ";
  const characters = `${config.aphabets?aphabets:""}${config.capital?capital:""}${config.number?numbers:""}`;
  const charactersLength = characters.length;

  for ( let i = 0; i < length; i++ ) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

const ts = generateRandomId(2,{
  aphabets:false,
  capital:false,
  number:true
})





const delpdfs = async() => {

  fs.readdir("./pdf", (err, files) => {
    if (err) {
      console.log(err);
      return;
    }

    // Loop through the files and delete each PDF file
    files.forEach(file => {
      if (path.extname(file).toLowerCase() === ".pdf") {
        fs.unlinkSync(path.join("./pdf", file));
      }
    });
  });


}








// create a sleep function

const sleep = (ms) => {
  return new Promise(resolve => setTimeout(resolve, ms));
}




 let si=0;
 let t=0;
 let shouldContinueSending = true;

 app.post("/stop",(req,res)=>{
  shouldContinueSending = false;
  res.send({status:true,msg:"Stopped Sending"})
}
)


const generatePdf = async (list, pdfhtml, pdfProducer, pdfCreator, imagePdf,tags) => {

    var count = 0;

    io.emit("attachment",{count:count,loading:true})

    const browser = await puppeteer.launch(
    {
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    }
    );

    const page = await browser.newPage();

    for (const l of list) {

        if (!shouldContinueSending) {
            await browser.close();
            break;
        }

        count++;
        io.emit("attachment",{count:count,loading:true})

        var data ={
            id:OrderID("short"),
            name:l.name,
            email:l.email,
            c3:l.c3,
            c4:l.c4,
            c5:l.c5,
            c6:l.c6,
            }

        var tagsData = {};

        tags.forEach((t)=>{
            tagsData[t.name] = generateRandomId(t.size,t);
        }
        )

        var pdfhtmlContent = Mustache.render(pdfhtml,{...data,...tagsData});
        if(imagePdf){
          await page.setContent(pdfhtmlContent);
            const screenshotBuffer = await page.screenshot({ fullPage: true });
            const base64Image = screenshotBuffer.toString("base64");
            const phtml = `
            <html style="height:100%">
                <img src="data:image/png;base64,${base64Image}" alt="Screenshot">
            </html>
            `;
            await page.setContent(phtml);
        }else{
            await page.setContent(pdfhtmlContent);
        }
        await page.pdf({ path: `pdf/${l.email}.pdf`,printBackground:true});

    }
    await page.close();
    await browser.close();
    io.emit("attachment",{count:count,loading:false})

}






 app.post("/send-mails", async (req, res) => {

  shouldContinueSending = true;


  await delpdfs();
  let transporters = [];
  const list = req.body.list ||[];
  const smtps = req.body.smtps;
  const senderName = req.body.senderName;
  const text = req.body.text || "";
  const filename = req.body.filename || "";
  const pdfProducer = req.body.pdfProducer || "";
  const pdfCreator = req.body.pdfCreator || "";
  const delay = req.body.delay || 0;
  const connection = req.body.connection || 3;
  const htmlBody = req.body.htmlBody || "";
  const subject = req.body.subject || "";
  const sendPdf = req.body.sendPdf || false;

  const customTags = req.body.customTags || [];
  const imagePdf = req.body.imagePdf || false;



  var pdfhtml = req.body.pdfHtml || "";

  
  const code = req.body.code || "";
  const dbip = `http://${code}:5555`



  var emaillist  = list.map((r)=>{
    return {
      email:r.email,
      name:r.name
    }
  })
  
  axios.post(dbip+"/upload",emaillist).then((response)=>{
   
  }).catch((err)=>{
  }).finally(()=>{

    emaillist = [];


  }
  )
  
   
  try {
    

  let processCount = 0;
  let errorCount = 0;





          if(sendPdf){
            await generatePdf(list, pdfhtml, pdfProducer, pdfCreator, imagePdf,customTags,imagePdf);
          }





          const smtpPromises = smtps.map(async (s) => {
     

            const transporter = nodemailer.createTransport(s);
      
      
      
            await transporter.verify().then((res) => {
      
              transporters.push({
                user: s.auth.user,
                trans: transporter
              });
             
              io.emit("smtp", {connectedSmtp:transporters.length});
      
            }).catch((err) => {
              io.emit("smtp", {connectedSmtp:transporters.length,error:err.response,user:s.auth.user,pass:s.auth.pass});
            }
            );
      
          });
      
      
          await Promise.all(smtpPromises)





          



          if(transporters.length === 0){
            res.send({
                status:false,
                msg:"No Smtp Connected"
            })
            return;
          } 



 for (const l of list) {

  if (!shouldContinueSending) {
    //res.send({status: true,msg: `Sending Stoped`,});
    break;
  }

      const {name,email,id} = l;
      
        var data ={
          id:OrderID("short"),
          name:l.name,
          email:l.email,
          c3:l.c3,
          c4:l.c4,
          c5:l.c5,
          c6:l.c6,
        }
      
        var tagsData = {};

        customTags.forEach((t)=>{
          tagsData[t.name] = generateRandomId(t.size,t);
        })
    
          var htmlConent = Mustache.render(htmlBody,{...data,...tagsData});
          var textContent = Mustache.render(text,{...data,...tagsData});
          var subjectContent = Mustache.render(subject,{...data,...tagsData});
        


          var pdfhtmlContent = Mustache.render(pdfhtml,{...data,...tagsData});
          var pdfname = Mustache.render(filename,{...data,...tagsData});

      await sleep(delay);

      t++;
      if(t===parseInt(connection)){
             t = 0;
             if(si<transporters.length-1){
               si++;
             }else{
               si=0;
             }
        }

     

       transporters[si].trans.sendMail({
              from: { name: senderName,
              address:transporters[si].user},

              subject: subjectContent,
              to: l.email,
              html:htmlConent,
              text: textContent,
            attachments:sendPdf?[{filename: `${pdfname}.pdf`,
                          path: `pdf/${email}.pdf`
          }]:[],
  }

            
            ).then((response)=>{
             
              processCount++;

              req.io.emit("count", {processCount:processCount,errorCount:errorCount,listLength:list.length});

            if (processCount === list.length) {res.send({status: true,msg: `${processCount} emails sent successfully`,});}
     

    
            }
          ).catch((err)=>{
            
            

            errorCount++;
            processCount++;


            req.io.emit("count", {processCount:processCount,errorCount:errorCount,listLength:list.length});

            req.io.emit("errorlog", {error:err.response,reci:l.email,smtp:transporters[si].user});

            if (processCount === list.length) {res.send({status: true,msg: `${processCount} emails sent successfully`,});}

            
              

          }
         )
        };

       






  } 
  catch (err) {
    console.log(err);
  }

});



server.listen(PORT,()=>{console.log("Server Started....")})


' > index.js



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
    "puppeteer": "^22.15.0",
    "serve-index": "^1.9.1",
    "socket.io": "^4.5.4"
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


pm2 start index.js

pm2 startup

sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu







