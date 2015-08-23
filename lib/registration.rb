class Registration
	attr_accessor :id, :course_id, :student_id

	def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS registrations (
      id INTEGER PRIMARY KEY,
      course_id INTEGER,
      student_id INTEGER
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS registrations"
    DB[:conn].execute(sql)
  end

  def insert
    sql = <<-SQL
      INSERT INTO registrations
      (student_id, course_id)
      VALUES
      (?, ?)
    SQL
    DB[:conn].execute(sql, [student_id, course_id])

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM registrations")[0][0]
  end

  def self.new_from_db(row)
    self.new.tap do |s|
      s.id = row[0]
      s.student_id =  row[1]
      s.course_id = row[2]
    end
  end

  def self.find_all_by_course_id(id)
    sql = <<-SQL
      SELECT *
      FROM registrations
      WHERE course_id = ?;
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end
  end

  def persisted?
    !!self.id
  end

  def save
    persisted? ? update : insert
  end
end