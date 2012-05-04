def get_git_command_output(*command)
  command.insert(0, %q{git})
  IO.popen('-') do |io|
    if io.nil?
      exec(*command)
    else
      io.read()
    end
  end.chomp()
end

def get_config_value(key)
  value = get_git_command_output(%q{config}, key)
  return nil unless $?.exitstatus() == 0
  value
end

def get_commit_id(ref_spec)
  commit_id = get_git_command_output(%q{rev-parse}, ref_spec)
  return nil unless $?.exitstatus() == 0
  commit_id
end

def get_branch_name(branch_ref)
  return nil unless branch_ref.start_with?('refs/heads/')
  branch_ref.slice!(0..10)
  branch_ref.chomp!()
  branch_ref
end

# find out the local branch
local_ref = get_git_command_output(*%w{symbolic-ref --quiet HEAD})
exit(1) unless $?.exitstatus() == 0
local_branch = get_branch_name(local_ref)
exit(1) if local_branch.nil?

# find out the remote branch
remote = get_config_value("branch.#{local_branch}.remote")
exit(1) if remote.nil?

remote_branch_ref = get_config_value("branch.#{local_branch}.merge")
exit(1) if remote_branch_ref.nil?
remote_branch = get_branch_name(remote_branch_ref)
exit(1) if remote_branch.nil?

# update the remote references
exit(1) unless system(*%w{git fetch --quiet} << remote)

remote_branch.insert(0, remote + '/')

# get the commit IDs of the local and remote branches
local_commit_id = get_commit_id(local_branch)
exit(1) if local_commit_id.nil?
remote_commit_id = get_commit_id(remote_branch)
exit(1) if remote_commit_id.nil?

# get the number of commits in the remote branch not present in the local branch
counts = get_git_command_output(*%w{rev-list --left-right --count} << "#{local_commit_id}...#{remote_commit_id}")
exit(1) unless $?.exitstatus() == 0

exit(counts.split('	')[1].to_i == 0 ? 1 : 0)
