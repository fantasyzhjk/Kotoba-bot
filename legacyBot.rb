require 'websocket-client-simple'
require 'json'
require 'open3'

$OwnerQQ = '1071814607'
$Debug = false

def msg(str)
  command, args = str.match(/(.*?)\s(.+)/).captures if str =~ /(.*?)\s(.+)/
  ret = help if str == 'help'
  ret = chp if str == 'chp'
  ret = djt if str == 'djt'
  ret = hito if str == 'hito'
  #  if str == "hitoq" && "#{$data["sender"]["user_id"]}" == $OwnerQQ
  #    ret = hitoq()
  #  end
  #  if command == "hitoa"
  #    ret = hitoa(args)
  #  end
  ret = run(args) if command == 'run' && ($data['sender']['user_id']).to_s == $OwnerQQ
  #  if str == "hitom"
  #    ret = hitom()
  #  end
  ret = roll(args) if str == 'roll'
  ret = haishi(str) if str =~ /^(.*?)[还還]是+(.*?)$/
  # if str =~ /^(.*?)不+(.*?)$/
  #     if "#{$data["sender"]["user_id"]}" == $OwnerQQ
  #         ret = bu(str)
  #     end
  # end
  if str =~ /^(.*?)不+(.*?)$/
    ret = bu(str) if ($data['sender']['user_id']).to_s
  end
  if str =~ /^(.*?)没+(.*?)$/
    ret = mei(str) if ($data['sender']['user_id']).to_s
  end
  ret = info(args) if command == 'info'
  ret = roll(args) if command == 'roll'
  #   if command == "contact"
  #     ret = contact(args)
  #   end
  if ret.to_s != ''
    ret = '消息过长，发送失败' if ret.length > 924
    if $data['message_type'] == 'private'
      msg = { 'action' => 'send_private_msg', 'params' => { 'user_id' => $data['sender']['user_id'], 'message' => ret.to_s } }
    elsif $data['message_type'] == 'group'
      msg = { 'action' => 'send_group_msg', 'params' => { 'group_id' => $data['group_id'], 'message' => ret.to_s } }
    end
    $ws.send msg.to_json
  end
end

def help
  "食用手册v0.1：
  1.!hito  #一言！
  2.!chp  #播放彩虹屁
  3.!djt  #播放毒鸡汤
  4.!吃饭还是睡觉  #还是屙屎
  5.!要不要/有没有...  #你问问
  6.!info [osu_id]  #仅支持std
  7.!roll [最大值(默认100)]  #随机生成一个数
没了！"
end

#   8.!contact [要说的话]  #要找窝妈妈喵？

def run(command)
  ret, s = Open3.capture2e(command.to_s)
  puts ret
  ret
end

def chp
  ret, s = Open3.capture2e('./fun -chp')
  ret
end

def djt
  ret, s = Open3.capture2e('./fun -djt')
  ret
end

def hito
  hito, s = Open3.capture2e('./hitokoto_flag -s')
  hito
end

def hitoa(custom)
  hitoa, s = Open3.capture2e("./hitokoto_flag -a \"#{custom}\"")
  hitoa
end

def hitoq
  hitoq, s = Open3.capture2e('./hitokoto_flag -q')
  puts hitoq
  ''
end

def hitom
  hitom, s = Open3.capture2e('./hitokoto_flag -s -t "m"')
  if hitom != detectPic(hitom)
    args = hitom.match(/(\[CQ:image,file=.*image\])/).captures
    return args[0]
  end
  hitom
end

def haishi(msg)
  return '？' if msg =~ /^[还還]是/

  args = Array.new(2)
  args[0], args[1] = msg.match(/^(.*?)[还還]是+(.*?)$/).captures
  return '你在搞什么。。？' if args[1] =~ /[还還]是/

  arg = args[rand(2)]
  arg.gsub!(/我/, '@gsubCache@')
  arg.gsub!(/你/, '我')
  arg.gsub!(/@gsubCache@/, '你')
  return '？' if arg =~ /一个顶俩/
  return detectPic(arg) if detectPic(arg) != arg

  "当然是#{arg}喽~"
end

