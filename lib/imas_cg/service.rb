# coding: utf-8

module ImasCG
  require 'faraday'
  require 'JSON'
  require 'date'

  require_relative 'wishlist'
  require_relative 'exception/maintenance'

  class Service
    def initialize sid, options = {}
      ObjectSpace.define_finalizer(self, proc{ self.finalize })

      @conn = Faraday::Connection.new(url: 'http://sp.pf.mbga.jp') do |conn|
        conn.use Faraday::Request::UrlEncoded
        conn.use Request::Mobage, app: 12008305
        conn.use Faraday::Response::Logger if options[:logging]
        conn.use Faraday::Adapter::NetHttp
      end

      self.sid = sid
    end

    attr_reader :sid

    def sid= value
      @sid = value
      @conn.headers[:sid] = value
    end

    def == other
      @sid == other.sid
    end

    def get_wishlist
      request_list :get, 'wish/index', nil, /<table width="100%" align="center" class="m-Btm10">.*?card%2Fs%2F(?<hash>[0-9a-f]{32})\.jpg%3Fv%3D\d+" width="90">.*?<td align="center">\s*<div class="m-Btm10">(?<name>[^<]*)<\/div>.*?http%3A%2F%2F125\.6\.169\.35%2Fidolmaster%2Fwish%2Fremoves%2F0%2F(?<id>\d*)%3Fl_frm%3DWish_1%26rnd%3D\d*'>/m do |matched|
        hash, name, id = *matched
        {
          id: id,
          hash: hash,
          name: name.strip,
        }
      end
    end

    def remove_wishlist id
      head "wish/removes/0/#{id}"
    end

    def regist_wishlist hash
      head "wish/regist/#{hash}/0"
    end

    def get_idol_detail id
