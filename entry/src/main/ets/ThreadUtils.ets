import { taskpool } from '@kit.ArkTS';
import { it } from '@ohos/hypium';
import { consumerTask } from './consumer';
import { producer } from './product';

export class ThreadUtils {

  private tempLogList: Array<string> = new Array()

  private static instance: ThreadUtils
  private sab :SharedArrayBuffer
  private ui8 :Uint8Array
  private i32a :Int32Array

  private constructor(bufferSize:number = 1024) {
    this.sab = new SharedArrayBuffer(bufferSize)
    this.ui8 = new Uint8Array(this.sab)
    this.i32a = new Int32Array(this.sab)
    this.startConsumer()
  };

  writeLog(log: string) {
    if (this.flag) {
      this.tempLogList.push(log)
    }else {
      this.product(log)
    }

  }

  public static getInstance(bufferSize:number = 1024): ThreadUtils {
    if (!ThreadUtils.instance) {
      ThreadUtils.instance = new ThreadUtils(bufferSize);
    }
    return ThreadUtils.instance;
  }


  async writeToFile(content: string): Promise<boolean> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {

        console.log("日志写入完成=" + content)
        console.log('pop element=' + content)
        resolve(true)
      }, 4000)
    })
  }

  flag = false
  async product(log: string):Promise<boolean> {
    return new Promise<boolean>((resolve,reject)=>{
      let newLog = log
      let task = new taskpool.Task(producer, this.i32a, this.ui8, newLog)
      task.onReceiveData((success: boolean) => {
        if (!success) {
          this.flag = true
          this.tempLogList.unshift(log)
          resolve(false)
        }
      })
      taskpool.execute(task).then(()=>{
        console.log('------taskpool.execute.then-----')
        resolve(true)
      });
    })


  }

  isWhile = false
  async startConsumer() {
    let task = new taskpool.Task(consumerTask, this.i32a, this.ui8)
    task.onReceiveData(async (hasSpace: boolean) => {
      if (hasSpace) {
        this.flag = false
        if (this.tempLogList.length > 0 && this.isWhile == false){
          let item = this.tempLogList.shift()
          console.log('---item---'+ item)
          this.isWhile = true
          let com = true
          while (item && this.flag == false && com){
            com = await this.product(item)
            item = this.tempLogList.shift()
          }
          this.isWhile = false
        }

      }
    })
    taskpool.execute(task)
  }

}