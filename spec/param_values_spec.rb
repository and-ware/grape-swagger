require 'spec_helper'
require 'grape_version'

describe 'Convert values to enum' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :letter, type: String, values: %w(a b c)
      end
      post :plain_array do
      end

      params do
        requires :letter, type: String, values: proc { %w(d e f) }
      end
      post :array_in_proc do
      end

      params do
        requires :letter, type: String, values: 'a'..'z'
      end
      post :range_letter do
      end

      params do
        requires :integer, type: Integer, values: -5..5
      end
      post :range_integer do
      end

      add_swagger_documentation
    end
  end

  def first_parameter_info(request)
    get "/swagger_doc/#{request}"
    expect(last_response.status).to eq 200
    body = JSON.parse last_response.body
    body['apis'].first['operations'].first['parameters']
  end

  context 'Plain array values' do
    subject(:plain_array) { first_parameter_info('plain_array') }

    it 'has values as array in enum' do
      expect(plain_array).to eq [
        { 'paramType' => 'form', 'name' => 'letter', 'description' => nil, 'type' => 'string', 'required' => true, 'allowMultiple' => false, 'enum' => %w(a b c) }
      ]
    end
  end

  context 'Array in proc values' do
    subject(:array_in_proc) { first_parameter_info('array_in_proc') }

    it 'has proc returned values as array in enum' do
      expect(array_in_proc).to eq [
        { 'paramType' => 'form', 'name' => 'letter', 'description' => nil, 'type' => 'string', 'required' => true, 'allowMultiple' => false, 'enum' => %w(d e f) }
      ]
    end
  end

  context 'Range values' do
    subject(:range_letter) { first_parameter_info('range_letter') }

    it 'has letter range values as array in enum' do
      expect(range_letter).to eq [
        { 'paramType' => 'form', 'name' => 'letter', 'description' => nil, 'type' => 'string', 'required' => true, 'allowMultiple' => false, 'enum' => ('a'..'z').to_a }
      ]
    end

    subject(:range_integer) { first_parameter_info('range_integer') }

    it 'has integer range values as array in enum' do
      expect(range_integer).to eq [
        { 'paramType' => 'form', 'name' => 'integer', 'description' => nil, 'type' => 'integer', 'required' => true, 'allowMultiple' => false, 'format' => 'int32', 'enum' => (-5..5).to_a }
      ]
    end
  end
end

describe 'Convert values to enum for float range and not arrays inside a proc', if: GrapeVersion.satisfy?('>= 0.11.0') do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :letter, type: String, values: proc { 'string' }
      end
      post :non_array_in_proc do
      end

      params do
        requires :float, type: Float, values: -5.0..5.0
      end
      post :range_float do
      end

      add_swagger_documentation
    end
  end

  def first_parameter_info(request)
    get "/swagger_doc/#{request}"
    expect(last_response.status).to eq 200
    body = JSON.parse last_response.body
    body['apis'].first['operations'].first['parameters']
  end

  context 'Non array in proc values' do
    subject(:non_array_in_proc) { first_parameter_info('non_array_in_proc') }

    it 'has proc returned value as string in enum' do
      expect(non_array_in_proc).to eq [
        { 'paramType' => 'form', 'name' => 'letter', 'description' => nil, 'type' => 'string', 'required' => true, 'allowMultiple' => false, 'enum' => 'string' }
      ]
    end
  end

  context 'Range values' do
    subject(:range_float) { first_parameter_info('range_float') }

    it 'has float range values as string in enum' do
      expect(range_float).to eq [
        { 'paramType' => 'form', 'name' => 'float', 'description' => nil, 'type' => 'float', 'required' => true, 'allowMultiple' => false, 'enum' => '-5.0..5.0' }
      ]
    end
  end
end
