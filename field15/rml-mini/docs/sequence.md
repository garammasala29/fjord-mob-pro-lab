# Ruby Mini Language - 処理フローシーケンス図

## 概要
ユーザーがREPLに入力してから結果が表示されるまでの一連の処理を表現しています。
例: `"x = 42"` の入力から `"x + 5"` の評価まで

## シーケンス図

```mermaid
sequenceDiagram
    participant User
    participant REPL as REPL<br/>(bin/repl.rb)
    participant Parser as ParserStep5
    participant Lexer as Lexer
    participant Token as Token
    participant Node as Node<br/>(AST)
    participant Evaluator as Evaluator
    participant Environment as Environment

    User->>REPL: 入力: "x = 42"

    Note over REPL: 1. 構文解析フェーズ
    REPL->>Parser: ParserStep5.parse(input)

    Parser->>Lexer: new(input)
    activate Lexer

    Note over Lexer: 字句解析
    loop トークン生成
        Lexer->>Token: new(type, value)
        Token-->>Lexer: トークンインスタンス
    end

    Parser->>Lexer: next_token()
    Lexer-->>Parser: Token(:identifier, "x")

    Parser->>Lexer: next_token()
    Lexer-->>Parser: Token(:equals)

    Parser->>Lexer: next_token()
    Lexer-->>Parser: Token(:int, 42)

    deactivate Lexer

    Note over Parser: 構文解析<br/>再帰下降パース
    Parser->>Node: new Assignment("x", Integer(42))
    activate Node
    Node-->>Parser: AST
    deactivate Node

    Parser-->>REPL: AST

    Note over REPL: 2. 評価フェーズ
    REPL->>Evaluator: evaluate(ast)
    activate Evaluator

    Note over Evaluator: ASTノード判定<br/>Node::Assignment

    alt Assignment ノードの場合
        Note over Evaluator: 右辺を評価
        Evaluator->>Evaluator: evaluate(value_node)
        Note over Evaluator: Node::Integer(42) → 42

        Note over Evaluator: 変数を環境に定義
        Evaluator->>Environment: define("x", 42)
        Environment-->>Evaluator: success

        Evaluator-->>REPL: 42 (代入値を返す)

    else BinaryOp ノードの場合
        Note over Evaluator: 左辺と右辺を再帰評価
        Evaluator->>Evaluator: evaluate(lhs)
        Evaluator->>Evaluator: evaluate(rhs)
        Note over Evaluator: 演算子に応じて計算
        Evaluator-->>REPL: 計算結果

    else Variable ノードの場合
        Evaluator->>Environment: lookup(name)
        Environment-->>Evaluator: 変数の値
        Evaluator-->>REPL: 変数の値

    else Integer ノードの場合
        Evaluator-->>REPL: そのまま数値を返す
    end

    deactivate Evaluator

    REPL->>User: 表示: "#=> 42"

    Note over REPL: 次の入力を待機
    User->>REPL: 入力: "x + 5"

    Note over REPL: 同様の処理フロー
    REPL->>Parser: ParserStep5.parse("x + 5")

    Note over Parser,Lexer: 字句解析<br/>[:identifier, :plus, :int]

    Note over Parser: BinaryOp AST構築<br/>Variable("x") + Integer(5)
    Parser-->>REPL: AST

    REPL->>Evaluator: evaluate(ast)

    Note over Evaluator: BinaryOp評価
    Evaluator->>Environment: lookup("x")
    Environment-->>Evaluator: 42

    Note over Evaluator: 42 + 5 = 47
    Evaluator-->>REPL: 47

    REPL->>User: 表示: "#=> 47"
```

## 処理フェーズの詳細

### フェーズ1 - 字句解析
- **入力**: 文字列（`"x = 42"`）
- **処理**: Lexerが文字列をトークンに分割
- **出力**: Token配列（`[:identifier, :equals, :int]`）

### フェーズ2 - 構文解析
- **入力**: Token配列
- **処理**: Parserが文法規則に従ってASTを構築
- **出力**: AST（`Node::Assignment`）

### フェーズ3 - 評価
- **入力**: AST
- **処理**: EvaluatorがASTを巡回して実際の値を計算
- **出力**: 実行結果（`42`）

## 重要なポイント

- **状態管理**: Environmentが変数の状態をREPLセッション間で保持
- **再帰的評価**: EvaluatorがASTを深さ優先で巡回して評価
- **分離された責務**: 各クラスが明確な役割を持つ
- **一方向の流れ**: 文字列 → Token → AST → 結果
