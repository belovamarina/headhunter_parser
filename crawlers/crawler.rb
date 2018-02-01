require 'open-uri'
require 'nokogiri'
require 'addressable/uri'

class Crawler
  attr_accessor :body, :fields
  attr_reader :query

  def initialize(query)
    @fields = {}
    @query = Addressable::URI.escape(query)
  end

  # Modify relative URL to absolute.
  def absolute_url(href)
    Addressable::URI.join(self.class::DOMAIN, href).to_s
  end

  # Open URL via open-uri and parse response with Nokogiri
  def visit(url)
    url = absolute_url(url)
    puts "Visiting: #{url}"
    @body = Nokogiri::HTML(open(url))
  end

  def request(url:, method:, data: {})
    visit(url)
    sleep(rand(1..4))
    self.send(method, data)

  rescue StandardError => e
    puts "ERROR #{e.class}\n#{e.message}\n#{e.backtrace}"
  end

  def field(name, value)
    fields[name] = value unless value.empty?
  end

  def save_fields!
    save_vacancies
    fields.clear
  end

  private

  def save_vacancies
    puts "Saving...#{fields.inspect}"
    Vacancy.create_with(fields).find_or_create_by(website_id: fields[:website_id])
  end
end
