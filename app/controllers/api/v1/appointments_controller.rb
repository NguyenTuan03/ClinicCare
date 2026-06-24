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
        # Only doctor can create schedule
        if @current_user.role.name != "doctor"
          return render_error(message: "You don't have permission to create appointment", status: :unauthorized)
        end

        appointment.user_id = @current_user.id

        if appointment.save
          render_success(data: appointment, message: "Success", status: :created)
        else
          render_error(message: appointment.errors.full_messages, status: :unprocessable_entity)
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
        params.require(:appointment).permit(:date, :start_time, :end_time, :user_id)
      end
    end
  end
end
