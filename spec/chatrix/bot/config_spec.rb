# frozen_string_literal: true

describe Chatrix::Bot::Config do
  let(:config) { Chatrix::Bot::Config.new }

  it 'sets a value' do
    config[:foo] = 'bar'
    expect(config[:foo]).to eql 'bar'
  end

  describe '#get' do
    it 'gets the default on undefined keys' do
      expect(config.get(:bar, 'world')).to eql 'world'
    end

    it 'sets the default on undefined keys' do
      config.get :baz, 'hello'
      expect(config[:baz]).to eql 'hello'
    end

    it 'gets existing value on defined keys' do
      config[:foo] = 'bar'
      expect(config.get(:foo, 'baz')).to eql 'bar'
    end

    it 'does not set defined keys' do
      config[:foo] = 'bar'
      config.get :foo, 'baz'
      expect(config[:foo]).to eql 'bar'
    end
  end

  describe '#load' do
    let(:data) do
      YAML.load(
        <<~EOF
        ---
        :str_key: "a string value"
        :arr_key:
        - foo
        - bar
        EOF
      )
    end

    let(:target) { File.expand_path 'config.yaml' }

    it 'should load from file properly' do
      dir = File.dirname target
      expect(File).to receive(:exist?).with(dir).and_return true
      expect(File).to receive(:exist?).with(target).and_return true
      expect(YAML).to receive(:load_file).with(target).and_return data
      config = Chatrix::Bot::Config.new 'config.yaml'
      expect(config.file).to eql target
      expect(config[:str_key]).to eql 'a string value'
    end
  end

  describe '#save' do
    let(:target) { File.expand_path 'my_file.yaml' }

    let(:content) do
      <<~EOF
      ---
      :my_key: my simple string
      EOF
    end

    let(:buffer) { StringIO.new }

    it 'should save data to file' do
      expect(File).to receive(:open).with(target, 'w').and_yield buffer
      Chatrix::Bot::Config.new(
        'my_file.yaml', my_key: 'my simple string'
      ).save
      expect(buffer.string).to eql content
    end
  end
end
