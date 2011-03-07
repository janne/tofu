todo.rb
=======

<pre>
Synopsis
  Very simple todo CLI app

Usage
  todo.rb [options] [filters...]
  todo.rb [options] command

Options
    -f, --file FILE                  Specify todo file
    -h, --help                       Display this help

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
</pre>

Setup
-----
Add an alias such as:
<pre>
alias t=~/bin/todo.rb ~/Dropbox/todo/todo.txt
</pre>

Tips
----
Add multiple aliases for other lists:
<pre>
alias w=~/bin/todo.rb ~/Dropbox/todo/work.txt
</pre>
