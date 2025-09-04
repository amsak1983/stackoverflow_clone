RSpec.shared_examples 'oauth_protected_endpoint' do |http_method:, path_proc:|
  it 'returns 401 Unauthorized without access token' do
    path = instance_exec(&path_proc)
    public_send(http_method, path, as: :json)
    expect(response).to have_http_status(:unauthorized)
  end
end
