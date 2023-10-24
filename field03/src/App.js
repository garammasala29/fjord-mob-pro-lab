import { useState } from 'react';

function Square({value, onSquareClick}) {
  return (
    <button className='square' onClick={onSquareClick}>
      {value}
    </button>
  )
}

export function Board({ xIsNext, squares, onPlay }) {
  function handleClick(i) {
    if (squares[i] || calculateWinner(squares)) {
      return;
    }
    const nextSquares = squares.slice();
    if (xIsNext) {
      nextSquares[i] = 'X';
    } else {
      nextSquares[i] = 'O';
    }
    onPlay(nextSquares);
  }

  const result = calculateWinner(squares);
  let status;
  if (result === 'draw') {
    status = '引き分けだよ！';
  } else if (result == 'O' || result == 'X'){
    status = 'Winner: ' + result;
  } else {
    status = 'Next player: ' + (xIsNext ? 'X' : 'O');
  }

  return (
    <>
      <div className='status'>
        {status}
        {[0, 1, 2].map((i) => {
          return (
          <div className="board-row">
            {
              [0, 1, 2].map((j) => {
                return <Square value={squares[i][j]} onSquareClick={() => handleClick(i, j)} />
              })
            }
          </div>)
        })}
      </div>
    </>
  );
}

function calculateWinner(squares) {
  const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];
  for (let i = 0; i < lines.length; i++) {
    const [a, b, c] = lines[i];
    if (squares[a] && squares[a] === squares[b] && squares[a] === squares[c]) {
      return squares[a];
    }
  }
  if (squares.some((square) => square == null)) {
    return null;
  } else {
    return 'draw';
  }
}

export default function Game() {
  const [history, setHistory] = useState([Array(3).fill(Array(3).fill(null))]);
  const [currentMove, setCurrentMove] = useState(0);
  const xIsNext = currentMove % 2 === 0
  const currentSquares = history[currentMove];

  function handlePlay(nextSquares) {
    const newHistory = JSON.parse(JSON.stringify(slice(0, currentMove + 1)))
    const nextHistory = [...newHistory, nextSquares];
    setHistory(nextHistory);
    setCurrentMove(nextHistory.length - 1);
  }

  function jumpTo(nextMove) {
    setCurrentMove(nextMove);
  }

  const moves = history.map((_, move) => {
    let description;
    if (move === history.length - 1) {
      description = `You are at move #${move}`
    } else if (move > 0) {
      description = 'Go to move #' + move;
    } else {
      description = 'Go to game start';
    }
    return (
      <li key={move}>
        {move === history.length - 1 ? description : <button onClick={() => jumpTo(move)}>{description}</button>}
      </li>
    );
  })

  return (
    <div className='game'>
      <div className='game-board'>
        <Board xIsNext={xIsNext} squares={currentSquares} onPlay={handlePlay} />
      </div>
      <div className='game-info'>
        <ol>{moves}</ol>
      </div>
    </div>
  )
}
