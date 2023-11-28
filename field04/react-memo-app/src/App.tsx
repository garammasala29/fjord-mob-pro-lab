import { useState } from "react";
import EditingArea from "./EditingArea";
import NoteList from "./NoteList ";

type Note = {
  id: string;
  title: string;
  content: string;
};

const defaultNotes: Note[] = [
  { id: crypto.randomUUID(), title: "title1", content: "memo1" },
  { id: crypto.randomUUID(), title: "title2", content: "memo2" },
];

function App() {
  const [isEditing, setIsEditing] = useState(false);
  const [text, setText] = useState("");
  const [notes, setNotes] = useState<Note[]>(defaultNotes);
  const [targetId, setTargetId] = useState("");

  const handleOnEdit = (e: React.MouseEvent<HTMLButtonElement>) => {
    setTargetId(e.currentTarget.id);
    const note = notes.find((note) => note.id === e.currentTarget.id);
    if (note) setText(`${note.title}\n${note.content}`);
    setIsEditing(true);
  };

  const handleOnDelete = () => {
    setNotes(notes.filter((note) => note.id !== targetId));
    setTargetId("");
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
      return { id: crypto.randomUUID(), title: newTitle, content: newContent };
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
      setNotes(newNotes);
    }
    setText("");
    setTargetId("");
    setIsEditing(false);
  };

  return (
    <div className="App">
      <h1>メモアプリ！</h1>
      <NoteList notes={notes} handleOnEdit={handleOnEdit} />
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
