# TODO
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
f.each_line do |line|
  flowers << line.chomp
end

headers = [ "Proven Winners Name",
            "Type of Plant",
            "Common Name",
            "Exposure", 
            "Mature Size", 
            "Attracts",
            "Resists", 
            "Habit", 
            "Bloom times", 
            "Uses", 
            "Spread", 
            "Tolerance", 
            "Duration",
            "Notes" ]

misses = []

data = []
data << headers

agent = Mechanize.new

flowers.each do |f|
  page = agent.get("https://www.provenwinners.com/")

  form = page.form_with(:action => "/search/content")
  form.search_theme_form = f
  page = agent.submit(form, form.buttons.first)
  html = Nokogiri::HTML(page.body)

  if !html.at_css("body.node-type-plant-identity")
      link = html.css("div#content div.field-branded-name a")[0]
      if link.nil?
        # select plant filter
        leaves = html.css("div.content-top li.leaf a")
        load = ""
        leaves.each { |l| load = l if l.text.include?("Plant") }
        html = Nokogiri::HTML(agent.click(load).body)
        link = html.css("div#content div.field-branded-name a")[0]
      end
    html = Nokogiri::HTML(agent.click(link).body)
  end

  series = html.css("div.page-title span.series").text
  variety = html.css("div.page-title span.variety").text
  genus = html.css("div.page-title span.genus").text
  species = html.css("div.page-title span.species").text
  common = html.css("div.page-title span.common-name").text

  exposure = html.css("li.detail.yellow ul li").text.strip.downcase
  size = html.css("li.detail.blue ul li").text.downcase
  attracts = html.css("div.field-field-attracts-wildlife div div").inner_html.split(" ")
  resists = html.css("div.field-field-resists-wildlife div div").inner_html.split(" ")

  habit = html.css("div.field-field-plant-habit div div").text
  habit = habit.gsub /[\n\s]*Habit:[\n\s]*/, ''
  habit = habit.gsub /\s\s+/, ''
  habit = habit.strip[1...-1]

  bloom = html.css("div.field-field-plant-bloom-time div div").text
  bloom = bloom.sub(/[\s\n]*/, '')

  bloom = html.css("div.field-field-plant-bloom-time div div")
  b2 = []
  bloom.each do |b|
    b = b.inner_html.sub(/<[^>]*>/m, '')
    b = b.sub(/B[^>]*>/m, '')
    b2.push(b.strip.downcase) unless b.include?(":")
  end

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

  notes = html.css("div.field-field-maintenance-notes p").first
  unless notes.nil?
    temp = notes.text
    notes = ""
    counter = 0
    temp.scan(/[A-Z][^.]*(?:deadhead|heat|soil)[^.]*./).each do |s|
      notes << s << " "
      counter += 1
      break if counter == 3
    end
    notes.chop!
  end

  element = []

  pw_name = unless series.empty?
              series << " " << variety
            else
              variety
            end

  plant_type =  unless genus.empty?
                  genus << " " << species
                else
                  species
                end
  
  element << pw_name << plant_type

  element << common << exposure << size

  csv_write(attracts, element)
  csv_write(resists, element)
  element << habit
  csv_write(b2, element)
  csv_write(u2, element)
  element << spread
  csv_write(tolerance, element)
  csv_write(duration, element)
  element << notes

  data << element
  misses << f if exposure.empty?

  headers.zip(element).each do |h, e|
    puts "#{h}: #{e}"
  end
  puts ""
end

CSV.open("flowers.csv", "wb", {:force_quotes=>true}) do |csv|
  data.each do |d|
    csv << d
  end
end

puts "Missed flowers: "
misses.each { |m| puts m }