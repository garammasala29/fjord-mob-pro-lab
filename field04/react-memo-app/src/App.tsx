import { useState } from 'react';

type Note = {
  id: number;
  title: string;
  content: string;
};

const defaultNotes: Note[] = [
  { id: 1, title: 'title1', content: 'memo1' },
  { id: 2, title: 'title2', content: 'memo2' }
];

function App() {
  const [id, setId] = useState(Math.max(...defaultNotes.map(({id}) => id)) + 1)
  const [isEditing, setIsEditing] = useState(false)
  const [text, setText] = useState('')
  const [notes, setNotes] = useState<Note[]>(defaultNotes)

  // const handleOnEdit = (e: MouseEvent<HTMLButtonElement>) => {
  //   const id = e.currentTarget?.id
  //   console.log(id)
  //   setIsEditing(true);

  // };

  const handleOnDelete = () => {
    setIsEditing(false);
  };

  const handleOnNew = () => {
    setIsEditing(true);
  };

  const handleOnChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setText(e.target.value);
  }

  const handleOnUpdate = () => {
    const [newTitle, ...rest] = text.split('\n');
    const newContent = rest.join('\n');

    const newNote = {id: id, title: newTitle, content: newContent};

    const newNotes = [...notes, newNote];
    setNotes(newNotes);
    setText('');
    setId((id) => id + 1);
  }

  return (
    <div className="App">
      <h1>メモアプリ！</h1>
      <ul>
        { notes.map((note) => {
          return (
            <li key={note.id}>
              {/* <button onClick={handleOnEdit} id={`${note.id}`} >{ note.title }</button> */}
              <button id={`${note.id}`} >{ note.title }</button>
            </li>
          )
        })}
      </ul>
      <button onClick={handleOnNew}>+</button>
      { isEditing &&
        (
          <div>
            <textarea onChange={handleOnChange}></textarea>
            <button onClick={handleOnUpdate}>更新</button>
            <button onClick={handleOnDelete}>削除</button>
          </div>
        )
      }
    </div>
  );
}

export default App;

// memo
// テキストエリアの表示は関数として切り出せそう
