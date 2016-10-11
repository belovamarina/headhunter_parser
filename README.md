# headhunter_parser
Parse spb.headhunter with sinatra, nokogiri and sidekiq, grab ruby vacancies

To install gems:
- `bundle install`

Start sinatra
- `bundle exec ruby app.rb`

Start sidekiq
- `bundle exec sidekiq -r './app.rb'`
