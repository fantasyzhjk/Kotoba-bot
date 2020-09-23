Sender = Struct.new(:age, :member_role, :card, :qqlevel, :nickname, :title, :sex)
Target = Struct.new(:messagetype, :time, :group_id, :user_id, :message_id, :message)
module Bot
  class Main
    class << self
      def dataParse(data)
        msg = JSON.parse(data)
        sdr = Sender.new
        tar = Target.new
        tar.time = msg['time']
        if msg['meta_event_type'] == 'lifecycle' && msg['sub_type'] == 'connect'
          $SelfID = msg['self_id']
          puts "[#{Time.at(tar.time).strftime('%Y-%m-%d %H:%M:%S')}][!]: go-cqhttp连接成功, BotQQ: #{$SelfID}"
        end
        if $DEBUGMODE == true
          puts msg if msg['meta_event_type'] != 'heartbeat'
        end
        if msg['post_type'] == 'message'
          tar.user_id = msg['user_id']
          tar.message_id = msg['message_id']
          tar.message = msg['message']
          sdr.age = msg['sender']['age']
          sdr.nickname = msg['sender']['nickname'] # 原有用户名
          sdr.sex = msg['sender']['sex']
          tar.messagetype = msg['message_type']
          # Group only
          tar.group_id = msg['group_id']
          sdr.card = msg['sender']['card'] # 群昵称
          sdr.title = msg['sender']['title'] # 头衔
          sdr.member_role = msg['sender']['role']
          sdr.qqlevel = msg['sender']['level']
          msgEvent msg, tar, sdr
        end
      end

      def msgEvent(msg, tar, sdr)
        if tar.messagetype == 'group'
          puts "[#{Time.at(tar.time).strftime('%Y-%m-%d %H:%M:%S')}][↓]: 收到群 #{tar.group_id} 内 #{sdr.nickname}(#{tar.user_id}) 的消息: #{tar.message} (#{tar.message_id})"
        else
          puts "[#{Time.at(tar.time).strftime('%Y-%m-%d %H:%M:%S')}][↓]: 收到好友 #{sdr.nickname}(#{tar.user_id}) 的消息: #{tar.message} (#{tar.message_id})"
        end

        if tar.message =~ /^[!！](.+)/
          msg = tar.message.match(/^[!！](.+)/).captures
          Command.parse msg[0].to_s, tar, sdr
        end
      end
    end
  end
  class Command
    class << self
      def parse(msg, tar, _sdr)
        ret = help if msg[0..4] == 'help'
        ret = randEvent msg, msg.match(/^.*?([不没])+.*?$/).captures if msg =~ /^.*?([不没])+.*?$/
        ret = randEvent msg, msg.match(/^.*?([还還])是+.*?$/).captures if msg =~ /^.*?([还還])是+.*?$/
        ret = randEvent msg[4..msg.length], 'roll' if msg[0..3] == 'roll'

        msgPost ret, tar
      end

      def randEvent(msg, type)
        msg.strip!
        msg.gsub!(/我/, '@gsubCache@')
        msg.gsub!(/你/, '我')
        msg.gsub!(/@gsubCache@/, '你')
        if type == 'roll'
          arg = msg
          return rand(100 + 1) if arg == ''
          return rand(0).to_s if arg == '0'

          if arg.to_i <= 0
            args = arg.split(' ')
            return '请至少输入两个事件' if args.length == 1

            return args[rand(args.length)]
          else
            return rand(arg.to_i + 1).to_s
          end
        end
        if type[0] == '没' || type[0] == '不'
          key = type[0]
          return '那必须的!' if msg =~ /^[b白柏][s鼠喵][该要]不[该要]女装$/
          return '那绝对好!' if msg =~ /^[b白柏][s鼠喵]女装好不好$/
          return '爬' if msg =~ /[我你他，。,.]不[你我他，。,.]/

          str = Array.new(2)
          if msg.index(key).to_s != '0'
            if msg[msg.index(key) - 1..msg.index(key) - 1] == msg[msg.index(key) + 1..msg.index(key) + 1]
              if msg[0..msg.index(key) - 2] != msg
                str[0] = msg[0..msg.index(key) - 2] + msg[msg.index(key) + 1..msg.length]
                str[1] = msg[0..msg.index(key) - 2] + msg[msg.index(key)..msg.length]
              else
                str[0] = msg[msg.index(key) + 1..msg.length]
                str[1] = msg[msg.index(key)..msg.length]
              end
              ret = str[rand(2)]
              if ret =~ /一个顶俩/
                return '？'
              else
                return Utils.blockPic(ret)
              end
            end
          end
        end
        if type[0] == '还' || type[0] == '還'
          ret = false if msg =~ /^[还還]是/
          args = Array.new(2)
          args[0], args[1] = msg.match(/^(.*?)[还還]是+(.*?)$/).captures
          ret = false if args[1] =~ /[还還]是/
          arg = args[rand(2)]
          if ret != false
            if arg =~ /一个顶俩/
              '？'
            elsif Utils.blockPic(arg) != arg
              Utils.blockPic(arg)
            else
              "当然是#{arg}喽~"
            end
          end
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

      def msgPost(msg, tar)
        if tar.messagetype == 'group'
          ret = { group_id: tar.group_id, message: msg }.to_json
          message_id = JSON.parse(Utils.httpPost('http://127.0.0.1:5700/send_group_msg', ret))['data']['message_id']
          puts "[#{Time.new.strftime('%Y-%m-%d %H:%M:%S')}][↑]: 发送至群 #{tar.group_id} 的消息: #{msg} (#{message_id})"
        elsif tar.messagetype == 'private'
          ret = { user_id: tar.user_id, message: msg }.to_json
          message_id = JSON.parse(Utils.httpPost('http://127.0.0.1:5700/send_private_msg', ret))['data']['message_id']
          puts "[#{Time.new.strftime('%Y-%m-%d %H:%M:%S')}][↑]: 发送至私聊 #{tar.user_id} 的消息: #{msg} (#{message_id})"
        end
        message_id
      end
    end
  end
end
