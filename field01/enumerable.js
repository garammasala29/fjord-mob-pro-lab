
// Array.prototype.myForEach = function(callback) {
//   for(let i = 0; i < this.length; i++){
//     const elem = this[i]
//     callback(elem);
//   }
// }

const myForEach = (ary, callback)  => {
  for(let i = 0; i < ary.length; i++){
    const elem = ary[i]
    callback(elem);
  }
}
// myForEach([1, 2, 3], (n) => console.log(n * 3));

const myMap = (ary, callback) => {
  const newArray = [];

  for (const n of ary) {
    const elem = callback(n)
    newArray.push(elem);
  }

  return newArray
}



const puts = console.log
// puts(myMap([1, 2, 3], (n) => n * 3)) // [3, 6, 9]
// puts(myMap([1, 2, 3], (n) => n >= 3)) // [false, false, true]

// puts(myFilter([1, 2, 3], (n) => n * 3))

const myFilter = (ary, callback) => {
  const newArray = [];

  for (i = 0; i < ary.length; i++ ) {
    const elem = callback(ary[i])
    if (elem) {
      newArray.push(ary[i])
    }
  }
  return newArray
}

// puts(myFilter([1, 2, 3], (n) => n >= 3))
// puts(myFilter([1, 2, 3], (n) => n >= 4))

// 方針
// falseのオブジェクトを作る
const mySample = (ary, num = 1) => {
  const newArray = []
  const table = {}

  // リストの作成（初期化）
  // {1: false, 2: false, 3: false}
  for (n of ary) {
    table[n] = false
  }

  while(true){
    const rand = Math.floor(Math.random() * ary.length)

    // ループの中でループを回してる
    // includesはnewArray全部チェックしてしまってる
    // 計算量多い（涙）
    if(table[ary[rand]]){
      continue
    }

    newArray.push(ary[rand])
    // 詰めたものをtrueに更新する作業
    table[ary[rand]] = true

    if(newArray.length === num){
        break
    }
  }

  // newArrayのlengthみて、戻り値を変える
  if (newArray.length === 1) {
    return newArray[0]
  }

  return newArray
}

console.log(globalThis)

puts(mySample([1, 2, 3, 4, 5, 6, 7]))
puts(mySample([1, 2, 3, 4, 5, 6, 7], 4))
