require 'rails_helper'

RSpec.describe 'Notes API', type: :request do
  let(:user) { User.create!(name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'Password@123') }
  let(:token) { JsonWebToken.encode(user_id: user.id) }
  let(:headers) { { 'Authorization' => "Bearer #{token}", 'CONTENT_TYPE' => 'application/json' } }

  path '/api/v1/notes/create' do
    post 'Create a note' do
      tags 'Notes'
      security [bearerAuth: []]
      consumes 'application/json'
      # Define the body as a raw JSON schema without wrapping
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        },
        required: ['title'],
        additionalProperties: false
      }, description: 'Note creation payload (flat structure)'

      response '200', 'Note created' do
        let(:body) { { title: "Kavita's Note", content: 'Testing Swagger CRUD' } }
        before do
          # Explicitly send the body as a flat JSON string
          submit_request(
            metadata.merge(
              headers: headers,
              body: body.to_json
            )
          )
        end
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Note added successfully')
        end
      end
    end
  end

  path '/api/v1/notes/getNote' do
    get 'Get all notes' do
      tags 'Notes'
      security [bearerAuth: []]
      response '200', 'Notes retrieved' do
        before { submit_request(metadata.merge(headers: headers)) }
        run_test!
      end
    end
  end

  path '/api/v1/notes/getNoteById/{id}' do
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
  end

  path '/api/v1/notes/updateNote/{id}' do
    patch 'Update a note' do
      tags 'Notes'
      security [bearerAuth: []]
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string }
        },
        additionalProperties: false
      }

      response '200', 'Note updated' do
        let(:id) { user.notes.create!(title: 'Test', content: 'Note').id }
        let(:body) { { title: 'Updated Title', content: 'Updated Content' } }
        before do
          submit_request(
            metadata.merge(
              headers: headers,
              body: body.to_json
            )
          )
        end
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Note updated successfully')
        end
      end
    end
  end

  path '/api/v1/notes/deleteNote/{id}' do
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

  path '/api/v1/notes/archiveToggle/{id}' do
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

  path '/api/v1/notes/trashToggle/{id}' do
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
