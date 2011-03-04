#!/usr/bin/env ruby

def help
  puts <<EOF
Synopsis
  Very simple todo CLI app

Usage
  todo.rb file a|add [text]
  Add todo. Run without arguments to create todos from STDIN, one per line

  todo.rb file [filters...]
  List in alphanumerical order with row numbers, optional filter on arguments

  todo.rb file do line...
  Complete item, row numbers as arguments

  todo.rb file e|edit
  Open file in editor

  todo.rb file s|summary prefix...
  Output a summary of words beginning with prefix

  todo.rb h|help
  Displays this help message

Author
  Jan Andersson

Copyright
  Copyright (c) 2011 Jan Andersson. Licensed under the MIT License:
  http://www.opensource.org/licenses/mit-license.php
EOF
end

def add_todo(file, text)
  length = File.read(file).split("\n").length
  File.open(file, 'a') do |f|
    printf(f, "%s\n", text)
    printf("Added '%s' to line %i\n", text, length + 1)
  end
end

def done_file(file)
  File.dirname(file) + "/done." + File.basename(file)
end

def today
  Time.new.strftime("%Y-%m-%d")
end

def do_todo(file, nums)
  lines = File.read(file).split("\n")
  nums = nums.map(&:to_i)
  if nums.empty? || nums.any?{|num| num <= 0 || num > lines.length}
    puts "Missing or invalid line numbers"
    exit 1
  end
  File.open(done_file(file), 'a') do |f|
    nums.each do |num|
      text = lines[num-1]
      printf(f, "x #{today} #{text}\n")
      puts "Marked '#{text}' as done"
    end
  end
  File.open(file + '.tmp', 'w') do |f|
    lines.each_with_index do |line, i|
      unless nums.include?(i+1)
        f.printf("%s\n", line)
      end
    end
    `mv #{file + '.tmp'} #{file}`
  end
end

def open_in_editor(file)
  editor = ENV['EDITOR'] || 'vim'
  exec "#{editor} #{file}"
end

def summary(file, prefixes)
  if prefixes.empty?
    puts "Missing prefix"
    exit 1
  end
end

def list_todos(file, filters)
  lines = File.read(file).split("\n")
  length = lines.length
  lines = (1..lines.length).to_a.zip(lines)
  lines = lines.select{|i, line| filters.all?{|filter| line.include?(filter)}} unless filters.empty?
  lines.sort{|a, b| a[1] <=> b[1] }.each{|i, text| printf("%*i %s\n", length.to_s.length, i, text) }
end

if ARGV.length == 0
  help
  exit 1
end

case ARGV[0]
when 'h', 'help'
  help
else
  file = ARGV[0]
  unless File.exists?(file)
    puts "No such file exists '#{file}'. You may create it with 'touch #{file}'"
    exit 1
  end
  case ARGV[1]
  when 'h', 'help'
    help
  when 'e', 'edit'
    open_in_editor(file)
  when 'd', 'do'
    do_todo(file, ARGV[2..-1])
  when 's', 'summary'
    summary(file, ARGV[2..-1])
  when 'a', 'add'
    text = ARGV[2..-1].join(' ')
    if text.empty?
      $stdin.read.split("\n").each{|text| add_todo(file, text)}
    else
      add_todo(file, text)
    end
  else
    filters = ARGV[1..-1]
    list_todos(file, filters)
  end
end
