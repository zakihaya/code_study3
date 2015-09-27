class HomeController < ApplicationController
  def index
    if params[:station]
      selected_station = Station.find_by_name params['station']
      @shops = HalalShop.list selected_station['lat'], selected_station['lon']
    end
  end
end
