require "pp"
require "openssl"
require "pry"

# usernames and passwords are assumed to be stored in ~/bin/.rad
# this will chmod 0600 your .rad file
# .rad file is assumed to be formatted as :
#<username>
#<password1>
#<username2>
#<password2>
#...

class Auth
    attr_reader :user, :users

    def initialize(filepath)
        #setup ciphers... scramble in memory... ghetto
        @cipher = OpenSSL::Cipher.new('AES-256-CBC')
        @decipher = OpenSSL::Cipher.new('AES-256-CBC')
        @cipher.encrypt
        @decipher.decrypt
        @decipher.key = @cipher.random_key
        @decipher.iv = @cipher.random_iv
        #read in userpass file
        filename = File.expand_path(filepath)
        file = File.new(filename , "r")
        #fix file permissions
        modcount = File.chmod(0600, filename)
        types = ['username', 'password']
        index = 0
        @users = Array.new
        @pwdatabase = Hash.new
        comment_expr = /\w*#.*/
        while (line = file.gets)
            #ignore lines that begin with "\w*#"
            if line =~ comment_expr
                #ignore comments
            else
                type = types[index]
                line = line.to_s.strip
                if type == 'username'
                    #set username
                    username = line
                    #add to users list
                    @users << username
                else
                    @pwdatabase[username] = @cipher.update(line) + @cipher.final
                    @cipher.encrypt
                    @decipher.decrypt
                end
                #toggle type => increement and mod%2 index
                index = (index + 1) % 2
            end
        end
        file.close
        self.change_user(@users[0])
    end

    def change_user(user)
        if (@pwdatabase.has_key?(user))
            @user = user
            return 1
        else 
            raise "Auth: Unable to change user to '#{user}'"
            return nil
        end
    end

    def passwd
        return @decipher.update(@pwdatabase[@user]) + @decipher.final
    end

end

#auth = Auth.new("~/bin/.rad")
