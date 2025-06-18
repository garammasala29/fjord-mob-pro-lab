# Ruby Mini Language - アーキテクチャドキュメント

## 概要
Ruby Mini Languageは、字句解析→構文解析→評価の3段階でコードを処理するシンプルなインタープリターです。

## 各クラスの役割と入出力

### 1. Token クラス
**役割**: レクサーが生成するトークンの最小単位を表現

**構造**:
- `type`: トークンの種類（:int, :plus, :identifier, etc.）
- `value`: トークンの値（数値や変数名など）

**入力例**:
```ruby
Token.new(:int, 42)
Token.new(:plus)
Token.new(:identifier, "x")
```

**出力例**:
```ruby
#<Token @type=:int @value=42>
#<Token @type=:plus @value=nil>
#<Token @type=:identifier @value="x">
```

---

### 2. Lexer クラス
**役割**: 入力文字列をトークンの列に分割する（字句解析）

**入力**: 文字列（プログラムのソースコード）
**出力**: Tokenオブジェクトの配列

**入力例1**:
```ruby
"x = 42"
```
**出力例1**:
```ruby
[
  Token.new(:identifier, "x"),
  Token.new(:equals),
  Token.new(:int, 42),
  Token.new(:eol)
]
```

**入力例2**:
```ruby
"3 + 4 * 5"
```
**出力例2**:
```ruby
[
  Token.new(:int, 3),
  Token.new(:plus),
  Token.new(:int, 4),
  Token.new(:asterisk),
  Token.new(:int, 5),
  Token.new(:eol)
]
```

**入力例3**:
```ruby
"(x + y) * 2"
```
**出力例3**:
```ruby
[
  Token.new(:l_paren),
  Token.new(:identifier, "x"),
  Token.new(:plus),
  Token.new(:identifier, "y"),
  Token.new(:r_paren),
  Token.new(:asterisk),
  Token.new(:int, 2),
  Token.new(:eol)
]
```

---

### 3. Node モジュール
**役割**: 抽象構文木（AST）のノードを表現するクラス群

#### Node::Integer
- 整数リテラルを表現
- `value`: 整数値

#### Node::BinaryOp
- 二項演算を表現
- `lhs`: 左辺のノード
- `op`: 演算子（:plus, :minus, :asterisk, :slash）
- `rhs`: 右辺のノード

#### Node::Assignment
- 変数への代入を表現
- `name`: 変数名
- `value`: 代入する値のノード

#### Node::Variable
- 変数の参照を表現
- `name`: 変数名

**例**:
```ruby
# 42 を表現
Node::Integer.new(42)

# x + 5 を表現
Node::BinaryOp.new(
  Node::Variable.new("x"),
  :plus,
  Node::Integer.new(5)
)

# x = 42 を表現
Node::Assignment.new("x", Node::Integer.new(42))
```

---

### 4. ParserStep5 クラス
**役割**: トークンの列から抽象構文木（AST）を構築する（構文解析）

**入力**: 文字列（内部でLexerを使用）
**出力**: Node オブジェクト（AST）

**入力例1**:
```ruby
"42"
```
**出力例1**:
```ruby
Node::Integer.new(42)
```

**入力例2**:
```ruby
"x = 10 + 5"
```
**出力例2**:
```ruby
Node::Assignment.new(
  "x",
  Node::BinaryOp.new(
    Node::Integer.new(10),
    :plus,
    Node::Integer.new(5)
  )
)
```

**入力例3**:
```ruby
"(x + y) * 2"
```
**出力例3**:
```ruby
Node::BinaryOp.new(
  Node::BinaryOp.new(
    Node::Variable.new("x"),
    :plus,
    Node::Variable.new("y")
  ),
  :asterisk,
  Node::Integer.new(2)
)
```

---

### 5. Environment クラス
**役割**: 変数名と値のマッピングを管理する（シンボルテーブル）

**主要メソッド**:
- `define(name, value)`: 新しい変数を定義
- `assign(name, value)`: 既存の変数の値を変更
- `lookup(name)`: 変数の値を取得

**入力例1** - 変数定義:
```ruby
env.define("x", 42)
```
**出力例1**:
```ruby
# 内部的に @values = {"x" => 42} に保存
# 新しい変数を作成
```

**入力例2** - 既存変数への再代入:
```ruby
env.assign("x", 100)  # x が既に定義済みの場合
```
**出力例2**:
```ruby
# @values = {"x" => 100} に更新
# 既存変数の値を変更
```

**入力例3** - 未定義変数への代入エラー:
```ruby
env.assign("undefined_var", 50)
```
**出力例3**:
```ruby
# RuntimeError: "未定義の変数です: undefined_var"
# assignは既存変数にのみ使用可能
```

**入力例4** - 変数の参照:
```ruby
env.lookup("x")
```
**出力例4**:
```ruby
100  # 最後に代入された値を返す
```

**defineとassignの違い**:
- `define`: 常に新しい変数を作成（上書き可能）
- `assign`: 既存の変数のみ変更可能（未定義ならエラー）

---

### 6. Evaluator クラス
**役割**: ASTを評価して実際の値を計算する

**入力**: Node オブジェクト（AST）
**出力**: 評価結果（数値など）

**入力例1**:
```ruby
Node::Integer.new(42)
```
**出力例1**:
```ruby
42
```

**入力例2**:
```ruby
Node::BinaryOp.new(
  Node::Integer.new(3),
  :plus,
  Node::Integer.new(4)
)
```
**出力例2**:
```ruby
7  # 3 + 4 の計算結果
```

**入力例3**:
```ruby
# 前提: x = 10 が既に定義済み
Node::BinaryOp.new(
  Node::Variable.new("x"),
  :asterisk,
  Node::Integer.new(2)
)
```
**出力例3**:
```ruby
20  # x * 2 = 10 * 2 の計算結果
```

## 処理の流れ

### 字句解析フェーズ（Lexer）
1. 入力文字列を1文字ずつ読み取り
2. 文字のパターンに応じてトークンを生成
3. 空白をスキップしながらトークンの配列を生成

### 構文解析フェーズ（Parser）
1. Lexerからトークンを順次取得
2. 文法規則に従って再帰下降構文解析
3. トークンをASTノードに変換
4. 演算子優先順位を考慮したツリー構造を構築

### 評価フェーズ（Evaluator）
1. ASTを深さ優先で巡回
2. ノードの種類に応じて適切な処理を実行
3. 変数の場合はEnvironmentから値を取得
4. 演算の場合は左右の子ノードを再帰的に評価
5. 最終的な計算結果を返却

## データフローの特徴

- **一方向の流れ**: 文字列 → トークン → AST → 結果
- **分離された責務**: 各クラスが明確な役割を持つ
- **再帰的な構造**: ParserとEvaluatorは再帰的にツリーを処理
- **状態管理**: Environmentが変数の状態を保持
