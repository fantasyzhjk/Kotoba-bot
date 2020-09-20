module Bot
  class Utils
    class << self
      def httpPost *args
        url = URI.parse args[0]
        req = Net::HTTP::Post.new(url.path, { 'Content-Type' => 'application/json' })
        req.body = args[1]
        res = Net::HTTP.start(url.hostname, url.port) do |http|
          http.request(req)
        end
        res.body
      end

      def blockPic msg
        if msg =~ /\[CQ:image,file=(.*)image\]/
          '暂不支持图片哦~'
        else
          msg
        end
      end
    end
  end
end
