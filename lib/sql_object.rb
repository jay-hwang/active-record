require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL)
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
    all = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    self.parse_all(all)
  end

  def self.parse_all(res)
    res.map { |data| self.new(data) }
  end

  def initialize(params ={})
    params.each do |name, value|
      sym_name = name.to_sym
      unless self.class.columns.include?(sym_name)
        raise "unknown attribute: '#{name}'"
      else
        self.send("#{name}=", value)
      end
    end
  end

  def self.find(id)
    element = DBConnection.instance.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        #{self.table_name}.id = ?
    SQL

    parse_all(element).first || nil
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    columns = attributes.keys
    values = attributes.values
    args = Array.new(values.count, '?')

    DBConnection.execute(<<-SQL, *values)
      INSERT INTO
        #{self.class.table_name} (#{columns.join(', ')})
      VALUES
        (#{args.join(', ')})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    columns = attributes.keys
    values = attribute_values

    new_values = []
    columns.each_index do |i|
      new_values << "#{columns[i]} = ?"
    end

    DBConnection.execute(<<-SQL, *values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{new_values.join(', ')}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
