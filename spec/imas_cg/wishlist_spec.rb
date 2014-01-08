# coding: utf-8

require_relative '../spec_helper.rb'

describe ImasCG::Wishlist do
  it 'はEnumerableをincludeしている' do
    expect( described_class ).to include Enumerable
  end

  context 'を<service>で初期化した場合' do
    let(:service){ double('ImasCG::Service') }
    let(:wishlist){ described_class.new service }

    describe '@service' do
      subject{ wishlist.instance_variable_get(:@service) }

      it 'は<service>である' do
        expect( subject ).to equal service
      end
    end

    describe '#each' do
      context 'にブロックを渡した場合' do
        subject do
          [].tap do |result|
            wishlist.each{ |value| result << value }
          end
        end

        it 'は<service>#get_wishlistを実行する' do
          expect( service ).to receive(:get_wishlist).and_return([1,2,3])
          expect( subject ).to eql [1,2,3]
        end
      end

      context 'にブロックを渡さない場合' do
        subject{ wishlist.each }

        it 'は<service>#get_wishlistを実行しない' do
          expect( service ).not_to receive(:get_wishlist)
          subject
        end

        it 'はEnumeratorを返す' do
          expect( subject ).to be_an_instance_of Enumerator
        end
      end

      context 'の戻り値のEnumeratorを実行した場合' do
        subject{ wishlist.each.to_a }

        it 'は<service>#get_wishlistを実行する' do
          expect( service ).to receive(:get_wishlist).and_return([1,2,3])
          expect( subject ).to eql [1,2,3]
        end
      end
    end

    describe '#<<' do
      subject{ wishlist << idol }

      context 'にIdolを渡した場合' do
        let(:idol){ ImasCG::Idol.new(digest: '123') }

        it 'は <service>#regist_wishlist(Idol#digest) を実行する' do
          expect( service ).to receive(:regist_wishlist).with('123')
          subject
        end
      end

      context 'にdigestの設定されていないIdolを渡した場合' do
        let(:idol){ ImasCG::Idol.new(id: 123) }

        it 'は <service>#regist_wishlist を実行しない' do
          expect( service ).not_to receive(:regist_wishlist)
          subject rescue nil
        end

        it 'は例外を返す' do
          expect{ subject }.to raise_error
        end
      end

      context 'にIdol以外を渡した場合' do
        let(:idol){ 123 }

        it 'は <service>#regist_wishlist(引数) を実行する' do
          expect( service ).to receive(:regist_wishlist).with(123)
          subject
        end
      end
    end

    context '#delete' do
      subject{ wishlist.delete(idol) }

      context 'にIdolを渡した場合' do
        let(:idol){ ImasCG::Idol.new(id: 123) }

        it 'は <service>#removes_wishlist(Idol#id) を実行する' do
          expect( service ).to receive(:removes_wishlist).with(123)
          subject
        end
      end

      context 'にidの設定されていないIdolを渡した場合' do
        let(:idol){ ImasCG::Idol.new(digest: '123') }

        it 'は <service>#removes_wishlist を実行しない' do
          expect( service ).not_to receive(:removes_wishlist)
          subject rescue nil
        end

        it 'は例外を返す' do
          expect{ subject }.to raise_error
        end
      end

      context 'にIdol以外を渡した場合' do
        let(:idol){ 123 }

        it 'は <service>#removes_wishlist(引数) を実行する' do
          expect(service).to receive(:removes_wishlist).with(123)
          subject
        end
      end
    end
  end
end
