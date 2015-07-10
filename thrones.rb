#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'csv'
require 'google_drive'

array = ["trono.txt"]
chapters = []
words = Hash.new(0)

array.each do |book|
  File.open(book, "r:UTF-8") do |f|
    f.each_line do |line|
      if line =~ /^[\sA-Z]+\n/ then
        # p words
        # chapters << words.sort_by{ |k, v| v }.reverse!
        chapters << words
        # words.each { |w| group << w[0] << "def" }
        # chapters << group
        words = Hash.new(0)
      else
        line = line.downcase.gsub(/\P{L}/, ' ')
        line.split.each { |w| words[w] += 1 }
      end
    end
  end
end

# chapters.each do |c|
#   c = c.sort_by{ |k, v| v }.reverse
# end

# total_words = []
# newchapters = []
# chapters.each do |section|
#   sectioncopy = [];
#   section.each do |k|
#     if !total_words.include? k then
#       sectioncopy.push k
#       total_words.push k
#     end
#   end
#   newchapters << sectioncopy
# end

output = open("wordcount.txt", "w:UTF-8") do |f|
  chapters[1].each { |k| f.write("#{k}\n")}
  # f.write(chapters[1])
  # words.each do |w, v|
  #   output.write("#{w} - #{v}\n")
  # end
end

definitions = []
# chapters[1].each { |k, v| definitions << k}


# CSV.open("vocab.csv", "wb:UTF-8") do |csv|
#   # chapters[1].sort_by{ |k, v| v }.reverse.each do |w, v|
#   chapters[1].each do |w, v|
#     array = []
#     array << w << "def"
#     csv << array
#   end
#   # chapters[1].each { |k| csv << k[0] }
#   # chapters[1].each { |c| csv << "#{c}\n"}
# end


agent = Mechanize.new

chapters[1].each do |f|
  page = agent.get("http://www.wordreference.com/enit/")

  # form = page.form_with(:name => "f")
  form = page.forms.first
  form.field_with(:name => "enit").value = f[0]
  # agent.page.forms[0]["q"] = f

  # form.search_theme_form = f
  page = agent.submit(form)
  html = Nokogiri::HTML(page.body)

  check = html.css("table.WRD td.ToWrd")[0]
  unless check.nil?
    series = check.text
  end

  pp series
end

  # if !html.at_css("body.node-type-plant-identity")
  #     link = html.css("div#content div.field-branded-name a")[0]
  #     if link.nil?
  #       # select plant filter
  #       leaves = html.css("div.content-top li.leaf a")
  #       load = ""
  #       leaves.each { |l| load = l if l.text.include?("Plant") }
  #       html = Nokogiri::HTML(agent.click(load).body)
  #       link = html.css("div#content div.field-branded-name a")[0]
  #     end
  #   html = Nokogiri::HTML(agent.click(link).body)
  # end
