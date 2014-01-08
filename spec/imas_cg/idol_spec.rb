# coding: utf-8

require_relative '../spec_helper.rb'

describe ImasCG::Idol do
  shared_examples_for '空' do
    describe '#name' do
      subject{ idol.name }

      it 'はnilである' do
        expect( subject ).to eql nil
      end
    end
  end

  context 'を数値（id）で初期化した場合' do
    let(:idol){ described_class.new 3000401 }

    describe '#id' do
      subject{ idol.id }

      it 'は数値（id）である' do
        expect( subject ).to eql 3000401
      end
    end

    describe '#digest' do
      subject{ idol.digest }

      it 'はnilである' do
        expect( subject ).to eql nil
      end
    end

    it_behaves_like '空'
  end

  context 'を文字列（digest）で初期化した場合' do
    let(:idol){ described_class.new '6bd01496d9b00da9563c7e92b6a40257' }

    describe '#id' do
      subject{ idol.id }

      it 'はnilである' do
        expect( subject ).to eql nil
      end
    end

    describe '#digest' do
      subject{ idol.digest }

      it 'は文字列（digest）である' do
        expect( subject ).to eql '6bd01496d9b00da9563c7e92b6a40257'
      end
    end

    it_behaves_like '空'
  end

  context 'をHash（データ）で初期化した場合' do
    let(:idol){ described_class.new id: 3000401, digest: '6bd01496d9b00da9563c7e92b6a40257', name: '龍崎薫' }

    it 'は、idまたはdigestのどちらかが指定されていなければエラーとなる' do
      expect{ described_class.new name: '龍崎薫' }.to raise_error
      expect{ described_class.new id: 3000401, name: '龍崎薫' }.not_to raise_error
      expect{ described_class.new digest: '6bd01496d9b00da9563c7e92b6a40257', name: '龍崎薫' }.not_to raise_error
    end

    describe '#id' do
      subject{ idol.id }

      it 'はHash[:id]である' do
        expect( subject ).to eql 3000401
      end
    end

    describe '#digest' do
      subject{ idol.digest }

      it 'はHash[:digest]である' do
        expect( subject ).to eql '6bd01496d9b00da9563c7e92b6a40257'
      end
    end

    describe '#name' do
      subject{ idol.name }

      it 'はHash[:name]である' do
        expect( subject ).to eql '龍崎薫'
      end
    end
  end
end
