require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  attr_reader :primary_key, :foreign_key, :other_class_name
  def other_class
    @other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @other_class_name = params[:class_name] ||= name.to_s.camelize
    @primary_key = params[:primary_key] ||= "id"
    @foreign_key = params[:foreign_key] ||= "#{name}_id"
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @other_class_name = params[:class_name] ||= name.to_s.singularize.camelize
    @primary_key = params[:primary_key] ||= "id"
    @foreign_key = params[:foreign_key] ||= "#{self_class.underscore}_id"
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)

    define_method(name) do
      results = DBConnection.execute(<<-SQL,self.send(aps.foreign_key))
        SELECT *
        FROM #{aps.other_table}
        WHERE id = ?
      SQL
      aps.other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)

    define_method(name) do
      query = <<-SQL
      SELECT *
      FROM #{aps.other_table}
      WHERE #{aps.foreign_key} = ?
      SQL

      aps.other_class.parse_all(DBConnection.execute(query, self.id))
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end































