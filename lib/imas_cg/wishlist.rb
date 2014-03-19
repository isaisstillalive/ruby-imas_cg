# coding: utf-8

module ImasCG
  class Wishlist
    include Enumerable

    def initialize service
      @service = service
    end

    def each
      return enum_for :each unless block_given?

      @service.get_wishlist.each do |idol|
        yield idol
      end
    end

    def << idol
      if idol.instance_of? Idol
        idol = idol.digest
        raise if idol.nil?
      end

      @service.regist_wishlist idol
    end

    def delete idol
      if idol.instance_of? Idol
        idol = idol.id
        raise if idol.nil?
      end

      @service.removes_wishlist idol
    end
  end
end
