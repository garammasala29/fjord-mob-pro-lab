
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

// puts(mySample([1, 2, 3, 4, 5, 6, 7]))
// puts(mySample([1, 2, 3, 4, 5, 6, 7], 4))

const myFilterMap = (ary, callback) => {
  const newArray = [];
  for(const i of ary){
    const result = callback(i)
    if (result){
      newArray.push(result)
    }
  }
  return newArray;
}

puts(myFilterMap([1, 2, 3, 4, 5, 6, 7, 8], (i) => {
    if (i % 2 === 0) {
      return i * 2
    }
  })
)

const myPartition = (ary, callback) => {
  const trueArray = [];
  const falseArray = [];

  for (const element of ary) {
    const bool = callback(element)
    if (bool) {
      trueArray.push(element);
    } else {
      falseArray.push(element);
    }
  }

  return [trueArray, falseArray];
}
const myMax = (ary, num = 1) => {
  const newArray = [...ary]
  if (num === 1) {
    return  newArray.sort((a, b) => b - a).at(0);
  } else {
    return  newArray.sort((a, b) => b - a).slice(0, num);
  }
};

puts(
  myMax([3, 5, 8, 2, 10, 4, 6, 11], 3) // 11
);

// 次回js回ラスト
// - grep_v
// - inject
// - zip
// slice

