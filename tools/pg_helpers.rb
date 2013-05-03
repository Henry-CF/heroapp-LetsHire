#!/usr/bin/env ruby

require 'pathname'
require 'shellwords'
require 'pg'
require 'yaml'

TEST_DIRECTORY = Pathname.getwd + "tmp_test_pgsql"

PGHOST = 'localhost'
PGPORT = '5432'

module PGTestHelper
  @test_pgdata = TEST_DIRECTORY + 'data'
  @logfile = TEST_DIRECTORY + 'setup.log'

  @config_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))

  module_function

  def database
    dbconf = YAML.load(File.open(@config_file))
    return dbconf["ci"]["database"]
  end

  def trace(*msg)
    output = msg.flatten.join(' ')
    $stderr.puts(output)
  end

  ### Return the specified args as a string, quoting any that have a space.
  def quotelist(*args)
    return args.flatten.collect {|part| part.to_s =~ /\s/ ? part.to_s.inspect : part.to_s }
  end

  ### Run the specified command +cmd+ with system(), failing if the execution
  ### fails.
  def run(*cmd)
    cmd.flatten!

    if cmd.length > 1
      trace(quotelist(*cmd))
    else
      trace(cmd)
    end

    system(*cmd)
    raise "Command failed: [%s]" % [cmd.join(' ')] unless $?.success?
  end

  ### Run the specified command +cmd+ after redirecting stdout and stderr to the specified
  ### +logpath+, failing if the execution fails.
  def log_and_run(logpath, *cmd)
    cmd.flatten!

    if cmd.length > 1
      trace(quotelist(*cmd))
    else
      trace(cmd)
    end

    # Eliminate the noise of creating/tearing down the database by
    # redirecting STDERR/STDOUT to a logfile if the Ruby interpreter
    # supports fork()
    logfh = File.open(logpath, File::WRONLY|File::CREAT|File::APPEND)
    begin
      pid = fork
    rescue NotImplementedError
      logfh.close
      system(*cmd)
    else
      if pid
        logfh.close
      else
        $stdout.reopen(logfh)
        $stderr.reopen($stdout)
        $stderr.puts(">>> " + cmd.shelljoin)
        exec(*cmd)
        $stderr.puts "After the exec()?!??!"
        exit!
      end
      Process.wait(pid)
    end

    raise "Command failed: [%s]" % [cmd.join(' ')] unless $?.success?
  end

  ### Check the current directory for directories that look like they're
  ### testing directories from previous tests, and tell any postgres instances
  ### running in them to shut down.
  def stop_existing_postmasters
    pat = Pathname.getwd + 'tmp_test_*'
    Pathname.glob(pat.to_s).each do |testdir|
      datadir = testdir + 'data'
      pidfile = datadir + 'postmaster.pid'
      if pidfile.exist? && pid = pidfile.read.chomp.to_i
        $stderr.puts "pidfile (%p) exists: %d" % [ pidfile, pid ]
        begin
          Process.kill(0, pid)
        rescue Errno::ESRCH
          $stderr.puts "No postmaster running for %s" % [ datadir ]
          # Process isn't alive, so don't try to stop it
        else
          $stderr.puts "Stopping lingering database at PID %d" % [ pid ]
          run 'pg_ctl', '-D', datadir.to_s, '-m', 'fast', 'stop'
        end
      else
        $stderr.puts "No pidfile (%p)" % [ pidfile ]
      end
    end
  end

  ### Set up a PostgreSQL database instance for testing.
  def setup_testing_db(description = 'PGTest')
    stop_existing_postmasters()

    puts "Setting up test database for #{description}"
    @test_pgdata.mkpath

    trace "Command output logged to #{@logfile}"

    begin
      unless (@test_pgdata+"postgresql.conf").exist?
        FileUtils.rm_rf(@test_pgdata, :verbose => $DEBUG)
        $stderr.puts "Running initdb"
        log_and_run @logfile, 'initdb', '-E', 'UTF8', '--no-locale', '-D', @test_pgdata.to_s
      end

      trace "Starting postgres"
      log_and_run @logfile, 'pg_ctl', '-w', '-D', @test_pgdata.to_s, 'start'
      sleep 2

      $stderr.puts "Creating the test DB"
      log_and_run @logfile, 'psql', '-e', '-c', "DROP DATABASE IF EXISTS #{database}", 'postgres'
      log_and_run @logfile, 'createdb', '-e', "#{database}"
    rescue => err
      $stderr.puts "%p during test setup: %s" % [ err.class, err.message ]
      $stderr.puts "See #{@logfile} for details."
      $stderr.puts *err.backtrace if $DEBUG
      fail
    end
  end

  def connect_testing_db
    @conninfo = "host=#{PGHOST} port=#{PGPORT} dbname=#{database}"

    conn = PGconn.connect(@conninfo)
    conn.set_notice_processor do |message|
      $stderr.puts(description + ':' + message) if $DEBUG
    end

    return conn
  end

  def fillinto_fake_data(conn)
    content = conn.escape_bytea("\xCC" * 1024)

    conn.transaction do
      conn.exec("CREATE TABLE fake_data (id SERIAL, content BYTEA)")
      conn.exec("INSERT INTO fake_data values (1, E'#{content}')")
    end
  end

  def teardown_testing_db(conn)
    puts "Tearing down test database"
    if conn
      check_for_lingering_connections(conn)
      conn.finish
    end
    log_and_run @logfile, 'pg_ctl', '-D', @test_pgdata.to_s, 'stop'
    sleep 2
    run 'rm', '-rf', TEST_DIRECTORY.to_s
  end

  def check_for_lingering_connections(conn)
    conn.exec( "SELECT * FROM pg_stat_activity" ) do |res|
      conns = res.find_all {|row| row['pid'].to_i != conn.backend_pid }
      unless conns.empty?
        puts "Lingering connections remain:"
        conns.each do |row|
          $stderr.puts "#{row.inspect}"
        end
      end
    end
  end
end #end of module definition

def usage
  puts ""
  puts "Postgresql test auxiliart tool."
  puts ""
  puts "    #{__FILE__} start/stop    Start/Stop the postgresql server before run unit test."
  puts ""
  exit
end

actions = %w(start stop)
if ARGV.length < 1 || !actions.include?(ARGV[0])
  usage
end

if ARGV[0] == 'start'
  PGTestHelper.setup_testing_db
  @conn = PGTestHelper.connect_testing_db
  PGTestHelper.fillinto_fake_data(@conn)

  #NOTE: The output format depends on the configuration parameter bytea_output, the default is hex.
  res = @conn.exec('SELECT * FROM fake_data')
  res.each do |row|
    puts "===> #{@conn.unescape_bytea(row['content'])}"
  end
elsif ARGV[0] == 'stop'
  @conn = PGTestHelper.connect_testing_db
  PGTestHelper.teardown_testing_db(@conn)
end
