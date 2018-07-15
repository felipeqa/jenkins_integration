Before do
  Capybara.reset_sessions!
end

After do |scenario|
  if scenario.name.include? 'bing'
    Dir.mkdir('prints') unless Dir.exist?('prints')
    sufix = ('error' if scenario.failed?) || 'success'
    name = scenario.name.tr(' ', '_').downcase
    page.save_screenshot("prints/#{sufix}-#{name}.png")
    embed("prints/#{sufix}-#{name}.png", 'image/png', 'Screenshot')
  end
end
