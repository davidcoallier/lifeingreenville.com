# Get ready to kick ass.
require 'sinatra'
require 'sass'
require 'compass'
require 'rdiscount'
require "sinatra/reloader" if development?

require './models/article'

configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config', 'compass.config'))
end

configure :production do
  # require 'newrelic_rpm'
end

before do
  set :ignore_header, false
end

get '/' do
  set :ignore_header, true
  erb :index
end

get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"stylesheets/#{params[:name]}", Compass.sass_engine_options )
end

get '/visit' do
  content_type 'text/html', :charset => 'utf-8'
  erb :visit, :layout => false
end

get '/:category' do
  content_type 'text/html', :charset => 'utf-8'
  articles = Article.find_all(params[:category])
  if articles.any?
    markdown '',
      :layout => :secondary, :layout_engine => :erb,
      :locals => { :articles => articles }
  else
    raise Sinatra::NotFound
  end
end

get '/:category/:name' do
  content_type 'text/html', :charset => 'utf-8'
  article = Article.find(params[:category], params[:name])
  if article
    markdown article.body,
      :layout => :tertiary, :layout_engine => :erb,
      :locals => { :article => article }
  else
    raise Sinatra::NotFound
  end
end

not_found do
  '404 Error, oops!'
end

error do
  '500 Error, ugh'
end

helpers do
  
  def render_aside
    if File.exist?("views/asides/#{params[:category]}/#{params[:name]}.md")
      html = '<aside class="row span4">'
      html << markdown("asides/#{params[:category]}/#{params[:name]}".to_sym)
      html << '</aside>'
    end
  end
  
end
