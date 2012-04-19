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
      loop do
        repl
      end
    end
  end

  def communicate(port)
    # TODO: implement me
    "Hi"
  end

  def repl
    # TODO: implement me
    $stderr.puts "I'm alive!"
    sleep 10
  end
end
