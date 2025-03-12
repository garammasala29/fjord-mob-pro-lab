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
// console.log(rankedWords(score, words)) // => ["javascript", "haskell", "ruby", "c++", "aaaaaaaa" ]
// console.log(rankedWords((w) => score(w) + bonus(w), words)) // ["javascript", "c++", "haskell", "ruby", "aaaaaaaa"]
// console.log(rankedWords((w) => score(w) + bonus(w) - penalty(w), words))

// 追加要件
// word の　スコアをリスト化して欲しい

// ["javascript", "haskell", "ruby", "c++", "aaaaaaaa" ]
function wordScores(wordScore, words) {
  return words.map(wordScore)
}

console.log(wordScores(score, words)) // =>=> [8, 6, 4, 3, 0]
console.log(wordScores((w) => score(w) + bonus(w) - penalty(w), words)) // => [\d, \d, \d ...]

// aを除いた文字を1点として点数を計算する

// スコアが1より大きい単語のリストを返す関数

function highScoreWords(wordScore, words) {
  return words.filter((w) => wordScore(w) > 1)
}

console.log(highScoreWords((w) => score(w) + bonus(w) - penalty(w), words)) // ["javascript", "haskell", "ruby", "c++"]

// スコアの閾値は現在は1だけど、複数モード用意したい
// とりあえず、0, 1, 5 の3段階用意したい

function highScoreWords(wordScore, words, higherThan) {
  return words.filter((w) => wordScore(w) > higherThan)
}

highScoreWords(w => score(w) + bonus(w) - penalty(w), words, 1)
highScoreWords(w => score(w) + bonus(w) - penalty(w), words, 0)
highScoreWords(w => score(w) + bonus(w) - penalty(w), words, 5)

// 高階関数(関数を返す関数)
function highScoringWords(wordScore, words) {
  return (higherThan) => words.filter((w) => wordScore(w) > higherThan)
}

const words1WithHighScoreThan = highScoreWords(w => score(w) + bonus(w) - penalty(w), words)
const words2WithHighScoreThan = highScoreWords(w => score(w) + bonus(w) - penalty(w), words2)
const words3WithHighScoreThan = highScoreWords(w => score(w) + bonus(w) - penalty(w), words3)
words1WithHighScoreThan(5)
words1WithHighScoreThan(1)
words1WithHighScoreThan(0)
words2WithHighScoreThan(5)
words2WithHighScoreThan(1)
words2WithHighScoreThan(0)

function highScoringWords(wordScore) {
  return (higherThan) => (words) => words.filter((w) => wordScore(w) > higherThan)
}

const wordsWithHighScoreThan = highScoringWords(w => score(w) + bonus(w) - penalty(w))
wordsWithHighScoreThan(5)(words)
wordsWithHighScoreThan(1)(words2)
wordsWithHighScoreThan(3)(words3)


function add(a, b) {
  return a + b
}

cosnt add = (a) => (b) => a + b;
add(1)(4) // => 5
const plusOne = add(1)
const plusTwo = add(2)
plusOne(4) // => 5
