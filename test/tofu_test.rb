require 'test/unit'

class TofuTest < Test::Unit::TestCase
  def setup
    @cmd = File.dirname(__FILE__) + "/../tofu"
    @todo_file = File.dirname(__FILE__) + "/todo.txt"
    @cmd_with_file = "#{@cmd} -f #{@todo_file}"
    @done_file = File.dirname(__FILE__) + "/done.todo.txt"

    `cp /dev/null #{@todo_file}`
  end

  def teardown
    `rm #{@todo_file}`
    `rm -f #{@done_file}`
  end

  def test_executable
    assert File.executable?(@cmd)
  end

  def test_missing_file
    assert `#{@cmd} -f missing_file`.include?("No such file exists 'missing_file'. You may create it with 'touch missing_file'\n")
  end

  def test_tofurc
    `echo "hello" > temp.txt`
    `echo "file: temp.txt" > .tofurc`
    assert_equal `#{@cmd}`, "1 hello\n"
    `rm temp.txt`
    `rm .tofurc`
  end

  # HELP

  def test_help_output
    assert `#{@cmd} -h`.include?('Very simple todo CLI app')
  end

  # ADD

  def test_add
    assert_equal `#{@cmd_with_file} add my data`, "Added 'my data' to line 1\n"
    assert File.read(@todo_file).include?('my data')
    assert_equal `#{@cmd_with_file} add more data`, "Added 'more data' to line 2\n"
    assert File.read(@todo_file).include?('more data')
  end

  # LIST

  def test_list
    File.open(@todo_file, 'a') do |f|
      f.write("xyz\n")
      f.write("abc\n")
      f.write("klm\n")
    end
    assert_equal `#{@cmd_with_file}`, "2 abc\n3 klm\n1 xyz\n"
  end

  def test_list_and_filter
    File.open(@todo_file, 'a') do |f|
      f.write("xyz\n")
      f.write("abc\n")
      f.write("klz\n")
    end
    assert_equal `#{@cmd_with_file} z`, "3 klz\n1 xyz\n"
    assert_equal `#{@cmd_with_file} z k`, "3 klz\n"
  end

  def test_list_and_filter_without_results
    assert_equal `#{@cmd_with_file} foo`, "Nothing found\n"
  end

  def test_space_pad_line_numbers
    File.open(@todo_file, 'a') do |f|
      10.times { f.write("a\n") }
    end
    assert_equal `#{@cmd_with_file}`, " 1 a\n 2 a\n 3 a\n 4 a\n 5 a\n 6 a\n 7 a\n 8 a\n 9 a\n10 a\n"
  end

  def test_should_space_pad_line_numbers_correctly_with_filter
    File.open(@todo_file, 'a') do |f|
      f.write("x\n")
      8.times { f.write("a\n") }
      f.write("x\n")
    end
    assert_equal `#{@cmd_with_file} x`, " 1 x\n10 x\n"
  end

  # DO

  def test_invalid_line_numbers
    File.open(@todo_file, 'a') {|f| f.write("todo\n")}
    assert_equal `#{@cmd_with_file} do`, "Missing or invalid line numbers\n"
    assert_equal `#{@cmd_with_file} do x`, "Missing or invalid line numbers\n"
    assert_equal `#{@cmd_with_file} do 0`, "Missing or invalid line numbers\n"
    assert_equal `#{@cmd_with_file} do 2`, "Missing or invalid line numbers\n"
    assert_equal `#{@cmd_with_file} do 1 2`, "Missing or invalid line numbers\n"
  end

  def test_remove_done_items_from_todo_file
    File.open(@todo_file, 'a') {|f| f.write("todo\n")}
    assert_equal `#{@cmd_with_file} do 1`, "Marked 'todo' as done\n"
    assert_equal `#{@cmd_with_file}`, ""
  end

  def test_put_done_items_in_done_file
    File.open(@todo_file, 'a') {|f| f.write("todo\n")}
    assert_equal `#{@cmd_with_file} do 1`, "Marked 'todo' as done\n"
    assert File.read(@done_file).include?('todo')
    assert !File.exists?(@todo_file + '.tmp')
  end

  # COUNT

  def test_count
    File.open(@todo_file, 'a') {|f| f.write("todo @b\ntodo @a @b\n")}
    assert_equal `#{@cmd_with_file} count @`, "@b: 2\n@a: 1\n"
  end

  def test_missing_prefix
    assert_equal `#{@cmd_with_file} count`, "Missing prefix\n"
  end

  def test_missing_chars
    assert_equal `#{@cmd_with_file} count x`, ""
  end

  def test_middle_of_words
    File.open(@todo_file, 'a') {|f| f.write("Kaka\nHaKaka\nHa Koko Keke\n")}
    assert_equal `#{@cmd_with_file} count K`, "Kaka: 1\nKeke: 1\nKoko: 1\n"
  end
end
