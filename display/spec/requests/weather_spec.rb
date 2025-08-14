require 'rails_helper'

RSpec.describe 'Weather page', type: :request do
  it 'renders index' do
    get '/'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Прогноз погоды')
  end
end


