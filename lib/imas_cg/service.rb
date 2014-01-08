# coding: utf-8

module ImasCG
    require 'faraday'
    require 'JSON'
    
    require_relative 'wishlist'

    class Service
        def initialize sid, options = {}
            ObjectSpace.define_finalizer(self, proc{ self.finalize })

            @conn = Faraday::Connection.new(url: 'http://sp.pf.mbga.jp', request: { app: 12008305 }) do |conn|
                conn.use Faraday::Request::UrlEncoded
                conn.use Request::Mobage
                conn.use Faraday::Response::Logger if options[:logging]
                conn.use Faraday::Adapter::NetHttp
            end

            self.sid = sid
        end

        attr_reader :sid

        def sid= value
            @sid = value
            @conn.options[:sid] = value
        end

        def == other
            @sid == other.sid
        end

        def get_wishlist
            request_list :get, 'wish/index', nil, /<table width="100%" align="center">.*?card%2Fs%2F(?<hash>[0-9a-f]{32})\.jpg" width="90">.*?<td align="center">\s*(?<name>[^<]*)<br \/>.*?http%3A%2F%2F125\.6\.169\.35%2Fidolmaster%2Fwish%2Fremoves%2F0%2F(?<id>\d*)%3Frnd%3D\d*'>/m do |matched|
                hash, name, id = *matched
                {
                    id: id,
                    hash: hash,
                    name: name,
                }
            end
        end

        def remove_wishlist id
            head "wish/removes/0/#{id}"
        end

        def regist_wishlist hash
            head "wish/regist/#{hash}/0"
        end

        def get_gallary keyword = nil
            request_list :post, 'gallery', { keyword: keyword }, /<a href='http:\/\/sp\.pf\.mbga\.jp\/12008305\/\?guid=ON&url=http%3A%2F%2F125\.6\.169\.35%2Fidolmaster%2Fgallery%2Fdesc%2F(?<index>\d+)[^']*'>.*?<div class="idol" style="background: url\(http:\/\/125\.6\.169\.35\/idolmaster\/image_sp\/card\/quest\/(?<hash>[0-9a-f]{32})\.png\?v=\d+\) -22px -26px no-repeat; background-size: 180px 188px;"><\/div>.*?<div class="name_(?:cute|cool|passion|trainer)">(?<name>.*?)<\/div>/m do |matched|
                index, hash, name = *matched
                {
                    index: index.to_i,
                    name: name,
                }
            end
        end

        def get_gallary_description index
            request_list :get, "gallery/desc/#{index}", nil, /<div class="idol" >.*?style="background: url\(http:\/\/125\.6\.169\.35\/idolmaster\/image_sp\/card\/xs\/(?<hash>[0-9a-f]{32})\.jpg\?v=[^\)]*\) no-repeat; background-size: 70px 70px;".*?<input type="hidden" name="basedata" data-name="(?<name>[^"]*)" data-rarity="(?<rare>[^"]*)" data-attribute="(?<attribute>[^"]*)">.*?data-profile='(?<profile>[^']*)'>/m do |matched|
                hash, name, rare, attribute, profile = *matched
                JSON.parse(URI.decode_www_form_component(profile), symbolize_names: true).tap do |profile|
                    profile[:hash] = hash
                    profile[:name] = URI.decode_www_form_component(name)
                    profile[:rare] = rare
                    profile[:attribute] = attribute
                end
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

        private

        def request method, url, params = nil
            source = @conn.__send__ method, url, params
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
    end

    module Request
        class Mobage < Faraday::Middleware
            def call env
                env[:request_headers]['User-Agent'] = 'Mozilla/5.0 (Linux; U; Android 2.3; en-us) AppleWebKit/999+ (KHTML, like Gecko) Safari/999.9'
                env[:request_headers]['Cookie'] = "sp_mbga_sid_#{env[:request][:app]}=#{env[:request][:sid]}"
                path = URI.encode_www_form_component('http://125.6.169.35/idolmaster/' + env[:url].path)
                env[:url] += "/#{env[:request][:app]}/?guid=ON&url=#{path}"
                @app.call env
            end
        end
    end
end
