module Api
  module V1
    class AppointmentsController < ApplicationController
      before_action :authorize_request

      def index
        appointments = policy_scope(Appointment)

        if params[:schedule_id].present?
          appointments = appointments.where(schedule_id: params[:schedule_id])
        end

        render_success(data: appointments, message: "Success", status: :ok)
      end

      def show
        appointment = Appointment.find_by(id: params[:id])
        if !appointment
          return render_error(message: "Appointment not found", status: :not_found)
        end

        authorize appointment

        render_success(data: appointment, message: "Success", status: :ok)
      end

      def create
        appointment = Appointment.new(appointment_params)
        appointment.patient_id = @current_user.id
        appointment.status = :pending

        authorize appointment

        ActiveRecord::Base.transaction do
          schedule_exist = Schedule.lock("FOR UPDATE").find_by(id: appointment_params[:schedule_id])

          if !schedule_exist
            return render_error(message: "Schedule not found", status: :not_found)
          end

          if Appointment.exists?(schedule_id: schedule_exist.id, status: [ :pending, :confirmed ])
            return render_error(message: "Schedule is already booked", status: :conflict)
          end

          appointment.schedule_id = appointment_params[:schedule_id]

          if appointment.save
            return render_success(data: appointment, message: "Success", status: :created)
          end

          return render_error(message: appointment.errors.full_messages, status: :unprocessable_entity)
        end
      end

      def update
        appointment = Appointment.find_by(id: params[:id])
        if !appointment
          return render_error(message: "Appointment not found", status: :not_found)
        end

        authorize appointment

        if @current_user.role.patient?
          new_schedule_id = appointment_params[:schedule_id]
          if new_schedule_id.blank?
            return render_error(message: "Missing new schedule id", status: :unprocessable_entity)
          end

          ActiveRecord::Base.transaction do
            schedule_exist = Schedule.lock("FOR UPDATE").find_by(id: new_schedule_id)
            if !schedule_exist
              return render_error(message: "Schedule not found", status: :not_found)
            end

            if Appointment.exists?(schedule_id: schedule_exist.id, status: [ :pending, :confirmed ])
              return render_error(message: "Schedule is already booked", status: :conflict)
            end

            appointment.schedule_id = new_schedule_id

            if appointment.save
              return render_success(data: appointment, message: "Success", status: :ok)
            end

            return render_error(message: appointment.errors.full_messages, status: :unprocessable_entity)
          end
        elsif @current_user.role.doctor?
          new_status = appointment_params[:status]
          if new_status.blank?
            return render_error(message: "Missing status", status: :unprocessable_entity)
          end

          unless Appointment.statuses.keys.include?(new_status.to_s)
            return render_error(message: "Invalid status", status: :unprocessable_entity)
          end

          if appointment.update(status: new_status)
            return render_success(data: appointment, message: "Success", status: :ok)
          end

          render_error(message: appointment.errors.full_messages, status: :unprocessable_entity)
        end
      end

      def bulk_update
        authorize Appointment, :bulk_update?

        appointment_ids = params[:ids]
        new_status = params[:status]

        if appointment_ids.blank? || new_status.blank?
          return render_error(message: "Missing ids or status", status: :unprocessable_entity)
        end

        unless Appointment.statuses.keys.include?(new_status.to_s)
          return render_error(message: "Invalid status", status: :unprocessable_entity)
        end

        appointments = Appointment.joins(:schedule).where(id: appointment_ids, schedules: { user_id: @current_user.id })

        if appointments.empty?
          return render_error(message: "No valid appointments found to update", status: :not_found)
        end

        if appointments.update_all(status: new_status)
          return render_success(data: { updated_count: appointments.count }, message: "Success", status: :ok)
        end

        render_error(message: "Failed to update appointments", status: :unprocessable_entity)
      end

      def destroy
        appointment = Appointment.find_by(id: params[:id])
        if !appointment
          return render_error(message: "Appointment not found", status: :not_found)
        end

        authorize appointment

        appointment.update(status: :cancelled)
        render_success(data: appointment, message: "Success", status: :ok)
      end

      private

      def appointment_params
        if @current_user.role.patient?
          params.require(:appointment).permit(:schedule_id)
        elsif @current_user.role.doctor?
          params.require(:appointment).permit(:status)
        else
          params.require(:appointment).permit()
        end
      end
    end
  end
end
