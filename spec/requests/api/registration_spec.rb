require 'swagger_helper'
require_relative '../../helpers/methods'

RSpec.describe '/registration', type: :request do
  path '/registration/authentication' do
    post 'Send registration envite on email' do
      tags 'Sign Up'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body,
                schema: {type: :object, properties: {email: {type: :string}}}

      response '200', 'success' do
        schema type: :object, properties: {data: {type: :object, properties: {email_sent: {type: :boolean}}}}
        let(:params) {{email: 'some_email@mail.com'}}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email_sent']).to eq(true)
        end
      end

      response '400', 'Validation Errors' do
        let(:params) {{email: 'invalid_params'}}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path '/registration/sign_up' do
    post 'Last steps of Registration' do
      tags 'Sign Up'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              token: {type: :string},
              full_name: {type: :string},
              password: {type: :string},
              password_confirmation: {type: :string}, }}

      response '201', 'success' do
        before do
          @create_params = user_creation_params
          @token = sign_up_token(@create_params[:email])
          @create_params[:token] = @token
        end
        let(:params) {@create_params}
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       properties: {
                           user_registered: {type: :boolean}
                       }
                   }
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq(@create_params[:email])
          expect(data['full_name']).to eq(@create_params[:full_name])
          expect(data['role']).to eq(@create_params[:role])
        end
      end

      response '400', 'Validation Errors' do
        let(:params) {{email: 'invalid_params'}}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end
end