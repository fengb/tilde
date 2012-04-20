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
      while conn = server.accept
        begin
          # eval must occur in here for local vars to remain in scope
          payload = conn.read

          $stderr = StringIO.new
          $stdout = StringIO.new
          result = eval(payload, context)
          $stderr.close
          $stdout.close

          conn.print "Creating console on :#{port}\n" if first_run
          conn.print $stderr.string
          conn.print $stdout.string
          conn.print "=> #{result.inspect}"

          first_run = false
        rescue StandardError, ScriptError => e
          conn.puts "#{e.class}: #{e.message}"
          e.backtrace.each do |line|
            conn.puts "\t" << line

            # Rest of stacktrace lives beyond the eval line so we ignore them
            break if line =~ /#{__FILE__.gsub('.', '\.').gsub('/', '\/')}.*eval/
          end
        ensure
          conn.close
        end
      end
    end
  end

  def communicate(port, message)
    TCPSocket.open '127.0.0.1', port do |socket|
      socket.puts message
      socket.close_write
      socket.read
    end
  end
end
