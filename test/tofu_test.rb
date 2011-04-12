require 'test/unit'

class TofuTest < Test::Unit::TestCase
  def setup
    @cmd = File.dirname(__FILE__) + "/../tofu"
    @todo_file = File.dirname(__FILE__) + "/todo.txt"
    @cmd_with_file = "#{@cmd} -f #{@todo_file}"
    @archive_file = File.dirname(__FILE__) + "/archive.todo.txt"
    @today = Time.new.strftime('%Y-%m-%d')

    `cp /dev/null #{@todo_file}`
  end

  def teardown
    `rm #{@todo_file}`
    `rm -f #{@archive_file}`
  end

  def test_executable
    assert File.executable?(@cmd)
  end

  def test_missing_file
    assert `#{@cmd} -f missing_file`.include?("No such file exists 'missing_file'. You may create it with 'touch missing_file'\n")
  end

  def test_tofurc
    `echo "hello" > temp.txt`
    `echo "todo_file: temp.txt" > .tofurc`
    assert_equal "1 hello\n", `#{@cmd}`
    `rm temp.txt`
    `rm .tofurc`
  end

  # HELP

  def test_help_output
    assert `#{@cmd} -h`.include?('Very simple todo CLI app')
  end

  # ADD

  def test_add
    assert_equal "Added 'my data' to line 1\n", `#{@cmd_with_file} add my data`
    assert File.read(@todo_file).include?('my data')
    assert_equal "Added 'more data' to line 2\n", `#{@cmd_with_file} add more data`
    assert File.read(@todo_file).include?('more data')
  end

  def test_add_and_mark_as_done
    assert_equal "Added 'my data' to line 1 and marked as done\n", `#{@cmd_with_file} add --done my data`
    assert File.read(@todo_file).include?("x #{@today} my data")
    assert_equal "Added 'more data' to line 2 and marked as done\n", `#{@cmd_with_file} add --done more data`
    assert File.read(@todo_file).include?("x #{@today} more data")
  end

  # LIST

  def test_list
    File.open(@todo_file, 'a') do |f|
      f.write("xyz\n")
      f.write("abc\n")
      f.write("klm\n")
    end
    assert_equal "2 abc\n3 klm\n1 xyz\n", `#{@cmd_with_file}`
  end

  def test_list_done
    File.open(@todo_file, 'a') {|f| f.write("todo 1\ntodo 2\n")}
    `#{@cmd_with_file} do 1`
    `#{@cmd_with_file} archive`
    `#{@cmd_with_file} do 1`
    assert_equal "x #{@today} todo 1\nx #{@today} todo 2\n", `#{@cmd_with_file} --done`
  end

  def test_list_and_filter
    File.open(@todo_file, 'a') do |f|
      f.write("xyz\n")
      f.write("abc\n")
      f.write("klz\n")
    end
    assert_equal "3 klz\n1 xyz\n", `#{@cmd_with_file} z`
    assert_equal "3 klz\n", `#{@cmd_with_file} z k`
  end

  def test_list_and_filter_without_results
    assert_equal "Nothing found\n", `#{@cmd_with_file} foo`
  end

  def test_space_pad_line_numbers
    File.open(@todo_file, 'a') do |f|
      10.times { f.write("a\n") }
    end
    assert_equal " 1 a\n 2 a\n 3 a\n 4 a\n 5 a\n 6 a\n 7 a\n 8 a\n 9 a\n10 a\n", `#{@cmd_with_file}`
  end

  def test_should_space_pad_line_numbers_correctly_with_filter
    File.open(@todo_file, 'a') do |f|
      f.write("x\n")
      8.times { f.write("a\n") }
      f.write("x\n")
    end
    assert_equal " 1 x\n10 x\n", `#{@cmd_with_file} x`
  end

  # DO

  def test_invalid_line_numbers
    File.open(@todo_file, 'a') {|f| f.write("todo\n")}
    assert_equal "Missing or invalid line numbers\n", `#{@cmd_with_file} do`
    assert_equal "Missing or invalid line numbers\n", `#{@cmd_with_file} do x`
    assert_equal "Missing or invalid line numbers\n", `#{@cmd_with_file} do 0`
    assert_equal "Missing or invalid line numbers\n", `#{@cmd_with_file} do 2`
    assert_equal "Missing or invalid line numbers\n", `#{@cmd_with_file} do 1 2`
    `#{@cmd_with_file} do 1`
    assert_equal "Missing or invalid line numbers\n", `#{@cmd_with_file} do 1`
  end

  def test_mark_done_items_in_todo_file
    File.open(@todo_file, 'a') {|f| f.write("todo\n")}
    assert_equal "Marked 'todo' as done\n", `#{@cmd_with_file} do 1`
    assert_equal "x #{@today} todo\n", File.read(@todo_file)
    assert_equal "", `#{@cmd_with_file}`
  end

  # ARCHIVE

  def test_archive
    File.open(@todo_file, 'a') {|f| f.write("todo\n")}
    `#{@cmd_with_file} do 1`
    assert_equal "Archived 1 item\n", `#{@cmd_with_file} archive`
    assert_equal "x #{@today} todo\n", File.read(@archive_file)
    assert !File.exists?(@todo_file + '.tmp')
  end

  def test_sorting_items_after_archive
    File.open(@todo_file, 'a') {|f| f.write("bbb\naaa\n")}
    assert_equal "2 aaa\n1 bbb\n", `#{@cmd_with_file}`
    assert_equal "Archived 0 items\n", `#{@cmd_with_file} archive`
    assert_equal "1 aaa\n2 bbb\n", `#{@cmd_with_file}`
  end

  def test_adding_archive_date
    File.open(@todo_file, 'a') {|f| f.write("X todo\n")}
    `#{@cmd_with_file} archive`
    assert File.read(@archive_file) == "x #{@today} todo\n"
  end

  def test_keeping_archive_date
    File.open(@todo_file, 'a') {|f| f.write("X 2011-01-01 todo\n")}
    `#{@cmd_with_file} archive`
    assert File.read(@archive_file) == "x 2011-01-01 todo\n"
  end

  # COUNT

  def test_count
    File.open(@todo_file, 'a') {|f| f.write("todo @b\ntodo @a @b\n")}
    assert_equal "@b: 2\n@a: 1\n", `#{@cmd_with_file} count @`
  end

  def test_count_done
    File.open(@todo_file, 'a') {|f| f.write("todo @b\nx #{@today} todo @a @b\n")}
    assert_equal "@a: 1\n@b: 1\n", `#{@cmd_with_file} count --done @`
  end

  def test_missing_prefix
    assert_equal "Missing prefix\n", `#{@cmd_with_file} count`
  end

  def test_missing_chars
    assert_equal "", `#{@cmd_with_file} count x`
  end

  def test_middle_of_words
    File.open(@todo_file, 'a') {|f| f.write("Kaka\nHaKaka\nHa Koko Keke\n")}
    assert_equal "Kaka: 1\nKeke: 1\nKoko: 1\n", `#{@cmd_with_file} count K`
  end
end
