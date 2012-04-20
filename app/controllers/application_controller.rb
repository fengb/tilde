class ApplicationController < ActionController::Base
  protect_from_forgery

  def command
    # TODO: implement me
    spawned = false
    port = 3001

    if !spawned
      spawn(port)
    end
    response = communicate(port)
    render :text => response
  end

  private
  def spawn(port)
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

end
