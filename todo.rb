#!/usr/bin/env ruby

VER = 0.1

def help
  puts <<EOF
Synopsis 
  Very simple todo CLI app

Usage 
  todo.rb file [args...]
  Add todo. Run without arguments to create todos from STDIN, one per line

  todo.rb file -l|--list [args...]
  List in alphanumerical order with row numbers, filter on arguments

  todo.rb file -cNUM|--complete=num
  Complete item, row number as argument

  todo.rb -h|--help
  Displays this help message

  todo.rb -v|--version
  Display the version, then exit

Author
  Jan Andersson

Copyright
  Copyright (c) 2011 Jan Andersson. Licensed under the MIT License:
  http://www.opensource.org/licenses/mit-license.php
EOF
end

def version
  puts "todo.rb version #{VER}"
end

def add_todo(file, text)
  File.open(file, 'a') do |f|
    f.write(text)
    f.write("\n")
  end
end

def list_todos(file, filters)
  lines = File.read(file).split("\n")
  lines = (1..lines.length).to_a.zip(lines)
  lines = lines.select{|i, line| filters.all?{|filter| line.include?(filter)}} unless filters.empty?
  lines.sort{|a, b| a[1] <=> b[1] }.each{|i, text| puts "#{i} #{text}"}
end

if ARGV.length == 0
  help
  exit 1
end

case ARGV[0]
when '-h', '--help'
  help
when '-v', '--version'
  version
else
  file = ARGV[0]
  unless File.exists?(file)
    puts "No such file exists '#{file}'. You may create it with 'touch #{file}'"
    exit 1
  end
  case ARGV[1]
  when '-h', '--help'
    help
  when '-v', '--version'
    version
  when '-l', '--list'
    filters = ARGV[2..-1]
    list_todos(file, filters)
  else
    text = ARGV[1..-1].join(' ')
    if text.empty?
      $stdin.read.split("\n").each{|text| add_todo(file, text)}
    else
      add_todo(file, text)
    end
  end
end
