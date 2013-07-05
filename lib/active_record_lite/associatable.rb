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
    @assoc_params.nil? ? @assoc_params = {} : @assoc_params
  end

  def belongs_to(name, params = {})
    assoc_params[name] = BelongsToAssocParams.new(name, params)

    define_method(name) do
      results = DBConnection.execute(<<-SQL, self.send(self.class.assoc_params[name].foreign_key))
        SELECT *
        FROM #{self.class.assoc_params[name].other_table}
        WHERE id = ?
      SQL
      self.class.assoc_params[name].other_class.parse_all(results)
    end
  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)

    define_method(name) do
      results = DBConnection.execute(<<-SQL, self.id)
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.foreign_key} = ?
      SQL
      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2) # :house, :human, :house
    define_method(name) do
      cat_to_human = self.class.assoc_params[assoc1]
      human_to_house = cat_to_human.other_class.assoc_params[assoc2]

      results = DBConnection.execute(<<-SQL, self.id)
      SELECT house.*
      FROM #{human_to_house.other_class.table_name} AS house
      JOIN #{cat_to_human.other_class.table_name} AS human
      ON house.#{human_to_house.primary_key} = human.#{human_to_house.foreign_key}
      JOIN #{self.class.table_name} AS cat
      ON cat.#{cat_to_human.foreign_key} = human.#{cat_to_human.primary_key}
      WHERE cat.id = ?
      SQL

      human_to_house.other_class.parse_all(results)
    end
  end
end































