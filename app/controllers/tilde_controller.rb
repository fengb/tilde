class TildeController < ApplicationController
  def command
    if request.post?
      # fork and wait for it to catch up
      (spawn(port) and sleep(1)) unless spawned?

      @response = communicate(port, params[:command])
      @command = params[:command]
      render :json => { "response" => @response }
    end
  end

  # TODO: remove once zombie process are properly removed
  def flush
    `pkill -P #{$$}`
    render :text => 'Success!'
  end

  private
  def port_used?(port)
    TCPSocket.open('localhost', port).close
    true
  rescue Errno::ECONNREFUSED => e
    # No server there!
    false
  end

  def reload_session
    session = ActiveRecord::SessionStore::Session.last
  end

  def port
    if session[:tilde_port].nil?
      begin
        session[:tilde_port] = (3000+rand(1000))
      end while port_used?(session[:tilde_port])
    end
    session[:tilde_port]
  end

  def ports
    (ConvenienceStore[:ports] ||= Set.new)
  end

  def spawned?
    port_used?(port)
  end

  def spawn(port)
    ports.add(port)

    fork do
      first_run = true
      server = TCPServer.new('127.0.0.1', port)
      context = binding
      real_stderr = $stderr
      real_stdout = $stdout

      while conn = server.accept
        $stderr = StringIO.new
        $stdout = StringIO.new

        # eval must occur in here for local vars to remain in scope
        begin
          conn.print "Creating console on :#{port}\n" if first_run
          first_run = false

          payload = conn.read

          out = begin
                  result = eval(payload, context)
                  "=> #{result.inspect}"
                rescue StandardError, ScriptError => e
                  lines = ["#{e.class}: #{e.message}"]
                  lines.concat(filter_backtrace(e.backtrace))
                  lines.join("\n\tfrom ")
                end

          conn.print $stderr.string
          conn.print $stdout.string
          conn.print out
        ensure
          $stderr.close
          $stdout.close
          $stderr = real_stderr
          $stdout = real_stdout
          conn.close
        end
      end
    end
  end

  # Remove the pieces beyond the eval line
  def filter_backtrace(backtrace)
    target = backtrace.find_index{|line| line =~ /#{__FILE__.gsub('.', '\.').gsub('/', '\/')}.*eval/ }
    target ? backtrace[0..target] : backtrace
  end

  def communicate(port, message)
    TCPSocket.open '127.0.0.1', port do |socket|
      socket.puts message
      socket.close_write
      socket.read
    end
  end
end
