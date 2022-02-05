require 'swagger_helper'
require_relative '../../helpers/methods'

RSpec.describe 'api/users', type: :request do

  path '/users/{id}' do
    put 'Update own user ' do
      tags 'Regular User'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: regular_user_update_schema
      parameter name: :id, :in => :path, :type => :integer, schema: {type: :integer, required: ['id']}

      response '200', 'user updated' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:params) {user_update_params}
        let(:id) {@user.id}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('shota@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('regular')
        end
      end

      response '400', 'Validation errors' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:params) {user_update_invalid_params}
        let(:id) {@user.id}
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) {"Bearer invalid_token"}
        before do
          initialize_user
        end
        let(:params) {user_update_params}
        let(:id) {@user.id}
        run_test!
      end

      response '403', 'Not Allowed' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @regular_user = regular_user
        end
        let(:params) {user_update_params}
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end
    end
  end

  path '/users/{id}' do
    get 'Show own user' do
      tags 'Regular User'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, :in => :path, :type => :integer, schema: {type: :integer, required: ['id']}

      response '200', 'user data' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:id) {@user.id}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('shota@mail.ru')
          expect(data['full_name']).to eq('test user')
          expect(data['role']).to eq('regular')
        end
      end

      response '403', 'show other user data' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @regular_user = regular_user
        end
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '401', 'Unauthorized' do
        let(:Authorization) {"Bearer invalid_token"}
        before do
          initialize_user
        end
        let(:id) {@user.id}
        run_test!
      end

      response '403', 'Not Allowed' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @regular_user = regular_user
        end
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'User not found' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:id) {19099}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end
    end
  end

  path '/users/{id}' do
    delete 'Delete own user' do
      tags 'Regular User'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, :in => :path, :type => :integer, schema: {type: :integer, required: ['id']}

      response '204', 'Destroyed' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:id) {@user.id}
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) {"Bearer invalid_token"}
        before do
          initialize_user
        end
        let(:id) {@user.id}
        run_test!
      end

      response '403', 'Not Allowed' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @regular_user = regular_user
        end
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'User not found' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:id) {19099}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end
    end
  end
end