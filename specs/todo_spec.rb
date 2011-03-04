cmd = File.dirname(__FILE__) + "/../todo.rb"
todo = File.dirname(__FILE__) + "/todo.txt"
done = File.dirname(__FILE__) + "/done.todo.txt"

describe "todo.rb" do
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
    `#{cmd} missing_file`.should == "No such file exists 'missing_file'. You may create it with 'touch missing_file'\n"
  end

  describe "help" do
    it "should output a help text" do
      `#{cmd}`.include?('Very simple todo CLI app').should be_true
      `#{cmd} h`.include?('Very simple todo CLI app').should be_true
      `#{cmd} h`.should == `#{cmd} help`
    end
    it "should be able to get help text with file argument" do
      `#{cmd} #{todo} h`.include?('Very simple todo CLI app').should be_true
    end
  end

  describe "add" do
    it "should be able to add items" do
      `#{cmd} #{todo} add my data`.should == "Added 'my data' to line 1\n"
      File.read(todo).include?('my data').should be_true
      `#{cmd} #{todo} a more data`.should == "Added 'more data' to line 2\n"
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
      `#{cmd} #{todo}`.should == "2 abc\n3 klm\n1 xyz\n"
    end
    it "should be able to list items containing elements" do
      File.open(todo, 'a') do |f|
        f.write("xyz\n")
        f.write("abc\n")
        f.write("klz\n")
      end
      `#{cmd} #{todo} z`.should == "3 klz\n1 xyz\n"
      `#{cmd} #{todo} z k`.should == "3 klz\n"
    end
    it "should space pad line numbers" do
      File.open(todo, 'a') do |f|
        10.times { f.write("a\n") }
      end
      `#{cmd} #{todo}`.should == " 1 a\n 2 a\n 3 a\n 4 a\n 5 a\n 6 a\n 7 a\n 8 a\n 9 a\n10 a\n"
    end
    it "should space pad line numbers correctly with filter" do
      File.open(todo, 'a') do |f|
        f.write("x\n")
        8.times { f.write("a\n") }
        f.write("x\n")
      end
      `#{cmd} #{todo} x`.should == " 1 x\n10 x\n"
    end
  end

  describe "do" do
    it "should handle invalid line numbers" do
      File.open(todo, 'a') {|f| f.write("todo\n")}
      `#{cmd} #{todo} do`.should == "Missing or invalid line numbers\n"
      `#{cmd} #{todo} do x`.should == "Missing or invalid line numbers\n"
      `#{cmd} #{todo} do 0`.should == "Missing or invalid line numbers\n"
      `#{cmd} #{todo} do 2`.should == "Missing or invalid line numbers\n"
      `#{cmd} #{todo} do 1 2`.should == "Missing or invalid line numbers\n"
    end
    it "should put done items in done file" do
      File.open(todo, 'a') {|f| f.write("todo\n")}
      `#{cmd} #{todo} do 1`.should == "Marked 'todo' as done\n"
      File.read(done).include?('todo').should == true
    end
  end
end
