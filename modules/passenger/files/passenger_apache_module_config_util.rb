command = ARGV.shift()
config_file = ARGV.shift()

case command
  when 'check'
    # check if the config file contents is the desired one
    current_config = File.open(config_file, 'r') { |f| f.read() }
    desired_config = %x{passenger-install-apache2-module --snippet}

    exit current_config == desired_config ? 0 : 1
  when 'configure'
    # the module needs to be rebuilt if there is no config file
    unless File.file?(config_file)
      exit $? unless system(*%w{passenger-install-apache2-module -a})
    end

    # write the config file
    pid = fork() do
      $stdout.reopen(File.open(config_file, 'w'))
      exec(*%w{passenger-install-apache2-module --snippet})
    end
    Process.waitpid(pid)
    exit $?.exitstatus
  else
    raise "uknown command #{command}"
end
