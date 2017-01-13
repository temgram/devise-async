RSpec.describe Devise::Async do
  it 'yields self when setup is called' do
    described_class.setup { |config| expect(config).to eq(Devise::Async) }
  end

  it 'stores enabled config' do
    described_class.enabled = false
    expect(described_class.enabled).to eq(false)
  end
end
