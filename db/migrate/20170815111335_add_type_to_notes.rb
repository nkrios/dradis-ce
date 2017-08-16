class AddTypeToNotes < ActiveRecord::Migration[5.1]
  def up
    add_column :notes, :type, :string

    Note.where(node: Node.issue_library).update_all(type: 'Issue')
  end

  def down
    remove_column :notes, :type
  end
end
