require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    query = <<-SQL
      SELECT *
      FROM "#{@table_name}"
    SQL

    rows = DBConnection.execute(query)
    rows.each do |row_hash|
      self.new(row_hash)
    end
  end

  def self.find(id)
    query = <<-SQL
    SELECT *
    FROM "#{@table_name}"
    WHERE id = ?
    SQL

    DBConnection.execute(query, id)
  end

  def create
    arr = (['?'] * self.class.attributes.length).join(', ')
    query = <<-SQL
      INSERT INTO "#{@table_name}" ("#{self.class.attributes.join(", ")}")
      VALUES "#{arr}"
    SQL

    DBConnection.execute(query, *attribute_values)
  end

  def update
    set_line = []
    self.class.attributes.each do |attr_name|
      set_line << "#{attr_name} = ?"
    end
    set_line.join(', ')

    query = <<-SQL
      UPDATE "#{@table_name}"
      SET "#{set_line}"
    SQL

    DBConnection.execute(query, *attribute_values)
  end

  def save
  end

  def attribute_values
    values = []
    self.class.attributes.each do |attribute|
      values << send(attribute)
    end
  end
end























