class ApplicationController < ActionController::API
  include ExceptionHandler
  include Response
  include AuthHelper
  include Pundit
end
