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
        let(:name) { 'Kavita Chaudhary' }
        let(:email) { 'kc247989@gmail.com' }
        let(:phone_number) { '+917888465372' }
        let(:password) { 'password@123' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:created)
          expect(data['message']).to eq('User created successfully')
        end
      end

      response '400', 'Invalid email' do
        let(:name) { 'Kavita Chaudhary' }
        let(:email) { 'invalid-email' }
        let(:phone_number) { '+917888465372' }
        let(:password) { 'password@123' }
        run_test! do |response|
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end

  path '/api/v1/users/login' do
    post 'Log in a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :email, in: :body, schema: { type: :string }
      parameter name: :password, in: :body, schema: { type: :string }

      response '200', 'Login successful' do
        let(:user) { User.create!(name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', phone_number: '+917888465372', password: 'password@123') }
        let(:email) { 'kc247989@gmail.com' }
        let(:password) { 'password@123' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(data['message']).to eq('Login successful')
          expect(data['token']).not_to be_nil
        end
      end

      response '401', 'Invalid credentials' do
        let(:user) { User.create!(name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', phone_number: '+917888465372', password: 'password@123') }
        let(:email) { 'invalid@example.com' }
        let(:password) { 'password@123' }
        run_test! do |response|
          data = JSON vase(response.body)
          expect(response).to have_http_status(:unauthorized)
          expect(data['error']).to eq('Invalid email or password')
        end
      end

      response '400', 'Missing parameters' do
        let(:password) { 'password@123' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(response).to have_http_status(:bad_request)
          expect(data['status']).to eq('error')
          expect(data['message']).to eq('Missing email or password')
        end
      end
    end
  end

  path '/api/v1/users/forget' do
    post 'Request password reset' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :email, in: :body, schema: { type: :string }

      response '200', 'OTP sent' do
        let(:user) { User.create!(name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password@123') }
        let(:email) { 'kc247989@gmail.com' }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('OTP sent successfully to your email')
        end
      end

      response '404', 'Email not found' do
        let(:email) { 'invalid@example.com' }
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
      parameter name: :new_password, in: :body, schema: { type: :string }
      parameter name: :otp, in: :body, schema: { type: :string }

      response '200', 'Password reset successful' do
        let(:user) { User.create!(name: 'Kavita Chaudhary', email: 'kc247989@gmail.com', password: 'password@123') }
        let(:id) { user.id }
        let(:otp) { UserService.forgetPassword({ email: 'kc247989@gmail.com' })[:otp] }
        let(:new_password) { 'newpassword@123' }
        let(:otp_param) { otp }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Password reset successfully')
        end
      end
    end
  end
end
