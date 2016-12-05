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

  describe '#request' do
    subject{ service.__send__(:request, :get, 'path') }

    it 'は @conn#method を呼び出す' do
      expect( conn ).to receive(:get).with('path', nil).and_return(double('Faraday::Response', body: '0123456789', status: 200))
      subject
    end

    context 'サーバがメンテ中ではない場合' do
      it 'は戻り値のレスポンスボディを返却する' do
        expect( conn ).to receive(:get).with('path', nil).and_return(double('Faraday::Response', body: '0123456789', status: 200))
        expect( subject ).to eql '0123456789'
      end
    end

    context 'サーバがメンテ中の場合' do
      it 'は例外を発生させる' do
        expect( conn ).to receive(:get).with('path', nil).and_return(double('Faraday::Response', body: '0123456789', status: 302, headers: { location:'http://sp.pf.mbga.jp/12008305/?guid=ON&url=http%3A%2F%2F125.6.169.35%2Fidolmaster%2Fapp_manage%2Fmaintenance%3Fl_frm%3DBirthday_1%26rnd%3D704872398'} ))
        expect{ subject }.to raise_error Exception::Maintenance
      end
    end

    context 'サーバがメンテ中以外のリダイレクトの場合' do
      it 'は例外を発生させない' do
        expect( conn ).to receive(:get).with('path', nil).and_return(double('Faraday::Response', body: '0123456789', status: 302, headers: { location:'http://sp.pf.mbga.jp/12008305/?guid=ON&url=http%3A%2F%2F125.6.169.35%2Fidolmaster%2F'} ))
        expect{ subject }.not_to raise_error
      end
    end
  end

  describe '#request_list' do
    context 'にブロックを渡さない場合' do
      subject{ service.__send__(:request_list, :method, 'path', nil, /\d/m) }

      it 'は #request(:method, "path", nil) を呼び出す' do
        expect( service ).to receive(:request).with(:method, 'path', nil).and_return('0123456789')
        subject
      end

      it 'は戻り値を配列に変換する' do
        expect( service ).to receive(:request).with(:method, 'path', nil).and_return('0123456789')
        expect( subject ).to eql %w{0 1 2 3 4 5 6 7 8 9}
      end
    end

    context 'にブロックを渡した場合' do
      subject{ service.__send__(:request_list, :method, 'path', nil, /\d/m){ |m| 'b'+m } }

      it 'は #request(:method, "path", nil) を呼び出す' do
        expect( service ).to receive(:request).with(:method, 'path', nil).and_return('0123456789')
        subject
      end

      it 'は戻り値をブロックを使用して配列に変換する' do
        expect( service ).to receive(:request).with(:method, 'path', nil).and_return('0123456789')
        expect( subject ).to eql %w{b0 b1 b2 b3 b4 b5 b6 b7 b8 b9}
      end
    end
  end

  describe '#get_wishlist' do
    subject{ service.get_wishlist }

    it 'は　#request("wish/index") を呼び出す' do
      expect( service ).to receive(:request).with(:get, 'wish/index', nil).and_return('')
      subject
    end

    it 'は戻り値を配列に変換する' do
      expect( service ).to receive(:request).with(:get, 'wish/index', nil).and_return(html 'get_wishlist.html')
      expect( subject ).to eql [
        {hash: 'ae3ba85f888597f52c2744eeac3d9ace', id: '3402901', name: '[ｻﾝﾌﾗﾜｰｲｴﾛｰ]龍崎薫'},
        {hash: '94f468204a314b13c221bc2ff351a15a', id: '3410001', name: '[ちびっこﾎﾟﾘｽ]龍崎薫'},
      ]
    end
  end

  describe '#regist_wishlist' do
    subject{ service.regist_wishlist(100) }

    it 'は #head("wish/regist/[hash]/0") を呼び出す' do
      expect( service ).to receive(:head).with('wish/regist/100/0')
      subject
    end
  end

  describe '#remove_wishlist' do
    subject{ service.remove_wishlist(100) }

    it 'は　#head("wish/removes/0/[id]") を呼び出す' do
      expect( service ).to receive(:head).with('wish/removes/0/100')
      subject
    end
  end

  describe '#get_gallary' do
    context 'に何も渡さなかった場合' do
      subject{ service.get_gallary() }

      it 'は　#request(:post, "gallery/index/0/1/?history=2&l_frm=Gallery_1", keyword: nil) を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'gallery/index/0/1/?history=2&l_frm=Gallery_1', keyword: nil).and_return('')
        subject
      end
    end

    context 'に{keyword: "Key"}を渡した場合' do
      subject{ service.get_gallary(keyword: 'Key') }

      it 'は #request(:post, "gallery/index/0/1/?history=2&l_frm=Gallery_1", keyword: Key) を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'gallery/index/0/1/?history=2&l_frm=Gallery_1', keyword: 'Key').and_return('')
        subject
      end
    end

    context 'に{type: :cute}を渡した場合' do
      subject{ service.get_gallary(type: :cute) }

      it 'は #request(:post, "gallery/index/1/1/?history=2&l_frm=Gallery_1") を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'gallery/index/1/1/?history=2&l_frm=Gallery_1', keyword: nil).and_return('')
        subject
      end
    end

    context 'に{type: :cool}を渡した場合' do
      subject{ service.get_gallary(type: :cool) }

      it 'は #request(:post, "gallery/index/2/1/?history=2&l_frm=Gallery_1") を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'gallery/index/2/1/?history=2&l_frm=Gallery_1', keyword: nil).and_return('')
        subject
      end
    end

    context 'に{type: :passion}を渡した場合' do
      subject{ service.get_gallary(type: :passion) }

      it 'は #request(:post, "gallery/index/3/1/?history=2&l_frm=Gallery_1") を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'gallery/index/3/1/?history=2&l_frm=Gallery_1', keyword: nil).and_return('')
        subject
      end
    end

    subject{ service.get_gallary(keyword: 'ざき') }

    it 'は戻り値を配列に変換する' do
      expect( service ).to receive(:request).with(:post, 'gallery/index/0/1/?history=2&l_frm=Gallery_1', keyword: 'ざき').and_return(html 'gallery_zaki.html')
      expect( subject ).to eql [
        {name: '神崎蘭子', index: 98},
        {name: '岡崎泰葉', index: 122},
        {name: '龍崎薫', index: 137},
        {name: '仙崎恵磨', index: 170},
      ]
    end
  end

  describe '#get_gallary_description' do
    subject{ service.get_gallary_description(133) }

    it 'は #request(:get, "gallery/desc/[index]", nil) を呼び出す' do
      expect( service ).to receive(:request).with(:get, 'gallery/desc/133', nil).and_return(html 'gallery_desc_kaoru.html')
      subject
    end

    it 'は戻り値をハッシュの配列に変換する' do
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

    it 'は戻り値をページをまたいでもハッシュの配列に変換する' do
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

  describe '#get_idol_detail' do
    subject{ service.get_idol_detail('6bd01496d9b00da9563c7e92b6a40257') }

    it 'は #request(:get, "idol_gallery/idol_detail/[id]", nil) を呼び出す' do
      expect( service ).to receive(:request).with(:get, 'idol_gallery/idol_detail/6bd01496d9b00da9563c7e92b6a40257', nil).and_return(html 'idol_detail_kaoru.html')
      subject
    end

    it 'は戻り値をハッシュの配列に変換する' do
      expect( service ).to receive(:request).with(:get, 'idol_gallery/idol_detail/6bd01496d9b00da9563c7e92b6a40257', nil).and_return(html 'idol_detail_kaoru.html')
      expect( subject.first[:data][:card_name] ).to eql '龍崎薫'
      expect( subject.first[:data][:real_name] ).to eql '龍崎薫'
      expect( subject.first[:data][:hash_card_id] ).to eql '6bd01496d9b00da9563c7e92b6a40257'
      expect( subject.first[:profile][:card_id] ).to eql '3000401'
    end

    it 'は戻り値をページをまたいでもハッシュの配列に変換する' do
      expect( service ).to receive(:request).with(:get, 'idol_gallery/idol_detail/6bd01496d9b00da9563c7e92b6a40257', nil).and_return(html 'idol_detail_kaoru.html')
      expect( subject.map{ |id| id[:data][:card_name] } ).to eql [
        '龍崎薫',
        '龍崎薫+',
        '[新春]龍崎薫',
        '[新春]龍崎薫+',
        '[ｺﾞｽﾍﾟﾙﾄﾞﾚｽ]龍崎薫',
        '[ｺﾞｽﾍﾟﾙﾄﾞﾚｽ]龍崎薫+',
        '[ﾏｰﾁﾝｸﾞﾊﾞﾝﾄﾞ]龍崎薫',
        '[ﾏｰﾁﾝｸﾞﾊﾞﾝﾄﾞ]龍崎薫+',
        '[ｴﾚｶﾞﾝﾄI.C]龍崎薫+',
        '[ｳｨﾝﾀｰﾊﾞｶﾝｽ]龍崎薫',
        '[ｳｨﾝﾀｰﾊﾞｶﾝｽ]龍崎薫+',
        '[ｻﾝﾌﾗﾜｰｲｴﾛｰ]龍崎薫',
        '[ｻﾝﾌﾗﾜｰｲｴﾛｰ]龍崎薫+',
        '[桜色少女]龍崎薫',
        '[桜色少女]龍崎薫+',
        '[桜色ｽﾏｲﾙ]龍崎薫',
        '[桜色ｽﾏｲﾙ]龍崎薫+',
        '[ちびっこﾎﾟﾘｽ]龍崎薫',
        '[ちびっこﾎﾟﾘｽ]龍崎薫+',
        '[ﾊﾋﾟﾈｽﾁｱｰ]龍崎薫',
        '[ﾊﾋﾟﾈｽﾁｱｰ]龍崎薫+',
        '[ﾊﾂﾗﾂお嬢様]龍崎薫',
        '[ﾊﾂﾗﾂお嬢様]龍崎薫+',
        '[ﾊﾂﾗﾂお嬢様･S]龍崎薫',
        '[ﾊﾂﾗﾂお嬢様･S]龍崎薫+',
        '[元気のみなもと]龍崎薫',
        '[元気のみなもと]龍崎薫+',
        '[じょいふるｽﾃｯﾌﾟ]龍崎薫',
        '[じょいふるｽﾃｯﾌﾟ]龍崎薫+',
      ]
    end
  end

  describe '#get_status' do
    subject{ service.get_status }

    it 'は　#get("mypage") を呼び出す' do
      expect( service ).to receive(:get).with('mypage').and_return('')
      subject
    end

    it 'は戻り値をハッシュに変換する' do
      expect( service ).to receive(:get).with('mypage').and_return(html 'mypage.html')
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

  describe '#get_auction_list' do
    context 'に何も渡さなかった場合' do
      subject{ service.get_auction_list() }

      it 'は　#request(:post, "auction/search_top?l_frm=auction_1", attr: nil, rare: nil, cost: nil, keyword:: nil) を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'auction/search_top?l_frm=auction_1', attr: nil, rare: nil, cost: nil, keyword: nil).and_return('')
        subject
      end
    end

    context 'にtypeを渡した場合' do
      subject{ service.get_auction_list(type: :cute) }

      it 'は　#request(:post, "auction/search_top?l_frm=auction_1", attr: 1, rare: nil, cost: nil, keyword:: nil) を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'auction/search_top?l_frm=auction_1', attr: 1, rare: nil, cost: nil, keyword: nil).and_return('')
        subject
      end
    end

    context 'にcostを渡した場合' do
      subject{ service.get_auction_list(cost: 10) }

      it 'は　#request(:post, "auction/search_top?l_frm=auction_1", attr: nil, rare: nil, cost: 10, keyword:: nil) を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'auction/search_top?l_frm=auction_1', attr: nil, rare: nil, cost: 10, keyword: nil).and_return('')
        subject
      end
    end

    context 'にidを渡した場合' do
      subject{ service.get_auction_list(id: '3220801') }

      it 'は　#request(:get, "auction/search_top/0/3220801?l_frm=auction_5", {}) を呼び出す' do
        expect( service ).to receive(:request).with(:get, 'auction/search_top/0/3220801?l_frm=auction_5', {}).and_return('')
        subject
      end
    end

    subject{ service.get_auction_list() }

    it 'は戻り値を配列に変換する' do
      allow( service ).to receive(:request).and_return(html 'auction_search_top.html')
      expect( subject ).to eql [
        {name: '[ﾑｰﾝﾗｲﾄﾌﾗﾜｰ]相葉夕美+',      id: '0rEt5qpmYbo', want: { stamina: 1 }},
        {name: '[3rdｱﾆﾊﾞｰｻﾘｰ･S]城ヶ崎美嘉+', id: 'ILAz1BxwtKk', want: { stamina: 18 }},
        {name: '[3rdｱﾆﾊﾞｰｻﾘｰ･S]新田美波',    id: 'bJWPea4aXOg', want: { idol: ['[3rdｱﾆﾊﾞｰｻﾘｰ･S]日野茜', '[ｱﾆﾊﾞｰｻﾘｰﾌﾟﾘﾝｾｽ]神崎蘭子'] }},
        {name: '[こぼれるｽﾏｲﾙ]今井加奈',     id: 'xYsGGLcOniY', want: { money: 2_000_000 }},
        {name: '[3rdｱﾆﾊﾞｰｻﾘｰ･S]城ヶ崎美嘉',  id: 'IvAU6aemxMU', want: { energy: 9 }},
      ]
    end
  end

  describe '#get_cartoon_list' do
    context 'に何も渡さなかった場合' do
      subject{ service.get_cartoon_list() }

      it 'は　#request(:get, "cartoon/index/0?l_frm=Cartoon_1", nil) を呼び出す' do
        expect( service ).to receive(:request).with(:get, 'cartoon/index/0?l_frm=Cartoon_1', nil).and_return('')
        subject
      end
    end

    context 'に{page: 1}を渡した場合' do
      subject{ service.get_cartoon_list(page: 1) }

      it 'は　#request(:get, "cartoon/index/0?l_frm=Cartoon_1", nil) を呼び出す' do
        expect( service ).to receive(:request).with(:get, 'cartoon/index/0?l_frm=Cartoon_1', nil).and_return('')
        subject
      end
    end

    context 'に{page: 2}を渡した場合' do
      subject{ service.get_cartoon_list(page: 2) }

      it 'は　#request(:get, "cartoon/index/0?l_frm=Cartoon_1", nil) を呼び出す' do
        expect( service ).to receive(:request).with(:get, 'cartoon/index/9?l_frm=Cartoon_1', nil).and_return('')
        subject
      end
    end

    context 'に{keyword: "Key"}を渡した場合' do
      subject{ service.get_cartoon_list(keyword: 'Key') }

      it 'は #request(:post, "cartoon/search/0?l_frm=Cartoon_1", keyword: Key) を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'cartoon/search/0?l_frm=Cartoon_1', keyword: 'Key').and_return('')
        subject
      end
    end

    context 'に{keyword: "Key", page: 2}を渡した場合' do
      subject{ service.get_cartoon_list(keyword: 'Key', page: 2) }

      it 'は #request(:post, "cartoon/search/9?l_frm=Cartoon_1", keyword: Key) を呼び出す' do
        expect( service ).to receive(:request).with(:post, 'cartoon/search/9?l_frm=Cartoon_1', keyword: 'Key').and_return('')
        subject
      end
    end

    subject{ service.get_cartoon_list() }

    it 'は戻り値を配列に変換する' do
      allow( service ).to receive(:request).and_return(html 'cartoon_search_kaoru_1.html')
      expect( subject ).to eql [
        # {number: 29,  hash: 'fb03578be1b721e550b87c5b47a52463', date: Date.parse('2012/08/30')},
        # {number: 60,  hash: '01d4fc8cee3362c95e2df1f1a62b2d02', date: Date.parse('2012/12/14')},
        # {number: 93,  hash: 'b978a80605beb02e38f5a3f0cd21936e', date: Date.parse('2013/03/28')},
        # {number: 150, hash: 'a26c1130d360a0d0280badcbac388432', date: Date.parse('2013/09/09')},
        # {number: 189, hash: 'a9c55bfcab8eed8ca34d5e1f2565ef2f', date: Date.parse('2013/11/20')},
        {number: 190, hash: '2835c27fcadbe8d18a6e977650dd30d4', date: Date.parse('2013/11/21')},
        {number: 283, hash: '3f3b991dc12bd073c04ac918e94f3731', date: Date.parse('2014/04/15')},
        {number: 310, hash: 'c9ffc6e3c864ac3f400ecce81af0c191', date: Date.parse('2014/05/27')},
        {number: 325, hash: 'cea391781e6cbb7d342e5f97cdac7762', date: Date.parse('2014/06/16')},
        {number: 383, hash: '1ecadec10702639c94632f42da44d0a6', date: Date.parse('2014/09/19')},
        {number: 400, hash: '96354af86dc3aa539ec26a1c7a482ae5', date: Date.parse('2014/10/20')},
        {number: 473, hash: '0a6550d482bb63b9eb9b354f108b5e66', date: Date.parse('2015/03/04')},
        {number: 512, hash: 'c3e215d930d6aaa6f95904c739dba7fc', date: Date.parse('2015/05/19')},
        {number: 526, hash: '79c14058544e2ae998032e54026fe60b', date: Date.parse('2015/06/15')},
      ]
    end
  end
end
