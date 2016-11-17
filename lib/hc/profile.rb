require "rest-client"
require "uri"
require "shellwords"
require "json"
require "yaml"
require "readline"

module Hc
  class Profile
    def initialize(config)
      @config  = config
      @name    = @config["name"]

      use(@config["default_env"])

      @response = nil
    end

    def self.open(path)
      new YAML.load(File.read(path)).to_h
    end

    attr_reader :name
    attr_reader :env

    def prompt
      "#{name}:#{env}> "
    end

    def start!
      loop do
        input = Readline.readline(prompt, true).strip
        run(input)
      end
    end

    def use(env)
      @env     = env
      @profile = @config["environments"][@env]
    end

    def get(args)
      resource = RestClient::Resource.new(url, user: user)
      path = args.shift
      data = args.any? ? Hash[args.map { |a| a.split(?=, 2) }] : {}
      resource[path].get(data) do |res|
        JSON.parse(res)
      end
    end

    def post(args)
      resource = RestClient::Resource.new(url, user: user)
      path = args.shift
      data = args.any? ? Hash[args.map { |a| a.split(?=, 2) }] : {}
      resource[path].post(data) do |res|
        JSON.parse(res)
      end
    end

    def patch(args)
      resource = RestClient::Resource.new(url, user: user)
      path = args.shift
      data = args.any? ? Hash[args.map { |a| a.split(?=, 2) }] : {}
      resource[path].patch do |res|
        JSON.parse(res)
      end
    end

    def delete(args)
      resource = RestClient::Resource.new(url, user: user)
      path = args.shift
      data = args.any? ? Hash[args.map { |a| a.split(?=, 2) }] : {}
      resource[path].patch do |res|
        JSON.parse(res)
      end
    end

    def run(input)
      args    = (input % store).shellsplit
      command = args.shift

      case command
      when "use"
        use(args.first)
      when "get"
        @response = get(args)
        body = JSON.pretty_generate(@response) << "\n"
        puts body
      when "post"
        @response = post(args)
        body = JSON.pretty_generate(@response) << "\n"
        puts body
      when "patch"
        @response = patch(args)
        body = JSON.pretty_generate(@response) << "\n"
        puts body
      when "delete"
        @response = delete(args)
        body = JSON.pretty_generate(@response) << "\n"
        puts body
      when "store"
        store[args[0].to_sym] = @response[args[1]]
      when "fetch"
        puts store[args[0].to_sym].inspect
      when "play"
        play(args.first)
      when "plays"
        puts plays.keys
      when "exit"
        raise Interrupt
      else
        puts "error: unknown command (#{command})"
      end
    rescue => e
      puts "error: #{e.message}"
    end

    def play(play_name)
      title = play_name.split("_").map(&:capitalize).join(" ")
      play  = plays[play_name]

      puts

      play.each_with_index do |input, index|
        puts "===[#{title}: #{index + 1}/#{play.count}]=".ljust(80, "=")
        puts
        puts [prompt, input].join("")
        run(input)
        puts
      end

      puts "===[#{title}: Ended]=".ljust(80, "=")
      puts
    end

    def plays
      @config["plays"]
    end

    def store
      @config["store"]
    end

    def url
      @profile["url"]
    end

    def user
      @profile["user"]
    end
  end
end
