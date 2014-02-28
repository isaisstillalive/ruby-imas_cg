# coding: utf-8

require_relative '../lib/imas_cg'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def html path
  File.read("#{File.dirname(__FILE__)}/html/#{path}", encoding: Encoding::UTF_8)
end
