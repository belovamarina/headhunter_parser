require './crawlers/head_hunter.rb'

class HeadHunterWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, queue: 'default'

  def perform
    HeadHunter.new(query='ruby').parse
  end
end
