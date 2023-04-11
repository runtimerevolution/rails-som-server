
class SelfOrganizingMapsController < ApplicationController
  def index
    render json: Map.all
  end

  def show
    render json: Map.find(params[:id])
  end

  def create
    map = Map.new(map_params)

    if map.save
      render json: map
    else
      render json: map.errors, status: :bad_request
    end
  end

  def datapoints
    map = Map.find(params[:id])

    results = store_data_points(map)

    if results[0]
      render json: results[1]
    else
      render json: results[1], status: :bad_request
    end
  end

  private

  def map_params
    params.require(:map).permit(:feature_number, :height, :width)
  end

  def data_point_params
    params.require(:datapoints).permit(points: [:label, value: []])
  end

  # this would better be going to a service, but to simplify, it'll be a method
  def store_data_points(map)
    points = []

    ActiveRecord::Base.transaction do
      data_point_params[:points].each do |point|
        entry = SampleDataEntry.new(map: map, label: point[:label], value: point[:value])

        entry.save!
        points << entry
      end
    rescue StandardError => e
      return [false, e.message]
    end

    [true, points]
  end
end
