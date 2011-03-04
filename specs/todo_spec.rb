cmd = File.dirname(__FILE__) + "/../todo.rb"
todo = File.dirname(__FILE__) + "/todo.txt"

describe "todo.rb" do
  before do
    `cp /dev/null #{todo}`
  end
  after do
    `rm #{todo}`
  end
  it "should be executable" do
    File.executable?(cmd)
  end
  it "should output a help text" do
    `#{cmd}`.include?('Very simple todo CLI app').should be_true
    `#{cmd} -h`.include?('Very simple todo CLI app').should be_true
    `#{cmd} -h`.should == `#{cmd} --help`
  end
  it "should be able to get help text with file argument" do
    `#{cmd} #{todo} -h`.include?('Very simple todo CLI app').should be_true
  end
  it "should output a version" do
    `#{cmd} -v`.include?('version').should be_true
    `#{cmd} -v`.should == `#{cmd} --version`
  end
  it "should handle missing file" do
    `#{cmd} missing_file`.should == "No such file exists 'missing_file'. You may create it with 'touch missing_file'\n"
  end
  it "should handle unknown options" do
    `#{cmd} #{todo} -unknown`.should == "Unknown option\n"
    `#{cmd} #{todo} --unknown`.should == "Unknown option\n"
    `#{cmd} #{todo} -u`.should == "Unknown option\n"
  end
  it "should be able to add items" do
    `#{cmd} #{todo} my data`
    File.read(todo).include?('my data').should be_true
  end
  it "should be able to list items" do
    File.open(todo, 'a') do |f|
      f.write("xyz\n")
      f.write("abc\n")
      f.write("klm\n")
    end
    `#{cmd} #{todo} -l`.should == "2 abc\n3 klm\n1 xyz\n"
  end
  it "should be able to list items containing elements" do
    File.open(todo, 'a') do |f|
      f.write("xyz\n")
      f.write("abc\n")
      f.write("klz\n")
    end
    `#{cmd} #{todo} -l z`.should == "3 klz\n1 xyz\n"
    `#{cmd} #{todo} -l z k`.should == "3 klz\n"
  end
  it "should space pad line numbers" do
    File.open(todo, 'a') do |f|
      10.times { f.write("a\n") }
    end
    `#{cmd} #{todo} -l`.should == " 1 a\n 2 a\n 3 a\n 4 a\n 5 a\n 6 a\n 7 a\n 8 a\n 9 a\n10 a\n"
  end
end
