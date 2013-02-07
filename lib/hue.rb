require 'httparty'
require 'digest/md5'
require 'json'

def debug(str)
  puts "DEBUG: #{str}"
end

class PhilipsHueError < RuntimeError ; end

module Colours
  class Attrs
    attr_reader :hash

    def initialize(hash={})
      @hash = hash
    end

    def + (other)
      if other.kind_of?(Attrs)
        other_hash = other.hash
      else
        other_hash = other
      end

      Attrs.new(hash.merge(other_hash))
    end
  end

  BASE = Attrs.new({
      on: true,
      bri: 1
    })

  OFF = BASE + {
      on: false
  }

  BRIGHT = BASE + {bri: 100}

  FLICKERING = BASE + {alert: 'lselect'}

  FLASH = BASE + {alert: 'select'}

  RED = BASE + {
    xy: [0.6405, 0.3302],
    ct: 500
  }

  GREEN = BASE + {
    hue: 25480,
    sat: 254
  }

  BLUE = BASE + {
    xy: [0.2096, 0.1238],
    ct: 500
  }
end

class App
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def hash
    Digest::MD5.hexdigest(@name)
  end

  def connect_to!(bridge)
    @bridge = bridge
    @bridge.register!(self)
    puts "App #{@name}/#{hash} connected to #{@bridge.ip}"
    debug(info)
  end

  def info
    @bridge.app_info(self)
  end

  def change_colours!(lamp, colour_settings)
    @bridge.change_state!(self, lamp, colour_settings.hash)
  end
end

class Bridge
  attr_reader :ip

  def initialize(ip)
    @ip = ip
  end

  def register!(app)
    response = POST(api_url, {username: app.hash, devicetype: app.name}).first
    raise PhilipsHueError.new("Unexpected response #{response.inspect}") unless response['success']['username'] == app.hash
  end

  def app_info(app)
    GET("#{app_api_url(app)}")
  end

  def change_state!(app, lamp, state)
    PUT("#{app_api_url(app)}/lights/#{lamp}/state", state)
  end

  private
  def not_expecting_an_error(&block)
    response = JSON.parse(block.call.body)
    if response.kind_of?(Array) and response.first['error']
      raise PhilipsHueError.new("Error talking to bridge: #{response.first['error']}")
    end

    response
  end

  def PUT(url, payload_hash)
    debug("PUT #{url} #{payload_hash}")
    not_expecting_an_error do
      HTTParty.put(url, {body: payload_hash.to_json})
    end
  end

  def GET(url)
    debug("GET #{url}")
    not_expecting_an_error do
      HTTParty.get(url)
    end
  end

  def POST(url, payload_hash={})
    debug("POST #{url} #{payload_hash}")
    not_expecting_an_error do
      HTTParty.post(url, {body: payload_hash.to_json})
    end
  end

  def app_api_url(app)
    "#{api_url}/#{app.hash}"
  end

  def api_url
    "http://#{@ip}/api"
  end
end

app = App.new("test")
bridge = Bridge.new("10.23.69.143")

#app.connect_to!(bridge)
#app.change_colours!(1, BRIGHT_RED)
