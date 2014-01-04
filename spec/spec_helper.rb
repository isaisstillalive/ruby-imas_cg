# coding: utf-8

require_relative '../lib/imas_cg'

def html path
	File.read("#{File.dirname(__FILE__)}/html/#{path}", encoding: Encoding::UTF_8)
end