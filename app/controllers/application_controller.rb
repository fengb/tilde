class ApplicationController < ActionController::Base
  protect_from_forgery

  def command
    if request.post?
      if !spawned?
        self.port = 3001
        spawn(port)
        sleep(1) # Wait for fork to catch up...
      end
      @response = communicate(port, params[:command])
    end
  end

  private
  def port
    session[:tilde_port]
  end

  def port=(val)
    session[:tilde_port] = val
  end

  def spawned?
    return port if port.nil?

    require 'securerandom'
    check = SecureRandom.base64
    response = communicate(port, "puts \"#{check}\"")
    response.strip == check.strip
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
          payload = get_request_body(conn)
          $stderr.puts payload
          response = eval(payload, context)

          conn.print("Response: #{response}")
        rescue => e
          conn.print ("Exception Encountered:\n")
          conn.print e.message
        ensure
          conn.close
        end
      end
    end
  end

  def get_request_body request
    request.gets
  end

  def readall(fileio)
    all = []
    while line = fileio.gets
      all << line
    end
    all.join('')
  end

  def communicate(port, message)
    s = TCPSocket.open '127.0.0.1', port
    s.puts command

    readall(s)
  end

  def get_console_port(name = nil)
    session[:tilde] ||= {}
    session[:tilde][:consoles] ||= {}

    unless session[:tilde][:consoles][name]
      session[:tilde][:consoles][name] = (3000+rand(1000))
    end
    session[:tilde][:consoles][name]
  end

end
