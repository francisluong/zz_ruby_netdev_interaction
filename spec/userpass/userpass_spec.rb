require 'simplecov'
require 'spec_helper'
SimpleCov.start
require 'userpass'
$: << File.expand_path(File.dirname(__FILE__))

YAMLPASS = <<-EOS
users:
    testuser1: testpasswd1
    testuser2: testpasswd2
defaultuser: testuser1
EOS

describe Userpass do

  it "#set_strict_file_permissions" do
    tmpfilename = "/var/tmp/userpass.permissions#{random_name}"
    File.open(tmpfilename, 'w') do |file|
      file.write(YAMLPASS)
    end
    File.chmod(0666, tmpfilename)
    auth2 = Userpass.new
    auth2.set_strict_file_permissions(tmpfilename)
    s = File.stat(tmpfilename)
    mode = sprintf("%o", s.mode)
    expect(mode).to eq("100600")
    FileUtils.rm_f tmpfilename
  end
  context "initialize using mock userpass data YAMLPASS" do
    before(:each) do
      # @auth = Userpass.new("#{$path}/test_userpass")
      @auth = Userpass.new
      allow(@auth).to receive(:read_and_parse_yaml).and_return YAML::load(YAMLPASS)
      allow(@auth).to receive(:set_strict_file_permissions).and_return(true)
      @auth.load(true)
    end
    describe '#new' do
      it "reads file contents and sets user and password to the first ones listed" do
        expect(@auth.user).to eq("testuser1")
        expect(@auth.passwd).to eq("testpasswd1")
      end
    end
    describe '#changeuser' do
      it "sets user and password for a specified exisiting user (testuser2)" do
        newuser = "testuser2"
        newpasswd = "testpasswd2"
        expect(@auth.user=newuser).to eq(newuser)
        expect(@auth.user).to eq(newuser)
        expect(@auth.passwd).to eq(newpasswd)
      end
      it "scrambles the value of password in the database" do
        user = @auth.user
        pwdatabase = @auth.instance_variable_get(:@pwdatabase)
        expect(@auth.passwd).not_to eq(pwdatabase[user])
      end
      it "raises an error if user doesn't exist (testuser3), but doesn't change user" do
        expect { @auth.change_user("testuser3") }.to raise_exception
        expect(@auth.user).to eq("testuser1")
        expect(@auth.passwd).to eq("testpasswd1")
      end
    end
  end
end
