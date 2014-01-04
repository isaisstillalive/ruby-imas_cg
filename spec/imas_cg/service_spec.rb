# coding: utf-8

require_relative '../spec_helper.rb'

describe ImasCG::Service do
  before do
    @service = ImasCG::Service.new 'id'
  end

  context 'を初期化する場合' do
    it 'はsidが第一引数である' do
      service = ImasCG::Service.new 'id'
      service.sid.should eql 'id'
      service.instance_variable_get(:@conn).options[:sid].should include 'id'
      service.instance_variable_get(:@conn).builder.handlers.should_not include Faraday::Response::Logger
    end

    it 'はオプション"logging: true"が指定されていればログ出力する' do
      service = ImasCG::Service.new 'id', logging: true
      service.instance_variable_get(:@conn).builder.handlers.should include Faraday::Response::Logger
    end
  end

  context 'で#request_listする場合' do
    it 'は#requestを呼び出す' do
      @service.should_receive(:request).with(:method, 'path', nil).and_return('')
      @service.__send__(:request_list, :method, 'path', nil, /\d/m).should eql []
    end

    it 'は#requestの戻り値をブロックを使用して配列に変換する' do
      @service.should_receive(:request).with(:method, 'path', nil).and_return('0123456789')
      @service.__send__(:request_list, :method, 'path', nil, /\d/m){ |m| 'b'+m }.should eql %w{b0 b1 b2 b3 b4 b5 b6 b7 b8 b9}
    end

    it 'は#requestの戻り値を配列に変換する' do
      @service.should_receive(:request).with(:method, 'path', nil).and_return('0123456789')
      @service.__send__(:request_list, :method, 'path', nil, /\d/m).should eql %w{0 1 2 3 4 5 6 7 8 9}
    end
  end

  context 'で#get_wishlistする場合' do
    it 'は#requestを"wish/index"で呼び出す' do
      @service.should_receive(:request).with(:get, 'wish/index', nil).and_return('')
      @service.get_wishlist.should eql []
    end

    it 'は#requestの戻り値を配列に変換する' do
      @service.should_receive(:request).with(:get, 'wish/index', nil).and_return(html 'get_wishlist.html')
      @service.get_wishlist.should eql [
        {hash: 'ae3ba85f888597f52c2744eeac3d9ace', id: '3402901', name: '[ｻﾝﾌﾗﾜｰｲｴﾛｰ]龍崎薫'},
        {hash: '94f468204a314b13c221bc2ff351a15a', id: '3410001', name: '[ちびっこﾎﾟﾘｽ]龍崎薫'},
      ]
    end
  end

  context 'で#regist_wishlistする場合' do
    it 'は#requestを"wish/regist/[hash]/0"で呼び出す' do
      @service.should_receive(:request).with(:head, 'wish/regist/100/0', nil).and_return(nil)
      @service.regist_wishlist(100).should eql nil
    end
  end

  context 'で#remove_wishlistする場合' do
    it 'は#requestを"wish/removes/0/[id]"で呼び出す' do
      @service.should_receive(:request).with(:head, 'wish/removes/0/100', nil).and_return(nil)
      @service.remove_wishlist(100).should eql nil
    end
  end

  context 'で#get_gallaryする場合' do
    it 'は#requestを"gallery"で呼び出す' do
      @service.should_receive(:request).with(:post, 'gallery', keyword: 'Key').and_return('')
      @service.get_gallary('Key').should eql []
    end

    it 'は#requestを"gallery"で呼び出す' do
      @service.should_receive(:request).with(:post, 'gallery', keyword: nil).and_return('')
      @service.get_gallary().should eql []
    end

    it 'は#requestの戻り値を配列に変換する' do
      @service.should_receive(:request).with(:post, 'gallery', keyword: 'ざき').and_return(html 'gallery_zaki.html')
      @service.get_gallary('ざき').should eql [
        {name: '神崎蘭子', index: 95},
        {name: '岡崎泰葉', index: 119},
        {name: '龍崎薫', index: 133},
        {name: '仙崎恵磨', index: 165},
      ]
    end
  end

  context 'で#get_gallary_descriptionする場合' do
    it 'は#requestを"gallery/desc/[index]"で呼び出す' do
      @service.should_receive(:request).with(:get, 'gallery/desc/133', nil).and_return('')
      @service.get_gallary_description(133).should eql []
    end

    it 'は#requestの戻り値をハッシュの配列に変換する' do
      @service.should_receive(:request).with(:get, 'gallery/desc/133', nil).and_return(html 'gallery_desc_kaoru.html')
      @service.get_gallary_description(133).first.should eql ({
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
      @service.should_receive(:request).with(:get, 'gallery/desc/133', nil).and_return(html 'gallery_desc_kaoru.html')

      idol = @service.get_gallary_description(133).map{ |id| id[:name] }
      idol.should eql [
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

  # context "でheadする場合" do
  #   it "は戻り値がreturnである" do
  #     @service.should_receive(:send).with(:head, 'path').and_return('return')
  #     @service.head('path').should eql 'return'
  #   end
  # end

  after do
    @service = nil
  end
end
