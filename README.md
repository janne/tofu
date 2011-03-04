todo.rb
=======

<pre>
todo.rb file a|add [args...]
Add todo. Run without arguments to create todos from STDIN, one per line

todo.rb file e|edit
Open file in editor

todo.rb file do args
Complete item, row numbers as arguments

todo.rb file [filters...]
List in alphanumerical order with row numbers, optional filter on arguments

todo.rb h|help
Displays this help message
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
