const express = require("express")
const app = express();
const cors = require("cors");

app.use(cors({origin: "*"}));
var bodyParser = require("body-parser");
app.use(bodyParser.json({limit: "400mb"}));
app.use(bodyParser.urlencoded({limit: "400mb", extended: true}));
var admin = require("firebase-admin");
const PORT = 5000;


////firebase
var serviceAccount = require("./mymail-294f5-firebase-adminsdk-skfom-84bd254a95.json");
const { getFirestore, Timestamp, FieldValue, Filter } = require('firebase-admin/firestore');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = getFirestore();






//// aws/////
const AWS = require("aws-sdk");
const awsConfig = require("./aws.json")
AWS.config.update(awsConfig);
const ec2 = new AWS.EC2();





/// get instance status.
app.post("/getStatus",(req,res)=>{

  const params = {InstanceIds: [req.body.id || "invalidId"]};

  ec2.describeInstances(params, (err, data) => {
    if (err) {
      res.send({
      status:false,
      err:err.code
      })
    } else {
      const instance = data.Reservations[0].Instances[0]; // Assuming only one instance is returned
      const publicIpAddress = instance.PublicIpAddress;
      const State = instance.State.Name
      res.send({
        publicIpAddress,
        status:State
      })

    }
  });
})




// start instance 
app.post("/startInstance",(req,res)=>{

  const params = {InstanceIds: [req.body.id || "invalidId"]};


 
  ec2.startInstances(params, (err, data) => {
      if (err) {
      res.send({
            status:false,
            err:err.code
      })
      } else {
         res.send({
          status:data.StartingInstances[0].CurrentState.Name
         })
      }
  }
  );
})


// stop instance 
app.post("/stopInstance",(req,res)=>{

  const params = {InstanceIds: [req.body.id || "invalidId"]};

  ec2.stopInstances(params, (err, data) => {
    if (err) {
      res.send({
        status:false,
        err:err.code
  })
    } else {
        console.dir(data,{depth:null})
        res.send({
          status:data.StoppingInstances[0].CurrentState.Name
    })
    }
}
);

 
  
})








/// aws end//


app.listen(PORT,()=>{console.log("Server Started....")})
