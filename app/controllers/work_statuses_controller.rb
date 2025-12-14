class WorkStatusesController < ApplicationController
  before_action :set_team
  before_action :set_client

  def index
    if params[:selected_team_id].present?
      requested_team = @office.teams.find_by(id: params[:selected_team_id])
      if requested_team && requested_team.id != @team&.id
        redirect_to team_work_statuses_path(requested_team, date: params[:date]) and return
      end
    end

    @date  = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @clients = @team.clients.order(:id)

    @shifts = @office.shifts
      .joins(:client)
      .where(date: @date, clients: { team_id: @team.id })
      .includes(:user, :client)
      .order("clients.name ASC, start_time ASC")
      .group_by(&:client_id)

    all_shifts = @shifts.values.flatten

    @work_count     = all_shifts.count { |s| s.work_status == "work" }
    @not_work_count = all_shifts.count { |s| s.work_status == "not_work" }

    @teams = @office.teams.joins(:clients).distinct.order(:id)
  end
end
