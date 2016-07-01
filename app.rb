ENV['RACK_ENV'] ||= "development"

require 'sinatra/base'
require 'sinatra/flash'
require 'json'

require_relative 'data_mapper_setup'

class MakersBnB < Sinatra::Base

  register Sinatra::Flash
  enable :sessions
  set :session_secret, 'super secret'

  get '/' do
    redirect '/spaces' if current_user
    redirect '/users/new'
  end

  get '/users/new' do
    @user = User.new
    erb :'users/new'
  end

  post '/users' do
    @user = User.new(params)
    if @user.save
      session[:user_id] = @user.id
      redirect '/spaces'
    else
      flash.now[:errors] = @user.errors.full_messages
      erb :'users/new'
    end
  end

  get '/sessions/new' do
    erb :'sessions/new'
  end

  post '/sessions' do
    user = User.authenticate(params[:email], params[:password])
    if user
      session[:user_id] = user.id
      redirect '/spaces'
    else
      flash.keep[:notice] = "Incorrect log in details. Please try again."
      redirect '/sessions/new'
    end
  end

  get '/sessions/end' do
    session.clear
    redirect '/'
  end

  helpers do
    def current_user
      @current_user ||= User.get(session[:user_id])
    end
  end

  get '/spaces' do
    @spaces = Space.all
    erb :'spaces/list'
  end

  get '/spaces/new' do
    redirect '/' unless current_user
    erb :'spaces/new'
  end

  post '/spaces' do
    space = Space.new(params)
    space.user_id = current_user.id
    if space.save
      redirect '/spaces'
    else
      flash.keep[:errors] = space.errors.full_messages
      redirect '/spaces/new'
    end
  end

  get '/spaces/details/:id' do
    @current_space = Space.first(id: params[:id])
    erb :'spaces/details'
  end

  post '/requests' do
    @booking_request = Request.new(check_in_date: params[:check_in_date])
    @booking_request.user_id = current_user.id
    @booking_request.space_id = params[:space_id]
    if @booking_request.save
      redirect '/requests'
    else
      flash.keep[:errors] = @booking_request.errors.full_messages
      redirect "/spaces/details/#{@booking_request.space_id}"
    end
  end

  get '/requests' do
    @requests_made = Request.all(user_id: current_user.id)
    @owned_space = current_user.spaces
    @requests_received = @owned_space.map do |space|
      space.requests
    end
    @requests_received.flatten!
    erb :'requests/requests'
  end

  get '/requests/review/:request_id' do
    @request_review = Request.get(params[:request_id])
    @space = Space.get(@request_review.space_id)

    if (@space.user_id != current_user.id)
      flash.next[:notice] = "You don't have permission to review the request"
      redirect '/requests'
    end
    @requester = User.get(@request_review.user_id)
    erb :'requests/review'
  end

  post '/requests/confirm' do
    @request_to_confirm = Request.get(params[:request_id])
    @request_to_confirm.confirmed = true
    if @request_to_confirm.save
      redirect '/requests'
    else
      flash.keep[:errors] = @request_to_confirm.errors.full_messages
      redirect '/requests'
    end
  end

  run! if app_file == $0
end
