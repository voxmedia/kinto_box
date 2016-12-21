$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'kinto_box'

KINTO_SERVER = 'https://kinto.dev.mozaws.net'.freeze

def random_string(n = 8)
  [*('a'..'z'), *('0'..'9')].to_a.shuffle[0, n].join
end
