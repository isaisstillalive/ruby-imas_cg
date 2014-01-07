# coding: utf-8

require_relative '../spec_helper.rb'

describe ImasCG::Wishlist do
  let(:service){ double('ImasCG::Service') }
  let(:wishlist){ described_class.new service }

  it 'はEnumerableをincludeしている' do
    expect( described_class ).to include Enumerable
  end

  context 'を<service>で初期化した場合' do
    describe '@service' do
      subject{ wishlist.instance_variable_get(:@service) }

      it 'は<service>である' do
        expect( subject ).to equal service
      end
    end
  end

  describe '#each' do
    subject{ wishlist.each{} }

    it 'は@service#get_wishlistを実行する' do
      expect( service ).to receive(:get_wishlist).and_return([])
      subject
    end
  end

  describe '#<<' do
    subject{ wishlist << 123 }

    it 'は@service#regist_wishlistを実行する' do
      expect( service ).to receive(:regist_wishlist).with(123)
      subject
    end
  end

  context '#delete' do
    subject{ wishlist.delete(123) }

    it 'は@service#removes_wishlistを実行する' do
      expect(service).to receive(:removes_wishlist).with(123)
      subject
    end
  end
end
