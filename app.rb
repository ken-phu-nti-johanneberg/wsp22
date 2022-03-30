require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions
# Skapa sessions med id, användaren inloggad
# Stora eller små bokstäver i databasen???

# Start
get('/') do
    slim(:start)
end

# Profil
get('/profile') do 
# Ska visa olika beroende på om användaren är inloggad eller inte¨
    id = session[:id].to_i
    db = SQLite3::Database.new('db/ryuutama.db')
    db.results_as_hash = true
    result = db.execute("SELECT username FROM users WHERE user_id = ?", id)
    slim(:profile, locals:{result:result})
end




# Registering sida
get('/register') do
    slim(:register)
end

# Skapa konto, skapas id automatisk?
post('/user') do 
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    if (password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new("db/ryuutama.db")
        db.execute("INSERT INTO users (username, password) VALUES (?,?)", username, password_digest)
        redirect('/showlogin')
    else
        "Password does not match"
    end
end

# Login sida, (kan göra så att man två routes med '/login' men en med get och en med post)
get('/showlogin') do
    slim(:login)
end

# Logga in
post('/login') do
    username = params[:username]
    password = params[:password]
    # Hämta lösenord och id för username
    db = SQLite3::Database.new("db/ryuutama.db")
    # Vad gör .first???
    # Vad gör db.result_as_hash = true
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?", username).first
    # Vad ska stå innanför result
    password_digest = result["password"]
    id = result["user_id"]
    if BCrypt::Password.new(password_digest) == password
        session[:id] = id
        redirect('/profile')
    else
        'Wrong password'
    end
end

# Character_list
get('/characters') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/ryuutama.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM character_list WHERE user_id = ?", id)
    slim(:"characters/index", locals:{result:result})
end

# New character
get('/characters/new') do
    slim(:"characters/new")
end

post('/characters') do
# Ta in data från formulär från slim
# Lägg till i data bas
# INSERT användaren id också
    id = session[:id].to_i
    name = params[:char_name]
    db = SQLite3::Database.new("db/ryuutama.db")
    db.execute("INSERT INTO character_list (name, user_id) VALUES (?,?)", name, id)
    redirect('/characters')
end

# Edit character
# get...
# Ta in data från formulär från slim
# Lägg till i data bas

# Visa karaktär
# Typ visa edit sidan utan att kunna ändra på saker