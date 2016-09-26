# Set the working application directory
working_directory '.'

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid './pids/unicorn.pid'

# Path to logs

stderr_path './log/unicorn.log'
stdout_path './log/unicorn.log'
#
# Number of processes
# Rule of thumb: 2x per CPU core available
# worker_processes 4
worker_processes 2
#
# Time-out
timeout 300
