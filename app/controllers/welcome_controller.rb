class WelcomeController < ApplicationController
  def index
    respond_to do |format|
      format.json{
        render :json => Hash[ENV.map{|k,v| [k,v]}.sort_by{|k,v| k}]
      }
    end
  end
end
