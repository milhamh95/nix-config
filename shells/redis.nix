{ pkgs }:

let
  dataDir = "$HOME/Documents/redis_data";
  defaultPort = "6380";

  redis_start = pkgs.writeShellScriptBin "redis_start" ''
    REDIS_DATA="${dataDir}"
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

    REDIS_CONF="$REDIS_DATA/redis-$port.conf"
    REDIS_PIDFILE="$REDIS_DATA/redis-$port.pid"
    REDIS_LOGFILE="$REDIS_DATA/redis-$port.log"

    # Create config if it doesn't exist
    if [ ! -f "$REDIS_CONF" ]; then
      echo "Creating Redis config for port $port"
      cat > "$REDIS_CONF" <<EOF
bind 127.0.0.1
port $port
dir $REDIS_DATA
pidfile $REDIS_PIDFILE
logfile $REDIS_LOGFILE
daemonize yes
EOF
    fi

    # Check if already running
    if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
      echo "Redis is already running on port $port (PID $(cat $REDIS_PIDFILE))"
      exit 0
    fi

    echo "Starting Redis on port $port..."
    if redis-server "$REDIS_CONF"; then
      sleep 1
      if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
        echo "Redis started successfully on port $port"
      else
        echo "Failed to verify Redis started. Check $REDIS_LOGFILE for details."
        exit 1
      fi
    else
      echo "Failed to start Redis. Check $REDIS_LOGFILE for details."
      exit 1
    fi
  '';

  redis_stop = pkgs.writeShellScriptBin "redis_stop" ''
    REDIS_PORT=''${REDIS_PORT:-${defaultPort}}
    REDIS_PIDFILE="${dataDir}/redis-$REDIS_PORT.pid"
    if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
      echo "Stopping Redis on port $REDIS_PORT..."
      if redis-cli -p "$REDIS_PORT" shutdown; then
        rm -f "$REDIS_PIDFILE"
        echo "Redis stopped."
      else
        echo "Failed to stop Redis gracefully."
      fi
    else
      echo "Redis is not running on port $REDIS_PORT."
    fi
  '';

  redis_status = pkgs.writeShellScriptBin "redis_status" ''
    REDIS_PORT=''${REDIS_PORT:-${defaultPort}}
    REDIS_PIDFILE="${dataDir}/redis-$REDIS_PORT.pid"
    if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
      echo "Redis is running (PID $(cat $REDIS_PIDFILE)) on port $REDIS_PORT"
      redis-cli -p "$REDIS_PORT" info | grep 'redis_version:'
    else
      echo "Redis is not running on port $REDIS_PORT."
    fi
  '';

  redis_help = pkgs.writeShellScriptBin "redis_help" ''
    REDIS_PORT=''${REDIS_PORT:-${defaultPort}}
    echo "Redis Development Shell Commands:"
    echo "  redis_start                - Start Redis server with port selection"
    echo "  redis_stop                 - Stop Redis server"
    echo "  redis_status               - Show Redis server status"
    echo "  redis-cli -p \$REDIS_PORT   - Open Redis CLI"
    echo "  redis_help                 - Show this help message"
    echo ""
    echo "Environment:"
    echo "  Port: $REDIS_PORT"
    echo "  Data: ${dataDir}"
  '';
in

pkgs.mkShell {
  packages = [
    pkgs.redis
    redis_start
    redis_stop
    redis_status
    redis_help
  ];

  shellHook = ''
    export REDIS_DATA="${dataDir}"
    export REDIS_PORT=${defaultPort}

    # Create data directory if it doesn't exist
    if [ ! -d "$REDIS_DATA" ]; then
      echo "Creating Redis data directory at $REDIS_DATA"
      mkdir -p "$REDIS_DATA"
    fi

    echo "Redis Development Shell (run 'redis_help' for commands)"
    echo "Port: $REDIS_PORT | Data: $REDIS_DATA"
    echo ""
    redis-server --version
  '';
}
