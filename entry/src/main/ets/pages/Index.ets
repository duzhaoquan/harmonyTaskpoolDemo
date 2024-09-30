import { buffer, taskpool } from '@kit.ArkTS';
import { consumerTask } from '../consumer';
import { producer } from '../product';
import { router } from '@kit.ArkUI';
import { ThreadUtils } from '../ThreadUtils';


@Entry
@Component
struct Index {
  timer = -1
  count = 0
  logTool = ThreadUtils.getInstance(32)
  aboutToAppear(): void {

  }



  @State inputText:string =''
  build() {
    Column({space: 20}) {

      TextInput({text: $$this.inputText})
        .width('80%')
      Button() {
        Text("生产日志").padding(10)
      }
      .backgroundColor(Color.Gray)
      .onClick(async () => {

        this.timer = setInterval(()=>{
          this.logTool.writeLog ('item' + this.count)
          this.count += 1
        },1000)

      })
      Button() {
        Text("停止生产").padding(10)
      }
      .backgroundColor(Color.Gray)
      .onClick(async () => {
        clearInterval(this.timer)
        // router.pushUrl({
        //   url: 'pages/TaskPoolPage'
        // })

      })

    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }
}