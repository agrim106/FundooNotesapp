require 'rails_helper'

RSpec.describe 'Notes API', type: :request do
  let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'Strong@123') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  path '/api/v1/notes' do
    post 'Create a note' do
      tags 'Notes'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :note, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        },
        required: ['title']
      }

      response '200', 'Note created' do
        let(:note) { { title: 'Test Note', content: 'Hello from Swagger' } }
        before { submit_request(metadata.merge(headers: headers)) }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Note added successfully')
        end
      end
    end

    get 'Get all notes' do
      tags 'Notes'
      security [bearerAuth: []]
      response '200', 'Notes retrieved' do
        before { submit_request(metadata.merge(headers: headers)) }
        run_test!
      end
    end
  end

  path '/api/v1/notes/{id}' do
    get 'Get a note by ID' do
      tags 'Notes'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      response '200', 'Note found' do
        let(:id) { user.notes.create!(title: 'Test', content: 'Note').id }
        before { submit_request(metadata.merge(headers: headers)) }
        run_test!
      end
    end

    patch 'Update a note' do
      tags 'Notes'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :note, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        }
      }
      response '200', 'Note updated' do
        let(:id) { user.notes.create!(title: 'Test', content: 'Note').id }
        let(:note) { { title: 'Updated Title' } }
        before { submit_request(metadata.merge(headers: headers)) }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Note updated successfully')
        end
      end
    end

    delete 'Delete a note' do
      tags 'Notes'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      response '200', 'Note deleted' do
        let(:id) { user.notes.create!(title: 'Test', content: 'Note').id }
        before { submit_request(metadata.merge(headers: headers)) }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Note deleted permanently')
        end
      end
    end
  end

  path '/api/v1/notes/{id}/archive_toggle' do
    patch 'Toggle archive status' do
      tags 'Notes'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      response '200', 'Archive status toggled' do
        let(:id) { user.notes.create!(title: 'Test', content: 'Note').id }
        before { submit_request(metadata.merge(headers: headers)) }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Archive status toggled')
        end
      end
    end
  end

  path '/api/v1/notes/{id}/trash_toggle' do
    patch 'Toggle trash status' do
      tags 'Notes'
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string
      response '200', 'Trash status toggled' do
        let(:id) { user.notes.create!(title: 'Test', content: 'Note').id }
        before { submit_request(metadata.merge(headers: headers)) }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Status toggled')
        end
      end
    end
  end
end
