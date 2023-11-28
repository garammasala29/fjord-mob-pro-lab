type Note = {
  id: string;
  title: string;
  content: string;
};

function NoteList({
  notes,
  handleOnEdit,
}: {
  notes: Note[];
  handleOnEdit: (args: React.MouseEvent<HTMLButtonElement>) => void;
}) {
  return (
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
  );
}

export default NoteList;
