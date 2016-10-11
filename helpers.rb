require 'nokogiri'
require 'open-uri'

def parse_salary(salary)
  if salary =~ /rub|руб/i
    currency = "RUB"
  elsif salary =~ /usd|\$/i
    currency = "USD"
  else
    currency = nil
  end

  salary_from, salary_to = salary.split("-")

  { currency: currency,
    salary_from: salary_from&.gsub(/[\D]/, ""),
    salary_to: salary_to&.gsub(/[\D]/, "") }
end

def parse_headhunter(key_word)
  page = Nokogiri::HTML(open("https://spb.hh.ru/search/vacancy?text=#{key_word}&area=2"))

  page.xpath("//div[@class='search-result-description']").each do |div|
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
end
