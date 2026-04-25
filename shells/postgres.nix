{ pkgs }:

let
  dataDir = "$HOME/Documents/postgres_data";
  defaultPort = "5433";

  pg_start = pkgs.writeShellScriptBin "pg_start" ''
    DATA_DIR="${dataDir}"
    echo "Select PostgreSQL port:"
    echo "1) 5433 (default)"
    echo "2) 5432"
    echo "3) Custom port"
    echo -n "Enter your choice [1-3]: "
    read -r choice

    case $choice in
      1) port=5433 ;;
      2) port=5432 ;;
      3)
        while true; do
          echo -n "Enter custom port number: "
          read -r port
          if [[ "$port" =~ ^[0-9]+$ ]] && [ "$port" -ge 1 ] && [ "$port" -le 65535 ]; then
            break
          else
            echo "Invalid port number. Please enter a number between 1 and 65535."
          fi
        done
        ;;
      *) port=5433 ;;
    esac

    export PGPORT="$port"

    if pg_ctl -D "$DATA_DIR" status >/dev/null 2>&1; then
      echo "PostgreSQL is already running. Please stop it first."
      exit 1
    fi

    sed -i.bak "s/^port = .*/port = $port/" "$DATA_DIR/postgresql.conf"

    echo "Starting PostgreSQL on port $port..."
    pg_ctl -D "$DATA_DIR" -o "-p $port -k /tmp" -l "$DATA_DIR/logfile" start -w -t 60

    if [ $? -eq 0 ]; then
      echo "PostgreSQL started successfully on port $port"
      echo "You can now connect using: psql -h localhost -p $port"
    else
      echo "Error: PostgreSQL failed to start. Checking logs:"
      cat "$DATA_DIR/logfile"
      exit 1
    fi
  '';

  pg_stop = pkgs.writeShellScriptBin "pg_stop" ''
    DATA_DIR="${dataDir}"
    if pg_ctl -D "$DATA_DIR" status >/dev/null 2>&1; then
      pg_ctl -D "$DATA_DIR" stop
      echo "PostgreSQL stopped"
    else
      echo "PostgreSQL is not running"
    fi
  '';

  pg_status = pkgs.writeShellScriptBin "pg_status" ''
    DATA_DIR="${dataDir}"
    PGPORT=''${PGPORT:-${defaultPort}}
    if pg_ctl -D "$DATA_DIR" status >/dev/null 2>&1; then
      echo "PostgreSQL is running on port $PGPORT"
      psql -l
    else
      echo "PostgreSQL is not running"
    fi
  '';

  pg_create_db = pkgs.writeShellScriptBin "pg_create_db" ''
    if [ -z "$1" ]; then
      echo "Usage: pg_create_db <database_name>"
      exit 1
    fi
    createdb "$1"
    echo "Database $1 created"
  '';

  pg_restore_db = pkgs.writeShellScriptBin "pg_restore_db" ''
    if [ "$#" -lt 2 ]; then
      echo "Usage: pg_restore_db <database_name> <dump_file>"
      echo "Supports both .sql and .dump formats"
      echo "Example: pg_restore_db mydb ./backup.sql"
      echo "Example: pg_restore_db mydb ./backup.dump"
      exit 1
    fi

    db_name="$1"
    dump_file="$2"

    if [ ! -f "$dump_file" ]; then
      echo "Error: Dump file '$dump_file' not found"
      exit 1
    fi

    createdb "$db_name" 2>/dev/null || true

    if [[ $dump_file == *.sql ]]; then
      psql -d "$db_name" -f "$dump_file"
    else
      pg_restore -d "$db_name" --clean --if-exists "$dump_file"
    fi

    echo "Database $db_name restored from $dump_file"
  '';

  pg_help = pkgs.writeShellScriptBin "pg_help" ''
    PGPORT=''${PGPORT:-${defaultPort}}
    echo "PostgreSQL Development Shell Commands:"
    echo ""
    echo "Database Server:"
    echo "  pg_start                      - Start PostgreSQL server with port selection"
    echo "  pg_stop                       - Stop PostgreSQL server"
    echo "  pg_status                     - Check PostgreSQL status and list databases"
    echo ""
    echo "Database Management:"
    echo "  pg_create_db <name>           - Create a new database"
    echo "  pg_restore_db <db> <dumpfile> - Restore database from dump file"
    echo "  psql                          - Connect to PostgreSQL"
    echo "  pg_help                       - Show this help message"
    echo ""
    echo "Environment:"
    echo "  Port: $PGPORT"
    echo "  Data: ${dataDir}"
  '';
in

pkgs.mkShell {
  packages = [
    pkgs.postgresql_17
    pg_start
    pg_stop
    pg_status
    pg_create_db
    pg_restore_db
    pg_help
  ];

  shellHook = ''
    export dataDir="${dataDir}"
    export PGPORT=${defaultPort}
    export PGHOST=localhost

    # First-time setup: create data directory and initialize database
    if [ ! -d "$dataDir" ]; then
      echo "Creating PostgreSQL data directory at $dataDir"
      mkdir -p "$dataDir"
      chmod 700 "$dataDir"

      initdb -D "$dataDir"

      echo "host all all 127.0.0.1/32 trust" >> "$dataDir/pg_hba.conf"
      echo "listen_addresses='127.0.0.1'" >> "$dataDir/postgresql.conf"
      echo "port=$PGPORT" >> "$dataDir/postgresql.conf"
      echo "unix_socket_directories='/tmp'" >> "$dataDir/postgresql.conf"

      echo "Starting PostgreSQL to create default database..."
      pg_ctl -D "$dataDir" -o "-p $PGPORT -k /tmp" -l "$dataDir/logfile" start -w -t 60

      if [ $? -eq 0 ]; then
        echo "Creating default database for user $(whoami)..."
        createdb -h localhost -p $PGPORT "$(whoami)"
        echo "Stopping PostgreSQL..."
        pg_ctl -D "$dataDir" stop -m fast
      else
        echo "Error: Failed to start PostgreSQL. Checking logs:"
        cat "$dataDir/logfile"
      fi
    fi

    echo "PostgreSQL 17 Development Shell (run 'pg_help' for commands)"
    echo "Port: $PGPORT | Data: $dataDir"
    echo ""
    psql --version
  '';
}
