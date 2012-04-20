class ApplicationController < ActionController::Base
  protect_from_forgery

  def command
    if request.post?
      if !spawned?
        spawn(port)
        sleep(1) # Wait for fork to catch up...
      end
      @response = communicate(port, params[:command])
    end
  end

  private
  def port
    session[:tilde_port] ||= (3000+rand(1000))
  end

  def spawned?
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
          conn.puts "\t" + e.backtrace.join("\n\t")
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
    s.puts message

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
