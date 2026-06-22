class ChangeStartTimeAndEndTimeToTimeInSchedules < ActiveRecord::Migration[8.1]
  def change
    change_column :schedules, :start_time, :time, using: 'start_time::timestamp::time'
    change_column :schedules, :end_time, :time, using: 'end_time::timestamp::time'
  end
end
