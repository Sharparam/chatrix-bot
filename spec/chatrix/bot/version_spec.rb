# frozen_string_literal: true

describe Chatrix::Bot do
  it 'has a version number' do
    expect(Chatrix::Bot::VERSION).not_to be nil
  end

  it 'has a correctly formatted version number' do
    expect(Chatrix::Bot::VERSION).to match(/^\d+\.\d+\.\d+(?:\.\w+)*$/)
  end
end
