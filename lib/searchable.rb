require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
    param_columns = params.keys
    param_values = params.values

    where_params = []
    param_columns.map do |col|
      where_params << "#{col} = ?"
    end
    where_params

    results = DBConnection.execute(<<-SQL, *param_values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_params.join(' AND ')}
    SQL

    results.map { |data| self.new(data) }
  end
end

class SQLObject
  extend Searchable
end
