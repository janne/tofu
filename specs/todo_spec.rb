describe "todo.rb" do
  cmd = File.dirname(__FILE__) + "/../todo.rb"
  it "should be executable" do
    File.executable?(cmd)
  end
  it "should output a help text" do
    `#{cmd} -h`.include?('Very simple todo CLI app').should be_true
  end
end
