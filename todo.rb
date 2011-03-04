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

if ARGV.length == 0
  help
  exit 1
end

case ARGV[0]
  when '-h', '--help'
    help
    exit
  when '-v', '--version'
    version
    exit
  else
    file = ARGV[0]
    text = ARGV[1..-1].join(' ')
end

unless File.exists?(file)
  puts "No such file exists '#{file}'. Please create it first with 'touch #{file}'"
  exit 1
end
end
