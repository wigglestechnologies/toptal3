require 'swagger_helper'
require_relative '../../helpers/methods'

describe 'Reports', type: :request do

  path '/reports' do
    get 'Report per week for my average speed and distance' do
      tags 'Reports'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :filters, in: :query, :type => :string, required: false
      parameter name: :page, in: :query, :type => :integer, required: false
      parameter name: :page_limit, in: :query, :type => :integer, required: false

      response '200', 'success' do
        schema type: :object,
               properties: {
                   type: :array,
                   items: {
                       type: :object,
                       properties: {
                           id: {type: :integer},
                           week: {type: :string},
                           average_speed: {type: :number},
                           total_distance: {type: :integer},
                       }
                   }
               }
        before do
          initialize_user
          create_joggings
        end
        let(:Authorization) {"Bearer #{ @jwt_token }"}
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].size).to eq(1)
          expect(data['total_count']).to eq(1)
        end
      end

      response '401', 'Unauthorised' do
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