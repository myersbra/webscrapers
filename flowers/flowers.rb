# TODO
# remove extra comma and space from cells
# autoload plants that lead to search result page
# fix capitalization of words like "To"
# fix comma placement for words like "or"

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'csv'

def csv_write(arr, element)
  if arr.empty?
    element << nil
  else
    string = ""
    arr.each { |a| string << "#{a}, " if a != [] }
    2.times { string.slice!(string.length - 1) }
    element << "#{string}"
  end
end

flowers = []
f = File.open("flowerlist.txt", "r")
# f = File.open("testlist.txt", "r")
f.each_line do |line|
  flowers << line.chomp
end

headers = ["Type of Plant", "Exposure", "Mature Size", "Attracts", "Deadheading", "Resists", "Habit", "Bloom times", "Watering needs", "Uses", "Spread", "Tolerance", "Duration"]
misses = []

data = []
data << headers

agent = Mechanize.new

flowers.each do |f|
  sleep(0.5)
  page = agent.get("https://www.google.com/")
  form = page.form('f')
  form.q = "proven winners #{f}"
  page = agent.submit(form, form.buttons.first)

  html = Nokogiri::HTML(page.body)

  link = html.css("h3.r a")[0]

  html = Nokogiri::HTML(agent.click(link).body)

  if !html.at_css("body.node-type-plant-identity")
    link = html.css("div#content div.field-branded-name a")[0]
    # puts link
    html = Nokogiri::HTML(agent.click(link).body)
  end

  # PLANT NAME
  # series
  # variety
  # genus
  # species
  series = html.css("div.page-title span.series").text
  variety = html.css("div.page-title span.variety").text
  genus = html.css("div.page-title span.genus").text
  species = html.css("div.page-title span.species").text
  puts "series: #{series}"
  puts "variety: #{variety}"
  puts "genus: #{genus}"
  puts "species #{species}"
  puts ""
  # name1 = html.css("div.page-title span.plant-name span span strong").text
  name1 = html.css("div.page-title span.genus").text
  name1.slice!(name1.length)
  name2 = html.css("span.genus em").text
  # puts name1

  exposure = html.css("li.detail.yellow ul li").inner_html
  exposure = exposure.strip
  size = html.css("li.detail.blue ul li").inner_html
  attracts = html.css("div.field-field-attracts-wildlife div div").inner_html.split(" ")
  deadheading = html.css("div.field-field-deadheading-not-necessary div div").inner_html.strip
  resists = html.css("div.field-field-resists-wildlife div div").inner_html.split(" ")

  habit = html.css("div.field-field-plant-habit div div").inner_html.strip
  habit = habit.sub /<div.*<\/div>/m, ''
  habit = habit.sub /Habit:/, ''
  habit = habit.gsub(/\s+/, "")

  bloom = html.css("div.field-field-plant-bloom-time div div").text
  bloom = bloom.sub(/[\s\n]*/, '')
  # p bloom

  bloom = html.css("div.field-field-plant-bloom-time div div")
  b2 = []
  bloom.each do |b|
    b = b.inner_html.sub(/<[^>]*>/m, '')
    b = b.sub(/B[^>]*>/m, '')
    b2.push(b.strip) unless b.include?(":")
  end

  water = html.css("div.field-field-plant-water-category div div").inner_html.strip
  water = water.sub(/<[^>]*>/m, '')
  water = water.sub(/W[^:]*:/m, '').split

  uses = html.css("div.field-field-plant-uses div div").text.split
  u2 = []
  uses.each { |u| u2.push(u) unless u.include? "Use" }

  spread = html.css("div.field-field-spread-maximum").text.strip
  spread = spread.sub(/Spread.*\n\s*/, "")

  tol = html.css("div.group-features div").text.split("\n")
  tolerance = []
  tol.each do |t|
    t = t.strip!
    tolerance.push(t) if !t.nil? && t.include?("Tolerant") && !tolerance.include?(t)
  end

  dur = html.css("div.field-field-plant-duration").text.split(" ")
  duration = []
  dur.each { |d| duration.push(d) unless d.include?("Duration")}

  element = []
  element << f << exposure << size

  csv_write(attracts, element)
  element << deadheading
  csv_write(resists, element)
  element << habit
  csv_write(b2, element)
  element << water[1]
  csv_write(u2, element)
  element << spread
  csv_write(tolerance, element)
  csv_write(duration, element)

  # << habit << b2 << water[1] << u2 << spread << tolerance << duration
  data << element
  misses << f if exposure.empty?

  puts "Type of Plant: #{f}"
  puts "Exposure: #{exposure.strip}"
  puts "Size: #{size}"
  puts "Attracts: #{attracts}"
  puts "Deadheading: #{deadheading}"
  puts "Resists: #{resists}"
  puts "Habit: #{habit}"
  puts "Bloom Times: #{b2}"
  puts "Watering Needs: #{water[1]}"
  puts "Uses: #{u2}"
  puts "Spread: #{spread}"
  puts "Tolerance: #{tolerance}"
  puts "Duration: #{duration}"
  puts ""
end

CSV.open("flowers.csv", "wb", {:force_quotes=>true}) do |csv|
  data.each do |d|
    csv << d
  end
end

puts "Missed flowers: "
misses.each { |m| puts m }