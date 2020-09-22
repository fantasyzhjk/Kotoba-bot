require 'faye/websocket'
require 'net/http'
require 'json'
module Bot
  autoload :Utils, File.expand_path('Utils', __dir__)
  autoload :Main, File.expand_path('Bot', __dir__)
  # Dir.foreach('plugins') do |file|
  #   require_relative 'plugins/' << file[0..file.length - 4] if (file != '.') && (file != '..')
  # end
end
