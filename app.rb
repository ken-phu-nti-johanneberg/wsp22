require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/') do
    slim(:start)
end

get('/profile') do 
# Ska visa olika beroende på om användaren är inloggad eller inte
    slim(:profile)
end

get('/register') do
    slim(:register)
end

get('/showlogin') do
    slim(:login)
end

post('/login') do
# Logga in
    redirect(:profile)
end

post('/user') do 
# spara lösenord
    redirect(:login)
end