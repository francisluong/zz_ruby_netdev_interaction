require "net/ssh"
require "net/ssh/telnet"

module NetDev
class SSH
    def initialize(user, passwd)
        @user = user
        @passwd = passwd
        @prompt_re = /^([@a-zA-Z0-9\.\-\_]+[>#%])/
        @reset_timeout_on_newlines = true
        @timeout_sec = 10
        @wait_sec = 0.01
        @quiet = false
        @received_text = ""
    end

    def connect(hostname, port=22)
        #connect to SSH target and open channel
        @ssh = Net::SSH.start(hostname,
            @user,
            :port => port,
            :password => @passwd)
        @session = Net::SSH::Telnet.new(
            "Session" => @ssh,
            "Prompt" => @prompt_re
        )
        @session.cmd("terminal length 0")
    end

    def wait_for_prompt
        return self.wait_for_regex @prompt_re
    end

    def wait_for_regex(expression)
        #Loop receive and wait until a regular expression is matched in output
        @received_text << @session.wait_for(
            "Match" => expression,
            "Timeout" => @timeout,
            "waittime" => @wait_sec
        )
    end

    def sendline(single_command)
        #send a single line and wait for prompt
        @received_text = @session.cmd(single_command)
        if not @quiet
            print @received_text
        end
    end

    def send(textblock)
        #send a series of lines, wait for prompt after each
        textblock.lines do |line|
            self.sendline(line.chomp)
        end
    end

end
end
