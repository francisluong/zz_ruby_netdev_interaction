require "net/ssh"
require 'timeout'
require "pry"
require 'logger'

module NetDev
  class SSH
    attr_accessor :prompt_re, :quiet, :timeout_sec

    def initialize(user: "", passwd: "", keys: [], disable_pubkey_auth: false)
      #constructor, does not connect to host
      @auth_methods = ['none', 'pubkey', 'password']
      @channel = nil
      @eof = false
      @log = Logger.new(STDOUT)
      @passwd = passwd
      @prompt_re = /^([@a-zA-Z0-9\.\-\_\:]*[>#%$])/
      @processed_text = ""
      @quiet = false
      @received_text = ""
      @reset_timeout_on_newlines = true
      @ssh = nil
      @state = :NetDev_Init
      @timeout_sec = 10
      @user = user
      @wait_sec = 0.01
      ["~/.ssh/id_rsa", "~/.ssh/id_dsa"].each do |keyfilepath|
        @keys ||= []
        keyfilepath = File.expand_path(keyfilepath)
        keys << keyfilepath if File.file?(keyfilepath)
      end
      @disable_pubkey_auth = disable_pubkey_auth
    end

    def connect(hostname, port: 22)
      #connect to SSH target and open channel
      raise ConnectionExists if not @state == :NetDev_Init
      @port = port
      @auth_methods.delete('pubkey') if (@disable_pubkey_auth || @keys.empty?)
      @ssh = Net::SSH.start(
        hostname,
        @user,
        :password => @passwd,
        :port => @port,
        # :auth_methods => @auth_methods,
        # :logger => @log
      )
      @state = :NetDev_Connect if @ssh
      raise UnableToConnect unless @state == :NetDev_Connect
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
      match = false
      Timeout::timeout(@timeout_sec,TimeoutException) do
        until (match )
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
        end
      end
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

    def send_wait(regex,single_command)
      sendline(single_command)
      wait_for_regex(regex)
    end

    def send(textblock)
      #send a series of lines, wait for prompt after each
      return_text = ""
      textblock.lines do |line|
        sendline line
        return_text << wait_for_prompt
      end
      return return_text
    end

    class UnableToConnect < Exception

    end

    class ConnectionExists < Exception

    end

    class TimeoutException < Exception

    end
  end

end
