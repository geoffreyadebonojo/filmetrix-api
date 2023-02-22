class TestController < ApplicationController
  def show
    render json: Link.all
  end
end