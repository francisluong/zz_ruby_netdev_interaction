require "net/ssh"

class SSH_Interact
    def initialize(user, passwd)
        @user = user
        @passwd = passwd
        @prompt_re = /([a-z]+@[a-zA-Z0-9\.\-\_]+[>#%])/
        @reset_timeout_on_newlines = true
        @timeout_sec = 10
        @quiet = 0
        @received_text = ""
    end

    def connect(hostname, port=22)
        #connect to SSH target and open channel
        @transport = Net::SSH.start(hostname,
            @user,
            :port => port,
            :password => @passwd)
        @channel = @transport.open_channel
        #@channel.request_pty
        #wait_for_prompt
    end

    def wait_for_prompt
    end

    def wait_for_regex
        #Loop receive and wait until a regular expression is matched in output
        #     - raise an exception if we hit the @timeout
    end

    def sendline
        #send a single line and wait for prompt
    end

    def send(textblock)
        #send a series of lines, wait for prompt after each
    end

end
