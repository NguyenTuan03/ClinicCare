class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.references :schedule, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
