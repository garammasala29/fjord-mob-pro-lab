# 再帰下降パーサー解説ガイド

## 1. 再帰下降パーサーとは？

**再帰下降パーサー**は、文法規則を**関数の呼び出し**で表現する構文解析手法です。各文法規則に対応する関数が、必要に応じて他の関数を**再帰的に呼び出す**ことで、複雑な構文を解析します。

### なぜ「再帰下降」と呼ばれるのか？
- **再帰**: 関数が自分自身や他の関数を呼び出す
- **下降**: 構文木を上から下に向かって構築していく

## 2. 文法規則の復習

Ruby Mini Languageの文法規則：
```
expression = term { ('+' | '-') term }
term       = factor { ('*' | '/') factor }
factor     = integer | '(' expression ')'
```

### 文法規則の読み方
- `{}` : 0回以上の繰り返し
- `|` : または（選択）
- `()` : グループ化

## 3. 文法規則と関数の対応

| 文法規則 | 対応する関数 | 役割 |
|---------|-------------|------|
| `expression` | `expr()` | `+`, `-` の処理（低優先度） |
| `term` | `term()` | `*`, `/` の処理（高優先度） |
| `factor` | `factor()` | 数値、括弧の処理（最高優先度） |

## 4. 実際のコード例で理解する

### Step3のParserStep3クラスを例に解説

```ruby
def expr
  # termを読んで、左辺とする
  lhs = term

  # + or - がある限り処理を続ける
  while %i[plus minus].include?(@current_token.type)
    op = @current_token
    advance(op.type)
    rhs = term  # 再帰呼び出し！

    case op.type
    when :plus
      lhs += rhs
    when :minus
      lhs -= rhs
    end
  end
  lhs
end
```

### 文法規則との対応
```
expression = term { ('+' | '-') term }
             ↓      ↓           ↓
           lhs = term  while演算子  rhs = term
```

## 5. 具体例で動作を追跡

### 入力: `"2 + 3 * 4"`

#### トークン列
```
[Token(:int, 2), Token(:plus), Token(:int, 3), Token(:asterisk), Token(:int, 4)]
```

#### 関数呼び出しの流れ

```
1. expr() が開始
   ├─ 2. term() を呼び出し
   │   ├─ 3. factor() を呼び出し → 2 を取得
   │   ├─ 4. * があるので继续
   │   ├─ 5. factor() を呼び出し → 3 を取得
   │   ├─ 6. 2 * 3 = 6 を計算
   │   └─ 7. term() が 6 を返す
   ├─ 8. + があるので继续
   ├─ 9. term() を再度呼び出し
   │   ├─ 10. factor() を呼び出し → 4 を取得
   │   └─ 11. term() が 4 を返す
   ├─ 12. 6 + 4 = 10 を計算
   └─ 13. expr() が 10 を返す
```

**重要**: `3 * 4` ではなく `(2 + 3) * 4 = 20` にならない理由は、`term()`が先に`3`を処理してから`* 4`を見つけるためです。

## 6. 演算子優先順位の実現方法

### 優先順位の階層構造

```
高優先度  factor()  ← 数値、括弧
    ↑      ↑
中優先度   term()   ← *, /
    ↑      ↑
低優先度   expr()   ← +, -
```

### なぜこの順序で呼び出すのか？

1. **expr()** は最初に **term()** を呼び出す
2. **term()** は最初に **factor()** を呼び出す
3. 結果的に、**より高い優先度の演算が先に評価される**

### 例: `"2 + 3 * 4"` の評価順序

```
expr() 開始
├─ term() 呼び出し (最初の項)
│  ├─ factor() → 2
│  └─ term() が 2 を返す
├─ + を発見
├─ term() 呼び出し (次の項)
│  ├─ factor() → 3
│  ├─ * を発見
│  ├─ factor() → 4
│  ├─ 3 * 4 = 12 を計算
│  └─ term() が 12 を返す
├─ 2 + 12 = 14 を計算
└─ expr() が 14 を返す
```

## 7. 括弧の処理

### factor()での括弧処理
```ruby
def factor
  if @current_token.type == :int
    # 数値の場合
    value = @current_token.value
    advance(:int)
    value
  elsif @current_token.type == :l_paren
    # 括弧の場合
    advance(:l_paren)
    result = expr()  # 再帰呼び出し！
    advance(:r_paren)
    result
  end
end
```

### `"(2 + 3) * 4"` の処理

```
term() 開始
├─ factor() 呼び出し
│  ├─ ( を発見
│  ├─ expr() を再帰呼び出し  ← ここがポイント！
│  │  ├─ term() → factor() → 2
│  │  ├─ + を発見
│  │  ├─ term() → factor() → 3
│  │  ├─ 2 + 3 = 5 を計算
│  │  └─ expr() が 5 を返す
│  ├─ ) を確認
│  └─ factor() が 5 を返す
├─ * を発見
├─ factor() → 4
├─ 5 * 4 = 20 を計算
└─ term() が 20 を返す
```

## 8. Step4でのAST構築

Step4では計算する代わりにASTノードを作成：

```ruby
def expr
  result = term

  while %i[plus minus].include?(@current_token.type)
    type = @current_token.type
    advance(type)
    rhs = term
    # 計算ではなくASTノードを作成
    result = Node::BinaryOp.new(result, type, rhs)
  end
  result
end
```

### `"2 + 3 * 4"` のAST構造

```
Node::BinaryOp
├─ lhs: Node::Integer(2)
├─ op: :plus
└─ rhs: Node::BinaryOp
    ├─ lhs: Node::Integer(3)
    ├─ op: :asterisk
    └─ rhs: Node::Integer(4)
```

## 9. よくある疑問と回答

### Q1: なぜ再帰が必要なのか？
**A**: 括弧の入れ子や、同じ文法規則の繰り返し（例：`1+2+3+4`）を処理するため。関数が自分自身を呼び出すことで、任意の深さの構造を解析できます。

### Q2: なぜexpr → term → factorの順で呼び出すのか？
**A**: 演算子優先順位を実現するため。高優先度の演算を先に評価することで、正しい計算順序を保証します。

### Q3: エラー処理はどうするのか？
**A**: 期待したトークンが来なかった場合に例外を投げることで、構文エラーを検出します。

```ruby
def advance(expected_type)
  raise "Expected #{expected_type}, got: #{@current_token.type}" unless @current_token.type == expected_type
  @current_token = @lexer.next_token
end
```

## 10. まとめ

再帰下降パーサーの核心：

1. **文法規則 = 関数** の対応関係
2. **再帰呼び出し**による構造の解析
3. **呼び出し順序**による優先順位制御
4. **base case**（factor）での再帰終了

この理解があれば、Step5の変数やStep6の条件分岐など、新しい文法要素が追加されても、「どの関数にどのロジックを追加すればよいか」が分かるようになります！
