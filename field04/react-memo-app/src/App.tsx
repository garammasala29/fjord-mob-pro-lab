import { useState } from "react";
import EditingArea from "./EditingArea";

type Note = {
  id: number;
  title: string;
  content: string;
};

const defaultNotes: Note[] = [
  { id: 1, title: "title1", content: "memo1" },
  { id: 2, title: "title2", content: "memo2" },
];

function App() {
  const [id, setId] = useState(
    Math.max(...defaultNotes.map(({ id }) => id)) + 1
  );
  const [isEditing, setIsEditing] = useState(false);
  const [text, setText] = useState("");
  const [notes, setNotes] = useState<Note[]>(defaultNotes);
  const [targetId, setTargetId] = useState(-1);

  const handleOnEdit = (e: React.MouseEvent<HTMLButtonElement>) => {
    const id = Number(e.currentTarget.id);
    setTargetId(id);
    const note = notes.find((note) => note.id === id);
    if (note) setText(`${note.title}\n${note.content}`);
    setIsEditing(true);
  };

  const handleOnDelete = () => {
    setNotes(notes.filter((note) => note.id !== targetId));
    setTargetId(-1);
    setText("");
    setIsEditing(false);
  };

  const handleOnNew = () => {
    setIsEditing(true);
  };

  const handleOnChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    setText(e.target.value);
  };

  const handleOnUpdate = () => {
    if (!text) {
      return;
    }
    const makeNote = () => {
      const [newTitle, ...rest] = text.split("\n");
      const newContent = rest.join("\n");
      return { id: id, title: newTitle, content: newContent };
    };

    const newNote = makeNote();
    const targetNote = notes.find((note) => note.id === targetId);
    const copyNotes = [...notes];
    if (targetNote) {
      const targetIndex = notes.indexOf(targetNote);
      copyNotes[targetIndex] = newNote;
      setNotes(copyNotes);
    } else {
      const newNotes = [...copyNotes, newNote];
      setId((id) => id + 1);
      setNotes(newNotes);
    }
    setText("");
    setTargetId(-1);
  };

  return (
    <div className="App">
      <h1>メモアプリ！</h1>
      <ul>
        {notes.map((note) => {
          return (
            <li key={note.id}>
              {
                <button onClick={handleOnEdit} id={`${note.id}`}>
                  {note.title}
                </button>
              }
            </li>
          );
        })}
      </ul>
      <button onClick={handleOnNew}>+</button>
      {isEditing && (
        <EditingArea>
          <textarea onChange={handleOnChange} value={text}></textarea>
          <button onClick={handleOnUpdate}>更新</button>
          <button onClick={handleOnDelete}>削除</button>
        </EditingArea>
      )}
    </div>
  );
}

export default App;
