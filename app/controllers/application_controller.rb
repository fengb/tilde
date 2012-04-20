class ApplicationController < ActionController::Base
  protect_from_forgery

  def command
    # TODO: implement me
    spawned = false
    port = get_console_port

    spawn(port) if !spawned
    response = communicate(port)
    render :text => response
  end

  private
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

          conn.print("Good response: #{response.inspect}\n")
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

  def communicate(port)
    # TODO: implement me
    "Hi"
  end

  def get_console_port(name = nil)
    $stderr.print session[:tilde]
    session[:tilde] ||= {}
    session[:tilde][:consoles] ||= {}

    unless session[:tilde][:consoles][name]
      session[:tilde][:consoles][name] = (3000+rand(1000))
    end
    session[:tilde][:consoles][name]
  end

end
