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
    `pkill #{$$}`
    render :text => 'Success!'
  end

  private
  def port
    session[:tilde_ports] ||= {}
    session[:tilde_ports][console] ||= (3000+rand(1000))
  end

  # todo multiple consoles
  def console
    nil
  end

  def spawned?
    TCPSocket.open('localhost', port).close
    true
  rescue Errno::ECONNREFUSED => e
    # No server there!
    false
  end

  def spawn(port)
    $stderr.puts "Spawning child on 127.0.0.1:#{port}"

    fork do
      server = TCPServer.new('127.0.0.1', port)
      context = binding
      while conn = server.accept
        begin
          # eval must occur in here for local vars to remain in scope
          payload = conn.read

          $stderr = StringIO.new
          $stdout = StringIO.new
          ret = eval(payload, context)
          $stderr.close
          $stdout.close

          conn.print $stderr.string
          conn.print $stdout.string
          conn.print "=> #{ret.inspect}"
        rescue StandardError, ScriptError => e
          conn.puts "#{e.class}: #{e.message}"
          e.backtrace.each do |line|
            conn.puts "\t" << line
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
