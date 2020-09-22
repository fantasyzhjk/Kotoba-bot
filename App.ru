require_relative 'autoRequire'

$DEBUGMODE = false
indexHtml = File.open('index.html').read

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)

    ws.on :message do |msg|
      Thread.start { Bot::Main.dataParse msg.data }
    end

    ws.on :close do |event|
      puts "[#{Time.new.strftime('%Y-%m-%d %H:%M:%S')}][!]: 一个客户端断开连接 (#{event.code})"
      ws = nil
    end

    ws.rack_response
  else
    # 正常HTTP请求
    [200, { 'Content-Type' => 'text/html' }, [indexHtml]]
  end
end

run App
