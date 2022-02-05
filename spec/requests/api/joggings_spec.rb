require 'swagger_helper'
require_relative '../../helpers/methods'


RSpec.describe '/joggings', type: :request do
  path '/joggings' do
    post 'Create jogging ' do
      tags 'Jogging'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: jogging_params_schema

      response '201', 'jogging created by user' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   date: {type: :string},
                   duration: {type: :string},
                   lon: {type: :string},
                   lat: {type: :string},
                   user_id: {type: :integer},
                   distance: {type: :integer},
                   weather: {
                       type: :object,
                       properties: {
                           temp_c: {type: :string},
                           temp_f: {type: :string},
                           weather_type: {type: :string},
                       }
                   }
               }

        before do
          initialize_user('admin')
          @regular_user = regular_user
          @params = new_jogging_params(@regular_user[:id])
        end
        let(:Authorization) {"Bearer #{ @regular_user[:jwt_token] }"}
        let(:params) { @params }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user_id']).to eq(@regular_user[:id])
          expect(data).to have_key('weather')
        end
      end

      response '400', 'validation errors' do
        before do
          initialize_user('admin')
          @regular_user = regular_user
          @params = new_jogging_params(@regular_user[:id])
          @params[:date] = 'invalid_date'
        end
        let(:Authorization) {"Bearer #{ @regular_user[:jwt_token] }"}
        let(:params) { @params }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end

      response '401', 'unauthorized' do
        before do
          initialize_user('admin')
          @regular_user = regular_user
          @params = new_jogging_params(@regular_user[:id])
        end
        let(:params) { @params }
        let(:Authorization) {"Bearer invalid_token"}
        run_test!
      end
    end
  end

  path '/joggings/{id}' do
    put 'Update jogging ' do
      tags 'Jogging'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: jogging_params_schema

      parameter name: :id, :in => :path, :type => :integer, schema: {
          type: :integer,
          required: ['id']
      }

      response '200', 'jogging updated' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   date: {type: :string},
                   duration: {type: :string},
                   lon: {type: :string},
                   lat: {type: :string},
                   user_id: {type: :integer},
                   distance: {type: :integer},
                   weather: {
                       type: :object,
                       properties: {
                           temp_c: {type: :string},
                           temp_f: {type: :string},
                           weather_type: {type: :string},
                       }
                   }
               }

        before do
          initialize_user
          @jogging = create_joggings
          @jogging.distance = 300
        end
        let(:params) { @jogging }
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['distance']).to eq(300)
        end
      end

      response '400', 'validation errors' do
        before do
          initialize_user
          @jogging = create_joggings
          @jogging.date = 'invalid_date'
        end
        let(:params) { @jogging }
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end

      response '401', 'unauthorized' do
        before do
          initialize_user
          @jogging = create_joggings
          @jogging.date = 'invalid_date'
        end
        let(:params) { @jogging }
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer invalid_token"}
        run_test!
      end

      response '403', 'not allowed' do
        before do
          initialize_user
          @jogging = create_joggings
          @jogging.date = 'invalid_date'
          @jogging.id = 9999
        end
        let(:params) { @jogging }
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end

      response '404', 'jogging not found' do
        before do
          initialize_user('admin')
          @jogging = create_joggings
          @jogging.date = 'invalid_date'
          @jogging.id = 9999
        end
        let(:params) { @jogging }
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path '/joggings/{id}' do
    get 'Show jogging' do
      tags 'Jogging'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, :in => :path, :type => :integer, schema: {
          type: :integer,
          required: ['id']
      }

      response '200', 'jogging data' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   date: {type: :string},
                   duration: {type: :string},
                   lon: {type: :string},
                   lat: {type: :string},
                   user_id: {type: :integer},
                   distance: {type: :integer},
                   weather: {
                       type: :object,
                       properties: {
                           temp_c: {type: :string},
                           temp_f: {type: :string},
                           weather_type: {type: :string},
                       }
                   }
               }
        before do
          initialize_user
          @jogging = create_joggings
        end
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['user_id']).to eq(@user.id)
        end
      end

      response '401', 'unauthorized' do
        before do
          initialize_user
          @jogging = create_joggings
        end
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer invalid_token"}
        run_test!
      end

      response '404', 'jogging not found' do
        before do
          initialize_user('admin')
        end
        let(:id) { 99999 }
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path '/joggings/{id}' do
    delete 'Delete jogging' do
      tags 'Jogging'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, :in => :path, :type => :integer, schema: {
          type: :integer,
          required: ['id']
      }

      response '204', 'destroyed' do
        before do
          initialize_user
          @jogging = create_joggings
          @total_joggings = Jogging.count
        end
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          expect(@total_joggings - 1).to eq(Jogging.count)
        end
      end

      response '401', 'unauthorized' do
        before do
          initialize_user
          @jogging = create_joggings
          @total_joggings = Jogging.count
        end
        let(:id) { @jogging.id }
        let(:Authorization) {"Bearer invalid_token"}
        run_test! do |response|
          expect(@total_joggings).to eq(Jogging.count)
        end
      end

      response '404', 'jogging not found' do
        before do
          initialize_user('admin')
          @jogging = create_joggings
          @total_joggings = Jogging.count
        end
        let(:id) { 9999 }
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
          expect(@total_joggings).to eq(Jogging.count)
        end
      end

    end
  end

  path '/joggings' do
    get 'Jogging List' do
      tags 'Jogging'
      security [Bearer: []]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :filters, in: :query, :type => :string, required: false
      parameter name: :page, in: :query, :type => :integer, required: false
      parameter name: :page_limit, in: :query, :type => :integer, required: false

      response '200', 'jogging list data' do
        schema type: :object,
               properties: {
                   type: :array,
                   items: {
                       type: :object,
                       properties: {
                           id: {type: :integer},
                           date: {type: :string},
                           jogging_duration: {type: :string},
                           lon: {type: :string},
                           lat: {type: :string},
                           user_id: {type: :integer},
                           distance: {type: :integer},
                           weather: {
                               type: :object,
                               properties: {
                                   temp_c: {type: :string},
                                   temp_f: {type: :string},
                                   weather_type: {type: :string},
                               }
                           },
                           user: {
                               type: :object,
                               properties: {
                                   full_name: {type: :string}
                               }
                           }
                       }
                   }
               }
        before do
          initialize_user
          create_joggings
          @total_joggings = Jogging.count
        end
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].size).to eq(@total_joggings)
          expect(data['total_count']).to eq(@total_joggings)
        end
      end

      response '401', 'unauthorized' do
        before do
          initialize_user
          create_joggings
        end
        let(:Authorization) {"Bearer invalid_token"}
        run_test!
      end
    end
  end

end