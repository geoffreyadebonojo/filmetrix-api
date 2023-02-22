class TestController < ApplicationController
  def show
    render json: {g: 'hello'}
  end
end