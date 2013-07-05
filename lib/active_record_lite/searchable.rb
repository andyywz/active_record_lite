require_relative './db_connection'

module Searchable
  def where(params = {})
    where_clause = []
    values = []
    params.each do |k,v|
      where_clause << "#{k} = ?"
      values << v
    end
    where_string = where_clause.join(" AND ")

    query = <<-SQL
      SELECT *
      FROM #{@table_name}
      WHERE #{where_string}
    SQL

    DBConnection.execute(query, *values)
  end
end