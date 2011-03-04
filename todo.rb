#!/usr/bin/env ruby

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

case ARGV[0]
  when '-h', '--help'
    help
end
