#!/usr/bin/env ruby

def help
  puts <<EOF
Synopsis 
  Very simple todo CLI app

Usage 
  todo.rb file a|add [args...]
  Add todo. Run without arguments to create todos from STDIN, one per line

  todo.rb file do args
  Complete item, row numbers as arguments

  todo.rb file [filters...]
  List in alphanumerical order with row numbers, optional filter on arguments

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
  File.open(file, 'a') do |f|
    printf(f, "%s\n", text)
  end
end

def list_todos(file, filters)
  lines = File.read(file).split("\n")
  lines = (1..lines.length).to_a.zip(lines)
  lines = lines.select{|i, line| filters.all?{|filter| line.include?(filter)}} unless filters.empty?
  lines.sort{|a, b| a[1] <=> b[1] }.each{|i, text| printf("%*i %s\n", lines.length.to_s.length, i, text) }
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
