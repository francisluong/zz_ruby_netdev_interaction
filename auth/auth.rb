require "pp"

# usernames and passwords are assumed to be stored in ~/bin/.rad
# this will chmod 0600 your .rad file
# .rad file is assumed to be formatted as :
#<username>
#<password1>
#<username2>
#<password2>
#...

class Auth
  attr_reader :user, :passwd

  def change_user(user)
    if (@pwdatabase.has_key?(user))
      @user = user
      @passwd = @pwdatabase[user]
      return 1
    else 
      raise "Auth: Unable to change user to '#{user}'"
      return nil
    end
  end

  def initialize(filepath)
    #read in userpass file
    filename = File.expand_path(filepath)
    file = File.new(filename , "r")
    modcount = File.chmod(0600, filename)
    input_array = Array.new
    while (line = file.gets)
      input_array << line.to_s.strip
    end
    file.close
    @pwdatabase = Hash[ *input_array ]
    self.change_user(input_array[0])
  end

end

#auth = Auth.new("~/bin/.rad")
