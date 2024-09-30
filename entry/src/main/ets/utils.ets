export function testMethod(str: string) {
  console.log('--test-function-str-' + str)
}
export function uint8TransformString(array:Uint8Array): string{
  let jsonStr: string = JSON.stringify([])
  let tempArr: number[] = []
  let j = 0
  for (let index = 0; index < array.length; index++) {
    if (array[index] == 0) {
      continue
    }
    tempArr[j++] = array[index]
  }

  let temp = new Uint8Array(tempArr)
  if (temp.byteLength > 0) {
    let str = '';
    for (let i = 0; i < temp.length; ) {
      let byte1 = temp[i];
      let codePoint: number

      if (byte1 >> 7 === 0) { // 1字节
        codePoint = byte1;
        i += 1;
      } else if (byte1 >> 5 === 0b110) { // 2字节
        codePoint = ((byte1 & 0b11111) << 6) | (temp[i + 1] & 0b111111);
        i += 2;
      } else if (byte1 >> 4 === 0b1110) { // 3字节
        codePoint = ((byte1 & 0b1111) << 12) | ((temp[i + 1] & 0b111111) << 6) | (temp[i + 2] & 0b111111);
        i += 3;
      } else {
        // 错误处理：不支持的字节序列
        i += 1; // 跳过当前字节
        continue;
      }
      str += String.fromCodePoint(codePoint)
      console.info('字节流转成可理解的字符串:' + str);

    }
    jsonStr = str
  }


  return jsonStr
}
//
export function stingToUint8(json: string, array:Uint8Array,formIndex: number = 0) : boolean{
  let i = formIndex
  let isFinish = true
  for (let index = 0; index < json.length; index++) {
    if (i >= array.byteLength) {
      if (index < json.length - 1) {
        isFinish = false
      }
      break
    }
    const element = json.charCodeAt(index);
    if (element > 0x7FF) {
      Atomics.store(array, i++, (0xE0 | (element >> 12)))
      Atomics.store(array, i++, (0x80 | ((element >> 6) & 0x3F)))
      Atomics.store(array, i++, (0x80 | (element & 0x3F)))
    } else if (element > 0x7F) {
      Atomics.store(array, i++, (0xC0 | (element >> 6)))
      Atomics.store(array, i++, (0x80 | (element & 0x3F)))
    } else {
      Atomics.store(array, i++, (element))
    }
  }
  //剩余空间赋值0
  for (let index = i; index < array.length; index++) {
    array[index] = 0
  }
  return isFinish
}

export function getStringArrayFromJson(json: string) : string[]{
  let jsonStr = json
  console.log('getStringArrayFromJson' + json)
  let arr: string[] = JSON.parse(jsonStr) as string[]
  console.log('getStringArrayFromJson arr' + arr)
  // jsonStr = jsonStr.slice(jsonStr.indexOf('[') + 1, jsonStr.indexOf(']'))
  // if (jsonStr.search(',') > -1) {
  //   arr = jsonStr.split(',')
  // } else if (jsonStr.length > 0) {
  //   arr = [jsonStr]
  // }
  // for (let i = 0; i < arr.length; i++){
  //   arr[i] = arr[i].slice(1,arr[i].length-1)
  // }
  return arr
}