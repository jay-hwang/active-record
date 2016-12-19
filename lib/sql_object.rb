require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    @columns.first.map { |column| column.to_sym }
  end

  def self.finalize!
    columns = self.columns

    columns.each do |column|
      define_method "#{column}" do
        attributes[column]
      end

      define_method "#{column}=" do |arg|
        attributes[column] = arg
      end
    end
  end

  def self.table_name
    @table_name ||= "#{self}".tableize
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.all
  end

  def self.parse_all(res)
  end

  def self.find(id)
  end

  def initialize(params = {})
  end

  def attributes
  end

  def attribute_values
  end

  def insert
  end

  def update
  end

  def save
  end
end
