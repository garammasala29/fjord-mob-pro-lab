## 概要
簡単なインタプリタをRubyで作ろう！

## 実行方法
CLIのエントリポイントは`bin/repl.rb`にあります。

```bash
ruby ./bin/repl.rb
```

## 実装方法
`lib/parser_step(n).rb` にそれぞれのステップのロジックを記述してください。 実装が完了したら、対応するテストを実行して確認します。

### テストの実行方法

```bash
# 全テストを実行
bundle exec rspec

# 例: step1 のテストを個別に実行
bundle exec rspec spec/parser_step1_spec.rb
```

## 各ステップの概要

### Step1
2項の値(整数)と1つの演算子(operator)を受け取り評価するインタプリタの実装を行なってください。

演算子の種類は`+, -, *, /`の4つを想定していますが、別に増やしてもらって構いません。
`/`演算子の挙動に関してはRubyの`/`と同じにしてください。(つまり小数点以下切り捨て)

例)

```rb
# OK
1 + 3
#=> 4

# OK
5 / 2
#=> 2

# NG
1 + 3 - 4 # 3項の演算

# NG
1.3 * 2.4 # 小数を含む演算(できるが正しい値は出ない)
```

### Step2
左から順番に評価するようにして、3項以上の式（例: `"1 + 2 * 3"`）を左結合で処理できるようにします。

※このステップでは演算の優先順位は考慮しません。

例)
```rb
ParserStep2.eval("2 + 3 * 4") #=> 20 (2 + 3 = 5, 5 * 4 = 20)
ParserStep2.eval("10 - 2 + 1") #=> 9
```

### Step3
演算子の優先順位（`*`, `/`が`+`, `-`より先）を考慮した評価を行えるようにします。
このステップでも全ての演算子は左結合として扱います。

例)
```rb
ParserStep3.eval("2 + 3 * 4") #=> 14 (3 * 4 = 12, 2 + 12 = 14)
ParserStep3.eval("45 / 5 / 3") #=> 3 (45 / 5 = 9, 9 / 3 = 3)
ParserStep3.eval("10 - 4 / 2 + 3") #=> 11 (4 / 2 = 2, 10 - 2 = 8, 8 + 3 = 11)
```

### Step4
このステップでは2つの大きな変更を行います：

1. **括弧のサポート**: 式の中で括弧 `( )` をサポートして、優先順位を動的に変更できるようにします。括弧で囲まれた部分は、最も高い優先順位として扱われます。

2. **評価器の分離**: 構文解析（パース）と評価を明確に分離します。パーサーは抽象構文木（AST）を返し、エバリュエーターがそのASTを評価します。これにより、コードの責務が明確に分離され、拡張性が向上します。

### 文法規則

基本的な文法規則は以下のようになります：

```txt
expression → term (('+' | '-') term)*
term       → factor (('*' | '/') factor)*
factor     → integer | '(' expression ')'
```

#### アーキテクチャ
- **Parser**: 入力文字列をASTに変換
  - `ParserStep4.parse(input)`→ASTを返す
- **Evaluator**: ASTを評価して結果を計算
  - `Evaluator.evaluate(ast)`→計算結果を返す

#### 使用例
例)
```rb
ast = ParserStep4.parse("2 * (3 + 4)")
result = Evaluator.new.evaluate(ast)  # => 14

ast = ParserStep4.parse("(3 + 4) * 2")
result = Evaluator.new.evaluate(ast)  # => 14

ast = ParserStep4.parse("10 - (4 + 2) * 3")
result = Evaluator.new.evaluate(ast)  # => -8
```

#### やること
実装のポイント

- パーサーの factor メソッドを拡張して、括弧内の式を expression として再帰的に解析
- 抽象構文木（AST）を実装して、式の構造を表現
- 評価ロジックをパーサーから分離して、専用のエバリュエーターに移動
- REPL（対話型実行環境）を更新して、パースと評価の分離を反映

### Step5: 変数と代入
STEP5ではインタプリタに変数と代入の機能を導入していきます。これにより、値を変数に格納して後で参照することができます。今回Rubyと同じように代入は値を返すものとして実装します。

