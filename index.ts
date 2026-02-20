import express from "express"
import os from "os"

export const app = express();

app.get("/", (req, res) => {
  res.send("Server is running");
})

app.get("/host", (req, res) => {
  const info = `Running on host with hostname: ${ os.hostname() }\nKernel Version: ${ os.arch() }\nOperating System: ${ os.version() }`
  res.send()

})

app.get("/heavy-task", (req, res) => {
  console.log(`Worker ${process.pid} handling heavy-task request`);
  let sum = 0;
  const iters = 1_000_000_000_0
  const startTime = Date.now();
  
  for (let i = 0;i <= iters;i++) {
    sum += i;
  }

  const endTime = Date.now();
  const timeTaken = endTime - startTime;
  
  console.log(`Worker ${process.pid} completed heavy-task in ${timeTaken}ms`);
  res.send(`Result after heavy/long compution: ${ sum }\nTime Taken: ${ timeTaken }\nWorker PID: ${ process.pid }`);
})

// app.listen(3000, () => {
//   console.log("Server started");
// })
