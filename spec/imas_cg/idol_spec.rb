# coding: utf-8

require_relative '../spec_helper.rb'

describe ImasCG::Idol do
  context 'を数値（id）で初期化する場合' do
    subject(:idol){ ImasCG::Idol.new 3000401 }

    it 'は#idが第一引数である' do
      expect( idol.id ).to eql 3000401
    end

    it 'は#digestがnilである' do
      expect( idol.digest ).to eql nil
    end
  end

  context 'を文字列（digest）で初期化する場合' do
    subject(:idol){ ImasCG::Idol.new '6bd01496d9b00da9563c7e92b6a40257' }

    it 'は、digestが第一引数である' do
      expect( idol.digest ).to eql '6bd01496d9b00da9563c7e92b6a40257'
    end

    it 'は、idがnilである' do
      expect( idol.id ).to eql nil
    end
  end

  context 'をHashで初期化する場合' do
    subject(:idol){ ImasCG::Idol.new id: 3000401, digest: '6bd01496d9b00da9563c7e92b6a40257' }

    it 'は、idまたはdigestのどちらかが指定されていなければエラー' do
      expect{ ImasCG::Idol.new name: '龍崎薫' }.to raise_error
      expect{ ImasCG::Idol.new id: 3000401 }.not_to raise_error
      expect{ ImasCG::Idol.new digest: '6bd01496d9b00da9563c7e92b6a40257' }.not_to raise_error
    end

    it 'は、idがidキーの値である' do
      expect( idol.id ).to eql 3000401
    end

    it 'は、digestがdigestキーの値である' do
      expect( idol.digest ).to eql '6bd01496d9b00da9563c7e92b6a40257'
    end
  end
end
