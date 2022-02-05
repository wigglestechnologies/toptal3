require 'swagger_helper'
require_relative '../../helpers/methods'

describe 'ResetPassword', type: :request do

  path '/password/forgot' do

    post 'Sends email to active user' do
      tags 'Password Reset'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              email: {type: :string, example: Faker::Internet.email}
          }
      }

      response '200', 'success' do
        before do
          @regular_user = regular_user
        end
        let(:params) {{email: @regular_user[:email]}}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email_sent']).to eq(true)
        end
      end

      response '200', 'Success in case of not_existed' do
        let(:params) {{email: 'not_exists@mail.ru'}}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email_sent']).to eq(true)
        end
      end
    end
  end

  path '/password/reset' do
    post 'Resets user password by token' do
      tags 'Password Reset'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              token: {type: :string},
              password: {type: :string},
              password_confirmation: {type: :string},
          }
      }

      response '200', 'success' do
        before do
          @regular_user = regular_user
          @reset_password_token = forget_password_token(@regular_user[:email])
        end
        let(:params) {new_password(@reset_password_token)}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('token')
          expect(data).to have_key('refresh_token')
        end
      end

      response '400', 'Validation Errors' do
        before do
          @invalid_token = 'invalid_token'
        end
        let(:params) {{token: @invalid_token}}
        run_test!
      end
    end
  end

end