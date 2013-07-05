require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    define_method(name) do
      other_class_name = params[:class_name] ||= name.camelize
      primary_key = params[:primary_key] ||= self.id
      foreign_key = params[:foreign_key] ||= "#{name}_id"

      other_class = other_class_name.constantize
      other_table_name = other_class.table_name

      query = <<-SQL
        SELECT *
        FROM #{other_table_name}
        WHERE id = ?
      SQL

      other_class.parse_all(DBConnection.execute(query, self.send(foreign_key)))
    end
  end

  def has_many(name, params = {})
    define_method(name) do
      other_class_name = params[:class_name] ||= name.to_s.singularize.camelize
      primary_key = params[:primary_key] ||= self.id
      foreign_key = params[:foreign_key] ||= "#{self.class.underscore}_id"

      other_class = other_class_name.constantize
      other_table_name = other_class.table_name

      query = <<-SQL
      SELECT *
      FROM #{other_table_name}
      WHERE #{foreign_key} = ?
      SQL

      other_class.parse_all(DBConnection.execute(query, self.id))
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end































