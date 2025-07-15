RSpec.shared_examples 'request status' do |status|
  it "returns http #{status}" do
    expect(response).to have_http_status(status)
  end
end

RSpec.shared_examples 'renders template' do |template|
  it "renders #{template} template" do
    expect(response).to render_template(template)
  end
end

RSpec.shared_examples 'redirects to' do |path_helper, *args|
  it "redirects to #{path_helper}" do
    expect(response).to redirect_to(send(path_helper, *args))
  end
end

RSpec.shared_examples 'sets flash message' do |type, message|
  it "sets flash #{type} to '#{message}'" do
    expect(flash[type]).to eq(message)
  end
end
