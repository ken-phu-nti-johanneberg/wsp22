# Connect to database
def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

# Register
def register(username,password,password_confirm)
    if (password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = connect_to_db('db/ryuutama.db')
        db.execute("INSERT INTO users (username, password) VALUES (?,?)", username, password_digest)
        redirect('/showlogin')
    else
        "Password does not match"
    end
end

# Login
def login(username, password, result)
    # db = connect_to_db('db/ryuutama.db')
    # result = db.execute("SELECT * FROM users WHERE username = ?", username).first
    password_digest = result["password"]
    if BCrypt::Password.new(password_digest) == password
        return true
    end
#         redirect('/profile')
#     else
#         "Wrong password <a href='/showlogin'>Försök igen</a>"
#     end
end

# Funktioner
# login
# register
# edit
# update
# create