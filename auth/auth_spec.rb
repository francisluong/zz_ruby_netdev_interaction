$: << File.expand_path(File.dirname(__FILE__)) 
require 'auth'

userpassfilename = "auth_spec.rad"
describe Auth do
  context "initialize using file auth_spec.rad" do
    describe '#new' do
      it "reads file contents and sets user and password to the first ones listed" do
        auth = Auth.new(userpassfilename)
        expect(auth.user).to eq("testuser1")
        expect(auth.passwd).to eq("testpasswd1")
      end
      it "resets the file permissions to 0600" do
        tmpfilename = "/var/tmp/userpass.permissions"
        FileUtils.cp userpassfilename, tmpfilename
        File.chmod(0666, tmpfilename)
        auth = Auth.new(tmpfilename)
        s = File.stat(tmpfilename)
        mode = sprintf("%o", s.mode)
        mode.should eq("100600")
        FileUtils.rm_f tmpfilename
      end
    end
    describe '#changeuser' do
      it "sets user and password for a specified exisiting user (testuser2), returns 1" do
        auth = Auth.new(userpassfilename)
        expect( auth.change_user("testuser2") ).to eq(1)
        auth.user.should eq("testuser2")
        auth.passwd.should eq("testpasswd2")
      end
      it "doesn't change anything if user doesn't exist (testuser3), only returns nil" do
        auth = Auth.new(userpassfilename)
        expect( auth.change_user("testuser3") ).to eq(nil)
        expect(auth.user).to eq("testuser1")
        expect(auth.passwd).to eq("testpasswd1")
      end
    end
  end
end
