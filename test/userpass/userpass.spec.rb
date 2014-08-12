require 'simplecov'
SimpleCov.start
$: << File.expand_path(File.dirname(__FILE__))
$path = File.expand_path(File.dirname(__FILE__))
require 'userpass'


userpassfilename = "#{$path}/test_userpass"
describe Userpass do
    context "initialize using file #{userpassfilename}" do
        describe '#new' do
            it "reads file contents and sets user and password to the first ones listed" do
                auth = Userpass.new(userpassfilename)
                expect(auth.user).to eq("testuser1")
                expect(auth.passwd).to eq("testpasswd1")
            end
            it "resets the file permissions to 0600" do
                tmpfilename = "/var/tmp/userpass.permissions"
                FileUtils.cp userpassfilename, tmpfilename
                File.chmod(0666, tmpfilename)
                auth = Userpass.new(tmpfilename)
                s = File.stat(tmpfilename)
                mode = sprintf("%o", s.mode)
                expect(mode).to eq("100600")
                FileUtils.rm_f tmpfilename
            end
        end
        describe '#changeuser' do
            it "sets user and password for a specified exisiting user (testuser2)" do
                auth = Userpass.new(userpassfilename)
                newuser = "testuser2"
                newpasswd = "testpasswd2"
                expect( auth.user=newuser ).to eq(newuser)
                expect( auth.user ).to eq(newuser)
                expect( auth.passwd ).to eq(newpasswd)
            end
            it "scrambles the value of password in the database" do
                #placeholder
                auth = Userpass.new(userpassfilename)
                user = auth.user
                pwdatabase = auth.instance_variable_get(:@pwdatabase)
                expect( auth.passwd ).not_to eq( pwdatabase[user] )
            end
            it "raises an error if user doesn't exist (testuser3), but doesn't change user" do
                auth = Userpass.new(userpassfilename)
                expect { auth.change_user("testuser3") }.to raise_exception
                expect(auth.user).to eq("testuser1")
                expect(auth.passwd).to eq("testpasswd1")
            end
        end
    end
end
