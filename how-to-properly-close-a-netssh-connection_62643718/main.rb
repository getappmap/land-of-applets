#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'appmap'
require 'json'
require 'net/ssh'
require 'pry'

port = `docker-compose port ssh-server 22`.strip.split(':').last
puts "Connecting to localhost on #{port}"

# binding.pry

demo = lambda do
  Net::SSH.start('localhost', 'test', port: port) do |ssh|
    ssh.exec! 'touch /tmp/file'
    puts "Hostname is: #{ssh.exec!('hostname')}"

    ssh.open_channel do |ch|
      ch.exec "sudo -p 'sudo password: ' ls" do |ch, success|
        abort 'could not execute sudo ls' unless success

        ch.on_data do |ch, data|
          print data
          if data =~ /sudo password: /
            ch.send_data("password\n")
          end
        end
      end
    end

    ssh.loop
  end
end

FileUtils.mkdir_p 'tmp'
appmap = AppMap.record do
  demo.call
end

File.write('tmp/appmap.json', JSON.generate(appmap))