# {"data":{"card_name":"\u9f8d\u5d0e\u85ab","rarity":"1","cost":"4","attribute":"passion","max_level":"20","skill_name":"","skill_effect":"","idol_base_id":"137","grow_idol_flag":"","default_attack":"480","default_defense":"320","max_attack":"1200","max_defense":"800","hash_card_id":"6bd01496d9b00da9563c7e92b6a40257","alias_name":"","real_name":"\u9f8d\u5d0e\u85ab"},"profile":{"card_id":"3000401","card_name":"\u9f8d\u5d0e\u85ab","card_kana":"\u308a\u3085\u3046\u3056\u304d\u304b\u304a\u308b","card_age":"9","card_from":"\u611b\u5a9b","card_height":"132","card_weight":"32","card_bust":"65","card_waist":"51","card_hip":"70","card_birthday":"7\u670820\u65e5","card_constellation":"\u87f9\u5ea7","card_blood":"O","card_arm":"\u53f3","card_hobby":"\u6599\u7406","card_cv":"\u6625\u702c\u306a\u3064\u307f"},"comments":{"comment":"\u3084\u3063\u307b\uff70! \u304b\u304a\u308b\u3060\u3088\uff70\u3063!! \u306d\u3047\u306d\u3047\u306d\u3047!! \uff71\uff72\uff84\uff9e\uff99\u3063\u3066\u307b\u3093\u3068\u306b\u306a\u308c\u308b? \u304b\u304a\u308b\u306f\uff83\uff9a\uff8b\uff9e\u306b\u51fa\u3066\u305f\u3053\u3068\u3042\u308b\u304b\u3089\uff64\uff8c\uff9f\uff9b\uff83\uff9e\uff6d\uff70\uff7b\uff70\u3055\u3093\u304c\u5148\u751f\u306b\u306a\u3063\u3066\u304f\u308c\u305f\u3089\u3060\u3044\u3058\u3087\u3076\u304b\u306a! ","comments_my_1":"\u304a\u3063\u306f\u3088\uff70\u3046!! ","comments_my_2":"\u304a\u306a\u304b\u3059\u3044\u305f\u2026","comments_my_3":"\u3042\u3063\uff64\u306d\u3053! \u306d\uff70\u3053\uff70! ","comments_my_4":"\u305b\u3093\u305b\u3047\uff64\u304b\u304a\u308b\u306e\u304a\u306b\u304e\u308a\u98df\u3079\u308b? ","comments_my_max":"ISA\u305b\u3093\u305b\u3047\uff64\u4eca\u65e5\u306f\u4f55\u3092\u6559\u3048\u3066\u304f\u308c\u308b\u306e? ","comments_work_1":"\u304a\u306f\u3088\u3046\u3054\u3056\u3044\u307e\uff70!!! ","comments_work_2":"\u304a\u3064\u304b\u308c\u3055\u307e\u3067\uff70!!! ","comments_work_3":"\u3048\u3078\u3078! \u697d\u3057\u3044\u306d!! ","comments_work_4":"\u305b\u3093\u305b\u3047\u2026\u3061\u3087\u3063\u3068\u306d\u3080\u3044\u2026\uff61","comments_work_max":"ISA\u305b\u3093\u305b\u3047! \u3042\u306e\u306d\uff64\u304b\u304a\u308b\uff64\u3046\u308c\u3057\u3044\u3088! ","comments_work_love_up":"\u3048\u3078\u3078\uff64ISA\u305b\u3093\u305b\u3047\uff70! \u3048\u3078\u3078\u3078\uff70! ","comments_live":"\u304c\u3093\u3070\u308a\u307e\u3059! ","comments_love_max":"\u3042\u306e\u306d\uff64\u304b\u304a\u308b\u307b\u3093\u3068\u306f\u305b\u3093\u305b\u3047\u3058\u3083\u306a\u304f\u3063\u3066\uff64ISA\u3055\u3093\u3063\u3066\u3088\u3073\u305f\u3044\u306e\uff64\u3060\u3063\u3066\u305d\u306e\u65b9\u304c\uff64\u3042\u3063\uff64\u3084\u3063\u3071\u308a\u3044\u3044! "},"voice":{"comment":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/c17641803806b9b9a3f2e28c883c83b2.mp4","comments_my_1":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/3286486c036dc153730ceb9e0627d914.mp4","comments_my_2":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/2497781ffc0d796d24eb404f17145652.mp4","comments_my_3":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/34c2498bf97b2dd3d55577d4945081e2.mp4","comments_my_4":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/301487690aef96b101c09434d97b2cdd.mp4","comments_my_max":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/7606fdb701453340c3c8c8ac319fbb4d.mp4","comments_work_1":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/673cce789d4668b13989c145fccd36c2.mp4","comments_work_2":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/9e9eb97810150adebdf8a98534d5919b.mp4","comments_work_3":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/fa9db74abbb7f2d69078caa95a73ae8a.mp4","comments_work_4":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/62c59196cd4e9640b0adc7b6b5d35eb1.mp4","comments_work_max":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/14d672f1d32d7ccbce2ce8d7e319f84f.mp4","comments_work_love_up":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/659217c82ec4db34ee804c70e263e549.mp4","comments_live":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/b78e8b9abbcf82302933dbec9421b7e5.mp4","comments_love_max":"http:\/\/idolmaster.edgesuite.net\/idolmaster\/sound\/3000401\/7406086073b3be314421ae5076f79ff0.mp4"},"event":null,"release":"2011\/11\/17","trade_prohibition":{"is_trade_limit":false},"idol_search_param":"keyword=%E3%82%8A%E3%82%85%E3%81%86%E3%81%96%E3%81%8D%E3%81%8B%E3%81%8A%E3%82%8B","archive":{"normal":"1","premium":"0"},"is_exist_archive":true,"is_max_love":true}

      request_list :get, "idol_gallery/idol_detail/#{id}", nil, /\{"data":\{"card_name":.*?,"is_max_love":(?:true|false)\}/m do |matched|
        JSON.parse(matched, symbolize_names: true)
      end
    end

    def get_idol_jsons hash
      data = request :get, "idol_gallery/idol_detail/#{hash}"

      character_id = /<input type="hidden" name="character_id" value="(\d+)">/.match(data)[1] rescue nil
      idol_detail_list = JSON.parse(/idol.detail_list = (\[.*?\]);/m.match(data)[1])
      idol_story_list = JSON.parse(/idol.idol_story_list = (\[.*?\]);/m.match(data)[1])

      return character_id, idol_detail_list, idol_story_list
    end

    def get_idol_recommend_idols_2017 hash
      data = request :get, "vote/idol_introduction/200006/#{hash}"
      data.force_encoding('UTF-8')

      return nil if data.empty?

      title = /<div class="recommend_idol_title" style="[^"]+">(.*)<\/div>/.match(data)[1].gsub(/<\/?[^>]+>/, '')
      comment = /<div class="comment_main_idol_bottom[^"]+">\n<div>(.*)<\/div>\n<\/div>/.match(data)[1].gsub('<br>', '')
      idols = []
      data.scan(/<img src='http:\/\/sp\.pf-img-a\.mbga\.jp\/12008305\/\?guid=ON&amp;url=http%3A%2F%2F125\.6\.169\.35%2Fidolmaster%2Fimage_sp%2Fcard%2Fxs%2F([0-9a-f]{32})\.jpg[^']+' class="recommend_idol_image">/) do |m|
        idols << m[0]
      end
      return {
        title: title,
        comment: comment,
        idols: idols,
      }
    end

    def get_auction_list type: nil, cost: nil, keyword: nil, id: nil
      if id
        method = :get
        url = "auction/search_top/0/#{id}?l_frm=auction_5"
        options = {}
      else
        method = :post
        url = 'auction/search_top?l_frm=auction_1'
        options = {attr: nil, rare: nil, cost: cost, keyword: keyword}
        options[:attr] = get_type_id(type) if type
      end
      request_list method, url, options, /<div class="idolStatus m-Btm15">.*?<div class="name">(?<name>.*?)<\/div>.*?<div class="pr want">.*?(?<want>(?:<li>.*?<\/li>)+)<\/ul>.*?<div class="m-Btm5">.*?search_contract%3Fid%3D(?<id>.{11}).*?<\/div>/m do |matched|
        name, want_string, id = *matched

        want = {}
        want_string.force_encoding('UTF-8')
        want_string.scan(/<li>(.*?)<\/li>/) do |values|
          case values[0]
          when /ｽﾀﾐﾅﾄﾞﾘﾝｸ \((\d+)\)/
            want[:stamina] = $1.to_i
          when /ｴﾅｼﾞｰﾄﾞﾘﾝｸ \((\d+)\)/
            want[:energy] = $1.to_i
          when /([\d,]+)ﾏﾆｰ/
            want[:money] = $1.gsub(',', '').to_i
          else
            want[:idol] ||= []
            want[:idol] << values[0]
          end
        end
        {
          name: name,
          id: id,
          want: want,
        }
      end
    end

    def get_status
      source = get 'mypage'
      return nil if source.empty?

      match = /<div class="value">スタミナ　(?<stamina>\d*) \/ (?<stamina_max>\d*)<\/div>.*?<div class="value">攻コスト　(?<offence>\d*) \/ (?<offence_max>\d*)<\/div>.*?<li class="type01">マニー：(?<money>[\d,]*)<\/li>.*?<li class="type02">守コスト：(?<diffence>\d*) \/ (?<diffence_max>\d*)<\/li>.*?<li class="type03">ファン：(?<fan>\d*)<\/li>/m.match(source)
      {
        stamina: match[:stamina].to_i,
        stamina_max: match[:stamina_max].to_i,
        offence: match[:offence].to_i,
        offence_max: match[:offence_max].to_i,
        diffence: match[:diffence].to_i,
        diffence_max: match[:diffence_max].to_i,
        money: match[:money].gsub(',', '').to_i,
        fan: match[:fan].to_i,
      }
    end

    def get_cartoon_list page: 1, keyword: nil
      if keyword
        method = :post
        action = 'search'
        params = {keyword: keyword}
      else
        method = :get
        action = 'index'
        params = nil
      end
      url = "cartoon/#{action}/#{(page-1)*9}?l_frm=Cartoon_1"

      request_list method, url, params, /<td align="center" valign="top" width="33%">\n<a href='.*?'><span class="a_link"><img src=".*?cartoon%2F\d*%2F(?<name>.*?)\.jpg" width="80"><\/span><\/a><br>\n【第(?<name>\d+?)話】<br \/>\n(?<date>.*?)\n<\/td>/m do |matched|
        hash, number, date = *matched
        {
          number: number.to_i,
          hash: hash,
          date: Date.parse(date),
        }
      end.reverse
    end

    private

    def request method, url, params = nil
      source = @conn.__send__ method, url, params
      raise Exception::Maintenance.new if source.status == 302 && source.headers[:location].match(/%2Fidolmaster%2Fapp_manage%2Fmaintenance/)
      source.body
    end

    def get url, params = nil
      request :get, url, params
    end

    def head url, params = nil
      request :head, url, params
    end

    def request_list method, url, params, pattern, &block
      source = request method, url, params

      if block_given?
        [].tap do |result|
          source.scan pattern do |match|
            result << block.call(match)
          end
        end
      else
        source.scan pattern
      end
    end

    def get_type_id type
      case type
        when 1, :cute
          1
        when 2, :cool
          2
        when 3, :passion
          3
        else
          0
        end
    end
  end

  module Request
    class Mobage < Faraday::Middleware
      def initialize app, options
        super app
        @mbga_app = options[:app]
      end

      def call env
        env[:request_headers]['User-Agent'] = 'Mozilla/5.0 (Linux; U; Android 2.3; en-us) AppleWebKit/999+ (KHTML, like Gecko) Safari/999.9'
        env[:request_headers]['Cookie'] = "sp_mbga_sid_#{@mbga_app}=#{env[:request_headers]['Sid']}"

        mobage_path = 'http://125.6.169.35/idolmaster'
        mobage_path << '/' unless env[:url].path[0] == '/'
        mobage_path += env[:url].path
        mobage_path += '?' + env[:url].query unless env[:url].query.nil?
        path = URI.encode_www_form_component(mobage_path)
        env[:url] += "/#{@mbga_app}/?guid=ON&url=#{path}"
        @app.call env
      end
    end
  end
end
