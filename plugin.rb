# plugin.rb
enabled_site_setting :openai_enabled

register_asset "javascripts/openai_reply.js"

after_initialize do
  require_dependency "openai_reply"
end