#### 実装する機能
1. 変数の宣言と代入
  - `x = 42`のような構文で変数に値を代入できるようにする（変数宣言と代入を同じタイミングで行う）
  - 代入文は割り当てられた値を返す
2. 変数の参照
  - 式の中で変数を参照できるようにする 例）`x + 3`
  - 未定義の変数を参照した場合はエラーを発生させる
3. シンボルテーブル（環境）の実装
  - 変数名と値をマッピングを管理する環境を実装する
  - REPL内で変数の状態を保持し、複数コマンド間で変数値を維持する

#### 文法規則
基本的な文法規則は以下のようになります：

```txt
statement  = assignment | expression ;
assignment = identifier "=" expression ;
expression = term { ("+" | "-") term } ;
term       = factor { ("*" | "/") factor } ;
factor     = integer | identifier | "(" expression ")" ;
identifier = letter { letter | digit } ;
letter     = "a" | "b" | ... | "z" | "A" | "B" | ... | "Z" | "_" ;
digit      = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
integer    = digit { digit } ;
```

#### アーキテクチャ
- **Environment**: 変数の値を保持するシンボルテーブル
  - `define(name, value)`: 変数を定義
  - `lookup(name)`: 変数の値を参照
- **Parser**: 入力文字列をASTに変換
  - `ParserStep4.parse(input)`→ASTを返す
- **Evaluator**: ASTを評価し、環境を管理する
  - `Evaluator.evaluate(ast)` → 計算結果を返す

### Step6: 条件分岐の導入
STEP6ではインタプリタに条件分岐機能を導入します。Boolean型、比較演算子、if文を実装することでより高度なプログラミングが可能になります。

#### 実装する機能
1. **Boolean型** の導入
  - `true`と`false`のBooleanリテラルをサポート
  - Boolean値の変数への代入と参照
1. **比較演算子**の実装
  - `==`(等価比較)
  - `!=`(不等価比較)
  - `<`(未満)
  - `>`(より大きい)
  - `=<` (以下)←これは独自実装です。あー、なんか気持ち悪いね
  - `=>` (以上)←これは独自実装です。あー、なんか気持ち悪いね
1. **if文**の実装
  - 基本的な構文: `if < condition > { statements }`
  - if-else文: `if < condition > { then_body } else { else_body }`
  - if-else-if-else文: 複数の条件分岐をサポート
    - `if < condition > { then_body } (else-if { elseif_body })* else { else_body }`
  - ブロック内で複数文の実行

#### 文法規則
基本的な文法規則は以下のようになります：

```txt
statement     = assignment | if_statement | expression ;
assignment    = identifier "=" expression ;
if_statement  = "if" "<" expression ">" block ("else-if" "<" expression ">" block)* ("else" block)? ;
block         = "{" statement* "}" ;
expression    = comparison ;
comparison    = addition ( ("==" | "!=" | "<" | ">" | "=<" | "=>") addition )? ;
addition      = multiplication ( ("+" | "-") multiplication )* ;
multiplication = factor ( ("*" | "/") factor )* ;
factor        = integer | boolean | identifier | "(" expression ")" ;
boolean       = "true" | "false" ;
identifier    = letter ( letter | digit )* ;
integer       = digit+ ;
```

#### 使用例

```rb
# Boolean値
flag = true
result = false

# 比較演算
x = 10
y = 5
is_greater = x > y  # => true
is_equal = x == y * 2  # => true

# if文
if < score => 90 > {
  grade = 4
} else-if < score => 80 > {
  grade = 3
} else-if < score => 70 > {
  grade = 2
} else {
  grade = 1
}

# 複雑な条件
if < (a + b) == (c * d) > {
  result = 1
} else {
  result = 0
}
```

#### 演算子の優先順位

1. 括弧 `( )`
2. 乗除算 `*, /`
3. 加減算 `+, -`
4. 比較演算子 `==, !=, <, >, =<, =>`

### 今後（予定）
- STEP7: ループ処理の導入
  - whileループの実装
- STEP8: 文字列操作
  - 文字列型の追加
  - 文字列の連結機能の実装
  - 出力機能の実装
- STEP9: 関数の導入
  - 関数定義と呼び出し
  - 引数戻り値のサポート
  - 関数のスコープ
- STEP10: FizzBuzzの実装
