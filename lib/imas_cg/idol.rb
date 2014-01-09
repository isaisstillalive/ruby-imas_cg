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

            id_nil     = (@id.nil? || other.id.nil?)
            digest_nil = (@digest.nil? || other.digest.nil?)

            # 両方nilなら比較できないのでnilを返す
            return nil if id_nil && digest_nil

            check_id     = id_nil     || @id == other.id
            check_digest = digest_nil || @digest == other.digest

            # # 片方が一致で片方が不一致の場合、nilを返す
            # return nil if check_id != check_digest

            return check_id && check_digest
        end
    end
end
