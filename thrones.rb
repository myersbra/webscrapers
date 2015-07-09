#!/usr/bin/env ruby

# Note: you'll have to change the line endings
# to LF for the dot slash shebang to work.

# words = Hash.new(0)

array = ["thrones1.txt"]
chapters = []
words = Hash.new(0)

array.each do |book|
  File.open(book, "r") do |f|
    f.each_line do |line|
      if line =~ /^[\sA-Z]+\n/ then
        # p words
        chapters << words.dup.sort_by{ |k, v| v }.reverse
        words = Hash.new(0)
      else
        line = line.downcase.gsub(/[^a-z ]/, ' ')
        line.split.each { |w| words[w] += 1 }
      end
    end
  end
end

# chapters.each do |c|
#   c = c.sort_by{ |k, v| v }.reverse
# end

total_words = []
newchapters = []
chapters.each do |section|
  sectioncopy = [];
  section.each do |k|
    if !total_words.include? k then
      sectioncopy.push k
      total_words.push k
    end
  end
  newchapters << sectioncopy
end

output = open("wordcount.txt", "w") do |f|
  newchapters[2].each { |k, v| f.write("#{k} - #{v}\n")}
  # f.write(chapters[1])
  # words.each do |w, v|
  #   output.write("#{w} - #{v}\n")
  # end
end
# p chapters
puts "done!"

begin
	STDIN.gets
rescue Interrupt => e
	nil
end
