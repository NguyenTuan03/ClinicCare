module Api
  module V1
    class AppointmentsController < ApplicationController
      before_action :authorize_request

      def index
        appointment = Appointment.all
        render_success(data: appointment, message: "Success", status: :ok)
      end

      def show
        appointment = Appointment.find_by(id: params[:id])
        if !appointment
          return render_error(message: "Appointment not found", status: :not_found)
        end
        render_success(data: appointment, message: "Success", status: :ok)
      end

      def create
        appointment = Appointment.new(appointment_params)
        puts "current user", @current_user
        # Only patient can create appointment
        if @current_user.role.name != "patient"
          return render_error(message: "You don't have permission to create appointment", status: :unauthorized)
        end

        ActiveRecord::Base.transaction do
          schedule_exist = Schedule.lock("FOR UPDATE").find_by(id: appointment_params[:schedule_id])

          if !schedule_exist
            return render_error(message: "Schedule not found", status: :not_found)
          end

          if Appointment.exists?(schedule_id: schedule_exist.id)
            return render_error(message: "Schedule is already booked", status: :conflict)
          end

          appointment.schedule_id = appointment_params[:schedule_id]
          appointment.patient_id = @current_user.id
          appointment.status = :pending

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

        if appointment.update(appointment_params)
          render_success(data: appointment, message: "Success", status: :ok)
        else
          render_error(data: appointment.errors, message: "Failed", status: :unprocessable_entity)
        end
      end

      def destroy
        appointment = Appointment.find_by(id: params[:id])
        if !appointment
          return render_error(message: "Appointment not found", status: :not_found)
        end

        appointment.destroy
        render_success(data: appointment, message: "Success", status: :ok)
      end

      private

      def appointment_params
        params.require(:appointment).permit(:schedule_id)
      end
    end
  end
end
