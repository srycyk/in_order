
class CreateInOrderElements < ActiveRecord::Migration[5.2]
  def change
    create_table :in_order_elements do |t|
      t.string :scope
      t.references :owner, polymorphic: true
      t.references :subject, polymorphic: true
      t.references :element

      t.timestamps
    end

    add_index :in_order_elements, :scope
  end
end
