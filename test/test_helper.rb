$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'kinto_box'
require 'response_handler'

KINTO_SERVER = 'https://kintobox.herokuapp.com'

def random_string (n = 8)
  [*('a'..'z'),*('0'..'9')].to_a.shuffle[0,n].join
end