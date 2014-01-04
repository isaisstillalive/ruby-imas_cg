# coding: utf-8

require_relative 'imas_cg/service'

module ImasCG
    class << self
        def [] sid, options = {}
            Service.new sid, options
        end
    end
end
