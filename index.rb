require 'sinatra'
require 'flickraw'
require 'soundcloud'
require 'sass/plugin/rack'

use Sass::Plugin::Rack

configure :production do
  use Rack::Static,
      urls: ['/stylesheets'],
      root: File.expand_path('../tmp', __FILE__)

  Sass::Plugin.options.merge!(template_location: 'public/stylesheets/sass',
                              css_location: 'tmp/stylesheets')
end

helpers do
  def getImg
    FlickRaw.api_key = "6eb9a6f841c27d55450db8f96a5411ef"
    FlickRaw.shared_secret = "387d8e8c2d3f27b2"
    list = flickr.interestingness.getList :per_page => 20
    img = list.to_a.sample
    FlickRaw.url_c(flickr.photos.getInfo(:photo_id => img.id))
  end

  def getTracks(param)
    client = Soundcloud.new(:client_id => '458a1bb842e789de43032495610e5ece')
    @tracks = client.get('/tracks', :genres => param, :limit => 60).sample(20)
  end
end

get '/' do
  @title = "Ready to shuffle"
  erb :index, :locals => {:img => getImg, :query => 'test'}
end

post '/' do
  temp = '/'+params[:search].gsub(" ", "%20")
  redirect to(temp), 303
end

get '/style.css' do
  scss :style
end

get '/:search' do
  @title = "Shuffling "+ params[:search]+" mix" 
  getTracks(params[:search])
  erb :mix, :locals => {:img => getImg, :query => params[:search]}
end

not_found do
  @title = "Not found:"
  erb :"404"
end