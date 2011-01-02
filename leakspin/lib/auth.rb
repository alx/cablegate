get '/login/?' do
  erb_template 'session/login'
end

post '/login/?' do
  authenticate_user!
  redirect "/dashboard"
end

post '/unauthenticated/?' do
  flash[:notice] = "That username and password are not correct!"
  status 401
  erb_template 'session/login'
end

get '/logout/?' do
  logout_user!
  redirect '/session/login'
end