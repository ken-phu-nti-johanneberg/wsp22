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
# Ska visa olika beroende på om användaren är inloggad eller inte
    slim(:profile)
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
        db.execute("INSERT INTO users (Username, Password) VALUES (?,?)", username, password_digest)
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
    result = db.execute("SELECT * FROM users WHERE Username =?", username).first
    # Vad ska stå innanför result
    password_digest = result["Password"]
    id = result["UserID"]
    if BCrypt::Password.new(password_digest) == password
        session[:id] = id 
        redirect('/profile')
    else
        'Wrong password'
    end
end

# Character_list
get('/characters/index') do
    slim(:"/characters/index")
end

# New character
get('/characters/new') do
    slim(:"characters/new")
end

post('/characters/new') do
# Ta in data från formulär från slim
# Lägg till i data bas
# INSERT användaren id också
    name = params[:char_name]
    db = SQLite3::Database.new("db/ryuutama.db")
    db.execute("INSERT INTO character_list (Name) VALUES (?)", name)
    redirect('/characters')
end
# Edit character
# Ta in data från formulär från slim
# Lägg till i data bas

# Visa karaktär
# Typ visa edit sidan utan att kunna ändra på saker