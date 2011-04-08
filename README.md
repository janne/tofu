Tofu
====

<pre>
Very simple todo CLI app

Usage
  tofu [options] [filters...]
  tofu [options] command [args...]

Options
    -f, --file FILE                  Specify todo file
    -d, --done                       Run command on done items
    -h, --help                       Display this help

Commands
  add       Create todo, text from args or STDIN, one per line
  archive   Archive all done items and sort remaining items
  count     Count words beginning with prefixes from args
  do        Remove todo, add to done, row numbers from args
  edit      Open file in editor

List items without command, filter on args
</pre>

Installation
------------
<pre>
sudo curl https://github.com/janne/tofu/raw/master/tofu > ~/usr/local/bin/tofu
sudo chmod +x ~/usr/local/bin/tofu
</pre>

Configuration
-------------
The default location for the todo file is todo.txt in the home directory. If
another location is preferred, create a file called ".tofurc" in the current
directory or the home directory, such as:

<pre>
echo "file: ~/Dropbox/tofu/todo.txt > ~/.tofurc"
touch ~/Dropbox/tofu/todo.txt
</pre>

Tips and tricks
---------------
To handle multiple lists, add an alias with a defined todo file:

<pre>
alias w=/usr/local/bin/tofu -f ~/Dropbox/tofu/work.txt
</pre>

To work on done todos, add the --done option. To add an item and mark it as
done:

<pre>
tofu add --done @buy shirt
</pre>

To list all done items marked with @buy

<pre>
tofu --done
</pre>

To edit the done items file:

<pre>
tofu edit --done
</pre>

To handle a todo list for a development project, add a todo file and a local
.tofurc. Any tofu command used in that directory is now using the local todo file.

<pre>
echo "file: todo.txt" > .tofurc
</pre>

You may wish to add context for items with the character @, such as "Call mom
@phone". When you have some time next to a phone, issue this command to list
your items:

<pre>
tofu @phone
</pre>

You can later get an overview of all your contexts with the command:

<pre>
tofu count @
</pre>

Likewise the character + may be used for projects, adding things like "Order
flowers +wedding".

You may then get a summary of both contexts and projects with:

<pre>
tofu count + @
</pre>

Author
------
Developed by [Jan Andersson](http://www.github.com/janne)

Heavily influenced by [Todo.txt by Gina Trapani](http://todotxt.com/)

Licensed under the [MIT License](http://www.opensource.org/licenses/mit-license.php)
