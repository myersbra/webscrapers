# A script to read news articles

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

agent = Mechanize.new

page = agent.get("https://www.msnbc.msn.com/explore")
form = page.form_with(:action => "/search/content")
form.search_theme_form = f
page = agent.submit(form, form.buttons.first)
html = Nokogiri::HTML(page.body)

# if !html.at_css("body.node-type-plant-identity")
#     link = html.css("div#content div.field-branded-name a")[0]
#     if link.nil?
#       # select plant filter
#       leaves = html.css("div.content-top li.leaf a")
#       load = ""
#       leaves.each { |l| load = l if l.text.include?("Plant") }
#       if load == ""
#         # search has failed, move on to next flower
#         misses << f
#         next
#       end
#       html = Nokogiri::HTML(agent.click(load).body)
#       link = html.css("div#content div.field-branded-name a")[0]
#     end
#   html = Nokogiri::HTML(agent.click(link).body)
# end
# 
# series = html.css("div.page-title span.series").text
# variety = html.css("div.page-title span.variety").text
# genus = html.css("div.page-title span.genus").text
# species = html.css("div.page-title span.species").text
# common = html.css("div.page-title span.common-name").text
# 
# exposure = html.css("li.detail.yellow ul li").text.strip.downcase
# size = html.css("li.detail.blue ul li").text.downcase
# 
# attracts = html.css("div.field-field-attracts-wildlife div div").text.downcase.split(" ")
# attracts = attracts.join(", ")
# resists = html.css("div.field-field-resists-wildlife div div").text.downcase.split(" ")
# resists = resists.join(", ")
# 
# habit = html.css("div.field-field-plant-habit div div").text.downcase
# habit = habit.gsub(/(?:\n|habit:|\s\s+|\u{00A0})*/, '')
# 
# bloom = html.css("div.field-field-plant-bloom-time div div").text.downcase
# bloom = bloom.gsub(/(?:\n|bloom\stime:|\s\s+)*/, '').split(/\u{00A0}/)
# bloom.delete_if { |b| b.empty? }
# bloom = bloom.join(", ")
# 
# uses = html.css("div.field-field-plant-uses div div").text.downcase
# uses = uses.gsub(/(?:\n|uses:|\s\s+)*/, '').split(/\u{00A0}/)
# uses.delete_if { |u| u.empty? }
# uses = uses.join(", ")
# 
# spread = html.css("div.field-field-spread-maximum").text.downcase
# spread = spread.gsub(/(?:\n|spread:|\s\s+|\u{00A0})*/, '')
# 
# tolerance = html.xpath('//div[contains(@class, "tolerant")]').text.downcase.split(/\s\s+/)
# tolerance.delete_if { |t| t.empty? }
# tolerance = tolerance.join(", ")
# 
# duration = html.css("div.field-field-plant-duration").text.downcase
# duration = duration.gsub(/(?:\n|duration:|\s\s+|\u{00A0})*/, '')
# 
# notes = html.css("div.field-field-maintenance-notes p").first
# unless notes.nil?
#   notes = notes.text.scan(/[A-Z][^.]*(?:deadhead|heat|soil)[^.]*./)[0..2] unless notes.nil?
#   notes = notes.join(" ")
# end
