cmd = File.dirname(__FILE__) + "/../tofu"
todo = File.dirname(__FILE__) + "/todo.txt"
cmd_with_file = "#{cmd} -f #{todo}"
done = File.dirname(__FILE__) + "/done.todo.txt"

describe "tofu" do
  before do
    `cp /dev/null #{todo}`
  end
  after do
    `rm #{todo}`
    `rm -f #{done}`
  end
  it "should be executable" do
    File.executable?(cmd)
  end
  it "should handle missing file" do
    `#{cmd} -f missing_file`.include?("No such file exists 'missing_file'. You may create it with 'touch missing_file'\n").should be_true
  end

  describe ".todorc" do
    before do
      `echo "hello" > temp.txt`
      `echo "file: temp.txt" > .todorc`
    end
    it "should use todorc" do
      `#{cmd}`.should == "1 hello\n"
    end
    after do
      `rm temp.txt`
      `rm .todorc`
    end
  end

  describe "help" do
    it "should output a help text" do
      `#{cmd} -h`.include?('Very simple todo CLI app').should be_true
    end
  end

  describe "add" do
    it "should be able to add items" do
      `#{cmd_with_file} add my data`.should == "Added 'my data' to line 1\n"
      File.read(todo).include?('my data').should be_true
      `#{cmd_with_file} add more data`.should == "Added 'more data' to line 2\n"
      File.read(todo).include?('more data').should be_true
    end
  end

  describe "list" do
    it "should be able to list items" do
      File.open(todo, 'a') do |f|
        f.write("xyz\n")
        f.write("abc\n")
        f.write("klm\n")
      end
      `#{cmd_with_file}`.should == "2 abc\n3 klm\n1 xyz\n"
    end
    it "should be able to list items containing elements" do
      File.open(todo, 'a') do |f|
        f.write("xyz\n")
        f.write("abc\n")
        f.write("klz\n")
      end
      `#{cmd_with_file} z`.should == "3 klz\n1 xyz\n"
      `#{cmd_with_file} z k`.should == "3 klz\n"
    end
    it "should space pad line numbers" do
      File.open(todo, 'a') do |f|
        10.times { f.write("a\n") }
      end
      `#{cmd_with_file}`.should == " 1 a\n 2 a\n 3 a\n 4 a\n 5 a\n 6 a\n 7 a\n 8 a\n 9 a\n10 a\n"
    end
    it "should space pad line numbers correctly with filter" do
      File.open(todo, 'a') do |f|
        f.write("x\n")
        8.times { f.write("a\n") }
        f.write("x\n")
      end
      `#{cmd_with_file} x`.should == " 1 x\n10 x\n"
    end
  end

  describe "do" do
    it "should handle invalid line numbers" do
      File.open(todo, 'a') {|f| f.write("todo\n")}
      `#{cmd_with_file} do`.should == "Missing or invalid line numbers\n"
      `#{cmd_with_file} do x`.should == "Missing or invalid line numbers\n"
      `#{cmd_with_file} do 0`.should == "Missing or invalid line numbers\n"
      `#{cmd_with_file} do 2`.should == "Missing or invalid line numbers\n"
      `#{cmd_with_file} do 1 2`.should == "Missing or invalid line numbers\n"
    end
    it "should remove done items from todo file" do
      File.open(todo, 'a') {|f| f.write("todo\n")}
      `#{cmd_with_file} do 1`.should == "Marked 'todo' as done\n"
      `#{cmd_with_file}`.should == ""
    end
    it "should put done items in done file" do
      File.open(todo, 'a') {|f| f.write("todo\n")}
      `#{cmd_with_file} do 1`.should == "Marked 'todo' as done\n"
      File.read(done).include?('todo').should == true
      File.exists?(todo + '.tmp').should == false
    end
  end

  describe "count" do
    it "should handle missing prefix" do
      `#{cmd_with_file} count`.should == "Missing prefix\n"
    end
    it "should handle missing chars" do
      `#{cmd_with_file} count x`.should == ""
    end
    it "should output result" do
      File.open(todo, 'a') {|f| f.write("todo @b\ntodo @a @b\n")}
      `#{cmd_with_file} count @`.should == "@b: 2\n@a: 1\n"
    end
    it "should only hit in beginning of words" do
      File.open(todo, 'a') {|f| f.write("Kaka\nHaKaka\nHa Koko Keke\n")}
      `#{cmd_with_file} count K`.should == "Kaka: 1\nKeke: 1\nKoko: 1\n"
    end
  end
end
