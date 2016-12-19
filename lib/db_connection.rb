require 'sqlite3'

PRINT_QUERIES = ENV['PRINT_QUERIES'] == 'true'
ROOT_FOLDER = File.join(File.dirname(__FILE__), '..')
DATABASE_SQL_FILE = File.join(ROOT_FOLDER, 'database.sql')
DATABASE_DB_FILE = File.join(ROOT_FOLDER, 'database.db')

class DBConnection
  def self.open(db_file_name)
    @db = SQLite3::Database.new(db_file_name)
    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.reset
    commands = [
      "rm '#{DATABASE_DB_FILE}'",
      "cat '#{DATABASE_SQL_FILE}' | sqlite3 '#{DATABASE_DB_FILE}'"
    ]

    commands.each { |command| `#{command}` }
    DBConnection.open(DATABASE_DB_FILE)
  end

  def self.instance
    reset if @db.nil?
    @db
  end

  def self.execute(*args)
    print_query(*args)
    instance.execute(*args)
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  private

    def self.print_query(query, *args)
      return unless PRINT_QUERIES

      puts '*******************'
      puts query
      unless args.empty?
        puts "interpolate: #{args.inspect}"
      end
      puts '*******************'
    end
end
