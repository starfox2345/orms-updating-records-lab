require_relative "../config/environment.rb"
require 'pry'

# DB[:conn].results_as_hash = true 

class Student
  attr_accessor :id, :name, :grade
  # attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end
      # options.each do |key, value|
    #   self.send("#{key}=", value) if respond_to?("#{key}=")
    # end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?)
      SQL

    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
    self
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  # def self.new_from_db(id)
  #   sql = <<-SQL
  #     SELECT * FROM students WHERE id = ?
  #   SQL
  #   student = DB[:conn].execute(sql, id)[0]
  #   self.new(student)
  # end

  def self.new_from_db(student)
    Student.new(student[0], student[1], student[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
    self
  end

  

end
