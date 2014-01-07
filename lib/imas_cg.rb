# coding: utf-8

require_relative 'imas_cg/service'
require_relative 'imas_cg/idol'

module ImasCG
    class << self
        def [] sid, options = {}
            Service.new sid, options
        end
    end
end
