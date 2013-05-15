#!/usr/bin/env ruby

require 'rest_client'
require 'optparse'
require 'json'

LETSHIRE_ADMIN          = 'admin@local.com'
LETSHIRE_ADMIN_PASSWORD = '123456789'
TEMPFILE                = '/tmp/testdata'

class TestClient
  attr_accessor :server, :port

  def initialize(opts)
    @server = opts[:server]
    @port = opts[:port]
  end

  def run
    begin
      res = RestClient.post "#{login}", {:user => {:email => LETSHIRE_ADMIN, :password => LETSHIRE_ADMIN_PASSWORD}}
      res = JSON.parse(res)
      puts res.to_s
      token = res["session"]["auth_token"]

      res = RestClient.get "#{list_interview}", :params => {:auth_token => token}
      res = JSON.parse(res)
      puts res.to_s

      if res["interviews"].length > 0
        interview = res["interviews"][0]
        interview_id = interview["id"].to_i

        res = RestClient.post "#{upload_file}", :params => {:auth_token => token},
            :interview_id => interview_id,
            :file => File.new("#{binary_file}",'rb')
        res = JSON.parse(res)
        puts res.to_s

        res = RestClient.get "#{enum_files}", :params => {:auth_token => token, :interview_id => interview_id}
        res = JSON.parse(res)
        puts res.to_s

        photo_id = res["photos"].last
        res = RestClient.get "#{download_file}", :params => {:auth_token => token, :photo_id => photo_id}
        puts res.to_s
        #save_to_file(res.to_s)
      end

      RestClient.delete "#{logout}", :params => {:auth_token => token}

      File.delete(TEMPFILE) if File.exists?(TEMPFILE)
    rescue => e
      puts "#{e}"
    end
  end

private
  def binary_file
    fp = File.open(TEMPFILE, 'wb')
    fp.write("\xCC" * 256)
    fp.close

    TEMPFILE
  end

  def save_to_file(s)
    File.open(TEMPFILE, 'wb') do |fp|
      fp.write(s)
    end
  end

  def login
    "http://#{@server}:#{@port}/api/v1/login"
  end

  def logout
    "http://#{@server}:#{@port}/api/v1/logout"
  end

  def list_interview
    "http://#{@server}:#{@port}/api/v1/interviews"
  end

  def upload_file
    "http://#{@server}:#{@port}/api/v1/photo/upload"
  end

  def enum_files
    "http://#{@server}:#{@port}/api/v1/photo/enum"
  end

  def download_file
    "http://#{@server}:#{@port}/api/v1/photo/download"
  end
end

options = {}

optparse = OptionParser.new do |opts|
  opts.on('-h', '--help', 'Show this help info') do
    puts opts
    exit
  end

  opts.on('-s', '--server', 'http server host or ip address') do |arg|
    options[:server] = arg
  end

  opts.on('-p', '--port', 'http server listen port') do |arg|
    options[:port] = arg
  end
end

optparse.parse!

options[:server] = '127.0.0.1' if options[:server].nil?
options[:port] = '3000' if options[:port].nil?

TestClient.new(options).run
