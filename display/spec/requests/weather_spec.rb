require 'rails_helper'

RSpec.describe 'Weather page', type: :request do
  it 'renders index' do
    nats_double = double(
      read_kv: nil,
      close: true
    )
    allow(NatsClient).to receive(:new).and_return(nats_double)
    get '/'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Прогноз погоды')
  end
end
