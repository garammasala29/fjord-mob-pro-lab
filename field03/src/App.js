import { useState } from 'react';

function Square({value, onSquareClick}) {
  return (
    <button className='square' onClick={onSquareClick}>
      {value}
    </button>
  )
}

export function Board({ xIsNext, squares, onPlay }) {
  function handleClick(i, j) {
    if (squares[i][j] || calculateWinner(squares)) {
      return;
    }
    const nextSquares = JSON.parse(JSON.stringify(squares));
    if (xIsNext) {
      nextSquares[i][j] = 'X';
    } else {
      nextSquares[i][j] = 'O';
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
          <div key={i} className="board-row">
            {
              [0, 1, 2].map((j) => {
                return <Square key={[i, j]} value={squares[i][j]} onSquareClick={() => handleClick(i, j)} />
              })
            }
          </div>)
        })}
      </div>
    </>
  );
}

function calculateWinner(squares) {
  let result = false
  squares.some((row) => {
    if (row.every((cell) => cell === 'O')) {
      result = 'O'
      return true
    } else if (row.every((cell) => cell === 'X')) {
      result = 'X'
      return true
    } else {
      return false
    }
  })

  const transposed_squares = [0, 1, 2].map(i => squares.map(row => row[i]))
  transposed_squares.some((row) => {
    if (row.every((cell) => cell === 'O')) {
      result = 'O'
      return true
    } else if (row.every((cell) => cell === 'X')) {
      result = 'X'
      return true
    } else {
      return false
    }
  })

  if (squares[0][0] && squares[0][0] === squares[1][1] && squares[0][0] === squares[2][2]) {
    result = squares[0][0]
  } else if (squares[0][2] && squares[0][2] === squares[1][1] && squares[0][2] === squares[2][0]) {
    result = squares[0][2]
  }

  if (result) {
    return result
  } else if (squares.some((row) => row.some((cell) => cell == null))) {
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
    const newHistory = JSON.parse(JSON.stringify(history.slice(0, currentMove + 1)))
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
