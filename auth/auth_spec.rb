$: << File.expand_path(File.dirname(__FILE__)) 
require 'auth'

radfilename = "auth_spec.rad"
describe Auth do
  context "initialize using file auth_spec.rad" do
    describe '#new' do
      it "reads file contents and sets user and password" do
        auth = Auth.new(radfilename)
        expect(auth.user).to eq("testuser1")
        expect(auth.passwd).to eq("testpasswd1")
      end
      it "resets the file permissions to 0600" do
      end
    end
    describe '#changeuser' do
      it "sets user and password for a specified exisiting user (testuser2), returns 1" do
        auth = Auth.new(radfilename)
        expect( auth.change_user("testuser2") ).to eq(1)
        auth.user.should eq("testuser2")
        auth.passwd.should eq("testpasswd2")
      end
      it "doesn't change anything if user doesn't exist (testuser3), only returns nil" do
        auth = Auth.new(radfilename)
        expect( auth.change_user("testuser3") ).to eq(nil)
        expect(auth.user).to eq("testuser1")
        expect(auth.passwd).to eq("testpasswd1")
      end
    end
  end
end
