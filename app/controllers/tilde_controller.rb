class TildeController < ApplicationController
  READ_MAX = 4096

  def command
    if request.post?
      if !spawned?
        spawn(port)
        sleep(1) # Wait for fork to catch up...
      end
      @response = communicate(port, params[:command])
      @command = params[:command]
    end
  end

  private
  def port
    session[:tilde_port] ||= (3000+rand(1000))
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
          payload = conn.read_nonblock(READ_MAX)

          $stderr = StringIO.new
          $stdout = StringIO.new
          ret = eval(payload, context)
          $stderr.close
          $stdout.close

          conn.print $stderr.string
          conn.print $stdout.string
          conn.print "=> #{ret.inspect}"
        rescue => e
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
      socket.read
    end
  end
end
