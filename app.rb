# MVC (MODEL, VIEW, CONTROLLER) - dela upp app.rb i hjälpfunktioner som hanterar databas kommunikation
# Yardoc - dokumentation
# Inner join - classname, ability_score, mastered_weapon_id, - borde vara klar
# Säkerhet - login cooldown
# Validering, before-block och andra saker - ska inte kunna skapa karaktärer om man inte är inloggad helst inte kunna nå karaktär sidan om man inte är inloggad.
# Ändra på redirect() till '/error' vid varje validering
# CRUD - Lägg till val och magic när man skapar karaktärer, 
# Felhantering - skriv till felmeddelanden vid fel lösen till exempel
# Logut sida och ta bort register/login när man är inloggad
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

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
    db = SQLite3::Database.new("db/ryuutama.db")
    db.results_as_hash = true
    result = db.execute("SELECT username FROM users WHERE user_id = ?", id).first
    p result
    slim(:profile, locals:{result:result})
end


# Registering sida
# Undersök varför det redan finns karaktärer för nya konton.
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
before('/characters') do
    if session[:id] == nil
        redirect to ('/register')
    end
end

get('/characters') do
    id = session[:id].to_i
    db = SQLite3::Database.new("db/ryuutama.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM characters WHERE user_id = ?", id)
    p result
    slim(:"characters/index", locals:{characters:result})
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
    gender = params[:gender]
    appearance = params[:appearance]
    hometown = params[:hometown]
    personal_item = params[:personal_item]
    details = params[:details]
    class_id = params[:class_id]
    type_id = params[:type_id]
    as_id = params[:ability_score_id]
    mw_id = params[:mastered_weapon_id]
    db = SQLite3::Database.new("db/ryuutama.db")
    db.execute("INSERT INTO characters (name, gender, appearance, hometown, personal_item, details, user_id, class_id, type_id, ability_score_id, mastered_weapon_id) VALUES (?,?,?,?,?,?,?,?,?,?,?)", name, gender, appearance, hometown, personal_item, details, id, class_id, type_id, as_id, mw_id)
    redirect('/characters')
end

# Visa karaktär
get('/characters/:char_id') do
    char_id = params[:char_id].to_i
    db = SQLite3::Database.new("db/ryuutama.db")
    db.results_as_hash = true
    owner = db.execute("SELECT user_id FROM characters WHERE char_id = ?", char_id).first["user_id"]
    if owner == session[:id].to_i
        result = db.execute("SELECT * FROM characters WHERE char_id = ?", char_id).first
        classname = db.execute("SELECT class.name FROM class INNER JOIN characters on class.class_id = characters.class_id WHERE char_id = ?",char_id).first
        typename = db.execute("SELECT type.name FROM type INNER JOIN characters on type.type_id = characters.type_id WHERE char_id = ?", char_id).first
        ability_score = db.execute("SELECT ability_score.name FROM ability_score INNER JOIN characters on ability_score.id = characters.ability_score_id WHERE char_id = ?", char_id).first
        mastered_weapon = db.execute("SELECT mastered_weapon.name FROM mastered_weapon INNER JOIN characters on mastered_weapon.id = characters.mastered_weapon_id WHERE char_id = ?",char_id).first
        p result
        slim(:"characters/show",locals:{character:result,classname:classname,typename:typename,ability_score:ability_score,mastered_weapon:mastered_weapon})
    else
        redirect('/')
    end
end

# Edit character
get('/characters/:char_id/edit') do
    char_id = params[:char_id].to_i
    db = SQLite3::Database.new("db/ryuutama.db")
    db.results_as_hash = true
    owner = db.execute("SELECT user_id FROM characters WHERE char_id = ?", char_id).first["user_id"]
    if owner == session[:id]
        result = db.execute("SELECT * FROM characters WHERE char_id = ?", char_id).first
        classname = db.execute("SELECT class.name FROM class INNER JOIN characters on class.class_id = characters.class_id WHERE char_id = ?",char_id).first
        typename = db.execute("SELECT type.name FROM type INNER JOIN characters on type.type_id = characters.type_id WHERE char_id = ?", char_id).first
        ability_score = db.execute("SELECT ability_score.name FROM ability_score INNER JOIN characters on ability_score.id = characters.ability_score_id WHERE char_id = ?", char_id).first
        mastered_weapon = db.execute("SELECT mastered_weapon.name FROM mastered_weapon INNER JOIN characters on mastered_weapon.id = characters.mastered_weapon_id WHERE char_id = ?",char_id).first
        p result
        p "#{ability_score}"
        slim(:"characters/edit",locals:{character:result,classname:classname,typename:typename,ability_score:ability_score,mastered_weapon:mastered_weapon})
    else
        redirect('/')
    end
end

post('/characters/:char_id/update') do
    char_id = params[:char_id].to_i   
    user_id = params[:user_id].to_i
    name = params[:char_name]
    gender = params[:gender]
    appearance = params[:appearance]
    hometown = params[:hometown]
    personal_item = params[:personal_item]
    details = params[:details]
    class_id = params[:class_id].to_i
    type_id = params[:type_id].to_i
    as_id = params[:ability_score_id].to_i
    mw_id = params[:mastered_weapon_id].to_i
    db = SQLite3::Database.new("db/ryuutama.db")
    db.execute("UPDATE characters SET name=?,gender=?,appearance=?,hometown=?,personal_item=?,details=?,class_id=?,type_id=?,ability_score_id=?,mastered_weapon_id=?,user_id=? WHERE char_id = ?",name,gender,appearance,hometown,personal_item,details,class_id,type_id,as_id,mw_id,user_id,char_id)
    redirect('/characters')
end

# Delete character
post('/characters/:char_id/delete') do
    char_id = params[:char_id].to_i
    db = SQLite3::Database.new("db/ryuutama.db")
    db.execute("DELETE FROM characters WHERE char_id = ?", char_id)
    redirect('/characters')
end