module Response
  def respond_json(object, status = :ok)
    render json: object, status: status
  end
end