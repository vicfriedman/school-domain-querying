class Course
	attr_accessor :id, :name, :department_id, :department, :students

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS courses (
      id INTEGER PRIMARY KEY,
      name TEXT,
      department_id INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS courses"
    DB[:conn].execute(sql)
  end

  def insert
    sql = <<-SQL
      INSERT INTO courses
      (name,department_id)
      VALUES
      (?,?)
    SQL
    DB[:conn].execute(sql, [name, department_id])

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM courses")[0][0]
  end

  def self.new_from_db(row)
    self.new.tap do |s|
      s.id = row[0]
      s.name =  row[1]
      s.department_id = row[2]
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end
  
  def self.all
  	sql = <<-SQL
      SELECT *
      FROM courses;
    SQL
    DB[:conn].execute(sql)
   end

  def self.find_all_by_department_id(id)
    sql = <<-SQL
      SELECT *
      FROM courses
      WHERE department_id = ?;
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end
  end

  def update
    sql = <<-SQL
      UPDATE courses
      SET name = ?,department_id = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, [name, department_id], id)
  end

  def persisted?
    !!self.id
  end

  def save
    persisted? ? update : insert
  end

  def department
  	Department.find_by_id(self.department_id)
  end

  def department=(new_department)
  	self.department_id = new_department.id
  	self.update
  end

  def add_student(student)
  	klass = Registration.new
  	klass.student_id = student.id
  	klass.course_id = self.id
  	klass.save
  end

  def students
  	# binding.pry
  	students = Registration.find_all_by_course_id(self.id)
  	all_students = []
  	students.each do |student|
  		all_students << Student.find_by_id(student.id)
  	end
  	all_students

  end




  # def self.find_all_by_department_id(id)
  #   sql = "SELECT * FROM #{table_name} WHERE department_id = ?"
  #   result = DB[:conn].execute(sql,id)
  #   result.map do |row| 
  #     self.new_from_db(row)
  #   end
  # end
end