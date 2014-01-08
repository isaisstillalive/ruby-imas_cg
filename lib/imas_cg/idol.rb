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
    end
end
