class CreateOwner < ActiveRecord::Migration[5.2]
  def change
    create_table :owners do |t|
      t.string :name

      t.timestamps
    end
    add_index :owners, :name
  end
end
