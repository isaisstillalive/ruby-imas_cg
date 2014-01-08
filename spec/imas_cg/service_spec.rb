# coding: utf-8

require_relative '../spec_helper.rb'

describe ImasCG::Service do
  let(:service){ described_class.new 'id' }
  let(:conn){ service.instance_variable_get(:@conn) }
  let(:handlers){ conn.builder.handlers }

  context 'を初期化する場合' do
    shared_examples_for '"id"を保持' do
      describe '#sid' do
        subject{ service.sid }

        it 'は"id"である' do
          expect( subject ).to eql 'id'
        end
      end
    end

    context 'に"id"を渡した場合' do
      let(:service){ described_class.new 'id' }

      it_behaves_like '"id"を保持'

      it 'はログ出力を行わない' do
        expect( handlers ).not_to include Faraday::Response::Logger
      end
    end

    context 'に"id, { logging: true }"を渡した場合' do
      let(:service){ described_class.new 'id', logging: true }

      it_behaves_like '"id"を保持'

      it 'はログ出力を行う' do
        expect( handlers ).to include Faraday::Response::Logger
      end
    end
  end

  describe '#request_list' do
    context 'にブロックを渡さない場合' do
      subject{ service.__send__(:request_list, :method, 'path', nil, /\d/m) }

      it 'は#requestを呼び出し、戻り値を配列に変換する' do
        expect( service ).to receive(:request).with(:method, 'path', nil).and_return('0123456789')
        expect( subject ).to eql %w{0 1 2 3 4 5 6 7 8 9}
      end
    end

    context 'にブロックを渡した場合' do
      subject{ service.__send__(:request_list, :method, 'path', nil, /\d/m){ |m| 'b'+m } }

      it 'は#requestを呼び出し、戻り値をブロックを使用して配列に変換する' do
        expect( service ).to receive(:request).with(:method, 'path', nil).and_return('0123456789')
        expect( subject ).to eql %w{b0 b1 b2 b3 b4 b5 b6 b7 b8 b9}
      end
    end
  end

  describe '#get_wishlist' do
    subject{ service.get_wishlist }

    it 'は#requestを"wish/index"で呼び出し、戻り値を配列に変換する' do
      expect( service ).to receive(:request).with(:get, 'wish/index', nil).and_return(html 'get_wishlist.html')
      expect( subject ).to eql [
        {hash: 'ae3ba85f888597f52c2744eeac3d9ace', id: '3402901', name: '[ｻﾝﾌﾗﾜｰｲｴﾛｰ]龍崎薫'},
        {hash: '94f468204a314b13c221bc2ff351a15a', id: '3410001', name: '[ちびっこﾎﾟﾘｽ]龍崎薫'},
      ]
    end
  end

  describe '#regist_wishlist' do
    subject{ service.regist_wishlist(100) }

    it 'は#headを"wish/regist/[hash]/0"で呼び出す' do
      expect( service ).to receive(:head).with('wish/regist/100/0')
      subject
    end
  end

  describe '#remove_wishlist' do
    subject{ service.remove_wishlist(100) }

    it 'は#headを"wish/removes/0/[id]"で呼び出す' do
      expect( service ).to receive(:head).with('wish/removes/0/100')
      subject
    end
  end

  describe '#get_gallary' do
    context 'に何も渡さなかった場合' do
      subject{ service.get_gallary() }

      it 'は#requestを"gallery, keyword: nil"で呼び出す' do
        expect( service ).to receive(:request).with(:post, 'gallery', keyword: nil).and_return('')
        subject
      end
    end

    context 'に"Key"を渡した場合' do
      subject{ service.get_gallary('Key') }

      it 'は#requestを"gallery, keyword: Key"で呼び出す' do
        expect( service ).to receive(:request).with(:post, 'gallery', keyword: 'Key').and_return('')
        subject
      end
    end

    subject{ service.get_gallary('ざき') }

    it 'は#requestの戻り値を配列に変換する' do
      expect( service ).to receive(:request).with(:post, 'gallery', keyword: 'ざき').and_return(html 'gallery_zaki.html')
      expect( subject ).to eql [
        {name: '神崎蘭子', index: 95},
        {name: '岡崎泰葉', index: 119},
        {name: '龍崎薫', index: 133},
        {name: '仙崎恵磨', index: 165},
      ]
    end
  end

  describe '#get_gallary_description' do
    subject{ service.get_gallary_description(133) }

    it 'は#requestを"gallery/desc/[index]"で呼び出す' do
      expect( service ).to receive(:request).with(:get, 'gallery/desc/133', nil).and_return(html 'gallery_desc_kaoru.html')
      subject
    end

    it 'は#requestの戻り値をハッシュの配列に変換する' do
      expect( service ).to receive(:request).with(:get, 'gallery/desc/133', nil).and_return(html 'gallery_desc_kaoru.html')
      expect( subject.first ).to eql ({
        name: '龍崎薫',
        hash: '6bd01496d9b00da9563c7e92b6a40257',
        kana: 'りゅうざきかおる',
        age: '9歳',
        height: '132cm',
        weight: '32kg',
        size: '65/51/70',
        birthday: '7月20日',
        constellation: '蟹座',
        blood: 'O型',
        arm: '右',
        from: '愛媛',
        hobby: '料理',
        rare: 'normal',
        attribute: 'passion',
      })
    end

    it 'は#requestの戻り値をページをまたいでもハッシュの配列に変換する' do
      expect( service ).to receive(:request).with(:get, 'gallery/desc/133', nil).and_return(html 'gallery_desc_kaoru.html')
      expect( subject.map{ |id| id[:name] } ).to eql [
        '龍崎薫',
        '龍崎薫+',
        '[新春]龍崎薫',
        '[新春]龍崎薫+',
        '[ｺﾞｽﾍﾟﾙﾄﾞﾚｽ]龍崎薫',
        '[ｺﾞｽﾍﾟﾙﾄﾞﾚｽ]龍崎薫+',
        '[ｻﾝﾌﾗﾜｰｲｴﾛｰ]龍崎薫',
        '[ｻﾝﾌﾗﾜｰｲｴﾛｰ]龍崎薫+',
        '[桜色少女]龍崎薫',
        '[桜色少女]龍崎薫+',
        '[桜色ｽﾏｲﾙ]龍崎薫',
        '[桜色ｽﾏｲﾙ]龍崎薫+',
        '[ちびっこﾎﾟﾘｽ]龍崎薫',
        '[ちびっこﾎﾟﾘｽ]龍崎薫+',
      ]
    end
  end

  describe '#get_status' do
    subject{ service.get_status }
    
    it 'は#requestを"mypage"で呼び出す' do
      expect( service ).to receive(:request).with(:get, 'mypage').and_return('')
      subject
    end

    it 'は#requestの戻り値をハッシュに変換する' do
      expect( service ).to receive(:request).with(:get, 'mypage').and_return(html 'mypage.html')
      expect( subject ).to eql ({
        stamina: 37,
        stamina_max: 300,
        offence: 3,
        offence_max: 184,
        diffence: 140,
        diffence_max: 141,
        money: 1_499_172,
        fan: 645969,
      })
    end
  end
end
