class HomeController < ApplicationController
  def index
    raise FooException.new
  end
end
