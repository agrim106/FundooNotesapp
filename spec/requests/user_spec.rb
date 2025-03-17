require 'rails_helper'

RSpec.describe 'User Authentication', type: :request do
  path '/api/v1/users' do
    post 'Register a new user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :name, in: :body, schema: { type: :string }
      parameter name: :email, in: :body, schema: { type: :string }
      parameter name: :phone_number, in: :body, schema: { type: :string }
      parameter name: :password, in: :body, schema: { type: :string }

      response '201', 'User created successfully' do
        let(:name) { 'Test User' }
        let(:email) { 'test@example.com' }
        let(:phone_number) { '+1234567890' }
        let(:password) { 'Strong@123' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(data['message']).to eq('User created successfully')
        end
      end

      response '400', 'Invalid email' do
        let(:name) { 'Test User' }
        let(:email) { 'invalid-email' }
        let(:phone_number) { '+1234567890' }
        let(:password) { 'Strong@123' }
        run_test! do |response|
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  # Rest of the file remains the same...
end

  path '/api/v1/users/login' do
    post 'Log in a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }
      response '200', 'Login successful' do
        let(:user) { User.create!(name: 'Test User', email: 'test@example.com', phone_number: '+1234567890', password: 'Strong@123') }
        let(:credentials) { { email: 'test@example.com', password: 'Strong@123' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['message']).to eq('Login successful')
          expect(data['token']).not_to be_nil
        end
      end
      response '401', 'Invalid credentials' do
        let(:user) { User.create!(name: 'Test User', email: 'test@example.com', phone_number: '+1234567890', password: 'Strong@123') }
        let(:credentials) { { email: 'invalid@example.com', password: 'Strong@123' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['error']).to eq('Invalid email or password')
        end
      end
      response '400', 'Missing parameters' do
        let(:credentials) { { password: 'Strong@123' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:bad_request)
          expect(data['status']).to eq('error')
          expect(data['message']).to eq('Missing email or password')
        end
      end
    end
  end

  path '/api/v1/users/forget' do  # Fixed typo
    post 'Request password reset' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string }
        },
        required: ['email']
      }
      response '200', 'OTP sent' do
        let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'Strong@123') }
        let(:user_params) { { email: 'test@example.com' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('OTP sent successfully to your email')
        end
      end
      response '404', 'Email not found' do
        let(:user_params) { { email: 'invalid@example.com' } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to eq('Email not registered')
        end
      end
    end
  end

  path '/api/v1/users/reset/{id}' do
    patch 'Reset password with OTP' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :reset, in: :body, schema: {
        type: :object,
        properties: {
          new_password: { type: :string },
          otp: { type: :string }
        },
        required: ['new_password', 'otp']
      }
      response '200', 'Password reset successful' do
        let(:user) { User.create!(name: 'Test User', email: 'test@example.com', password: 'Strong@123') }
        let(:id) { user.id }
        let(:otp) { UserService.forgetPassword({ email: 'test@example.com' })[:otp] }
        let(:reset) { { new_password: 'NewPass@123', otp: otp } }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Password reset successfully')
        end
      end
    end
  end
