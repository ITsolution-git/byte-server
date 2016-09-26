Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user == ENV['resque_user']
  password == ENV['resque_password']
end
