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
      while connection = server.accept
        $stderr.puts "Accepted"
        response = execute([connection.gets, connection.gets, connection.gets].join("\n"))
        connection.print(response)
        connection.close
      end
    end
  end

  def communicate(port)
    # TODO: implement me
    "Hi"
  end

  def execute(body)
    # TODO: implement me
    body
  end
end
