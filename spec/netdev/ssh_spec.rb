require 'simplecov'
require 'netdev/ssh'
SimpleCov.start

describe NetDev::SSH do
  it "allows a user to login to a router with username and pubkey" do
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

  it "raises Net::SSH::AuthenticationFailed exception when user/pass fails" do
    u = "fail"
    p = "fail"
    host = "localhost"
    ssh = NetDev::SSH.new(user: u, passwd: p,
                          disable_pubkey_auth: true)
    ssh.prompt_re = /^.*\$/
    ssh.quiet = true
    expect { ssh.connect(host) }.to raise_error(Net::SSH::AuthenticationFailed)
  end

  it "raises Net::SSH::AuthenticationFailed exception when pubkey authentication fails" do
    u = "fail"
    host = "localhost"
    ssh2 = NetDev::SSH.new(user: u)
    ssh2.prompt_re = /^.*\$/
    ssh2.quiet = true
    expect { ssh2.connect(host) }.to raise_error(Net::SSH::AuthenticationFailed)
  end
end