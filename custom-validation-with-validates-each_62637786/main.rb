#!/usr/bin/env ruby
# frozen_string_literal: true

require 'active_support'
require 'active_model'
require 'appmap'

class Person
  include ActiveModel::Validations

  attr_accessor :gender, :title

  def self.parse_persons
   JSON.parse(File.read('rules.json')).deep_symbolize_keys
  end

  def self.all_funders(attribute)
   @all_persons ||= parse_persons[attribute.to_sym][:options]
  end

  validates_each :gender, :title do |record, attr, value|
   record.errors.add(attr, "Error message") if !all_funders(attr).include?(value)
  end

  def to_s
    { gender: gender, title: title }.compact.to_s
  end
end

FileUtils.mkdir_p 'tmp'
appmap = AppMap.record do
  person = Person.new.tap do |p|
    p.gender = 'Male'
    p.title = 'Mr'
  end
  puts "#{person} is not valid" unless person.valid?
end

File.write('tmp/appmap.json', JSON.generate(appmap))
