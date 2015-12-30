require 'test/unit'
require_relative '../lib/vamper.rb'

class VamperTest < Test::Unit::TestCase

  def test_vamper_help
    $ARGV = "-?"
    Vamper.new.execute
  end
end