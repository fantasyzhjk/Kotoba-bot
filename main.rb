require_relative 'autoRequire'

$DEBUGMODE = 'false'.freeze

begin
  ws = WebSocket::Client::Simple.connect 'ws://localhost:6700/'
  ws.on :message do |msg|
    Thread.start { Bot::Main.DataProp msg.data }
  end

  ws.on :open do
    puts('连接成功！')
  end

  ws.on :close do |e|
    p e
    exit 1
  end

  ws.on :error do |e|
    p e
    exit 1
    # goto :start
  end
  loop {}
rescue Errno::ECONNREFUSED
  print '连接超时，请重试。'
end
