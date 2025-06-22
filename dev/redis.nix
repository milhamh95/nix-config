{ pkgs ? import <nixpkgs> {} }:

let
  defaultPort = 6380;
  redisData = "$HOME/Documents/redis_data";
in
pkgs.mkShell {
  buildInputs = with pkgs; [ redis ];

  shellHook = ''
    # Directory for persistent Redis data
    export REDIS_DATA="$HOME/Documents/redis_data"
    export REDIS_PORT=${toString defaultPort}
    export REDIS_CONF="$REDIS_DATA/redis-${toString defaultPort}.conf"
    export REDIS_PIDFILE="$REDIS_DATA/redis-${toString defaultPort}.pid"
    export REDIS_LOGFILE="$REDIS_DATA/redis-${toString defaultPort}.log"

    # Create data directory if it doesn't exist
    if [ ! -d "$REDIS_DATA" ]; then
      echo "Creating Redis data directory at $REDIS_DATA"
      mkdir -p "$REDIS_DATA"
    fi

    create_redis_config() {
      local port="$1"
      local conf="$REDIS_DATA/redis-$port.conf"
      local pidfile="$REDIS_DATA/redis-$port.pid"
      local logfile="$REDIS_DATA/redis-$port.log"

      if [ ! -f "$conf" ]; then
        echo "Creating Redis config for port $port at $conf"
        cat > "$conf" <<EOF
        bind 127.0.0.1
        port $port
        dir $REDIS_DATA
        pidfile $pidfile
        logfile $logfile
        daemonize yes
        EOF
      fi
      
      echo "$conf"
    }

    redis_help() {
      echo "Redis Development Shell Commands:"
      echo "  redis_start      - Start Redis server with port selection"
      echo "  redis_stop       - Stop Redis server"
      echo "  redis_status     - Show Redis server status"
      echo "  redis_cli        - Open Redis CLI"
      echo "  redis_help       - Show this help message"
      echo "\nCurrent Environment:"
      echo "  Port: $REDIS_PORT"
      echo "  Data: $REDIS_DATA"
      echo "  Config: $REDIS_CONF"
    }

    redis_start() {
      echo "Select Redis port:"
      echo "1) 6380 (default)"
      echo "2) 6379"
      echo "3) Custom port"
      echo -n "Enter your choice [1-3]: "
      read -r choice
      
      case $choice in
        1) port=6380 ;;
        2) port=6379 ;;
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
        *) port=6380 ;;
      esac

      # Update environment variables
      export REDIS_PORT="$port"
      export REDIS_CONF="$REDIS_DATA/redis-$port.conf"
      export REDIS_PIDFILE="$REDIS_DATA/redis-$port.pid"
      export REDIS_LOGFILE="$REDIS_DATA/redis-$port.log"

      # Create config if it doesn't exist
      create_redis_config "$port" > /dev/null

      # Check if Redis is already running
      if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
        echo "Redis is already running on port $port (PID $(cat $REDIS_PIDFILE))"
        return 0
      fi

      echo "Starting Redis on port $port..."
      if redis-server "$REDIS_CONF"; then
        sleep 1
        if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
          echo "Redis started successfully on port $port"
        else
          echo "Failed to verify Redis started. Check $REDIS_LOGFILE for details."
          return 1
        fi
      else
        echo "Failed to start Redis. Check $REDIS_LOGFILE for details."
        return 1
      fi
    }

    redis_stop() {
      if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
        echo "Stopping Redis on port $REDIS_PORT..."
        if redis-cli -p "$REDIS_PORT" shutdown; then
          rm -f "$REDIS_PIDFILE"
          echo "Redis stopped."
        else
          echo "Failed to stop Redis gracefully. You may need to stop it manually."
        fi
      else
        echo "Redis is not running on port $REDIS_PORT."
      fi
    }

    redis_status() {
      if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
        echo "Redis is running (PID $(cat $REDIS_PIDFILE)) on port $REDIS_PORT"
        redis-cli -p "$REDIS_PORT" info | grep 'redis_version:'
      else
        echo "Redis is not running on port $REDIS_PORT."
      fi
    }

    alias redis_cli="redis-cli -p $REDIS_PORT"

    # Show initial help
    echo "Redis Development Shell (run 'redis_help' for commands)"
    echo "Current port: $REDIS_PORT"
    echo "Data directory: $REDIS_DATA"
    echo "Config file: $REDIS_CONF"
    echo ""
    echo "Available commands:"
    echo "  redis_start      - Start Redis server with port selection"
    echo "  redis_stop       - Stop Redis server"
    echo "  redis_status     - Show Redis server status"
    echo "  redis_cli        - Open Redis CLI"
    echo "  redis_help       - Show this help message"
    echo ""
    echo "Redis Version:"
    redis-server --version
  '';
}
