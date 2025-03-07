require 'pry'

class Dog
  
  attr_accessor :name, :breed, :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
    sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    Dog.new(id: id, name: name, breed: breed)
  end
  
  def self.find_by_name(name)
    sql = "SELECT*FROM dogs WHERE name = ?"
    dog_data = DB[:conn].execute(sql, name)[0]
    dog = Dog.create(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end  
  
  def self.create(id: nil, name:, breed:)
    dog = Dog.new(id: id, name: name, breed: breed)
    dog.save
    dog
  end
  
  def self.find_by_id(id)
    sql = "SELECT*FROM dogs WHERE id = ?"
    dog_data = DB[:conn].execute(sql, id)[0]
    dog = Dog.create(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
  end
  
  def self.find_or_create_by(id: nil, name:, breed:)
      dog_array = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed)
      if !dog_array.empty?
        dog_data = dog_array[0]
        dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
        dog = self.create(id: id, name: name, breed: breed)
      end
      dog
  end
  
  
  
  def update
	  sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
	  DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def save
	  if self.id
		  self.update
	  else
		  sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
		  DB[:conn].execute(sql, self.name, self.breed)
		  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
	  end
    self
  end
  
end
