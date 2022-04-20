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
    # Hämta information från databasen
    # Använd sedan informationen för att skapa en array och loopa arrayen för varje option
    slim(:"characters/new")
end

post('/characters') do
# Ta in data från formulär från slim
# Lägg till i data bas
# INSERT användaren id också
    id = session[:id].to_i
    name = params[:char_name]
    class_id = params[:class_id]
    type_id = params[:type_id]
    as_id = params[:ability_score_id]
    mw_id = params[:mastered_weapon_id]
    db = SQLite3::Database.new("db/ryuutama.db")
    db.execute("INSERT INTO characters (name, user_id, class_id, type_id, ability_score_id, mastered_weapon_id) VALUES (?,?,?,?,?,?)", name, id, class_id, type_id, as_id, mw_id)
    redirect('/characters')
end

# Edit character
# get...
# Ta in data från formulär från slim
# Lägg till i data bas

# Visa karaktär
# Typ visa edit sidan utan att kunna ändra på saker