#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'appmap'
require 'diffy'
require 'net/http'
require 'httparty'
require 'rack'
require 'rack/lobster'
require 'pry'

# AppMap.hook Net::HTTP

# https://github.com/rwdaigle/echo-server/blob/master/echo_server.rb
class EchoServer
  def initialize(options = {})
  end

  def call(env)
    headers = env.inject({}) do |values, header|
      k, v = header
      values[k.sub(/^HTTP_/, '')] = v if k.start_with? 'HTTP_' and k != 'HTTP_VERSION'
      values
    end

    body = headers.collect { |k, v| "#{k}: #{v}" }.join("\r\n")
    body = "#{body}\r\n\r\n#{env['rack.input'].read}"

    [200, headers, [body]]
  end
end

server_thread = Thread.new do
  Rack::Server.start(
    app: Rack::ShowExceptions.new(Rack::Lint.new(EchoServer.new)), Port: 9292
  )
end

sleep 1

demo = lambda do
  uri = URI('http://localhost:9292')
  net_http_response = Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Post.new(uri)
    form_data = [
      ['attachments[]', File.open('file1.txt')],
      ['attachments[]', File.open('file2.rb')]
    ]
    request.set_form form_data, 'multipart/form-data'
    response = http.request(request)
    response.body
  end

  body = { attachments: [File.open('file1.txt'), File.open('file2.rb')] }
  http_party_response = HTTParty.post(uri, body: body)

  puts Diffy::Diff.new(net_http_response, http_party_response)
end

appmap = \
  begin
    AppMap.record do
      demo.call
    end
  ensure
    server_thread.kill
  end

FileUtils.mkdir_p 'tmp'
File.write('tmp/appmap.json', JSON.generate(appmap))
