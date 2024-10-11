# lib/openai_reply.rb
module ::OpenAIReply
    class Engine < ::Rails::Engine
      engine_name "openai_reply"
      isolate_namespace OpenAIReply
    end
  
    def self.generate_reply(prompt)
      require 'net/http'
      require 'json'
  
      api_key = SiteSetting.openai_api_key
      uri = URI("https://api.openai.com/v1/chat/completions")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
  
      request = Net::HTTP::Post.new(uri.path, {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{api_key}"
      })
  
      request.body = {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        max_tokens: 150
      }.to_json
  
      response = http.request(request)
      JSON.parse(response.body)["choices"][0]["message"]["content"]
    end
  end
  

# lib/openai_reply.rb (继续)
DiscourseEvent.on(:topic_created) do |topic|
    prompt = "请为这个话题提供一个回复: #{topic.title}"
    reply = OpenAIReply.generate_reply(prompt)
  
    # 创建回复
    topic.posts.create!(
      raw: reply,
      user_id: User.find_by(username: '系统').id, # 确保有一个系统用户
      created_at: Time.now
    )
  end
  