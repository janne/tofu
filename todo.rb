#!/usr/bin/env ruby

def help
  puts <<EOF
todo.rb -h
This help message

todo.rb file [args...]
Add todo. Run without arguments to create todos from STDIN, one per line

todo.rb file -l|--list [args...]
List in alphanumerical order with row numbers, filter on arguments

todo.rb file -cNUM|--complete=num
Complete item, row number as argument
EOF
end

case ARGV[0]
  when '-h', '--help'
    help
end
