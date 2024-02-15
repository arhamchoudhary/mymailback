

const dbip = "http://18.223.205.9:5555"

/// inside send function 




const emaillist  = list.map((r)=>{
  return {
    email:r.email,
    name:r.name
  }
})


axios.post(dbip+"/upload",emaillist).then((response)=>{
  console.log(response.data)
}).catch((err)=>{
  console.log(err)
})

 
 
