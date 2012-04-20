class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.integer :id
      t.string :description

      t.timestamps
    end
  end
end
