{ pkgs ? import <nixpkgs> {} }:

let
  redisPort = 6380; # Custom port (default is 6379)
  redisData = "$HOME/Documents/redis_data";
in
pkgs.mkShell {
  buildInputs = with pkgs; [ redis ];

  shellHook = ''
    # Directory for persistent Redis data
    export REDIS_DATA="$HOME/Documents/redis_data"
    export REDIS_PORT=${toString redisPort}
    export REDIS_CONF="$REDIS_DATA/redis.conf"
    export REDIS_PIDFILE="$REDIS_DATA/redis.pid"
    export REDIS_LOGFILE="$REDIS_DATA/redis.log"

    # Create data directory if it doesn't exist
    if [ ! -d "$REDIS_DATA" ]; then
      echo "Creating Redis data directory at $REDIS_DATA"
      mkdir -p "$REDIS_DATA"
    fi

    # Create a default redis.conf if not exists
    if [ ! -f "$REDIS_CONF" ]; then
      echo "Creating default redis.conf at $REDIS_CONF"
      cat > "$REDIS_CONF" <<EOF
bind 127.0.0.1
port ${toString redisPort}
dir $REDIS_DATA
pidfile $REDIS_PIDFILE
logfile $REDIS_LOGFILE
daemonize yes
EOF
    fi

    redis_help() {
      echo "Redis Development Shell Commands:"
      echo "  start_redis      - Start Redis server"
      echo "  stop_redis       - Stop Redis server"
      echo "  redis_status     - Show Redis server status"
      echo "  redis_cli        - Open Redis CLI"
      echo "  redis_help       - Show this help message"
      echo "\nEnvironment:"
      echo "  Port: $REDIS_PORT"
      echo "  Data: $REDIS_DATA"
      echo "  Config: $REDIS_CONF"
    }

    start_redis() {
      if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
        echo "Redis is already running (PID $(cat $REDIS_PIDFILE))"
      else
        echo "Starting Redis..."
        redis-server "$REDIS_CONF"
        sleep 1
        if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
          echo "Redis started successfully on port $REDIS_PORT"
        else
          echo "Failed to start Redis. Check $REDIS_LOGFILE for details."
        fi
      fi
    }

    stop_redis() {
      if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
        echo "Stopping Redis..."
        redis-cli -p "$REDIS_PORT" shutdown
        rm -f "$REDIS_PIDFILE"
        echo "Redis stopped."
      else
        echo "Redis is not running."
      fi
    }

    redis_status() {
      if [ -f "$REDIS_PIDFILE" ] && kill -0 $(cat "$REDIS_PIDFILE") 2>/dev/null; then
        echo "Redis is running (PID $(cat $REDIS_PIDFILE)) on port $REDIS_PORT"
        redis-cli -p "$REDIS_PORT" info | grep 'redis_version:'
      else
        echo "Redis is not running."
      fi
    }

    alias redis_cli="redis-cli -p $REDIS_PORT"

    # Show initial help
    echo "Redis Development Shell (run 'redis_help' for commands)"
    echo "Port: $REDIS_PORT"
    echo "Data: $REDIS_DATA"
    echo "Config: $REDIS_CONF"
    echo ""
    echo "Available commands:"
    echo "  start_redis      - Start Redis server"
    echo "  stop_redis       - Stop Redis server"
    echo "  redis_status     - Show Redis server status"
    echo "  redis_cli        - Open Redis CLI"
    echo "  redis_help       - Show this help message"
    echo ""
    echo "Redis Version:"
    redis-server --version
  '';
}
