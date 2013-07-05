require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable

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
    attr_names = self.class.attributes.join(", ")
    query = <<-SQL
      INSERT INTO #{self.class.table_name} (#{attr_names})
      VALUES (#{arr})
    SQL

    DBConnection.execute(query, *attribute_values)
    self.send("#{:id}=", DBConnection.last_insert_row_id)
  end

  def update
    set_line = []
    self.class.attributes.each do |attr_name|
      set_line << "#{attr_name} = ?"
    end
    set_line = set_line.join(', ')

    query = <<-SQL
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = ?
    SQL

    DBConnection.execute(query, *attribute_values, self.id)
  end

  def save
    p self.id
    create if send(:id).nil?
    update if not send(:id).nil?
  end

  private
    def attribute_values
      values = self.class.attributes.map{|attribute| send(attribute)}
    end
end
