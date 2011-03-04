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
  it "should output a version" do
    `#{cmd} -v`.include?('version').should be_true
    `#{cmd} -v`.should == `#{cmd} --version`
  end
  it "should handle missing file" do
    `#{cmd} missing_file`.should == "No such file exists 'missing_file'. Please create it first with 'touch missing_file'\n"
  end
end
