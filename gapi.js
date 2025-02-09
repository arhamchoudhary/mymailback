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
const { google } = require("googleapis");
const MailComposer = require("nodemailer/lib/mail-composer");
var bodyParser = require("body-parser");
app.use(bodyParser.json({limit: "400mb"}));
app.use(bodyParser.urlencoded({limit: "400mb", extended: true}));

const fs = require("fs");
const { PDFDocument } = require("pdf-lib");


//// socket io
const socketIo = require("socket.io");
const  axios  = require("axios");
const server = createServer(app);
const io = socketIo(server, { cors: { origin: "*" } }); 

const PORT = 5000;

// add static files location for pdf foler 
app.use("/pdfs", express.static(__dirname + "/pdf"));

app.use((req, res, next) => {
  req.io = io;
  return next();
});


app.get("/",(req,res)=>{
  res.send("Hello World")
}
)


const testcharacters ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

function generateString(length) {

  const characters ="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
 let result = " ";
  const charactersLength = characters.length;
  for ( let i = 0; i < length; i++ ) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }

  return result;
}


function generateRandomLetter(length){
  const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let result = " ";
  const charactersLength = charset.length;
  for ( let i = 0; i < length; i++ ) {
      result += charset.charAt(Math.floor(Math.random() * charactersLength));
  }

  return result;
 
}

function getRandomNumber(min, max) {
  // Generate a random number between min and max (inclusive of min, exclusive of max)
  return Math.random() * (max - min) + min;
}














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



 app.post("/send-mails", async (req, res) => {







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
  

      const smtpPromises = smtps.map(async (s) => {
     

      const username = s.user;
      const password = s.pass;
      const CLIENT_ID = s.clientId;
      const CLEINT_SECRET = s.clientSecret;
      const REDIRECT_URI = s.redirectUri;

      
      const oAuth2Client = new google.auth.OAuth2(CLIENT_ID,CLEINT_SECRET,REDIRECT_URI);

      oAuth2Client.setCredentials({ refresh_token: password });
      const accessToken = await oAuth2Client.getAccessToken().then((res) => {
        const gmail =  google.gmail({ version: "v1", auth: oAuth2Client });

        transporters.push({
            user: username,
            gmail: gmail,
          });
      }).catch((err) => console.log(err));

      
     


       
        io.emit("smtp", {connectedSmtp:transporters.length});

    

    });


    await Promise.all(smtpPromises).then(()=>{
        if(transporters.length === 0){
          res.send({
              status:false,
              msg:"No Smtp Connected"
          })
        }
    })

    if(true){

  let processCount = 0;
  let errorCount = 0;

  const browser = await puppeteer.launch(
    {
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
  }
  );
          const page = await browser.newPage();



 for (const l of list) {

      const {name,email,id} = l;
      
        var data ={
          id:OrderID("short"),
          name:l.name,
          email:l.email,
          price:getRandomNumber(250,550),
          uid:generateString(8),
          sid:`${generateRandomLetter(2)}/${getRandomNumber(3)}-${generateRandomLetter(3)+generateString(2)}/${generateString(4)}`
        }
    
          var htmlConent = Mustache.render(htmlBody,data);
          var textContent = Mustache.render(text,data);
          var subjectContent = Mustache.render(subject,data);
        


          var pdfhtmlContent = Mustache.render(pdfhtml,data);
          var pdfname = Mustache.render(filename,data);

       if(sendPdf){

        
          await page.setContent(pdfhtmlContent);
          await page.pdf({ path: `pdf/${email}.pdf`, format: "A4" ,printBackground:true});
          const pdfBytes = fs.readFileSync(`pdf/${email}.pdf`);
          const pdfDoc = await PDFDocument.load(pdfBytes);
          pdfDoc.setProducer(pdfProducer);
          pdfDoc.setCreator(pdfCreator);
          const modifiedPdfBytes = await pdfDoc.save();
          fs.writeFileSync(`pdf/${email}.pdf`, modifiedPdfBytes);
          

       }
        


      await sleep(delay);

      t++;
      if(t===parseInt(connection)){
             t = 0;
             if(si<transporters.length-1){
               si++;
               console.log("smtp increse...........")
             }else{
               si=0;
             }
        }

        var rawMessage;

        if (sendPdf){
        const newMessage = new MailComposer({
            from: { name: senderName,
                address:transporters[si].user},
                subject: subjectContent,
                to: l.email,
                html:htmlConent,
                text: textContent,
                attachments:{
                  filename: `${pdfname||generateString(8)}.pdf`,
                  path: `pdf/${email}.pdf`,
                  contentType: "application/pdf"}    
        });
         rawMessage = await newMessage.compile().build();
      }else{
        const newMessage = new MailComposer({
          from: { name: senderName,
              address:transporters[si].user},
              subject: subjectContent,
              to: l.email,
              html:htmlConent,
              text: textContent,
      });
       rawMessage = await newMessage.compile().build();
        }


        const encodedMessage = Buffer.from(rawMessage)
        .toString("base64")



       transporters[si].gmail.users.messages.send({
            userId: "me",
            requestBody: {
              raw: encodedMessage,
            },
            }).then((response)=>{
              console.log(processCount)
              processCount++;
              req.io.emit("count", {processCount:processCount,errorCount:errorCount});

              if (processCount === list.length) {res.send({status: true,msg: `${processCount} emails sent successfully`,});}
           // console.log(response)
    
            }
          ).catch((err)=>{
            
            // console log error mess
            console.log(err)

            errorCount++;
            processCount++;


            req.io.emit("count", {processCount:processCount,errorCount:errorCount});

            req.io.emit("errorlog", {error:err.response,reci:l.email,smtp:transporters[si].user});

            if (processCount === list.length) {res.send({status: true,msg: `${processCount} emails sent successfully`,});}
            console.log(err)
              

          }
         )
        };

       


    console.log(processCount, list.length)

    }



  } 
  catch (err) {
    console.log(err);
  }

});



server.listen(PORT,()=>{console.log("Server Started....")})

