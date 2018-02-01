require_relative 'crawler'

class HeadHunter < Crawler
  DOMAIN = 'https://hh.ru/'.freeze

  def parse
    visit "https://hh.ru/search/vacancy?text=#{query}&area=1"
    vacancies_links.each do |link|
      request(url: absolute_url(link[:href]), method: :parse_vacancy, data: { short_description: short_desc(link) })
    end
  end

  def parse_vacancy(data)
    data.each { |key, value| field key, value }

    field :name, body.xpath("//h1[@class='header']").text.strip
    field :description, body.xpath("//div[@class='b-vacancy-desc-wrapper']/*[text()]").text.strip
    field :company_name, body.xpath("//a[@class='vacancy-company-name']").text.strip
    field :company_link, absolute_url(body.xpath("//a[@class='vacancy-company-name']/@href").text)
    field :currency, body.xpath("(//meta[@itemprop='salaryCurrency']/@content)[1]").text
    field :salary_from, body.xpath("(//meta[@itemprop='baseSalary']/@content)[1]").text
    field :website_id, body.xpath("(//meta[@itemprop='url']/@content)[1]").text[/\d+/]

    save_fields!
  end

  private

  def vacancies_links
    body.xpath("//div[@class='vacancy-serp-item__title']/a")
  end

  def short_desc(node)
    node.xpath("following::div[@data-qa='vacancy-serp__vacancy_snippet_responsibility'][1]").text.strip
  end
end
