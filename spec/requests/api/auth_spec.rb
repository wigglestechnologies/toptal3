require 'swagger_helper'
require_relative '../../helpers/methods'

RSpec.describe '/auth', type: :request do

  path '/auth/login' do
    post 'Authenticate customer with credentials' do
      tags 'Auth'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: auth_schema,
          required: [:username, :password]
      }

      response '200', 'success' do
        schema type: :object, properties: login_response_schema
        before do
          @user = create(:user, email: 'a@a.com', password: "Password123!")
        end
        let(:params) {login_params}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('refresh_token')
        end
      end

      response '401', 'Unauthorized' do
        let(:params) {login_params}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path '/auth/logout' do

    delete 'User Logout' do
      tags 'Auth'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'Ok' do
        before do
          initialize_user
        end
        let(:Authorization) {"Bearer #{ @refresh_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['logged_out']).to eq(true)
        end
      end

      response '401', 'Unauthorized' do
        let(:Authorization) {"Bearer invalid_token"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path "/auth/token" do

    post "get new JWT  using refresh token" do
      tags 'Auth'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'OK' do
        schema type: :object, properties: login_response_schema
        before do
          initialize_user
        end
        let(:"Authorization") {"Bearer #{ @refresh_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('refresh_token')
        end
      end

      response '401', 'Unauthorized' do
        let(:Authorization) {"Bearer #{ 'invaalid_token' }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end
end