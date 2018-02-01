require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'sidekiq'
require 'will_paginate'
require 'will_paginate/active_record'
require_relative 'models/vacancy'
require_relative 'workers/head_hunter_worker'

register WillPaginate::Sinatra

get '/' do
  @vacancies = Vacancy.paginate(page: params[:page], per_page: 10).order('id DESC')
  slim :index
end

get '/grab_vacancies' do
  HeadHunterWorker.perform_async
  redirect to('/')
end
