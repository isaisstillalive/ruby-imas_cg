# coding: utf-8

require_relative 'spec_helper.rb'

describe ImasCG do
  describe '#[]' do
    context 'に "id" を渡した場合' do
      subject{ described_class['id'] }

      it 'は ImasCG::Service.new "id" を実行する' do
        expect( ImasCG::Service ).to receive(:new).with('id', {}).and_return('')
        expect( subject ).to eql ''
      end
    end

    context 'に "id", options を渡した場合' do
      let(:options) { {test: 'value'} }
      subject{ described_class['id', options] }

      it 'は ImasCG::Service.new "id", options を実行する' do
        expect( ImasCG::Service ).to receive(:new).with('id', options).and_return('')
        expect( subject ).to eql ''
      end
    end
  end
end
