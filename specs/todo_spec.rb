describe "todo.rb" do
  cmd = File.dirname(__FILE__) + "/../todo.rb"
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
end
