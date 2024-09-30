
import { getStringArrayFromJson, testMethod, uint8TransformString} from './utils';
import { buffer, taskpool } from '@kit.ArkTS';
import { ThreadUtils } from './ThreadUtils';

// export function stringToUint8Array(str: string) {
//   return new Uint8Array(buffer.from(str, 'utf-8').buffer);
// }
@Concurrent
export async function consumerTask(ArrayBuffer: Int32Array, dataBuffer: Uint8Array): Promise<void> {
  let i32a = ArrayBuffer;
  let array = dataBuffer

  while (true) {
    let jsonStr: string = uint8TransformString(array)
    let arr = getStringArrayFromJson(jsonStr)

    if (arr.length == 0) {
      Atomics.wait(i32a, 0, 0);
    } else {
      let i = 4
      for (let index = 0; index < array.byteLength; index++) {
        if (i >= array.byteLength) {
          break
        }
        Atomics.store(array, i++, 0)
      }
      taskpool.Task.sendData(true)
      let writeResult: boolean = true
      while ((writeResult == true || writeResult == false)) {
        let ele = arr.shift()
        if (!ele) {
          break
        }
        writeResult = await ThreadUtils.getInstance().writeToFile(ele)
        console.log('-----atomics-consumer-' + ele)
      }

    }
  }
}


