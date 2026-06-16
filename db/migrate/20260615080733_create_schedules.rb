class CreateSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :schedules do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date
      t.date :start_time
      t.date :end_time

      t.timestamps
    end
  end
end
