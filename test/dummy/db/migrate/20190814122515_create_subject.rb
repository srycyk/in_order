class CreateSubject < ActiveRecord::Migration[5.2]
  def change
    create_table :subjects do |t|
      t.string :name

      t.timestamps
    end
    add_index :subjects, :name
  end
end
