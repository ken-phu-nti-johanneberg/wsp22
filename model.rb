def connect_to_db(path)
    db.SQLite3::Database.new(path)
    db.result_as_hash = true
    return db
end

# Funktioner
# login
# register
# edit
# update
# create