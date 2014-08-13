# coding: utf-8

module ImasCG
  class Idol
    attr_reader :id, :digest, :name

    def initialize data
      case data
      when Numeric
        data = { id: data }
      when String
        data = { digest: data }
      end

      raise if data[:id].nil? && data[:digest].nil?

      @id = data[:id]
      @digest = data[:digest]

      @name = data[:name]
    end

    def == other
      return false unless other.instance_of? Idol

      is_id_comparable     = !(@id.nil? || other.id.nil?)
      is_digest_comparable = !(@digest.nil? || other.digest.nil?)

      # idでもdigestでも比較できなければnilを返す
      return nil unless is_id_comparable || is_digest_comparable

      check_id     = @id == other.id
      check_digest = @digest == other.digest

      # idのみならidの比較結果を、digestのみならidの比較結果を返す
      if !is_id_comparable
        return check_digest
      elsif !is_digest_comparable
        return check_id
      end

      # 片方が一致で片方が不一致の場合、TypeError例外を発生
      raise TypeError if check_id != check_digest

      # 一致してる場合、どちらでも同じなので返す
      return check_id
    end
  end
end
