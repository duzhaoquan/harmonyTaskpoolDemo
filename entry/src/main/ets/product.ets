
import { taskpool } from '@kit.ArkTS';
import { stingToUint8, uint8TransformString } from './utils';

@Concurrent
export async function producer(ArrayBuffer: Int32Array, dataBuffer: Uint8Array, newStr: string) {
  let i32a = ArrayBuffer;
  let array = dataBuffer
  if (array[array.length-1] !== 0) {
    taskpool.Task.sendData(false)
    console.log("-----atomics-producer-push-fal-" + newStr)
    return
  }
  let jsonStr: string = uint8TransformString(array)

  let arr: string[] = []
  try {
    arr= JSON.parse(jsonStr) as string[]
  } catch (e) {
    taskpool.Task.sendData(false)
    return
  }

  arr.push(newStr)
  let newArrJson = JSON.stringify(arr) ?? ''
  //console.log("newArrJson" + newArrJson)
  let isFinish = stingToUint8(newArrJson,array,4)
  if (!isFinish) {
    arr.pop()
    let newArrJson1 = JSON.stringify(arr) ?? ''
    stingToUint8(newArrJson1,array,4)
    taskpool.Task.sendData(false)
    console.log("-----atomics-producer-push-fal-" + newStr)
  }else{
    console.log("-----atomics-producer-push-sec-" + newStr)
  }

  Atomics.notify(i32a, 0, 1)
  Promise.resolve()
}
