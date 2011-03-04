describe "todo.rb" do
  cmd = File.dirname(__FILE__) + "/../todo.rb"
  it "should be executable" do
    File.executable?(cmd)
  end
end
