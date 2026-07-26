class NoteSerializer
  def initialize(note)
    @note = note
  end

  def as_json(options = {})
    {
      id: @note.id,
      message: @note.message,
      user: {
        id: @note.user.id,
        name: @note.user.name,
        email: @note.user.email
      },
      created_at: @note.created_at,
      updated_at: @note.updated_at
    }
  end
end

class NotesSerializer
  def initialize(notes)
    @notes = notes
  end

  def as_json(options = {})
    @notes.map { |note| NoteSerializer.new(note).as_json }
  end
end

