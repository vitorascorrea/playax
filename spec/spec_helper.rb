require_relative './../lib/importers/pdfecad'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :should
  end
end
