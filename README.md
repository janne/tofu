todo.rb
=======

<pre>
todo.rb -h
This help message

todo.rb file [args...]
Add todo. Run without arguments to create todos from STDIN, one per line

todo.rb file -l|--list [args...]
List in alphanumerical order with row numbers, filter on arguments

todo.rb file -cNUM|--complete=num
Complete item, row number as argument
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

Ideas
-----

Plugins may provide more functionality, such as:

* Archive
* Priority
* Contexts
