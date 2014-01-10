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

            check_id     = @id == other.id
            check_digest = @digest == other.digest

            # 片方がnilなら反対側の結果を返す
            if id_nil
                return check_digest
            elsif digest_nil
                return check_id
            end

            # 片方が一致で片方が不一致の場合、nilを返す
            # イレギュラーなので例外を発生させた方が良いか？
            return nil if check_id != check_digest

            # 一致してる場合、どちらでも同じなので返す
            return check_id
        end
    end
end
