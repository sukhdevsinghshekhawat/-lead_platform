class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :company
      t.text :message
      t.integer :status, default: 0, null: false
      t.references :assigned_to, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end
    add_index :leads, :email
    add_index :leads, :status
    add_index :leads, :created_at
  end
end
