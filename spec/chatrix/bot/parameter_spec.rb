# frozen_string_literal: true

describe Chatrix::Bot::Parameter do
  let(:autoparam) { Chatrix::Bot::Parameter.new :test, false }
  let(:matcher) { /\w+/ }
  let(:param) { Chatrix::Bot::Parameter.new :expl, false, matcher }
  let(:reqparam) { Chatrix::Bot::Parameter.new :req, true }

  it 'should initialize properly' do
    expect(autoparam.name).to eql :test
    expect(autoparam.required).to eql false
  end

  it 'should match regular parameter' do
    match = autoparam.match 'hello world'
    expect(match).to_not be nil
    expect(match.to_s).to eql 'hello'
  end

  context 'when parameter missing' do
    describe '#parse' do
      context 'when optional parameter' do
        it 'should return nil' do
          expect(autoparam.parse('')).to be nil
        end
      end

      context 'when required parameter' do
        it 'should raise CommandError' do
          expect do
            reqparam.parse ''
          end.to raise_error(
            Chatrix::Bot::CommandError, 'Missing required parameter req'
          )
        end
      end
    end
  end
end
