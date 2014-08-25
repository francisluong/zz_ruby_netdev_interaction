require 'simplecov'
require 'netdev/ssh'
SimpleCov.start

describe NetDev::SSH do
  it "allows a user to login to a router with username and password" do
    user = ENV['USER']
    host = "localhost"
    ssh = NetDev::SSH.new(user: user)
    ssh.prompt_re = /^.*\$/
    ssh.quiet = true
    ssh.connect(host)
    expect(ssh).not_to eq(nil)
  end
  it "only returns text up to the line matching expression" do
    user = ENV['USER']
    host = "localhost"
    ssh = NetDev::SSH.new(user: user)
    ssh.prompt_re = /^.*\$/
    ssh.quiet = true
    ssh.connect(host)
    ssh.sendline("env")
    output = ssh.wait_for_regex(/USER/)
    lastline_varname = output.lines[-1].split("=")[0]
    expect(lastline_varname).to eq("USER")
  end
end