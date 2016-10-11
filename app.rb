require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'sidekiq'
require 'nokogiri'
require 'open-uri'
require 'byebug'

require_relative 'models/vacancy'
require_relative './helpers'

class HeadHunterWorker
  include Sidekiq::Worker

  def perform(query="ruby")
    page = Nokogiri::HTML(open("https://spb.hh.ru/search/vacancy?text=#{query}&area=2"))

    loop do
      page.xpath("//div[@class='search-result-description']").map do |div|
        vacancy_params = {  link: div.xpath(".//a[contains(@class, 'item__name')]/@href").text,
                            name: div.xpath(".//a[contains(@class, 'item__name')]").text,
                            website_id: div.xpath(".//a[contains(@class, 'item__name')]/@href").text[/\/(\d+)/, 1].to_i,
                            short_description: div.xpath("div/div[contains(@class, 'snippet')]").map(&:text).join("\n"),
                            company_link: "https://spb.hh.ru" + div.xpath(".//div[contains(@class, 'company')]/a/@href").text,
                            company_name: div.xpath(".//div[contains(@class, 'company')]/a").text }

        if salary = div.at_xpath(".//div[contains(@class, 'salary')]")
          vacancy_params = vacancy_params.merge(parse_salary(salary.text))
        end

        sleep rand(3..8)

        vacancy_page = Nokogiri::HTML(open(vacancy_params[:link]))
        vacancy_params[:description] = vacancy_page.xpath("//div[@class='b-vacancy-desc-wrapper']").text
        puts vacancy_params

        Vacancy.create_with(vacancy_params).find_or_create_by(website_id: vacancy_params[:website_id])
      end

      next_page = page.at_xpath("//div[@class='b-pager__next']/a[text()='следующая']/@href") rescue break
      page = Nokogiri::HTML(open("https://spb.hh.ru" + next_page.text))
      sleep rand(3..8)
    end
  end
end

get '/' do
  @vacancies = Vacancy.order(created_at: :desc)
  slim :index
end

get '/grab_vacancies' do
  HeadHunterWorker.perform_async
  redirect to('/')
end





