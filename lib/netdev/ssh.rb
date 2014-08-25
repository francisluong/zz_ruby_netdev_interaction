require "net/ssh"
require "pry"

module NetDev
    class SSH
        attr_accessor :prompt_re, :quiet, :timeout_sec

        def initialize(user: "", passwd: "",
                       keys: ["~/.ssh/id_rsa", "~/.ssh/id_dsa"])
            #constructor, does not connect to host
            @user = user
            @passwd = passwd
            @keys = keys
            @prompt_re = /^([@a-zA-Z0-9\.\-\_\:]*[>#%$])/
            @reset_timeout_on_newlines = true
            @timeout_sec = 10
            @wait_sec = 0.01
            @quiet = false
            @received_text = ""
            @processed_text = ""
            @ssh = nil
            @channel = nil
            @eof = false
            @state = :NetDev_Init
        end

        def connect(hostname, port: 22)
            #connect to SSH target and open channel
            raise ConnectionExists if not @state == :NetDev_Init
            @port = port
            #attempt to connect using pubkey
            begin
              if @keys != []
                puts "Attempting Pubkey" if not @quiet
                @ssh = Net::SSH.start(
                    hostname,
                    @user,
                    :port => @port,
                    :keys => @keys
                )
                @state = :NetDev_Connect if @ssh
              end
            rescue Net::SSH::AuthenticationFailed
              puts "Pubkey Auth Failed"
            end
            # if @state != :NetDev_Connect and @passwd != "", attempt
            #   to connect via username/passwd
            if (@state != :NetDev_Connect) && (@passwd != "")
              puts "Attempting Password" if not @quiet
              @ssh = Net::SSH.start(
                  hostname,
                  @user,
                  :port => port,
                  :password => @passwd
              )
              @state = :NetDev_Connect if @ssh
            end
            raise UnableToConnect if (@state != :NetDev_Connect)
            @ssh.open_channel do |channel|
              channel.request_pty do |ch, success|
                if success == false
                  raise "Failed to open SSH pty: Hostname => #{hostname}:#{port}"
                end
              end
              channel.send_channel_request("shell") do |ch, success|
                if success
                  @channel = ch
                  wait_for_regex(@prompt_re)
                else
                  raise "Failed to open SSH shell: Hostname => #{hostname}:#{port}"
                end
                return false
              end
              channel.on_data do |ch, data|
                @received_text << data
              end
              channel.on_extended_data do |ch, type, data|
                @received_text << data if type == 1
              end
              channel.on_close do
                @eof = true
              end
            end
            @ssh.loop
        end

        def wait_for_prompt
            wait_for_regex @prompt_re
        end

        def wait_for_regex(expression)
            #Loop: receive and wait until a regular expression is matched in output
            channel = @channel
            start_time = Time.now
            match = false
            timeout = false
            return_text = ""
            has_newline_re = /.*\n/
            until (match or timeout)
                @ssh.process(0.1)
                #process lines if we get matches
                examine_this_text = @received_text[@processed_text.length..-1]
                # get length of examine_this_text because we have to treat last
                # line differently
                #
                # it may get more stuff added to it so we don't add it to
                # processed immediately
                numlines = examine_this_text.length
                is_last_line = false
                #iterate through lines and check for matches
                current_line = 0
                examine_this_text.lines.each do |line|
                    current_line += 1
                    #is_last_line will be true if last line has been reached
                    is_last_line = (numlines == current_line)
                    #add the line to @processed_text if not last line
                    @processed_text << line if not is_last_line
                    #print line if we're not suppressing output
                    print line unless @quiet
                    #check match
                    match = (expression === line)
                    if match
                        if is_last_line
                            @processed_text << line
                        end
                        break
                    end
                end
                #update timeout check
                timeout = ((Time.now - start_time) > @timeout_sec)
            end
            raise TimeoutError, "Timeout Waiting for Expression: #{expression}" if ((not match) and timeout)
            #remove @processed_text from @received_text
            @received_text = @received_text[@processed_text.length..-1]
            binding.pry if @received_text == nil
            #return @processed_text and set it to empty string
            return_text = @processed_text
            @processed_text = ""
            return return_text
        end

        def sendline(single_command)
            #send a single line, but do not wait for prompt
            channel = @channel
            this_line = single_command.chomp + "\n"
            #puts this_line
            @ssh.process(0.1)
            channel.send_data(this_line)
        end

        def send(textblock)
            #send a series of lines, wait for prompt after each
            channel = @channel
            return_text = ""
            textblock.lines do |line|
                sendline line
                return_text << wait_for_prompt
            end
            return return_text
        end

    end

    class UnableToConnect < Exception

    end

    class ConnectionExists < Exception

    end

    class TimeoutException < Exception

    end
end
