require 'roka/version'
require 'roka/converter'

module Roka

  extend self

  def convert(str)
    Converter.new(str).tap(&:convert).results
  end

end
