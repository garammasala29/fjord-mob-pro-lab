// 要件
// 単語のランク付け
// 単語のスコアは'a'以外の文字ごとに1ポイント与える計算方法
// 単語の配列が与えられたら、スコアの高い順に並べ替えた配列を返す
// 追加1
// 単語に'c'が入っている場合はボーナスポイントとして5点加算
// ボーナスなしの場合のスコアリングは継続
// 追加2
// ペナルティスコア
// 単語に's'が含まれていたら　7ポイントのペナルティ

// ポイント計算
// function score(word) {
//   return [...word].filter(w => w != 'a').length
// }
function score(word) {
  // 'haskell' -> ['h', 'skell'] -> 'hskell'
  return word.split("a").join("").length
}

function bonus(word) {
  return word.includes('c') ? 5 : 0
}

function penalty(word) {
  return word.includes('s') ? 7 : 0
}

// 並べ替え
function rankedWords(wordScore, words) {
  const compareFn = (word1, word2) => wordScore(word2) - wordScore(word1)
  return words.toSorted(compareFn)
}


const words = ['haskell', 'ruby', 'javascript', 'aaaaaaaa', 'c++']
// 計算ロジックだけ渡したらうまいこと並び替えて欲しい
console.log(rankedWords(score, words)) // => ["javascript", "haskell", "ruby", "c++", "aaaaaaaa" ]
console.log(rankedWords((w) => score(w) + bonus(w), words)) // ["javascript", "c++", "haskell", "ruby", "aaaaaaaa"]
console.log(rankedWords((w) => score(w) + bonus(w) - penalty(w), words))

// 追加要件
// word の　スコアをリスト化して欲しい
