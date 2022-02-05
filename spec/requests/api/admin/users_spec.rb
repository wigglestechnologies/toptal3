require 'swagger_helper'
require_relative '../../../helpers/methods'

RSpec.describe 'api/admin/users', type: :request do

  path '/admin/users' do
    post 'Create user ' do
      tags 'User'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: user_creation_schema

      response '201', 'regular user created by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
        end
        let(:params) {user_creation_params}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('foo@foo.com')
          expect(data['full_name']).to eq('test')
          expect(data['role']).to eq('regular')
        end
      end

      response '201', 'manager user created by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
        end
        let(:params) { user_creation_params(role: 'manager') }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('foo@foo.com')
          expect(data['full_name']).to eq('test')
          expect(data['role']).to eq('manager')
        end
      end

      response '201', 'admin user created by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
        end
        let(:params) { user_creation_params(role: 'admin') }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('foo@foo.com')
          expect(data['full_name']).to eq('test')
          expect(data['role']).to eq('admin')
        end
      end

      response '201', 'regular user created by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
        end
        let(:params) { user_creation_params }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('foo@foo.com')
          expect(data['full_name']).to eq('test')
          expect(data['role']).to eq('regular')
        end
      end

      response '201', 'manager user created by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
        end
        let(:params) { user_creation_params(role: 'manager') }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('foo@foo.com')
          expect(data['full_name']).to eq('test')
          expect(data['role']).to eq('manager')
        end
      end

      response '403', 'Not Allowed admin user created by manager' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
        end
        let(:params) { user_creation_params(role: 'admin') }
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Not Allowed regular user created by regular' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:params) { user_creation_params }
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Not Allowed manager user created by regular' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:params) { user_creation_params(role: 'manager') }
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Not Allowed admin user created by regular' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:params) { user_creation_params(role: 'admin') }
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '422', 'existed admin user created by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
        end
        let(:params) {user_creation_params(email: 'shota@mail.ru')}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '400', 'Validation errors' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
        end
        let(:params) {user_creation_invalid_params}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
          expect(data[0]['field']).to eq('email')
        end
      end

      response '401', 'Unauthorized' do
        let(:Authorization) {"Bearer invalid_token"}
        before do
          initialize_user
        end
        let(:params) {user_creation_params}
        run_test!
      end
    end
  end

  path '/admin/users/{id}' do
    put 'Update user ' do
      tags 'User'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: user_update_schema
      parameter name: :id, :in => :path, :type => :integer, schema: {type: :integer, required: ['id']}

      response '200', 'regular user updated by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @regular_user = regular_user
        end
        let(:params) { user_update_params }
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('regular@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('regular')
        end
      end

      response '200', 'promote regular user to manager by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @regular_user = regular_user
        end
        let(:params) { user_update_params(role: 'manager') }
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('regular@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('manager')
        end
      end

      response '200', 'manager user updated by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @manager_user = manager_user
        end
        let(:params) { user_update_params }
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('manager@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('manager')
        end
      end

      response '200', 'promote manager user to admin by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @manager_user = manager_user
        end
        let(:params) { user_update_params(role: 'admin') }
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('manager@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('admin')
        end
      end

      response '200', 'demoted manager user to regular by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @manager_user = manager_user
        end
        let(:params) { user_update_params(role: 'regular') }
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('manager@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('regular')
        end
      end

      response '200', 'admin user updated by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @admin_user = admin_user
        end
        let(:params) { user_update_params }
        let(:id) {@admin_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('admin@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('admin')
        end
      end

      response '200', 'demoted admin user to manager by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @admin_user = admin_user
        end
        let(:params) { user_update_params(role: 'manager') }
        let(:id) {@admin_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('admin@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('manager')
        end
      end

      response '200', 'regular user updated by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @regular_user = regular_user
        end
        let(:params) { user_update_params }
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('regular@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('regular')
        end
      end

      response '200', 'promoted regular user to manager by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @regular_user = regular_user
        end
        let(:params) { user_update_params(role: 'manager') }
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('regular@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('manager')
        end
      end

      response '200', 'manager user updated by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @manager_user = manager_user
        end
        let(:params) { user_update_params }
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('manager@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('manager')
        end
      end

      response '200', 'demoted manager user to regular by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @manager_user = manager_user
        end
        let(:params) { user_update_params(role: 'regular') }
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('manager@mail.ru')
          expect(data['full_name']).to eq('name_update')
          expect(data['role']).to eq('regular')
        end
      end

      response '403', 'Not allowed promoted manager user to admin by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @manager_user = manager_user
        end
        let(:params) { user_update_params(role: 'admin') }
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Not allowed regular user updated by regular' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @regular_user = regular_user
        end
        let(:params) { user_update_params }
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'regular user update' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @regular_user[:jwt_token] }"}
        before do
          @regular_user = regular_user
        end
        let(:params) { user_update_params }
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '400', 'Validation errors' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
        end
        let(:params) {user_update_invalid_params}
        let(:id) {@user.id}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
          expect(data[0]['field']).to eq('email')
        end
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
    end
  end

  path '/admin/users/{id}' do
    get 'Show user' do
      tags 'User'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, :in => :path, :type => :integer, schema: {type: :integer, required: ['id']}

      response '200', 'show admin user data by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do  initialize_user('admin') end
        let(:id) {@user.id}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('shota@mail.ru')
          expect(data['full_name']).to eq('test user')
          expect(data['role']).to eq('admin')
        end
      end

      response '200', 'show other admin user data by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @admin_user = admin_user
        end
        let(:id) {@admin_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('admin@mail.ru')
          expect(data['full_name']).to eq('admin user')
          expect(data['role']).to eq('admin')
        end
      end

      response '200', 'show manager user data by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @manager_user = manager_user
        end
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('manager@mail.ru')
          expect(data['full_name']).to eq('manager user')
          expect(data['role']).to eq('manager')
        end
      end

      response '200', 'show regular user data by admin' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @regular_user = regular_user
        end
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('regular@mail.ru')
          expect(data['full_name']).to eq('regular user')
          expect(data['role']).to eq('regular')
        end
      end

      response '200', 'show manager user data by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
        end
        let(:id) {@user.id}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('shota@mail.ru')
          expect(data['full_name']).to eq('test user')
          expect(data['role']).to eq('manager')
        end
      end

      response '200', 'show other manager user data by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @manager_user = manager_user
        end
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('manager@mail.ru')
          expect(data['full_name']).to eq('manager user')
          expect(data['role']).to eq('manager')
        end
      end

      response '200', 'show regular user data by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @regular_user = regular_user
        end
        let(:id) {@regular_user[:id]}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['email']).to eq('regular@mail.ru')
          expect(data['full_name']).to eq('regular user')
          expect(data['role']).to eq('regular')
        end
      end

      response '403', 'Not allowed show admin user data by manager' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @admin_user = admin_user
        end
        let(:id) {@admin_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Not allowed show admin user data by regular' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @admin_user = admin_user
        end
        let(:id) {@admin_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Not allowed show manager user data by regular' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @manager_user = manager_user
        end
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Not allowed show other regular user data by regular' do
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

      response '403', 'show regular user data by regular' do
        schema type: :object, properties: user_response
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
        end
        let(:id) {@user.id}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '401', 'Unauthorized' do
        let(:Authorization) {"Bearer invalid_token"}
        before do  initialize_user('admin') end
        let(:id) {@user.id}
        run_test!
      end

      response '403', 'Not Allowed' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @user_to_destroy = create(:user, email: "email@mail.ru", password: "Pass123!")
        end
        let(:id) {@user_to_destroy.id}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '404', 'User not found' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do  initialize_user('admin') end
        let(:id) {19099}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end
    end
  end

  path '/admin/users/{id}' do
    delete 'Delete user' do
      tags 'User'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, :in => :path, :type => :integer, schema: {type: :integer, required: ['id']}

      response '204', 'Destroy admin user by admin' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @admin_user = admin_user
        end
        let(:id) {@admin_user[:id]}
        run_test!
      end

      response '204', 'Destroy manager user by admin' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @manager_user = manager_user
        end
        let(:id) {@manager_user[:id]}
        run_test!
      end

      response '204', 'Destroy regular user by admin' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          @regular_user = regular_user
        end
        let(:id) {@regular_user[:id]}
        run_test!
      end

      response '403', 'Destroy admin user by manager' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @admin_user = admin_user
        end
        let(:id) {@admin_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '204', 'Destroy manager user by manager' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @manager_user = manager_user
        end
        let(:id) {@manager_user[:id]}
        run_test!
      end

      response '204', 'Destroy regular user by manager' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @regular_user = regular_user
        end
        let(:id) {@regular_user[:id]}
        run_test!
      end

      response '403', 'Destroy admin user by regular' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @admin_user = admin_user
        end
        let(:id) {@admin_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Destroy manager user by regular' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @manager_user = manager_user
        end
        let(:id) {@manager_user[:id]}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '403', 'Destroy regular user by regular' do
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
        before do  initialize_user('admin') end
        let(:id) {@user.id}
        run_test!
      end

      response '404', 'User not found' do
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do  initialize_user('admin') end
        let(:id) {19099}
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end
    end
  end

  path '/admin/users' do
    get 'User List' do
      tags 'User'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :filters, in: :query, :type => :string, required: false
      parameter name: :page, in: :query, :type => :integer, required: false
      parameter name: :page_limit, in: :query, :type => :integer, required: false

      response '200', 'User list data by admin' do
        schema  type: :object, properties: {type: :array, items: {type: :object, properties: user_response}}
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('admin')
          manager_user
          regular_user
        end
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].size).to eq(3)
          expect(data['total_count']).to eq(3)
        end
      end

      response '200', 'User list data by manager' do
        schema  type: :object, properties: {type: :array, items: {type: :object, properties: user_response}}
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user('manager')
          @admin_user = admin_user
          @regular_user = regular_user
        end
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].size).to eq(2)
          expect(data['total_count']).to eq(2)
        end
      end

      response '403', 'User list data by regular' do
        schema  type: :object, properties: {type: :array, items: {type: :object, properties: user_response}}
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        before do
          initialize_user
          @admin_user = admin_user
          @manager_user = manager_user
        end
        run_test! do |response|
          data = error_response_parser(response)
          expect(data.size).to eq(1)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) {"Bearer  invalid token "}
        before do initialize_user('admin') end
        run_test!
      end
    end
  end
end