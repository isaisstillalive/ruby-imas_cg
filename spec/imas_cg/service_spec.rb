# coding: utf-8

require_relative '../spec_helper.rb'

describe ImasCG::Service do
  let(:service){ ImasCG::Service.new 'id' }

  context 'を初期化する場合' do
    let(:conn){ service.instance_variable_get(:@conn) }

    context 'sidのみならば' do
      subject(:service){ ImasCG::Service.new 'id' }

      it '#sidが第一引数である' do
        expect( service.sid ).to eql 'id'
        expect( conn.options[:sid] ).to include 'id'
      end

      it 'ログ出力しない' do
        expect( conn.builder.handlers ).not_to include Faraday::Response::Logger
      end
    end

    context 'sidとオプション { logging: true } を指定すれば' do
      subject(:service){ ImasCG::Service.new 'id', logging: true }

      it '#sidが第一引数である' do
        expect( service.sid ).to eql 'id'
        expect( conn.options[:sid] ).to include 'id'
      end

      it 'ログ出力する' do
        expect( conn.builder.handlers ).to include Faraday::Response::Logger
      end
    end
  end

  context 'で#request_listする場合' do
    before do
      service.should_receive(:request).with(:method, 'path', nil).and_return('0123456789')
    end

    context 'ブロックを渡さなければ' do
      subject(:request_list){ service.__send__(:request_list, :method, 'path', nil, /\d/m) }

      it '#requestを呼び出し、戻り値を配列に変換する' do
        expect( request_list ).to eql %w{0 1 2 3 4 5 6 7 8 9}
      end
    end

    context 'ブロックを渡せば' do
      subject(:request_list){ service.__send__(:request_list, :method, 'path', nil, /\d/m){ |m| 'b'+m } }

      it '#requestの戻り値をブロックを使用して配列に変換する' do
        expect( request_list ).to eql %w{b0 b1 b2 b3 b4 b5 b6 b7 b8 b9}
      end
    end
  end

  context 'で#get_wishlistする場合' do
    before do
      service.should_receive(:request).with(:get, 'wish/index', nil).and_return(html 'get_wishlist.html')
    end

    subject(:get_wishlist){ service.get_wishlist }

    it '#requestを"wish/index"で呼び出し、戻り値を配列に変換する' do
      expect( get_wishlist ).to eql [
        {hash: 'ae3ba85f888597f52c2744eeac3d9ace', id: '3402901', name: '[ｻﾝﾌﾗﾜｰｲｴﾛｰ]龍崎薫'},
        {hash: '94f468204a314b13c221bc2ff351a15a', id: '3410001', name: '[ちびっこﾎﾟﾘｽ]龍崎薫'},
      ]
    end
  end

  context 'で#regist_wishlistする場合' do
    it 'は#requestを"wish/regist/[hash]/0"で呼び出す' do
      service.should_receive(:request).with(:head, 'wish/regist/100/0', nil).and_return(nil)
      expect( service.regist_wishlist(100) ).to eql nil
    end
  end

  context 'で#remove_wishlistする場合' do
    it 'は#requestを"wish/removes/0/[id]"で呼び出す' do
      service.should_receive(:request).with(:head, 'wish/removes/0/100', nil).and_return(nil)
      expect( service.remove_wishlist(100) ).to eql nil
    end
  end

  context 'で#get_gallaryする場合' do
    it 'は#requestを"gallery"で呼び出す' do
      service.should_receive(:request).with(:post, 'gallery', keyword: 'Key').and_return('')
      expect( service.get_gallary('Key') ).to eql []
    end

    it 'は#requestを"gallery"で呼び出す' do
      service.should_receive(:request).with(:post, 'gallery', keyword: nil).and_return('')
      expect( service.get_gallary() ).to eql []
    end

    it 'は#requestの戻り値を配列に変換する' do
      service.should_receive(:request).with(:post, 'gallery', keyword: 'ざき').and_return(html 'gallery_zaki.html')
      expect( service.get_gallary('ざき') ).to eql [
        {name: '神崎蘭子', index: 95},
        {name: '岡崎泰葉', index: 119},
        {name: '龍崎薫', index: 133},
        {name: '仙崎恵磨', index: 165},
      ]
    end
  end

  context 'で#get_gallary_descriptionする場合' do
    before do
      service.should_receive(:request).with(:get, 'gallery/desc/133', nil).and_return(html 'gallery_desc_kaoru.html')
    end

    it 'は#requestを"gallery/desc/[index]"で呼び出し、戻り値をハッシュの配列に変換する' do
      expect( service.get_gallary_description(133).first ).to eql ({
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
      expect( service.get_gallary_description(133).map{ |id| id[:name] } ).to eql [
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

  context 'で#get_statusする場合' do
    before do
      service.should_receive(:request).with(:get, 'mypage').and_return(html 'mypage.html')
    end

    it 'は#requestを"mypage"で呼び出し、戻り値をハッシュに変換する' do
      expect( service.get_status ).to eql ({
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
