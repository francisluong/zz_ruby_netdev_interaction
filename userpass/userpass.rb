require "rubygems"
require "bundler/setup"
require "openssl"
require "pry"
require "yaml"

# usernames and passwords can be read from a YAML file.
# sample yamlpass file:
#     users:
#        test: test123
#        lab: lab123
#     defaultuser: lab

class Userpass
    def initialize(filepath=nil)
        #setup ciphers... scramble in memory... ghetto
        @cipher = OpenSSL::Cipher.new('AES-256-CBC')
        @decipher = OpenSSL::Cipher.new('AES-256-CBC')
        @cipher.encrypt
        @decipher.decrypt
        @decipher.key = @cipher.random_key
        @decipher.iv = @cipher.random_iv
        @pwdatabase = Hash.new
        @current_user = nil
        if filepath != nil
            self.load(filepath)
        end
    end

    def load(filepath)
        #read in yamlpass file
        filename = File.expand_path(filepath)
        file = File.new(filename , "r")
        #fix file permissions
        modcount = File.chmod(0600, filename)
        yaml = YAML.load(file)
        users = yaml["users"]
        users.each do |user, passwd|
            self.add_user_passwd(user, passwd)
        end
        @current_user = yaml["defaultuser"]

    end

    def add_user_passwd(user, passwd)
        #add a username/password
        #set current user if this is not set
        if @current_user == nil
            @current_user = user
        end
        #add password for this user
        @cipher.encrypt
        @pwdatabase[user] = @cipher.update(passwd) + @cipher.final
    end


    def user
        # getter for current user
        return @current_user
    end

    def user=(newuser)
        #setter for user
        #switch current user...
        if @pwdatabase.has_key?(newuser)
            #...but only switch if user is already in the pwdatabase
            @current_user = newuser
        else
            raise "Auth: Unable to change user to '#{newuser}'"
            return nil
        end
    end

    def passwd
        #get passwd for current user
        return self.passwd_for(@current_user)
    end

    def passwd_for(user)
        #get passwd for specific user
        @decipher.decrypt
        return @decipher.update(@pwdatabase[user]) + @decipher.final
    end

    def users
        # return list of users in pwdatabase
        return @pwdatabase.keys()
    end

    def keys
        # alias --> users
        return self.users
    end

    def has_key(user)
        return @pwdatabase.has_key?(user)
    end

end

#auth = Userpass.new("~/bin/.rad")
