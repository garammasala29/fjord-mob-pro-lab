import { useState } from 'react';

type Note = {
  id: number;
  title: string;
  content: string;
};

const notes: Note[] = [
  { id: 1, title: 'title1', content: 'memo1' },
  { id: 2, title: 'title2', content: 'memo2' }
];

function App() {
  const [isEditing, setIsEditing] = useState(false)
  const handleOnClick = () => {

  }

  return (
    <div className="App">
      <h1>メモアプリ！</h1>
      <ul>
        { notes.map((note) => {
          return (
            <li key={note.id}>
              <button onClick={handleOnClick} >{ note.title }</button>
            </li>
          )
        })}
      </ul>
    </div>
  );
}

export default App;
