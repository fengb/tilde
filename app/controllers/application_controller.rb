class ApplicationController < ActionController::Base
  protect_from_forgery

  def command
    port = get_console_port

    spawn(port) if !spawned?(port)
    response = communicate(port, params[:command])
    render :text => response
  end

  private
  def port
    session[:tilde_port]
  end

  def port=(val)
    session[:tilde_port] = val
  end

  def spawned?(port)
    TCPSocket.open('localhost', port).close
    true
  rescue
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
    while line = request.gets and line !~ /^\s*$/
      if line =~ /Content-Length/
        content_length = line.match(/\d+/).to_s.to_i
      end
    end

    request.read(content_length)
  end

  def communicate(port, message)
    # @TODO
    "Hi"
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
