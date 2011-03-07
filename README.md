todo.rb
=======

<pre>
Synopsis
  Very simple todo CLI app

Usage
  t [options] [filters...]
  t [options] command [args...]

Options
    -f, --file FILE                  Specify todo file
    -h, --help                       Display this help

Commands
  add     Create todo, text from args or STDIN, one per line
  do      Remove line from todo, add to done, row numbers from args
  edit    Open file in editor
  count   Count words beginning with prefixes from args

List items without command, filter on args
</pre>

Installation
------------
<pre>
sudo curl https://github.com/janne/todo.rb/raw/master/todo.rb > ~/usr/local/bin/t
sudo chmod +x ~/usr/local/bin/t
</pre>

Configuration
-------------
The default location for the todo file is todo.txt in the home directory. If
another location is preferred, create a file called ".todorc" in the current
directory or the home directory, such as:

<pre>
echo "file: ~/Dropbox/todo/todo.txt > ~/.todorc"
touch ~/Dropbox/todo/todo.txt
</pre>

Tips and tricks
---------------
To handle multiple lists, add an alias with a defined todo file:

<pre>
alias w=/usr/local/bin/t -f ~/Dropbox/todo/work.txt
</pre>

To handle a todo list for a development project, add a todo file and a local
.todorc. Any t command used in that directory is now using the local todo file.

<pre>
echo "file: todo.txt" > .todorc
</pre>

You may wish to add context for items with the character @, such as "Call mom
@phone". When you have some time next to a phone, issue this command to list
your items:

<pre>
t @phone
</pre>

You can later get an overview of all your contexts with the command:

<pre>
t count @
</pre>

Likewise the character + may be used for projects, adding things like "Order
flowers +wedding".

You may then get a summary of both contexts and projects with:

<pre>
t count + @
</pre>

Author
------
Developed by [Jan Andersson](http://www.github.com/janne)

Heavily influenced by [Todo.txt by Gina Trapani](http://todotxt.com/)

Licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.php)