def bu(msg)
  return '那必须的!' if msg =~ /^[b白柏][s鼠喵][该要]不[该要]女装$/
  return '那绝对好!' if msg =~ /^[b白柏][s鼠喵]女装好不好$/
  return '爬' if msg =~ /[我你他，。,.]不[你我他，。,.]/

  msg.gsub!(/我/, '@gsubCache@')
  msg.gsub!(/你/, '我')
  msg.gsub!(/@gsubCache@/, '你')
  str = Array.new(2)
  if msg.index('不').to_s != '0'
    if msg[msg.index('不') - 1..msg.index('不') - 1] == msg[msg.index('不') + 1..msg.index('不') + 1]
      if msg[0..msg.index('不') - 2] != msg
        str[0] = msg[0..msg.index('不') - 2] + msg[msg.index('不') + 1..msg.length]
        str[1] = msg[0..msg.index('不') - 2] + msg[msg.index('不')..msg.length]
      else
        str[0] = msg[msg.index('不') + 1..msg.length]
        str[1] = msg[msg.index('不')..msg.length]
      end
      ret = str[rand(2)]
      return '？' if ret =~ /一个顶俩/

      detectPic(ret)
    end
  end
end

def mei(msg)
  return '爬' if msg =~ /[我你他，。,.]没[你我他，。,.]/

  msg.gsub!(/我/, '@gsubCache@')
  msg.gsub!(/你/, '我')
  msg.gsub!(/@gsubCache@/, '你')
  str = Array.new(2)
  if msg.index('没').to_s != '0'
    if msg[msg.index('没') - 1..msg.index('没') - 1] == msg[msg.index('没') + 1..msg.index('没') + 1]
      if msg[0..msg.index('没') - 2] != msg
        str[0] = msg[0..msg.index('没') - 2] + msg[msg.index('没') + 1..msg.length]
        str[1] = msg[0..msg.index('没') - 2] + msg[msg.index('没')..msg.length]
      else
        str[0] = msg[msg.index('没') + 1..msg.length]
        str[1] = msg[msg.index('没')..msg.length]
      end
      ret = str[rand(2)]
      return '？' if ret =~ /一个顶俩/

      detectPic(ret)
    end
  end
end

def info(user)
  puts user
  info, s = Open3.capture2e("./osubot -k \"fd1f4ec238dea7e8b481819b57583f7ff5965be2\" -u \"#{user}\"")
  puts info
  # if $data["group_id"] = 527686231
  #     return ""
  # end
  info
end

def contact(arg)
  msg = { 'action' => 'send_private_msg', 'params' => { 'user_id' => $OwnerQQ, "message": "用户：#{$data['sender']['nickname']}（#{$data['sender']['user_id']}） 说：\n#{arg}" } }
  $ws.send msg.to_json
  msg = '已经传达给妈妈了喵w'
end

def roll(arg)
  arg = 100 if arg.nil?
  return rand(arg.to_i) if arg == '0'
  return '参数错误' if arg.to_i <= 0

  rand(arg.to_i + 1)
end

def cqChange(arg)
  arg.gsub!(/CQ:image/, '图片文件')
  arg
end

def detectPic(arg)
  return '暂不支持图片哦~' if arg =~ /\[CQ:image,file=(.*)image\]/

  arg
end

$ws = WebSocket::Client::Simple.connect 'ws://localhost:6700/'
$ws.on :message do |msg|
  $data = JSON.parse(msg.data)
  puts msg.data
  if $data['message'] =~ /^[!！](.+)/
    # $command,$args = $data["raw_message"].match(/^[!！](.*?)\s(.+)/).captures
    msg = $data['message'].match(/^[!！](.+)/).captures
    msg(msg[0].to_s)
  end
  if $data['status'] == 'ok'
    puts '发送成功！'
  elsif  $data['status'] == 'failed'
    puts '发送失败！'
  end
end

$ws.on :open do
  puts('连接成功！')
end

$ws.on :close do |e|
  p e
  exit 1
end

$ws.on :error do |e|
  p e
  exit 1
  # goto :start
end

loop do
  msg = { 'action' => 'send_private_msg', 'params' => { 'user_id' => $OwnerQQ, "message": STDIN.gets.strip.to_s } }
  $ws.send msg.to_json
end
