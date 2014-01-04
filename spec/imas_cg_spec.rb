# coding: utf-8

require_relative 'spec_helper.rb'

describe ImasCG do
  context 'の#[]を実行する場合' do
    it 'はImasCG::Service.newを実行する' do
      ImasCG::Service.should_receive(:new).with('id', {}).and_return('')
      ImasCG['id'].should eql ''
    end

    it 'はImasCG::Service.newを実行する' do
      options = {test: 'value'}
      ImasCG::Service.should_receive(:new).with('id', options).and_return('')
      ImasCG['id', options].should eql ''
    end
  end
end
