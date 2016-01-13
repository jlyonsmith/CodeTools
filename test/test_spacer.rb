require 'minitest/autorun'

class TestSpacer < Minitest::Test
  def setup()
    @bin_dir = File.expand_path(File.join(File.dirname(__FILE__), '../bin'))
  end

  def test_vamper_help
    output = `#{@bin_dir}/spacer --help`
    assert_match /Usage:/, output
  end
end
