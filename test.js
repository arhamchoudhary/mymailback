const nodemailer = require('nodemailer');







async function sendEmail(to, subject, text) {

  //  const proxyUrl = 'socks5://HbJdCD:kHqc8F@217.29.63.202:12695';




    let transporter = nodemailer.createTransport({ 
  service: 'gmail',
  auth: {
    user: "collinbunnyvhin@gmail.com", 
    pass: "yhmy opvp olkd obot",
  },
  name: "198.8.8.1"
    });

    let mailOptions = {
        from: {
            name: 'Josh',
            address: "collinbunnyvhin@gmail.com"
        },
        to: to,
        subject: subject,
        text: text
    };

    try {
        let info = await transporter.sendMail(mailOptions);
        console.log('Email sent: ' + info.response);
    } catch (error) {
        console.error('Error sending email: ' + error);
    }
}

// Usage example
sendEmail('arhamc241@gmail.com', 'Test Subject', 'Test email body');
