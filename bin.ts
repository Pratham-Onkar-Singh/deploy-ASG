import os from "os"
import cluster from "cluster"
import { app } from ".";

const total_cpus = os.cpus().length;

if(cluster.isPrimary) {
  // Explicitly set round-robin scheduling (default on most platforms except Windows < Node 16)
  cluster.schedulingPolicy = cluster.SCHED_RR;
  
  console.log(`Primary process ${process.pid} is running`);
  console.log(`CPU Cores: ${total_cpus}`);
  console.log(`Scheduling Policy: Round-Robin`);
  console.log(`Forking ${total_cpus} workers...`);
  
  for (let i = 0;i < total_cpus;i++) {
    const worker = cluster.fork();
    console.log(`Worker ${worker.process.pid} started`);
  }
  
  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died. Restarting...`);
    cluster.fork();
  });
  
} else {
  app.listen(3000, () => {
    console.log(`Worker ${process.pid} listening on port 3000`);
  })
}

