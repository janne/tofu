#!/usr/bin/env ruby
require 'optparse'
require 'yaml'

BASENAME = File.basename($0)

def banner
<<EOF
Synopsis
  Very simple todo CLI app

Usage
  #{BASENAME} [options] [filters...]
  #{BASENAME} [options] command

Options
EOF
end

def commands
<<EOF
Commands
  a|add [text]
  Add todo. Run without arguments to create todos from STDIN, one per line

  d|do line...
  Remove line from todo, add to done document, row numbers as arguments

  e|edit
  Open file in editor

  c|count prefix...
  Count words beginning with prefix

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

def count_todos(file, prefixes)
  if prefixes.empty?
    puts "Missing prefix"
    exit 1
  end
  hash = {}
  prefixes.each do |prefix|
    File.read(file).scan(/(^|\s)(#{prefix}\S*)/) do |pre, w|
      hash[w] ? hash[w] += 1 : hash[w] = 1
    end
  end
  hash.to_a.sort{|a,b| order = -(a[1] <=> b[1]); order == 0 ? a[0] <=> b[0] : order }.each do |k, v|
    puts "#{k}: #{v}"
  end
end

def list_todos(file, filters)
  lines = File.read(file).split("\n")
  length = lines.length
  lines = (1..lines.length).to_a.zip(lines)
  lines = lines.select{|i, line| filters.all?{|filter| line.include?(filter)}} unless filters.empty?
  lines.sort{|a, b| a[1] <=> b[1] }.each{|i, text| printf("%*i %s\n", length.to_s.length, i, text) }
end

def file_exists?(f)
  puts "No such file exists '#{f}'. You may create it with 'touch #{f}'" unless File.exists?(f)
  File.exists?(f)
end

if rc = ["./.todorc", "~/.todorc"].detect{|f| File.exists?(f)}
  file = YAML.load(File.read(rc))['file']
else
  file = "~/todo.txt"
end
file = File.expand_path(file)

opts = OptionParser.new do |opts|
  opts.banner = banner
  opts.on('-f', '--file FILE', 'Specify todo file') do |f|
    file = f
  end
  opts.on('-h', '--help', 'Display this help') do
    puts opts
    exit
  end

  opts.separator ""
  opts.separator commands
end

opts.parse!
command = ARGV[0]
args = ARGV[1..-1]

case command
when 'e', 'edit'
  open_in_editor(file)
when 'd', 'do'
  do_todo(file, args) if file_exists?(file)
when 'c', 'count'
  count_todos(file, args)
when 'a', 'add'
  if file_exists?(file)
    text = args.join(' ')
    if text.empty?
      $stdin.read.split("\n").each{|text| add_todo(file, text)}
    else
      add_todo(file, text)
    end
  end
else
  if file_exists?(file)
    list_todos(file, ARGV)
  else
    puts opts
  end
end
