{ pkgs ? import <nixpkgs> {} }:

let
  # Configuration variables
  pgPort = 5433;  # Changed from default 5432
  pgData = "$HOME/Documents/postgres_data";
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    postgresql_17
  ];

  shellHook = ''
    # Directory for persistent data
    export dataDir="$HOME/Documents/postgres_data"

    # Create data directory if it doesn't exist
    if [ ! -d "$dataDir" ]; then
      echo "Creating PostgreSQL data directory at $dataDir"
      mkdir -p "$dataDir"
      chmod 700 "$dataDir"

      # Initialize the database
      initdb -D "$dataDir"

      # Configure PostgreSQL
      echo "host all all 127.0.0.1/32 trust" >> "$dataDir/pg_hba.conf"
      echo "listen_addresses='127.0.0.1'" >> "$dataDir/postgresql.conf"
      echo "port=${toString pgPort}" >> "$dataDir/postgresql.conf"
      echo "unix_socket_directories='/tmp'" >> "$dataDir/postgresql.conf"

      # Start PostgreSQL temporarily to create default database
      echo "Starting PostgreSQL to create default database..."
      pg_ctl -D "$dataDir" -o "-p ${toString pgPort} -k /tmp" -l "$dataDir/logfile" start -w -t 60

      if [ $? -eq 0 ]; then
        # Create default database for user
        echo "Creating default database for user $(whoami)..."
        createdb -h localhost -p ${toString pgPort} "$(whoami)"

        # Stop PostgreSQL
        echo "Stopping PostgreSQL..."
        pg_ctl -D "$dataDir" stop -m fast
      else
        echo "Error: Failed to start PostgreSQL. Checking logs:"
        cat "$dataDir/logfile"
      fi
    fi

    # Set environment variables
    export PGPORT=${toString pgPort}
    export PGHOST=localhost  # Force TCP/IP connection

    # Function to show help
    pg_help() {
      echo "PostgreSQL Development Shell Commands:"
      echo ""
      echo "Database Server:"
      echo "  start_postgres              - Start PostgreSQL server"
      echo "  stop_postgres               - Stop PostgreSQL server"
      echo "  postgres_status             - Check PostgreSQL status and list databases"
      echo ""
      echo "Database Management:"
      echo "  create_db <name>            - Create a new database"
      echo "  restore_db <db> <dumpfile>  - Restore database from dump file"
      echo "  psql                        - Connect to PostgreSQL"
      echo "  pg_help                     - Show this help message"
      echo ""
      echo "Environment:"
      echo "  Port: ${toString pgPort}"
      echo "  Data: $dataDir"
      echo ""
      echo "Usage Examples:"
      echo "  start_postgres              # Start the server"
      echo "  create_db myproject         # Create a new database"
      echo "  psql -d myproject           # Connect to specific database"
      echo "  restore_db db ~/dump.sql    # Restore from SQL dump"
    }

    # Define functions
    start_postgres() {
      if ! pg_ctl -D "$dataDir" status >/dev/null 2>&1; then
        echo "Starting PostgreSQL..."
        pg_ctl -D "$dataDir" -o "-p ${toString pgPort} -k /tmp" -l "$dataDir/logfile" start -w -t 60

        if [ $? -eq 0 ]; then
          echo "PostgreSQL started successfully on port ${toString pgPort}"
          echo "You can now connect using: psql -h localhost -p ${toString pgPort}"
        else
          echo "Error: PostgreSQL failed to start. Checking logs:"
          cat "$dataDir/logfile"
          return 1
        fi
      else
        echo "PostgreSQL is already running"
      fi
    }

    stop_postgres() {
      if pg_ctl -D "$dataDir" status >/dev/null 2>&1; then
        pg_ctl -D "$dataDir" stop
        echo "PostgreSQL stopped"
      else
        echo "PostgreSQL is not running"
      fi
    }

    create_db() {
      if [ -z "$1" ]; then
        echo "Usage: create_db <database_name>"
        return 1
      fi
      createdb "$1"
      echo "Database $1 created"
    }

    restore_db() {
      if [ "$#" -lt 2 ]; then
        echo "Usage: restore_db <database_name> <dump_file>"
        echo "Example: restore_db mydb ./backup.dump"
        return 1
      fi

      local db_name="$1"
      local dump_file="$2"

      if [ ! -f "$dump_file" ]; then
        echo "Error: Dump file '$dump_file' not found"
        return 1
      fi

      # Create database if it doesn't exist
      createdb "$db_name" 2>/dev/null || true

      # Restore the database
      if [[ $dump_file == *.sql ]]; then
        psql -d "$db_name" -f "$dump_file"
      else
        pg_restore -d "$db_name" --clean --if-exists "$dump_file"
      fi

      echo "Database $db_name restored from $dump_file"
    }

    postgres_status() {
      if pg_ctl -D "$dataDir" status >/dev/null 2>&1; then
        echo "PostgreSQL is running on port ${toString pgPort}"
        psql -l
      else
        echo "PostgreSQL is not running"
      fi
    }

    # Show initial help
    echo "PostgreSQL 17 Development Shell (run 'pg_help' for commands)"
    echo "Port: ${toString pgPort}"
    echo "Data: $dataDir"
    echo ""
    echo "Available commands:"
    echo "  start_postgres              - Start PostgreSQL server"
    echo "  stop_postgres               - Stop PostgreSQL server"
    echo "  postgres_status             - Check PostgreSQL status and list databases"
    echo "  create_db <name>            - Create a new database"
    echo "  restore_db <db> <dumpfile>  - Restore database from dump file"
    echo "  psql                        - Connect to PostgreSQL"
    echo "  pg_help                     - Show this help message"

    echo ""
    echo "PostgreSQL Version:"
    psql --version
  '';
}
