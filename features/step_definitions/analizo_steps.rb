require 'fileutils'
require 'tmpdir'

top_dir = FileUtils.pwd
saved_path = ENV["PATH"]
ENV['LC_ALL'] = 'C'

Before do
  ENV['PATH'] = top_dir + ':' + ENV['PATH']
end

After do
  FileUtils.rm_f('tmp.out')
  FileUtils.rm_f('tmp.err')
  FileUtils.rm_f(Dir.glob('*.tmp'))
  FileUtils.cd(top_dir)
  ENV['PATH'] = saved_path
end

Given /^I am in (.+)$/ do |dir|
  FileUtils.cd(dir)
end

Given /^I explode (.+) and run "([^\"]*)"$/ do |tarball, command|
  tarball_full_path = File.expand_path(tarball)
  dirname = File.basename(tarball).sub('.tar.gz', '')
  Dir.mktmpdir do |tmpdir|
    Dir.chdir(tmpdir) do
      system("tar xzf #{tarball_full_path}")
      Dir.chdir(dirname) do
        When("I run \"#{command}\"")
      end
    end
  end
end

When /^I run "([^\"]*)"$/ do |command|
  system("#{command} >tmp.out 2>tmp.err")
  if $?.is_a?(Fixnum)
    @exit_status = $?
  else
    @exit_status = $?.exitstatus
  end
  @stdout = File.readlines('tmp.out')
  @stderr = File.readlines('tmp.err')
end

Then /^analizo must report that "([^\"]*)" depends on "([^\"]*)"$/ do |dependent, depended|
  dependent_regex = Regexp.escape dependent
  depended_regex = Regexp.escape depended
  if (@stdout.select { |line| line =~ /"#{dependent_regex}" -> "#{depended_regex}"/ }).size < 1
    raise AnalizoException.new("Output should say that %s depends on %s!" % [dependent.inspect, depended.inspect], @stdout, @stderr)
  end
end

Then /^the exit status must be (.+)$/ do |n|
  @exit_status.should == n.to_i
end

Then /^the exit status must not be (.+)$/ do |n|
  @exit_status.should_not == n.to_i
end

Then /^analizo must report that "([^\"]*)" is part of "([^\"]*)"$/ do |func,mod|
  line = (0...(@stdout.size)).find { |i| @stdout[i] =~ /subgraph "cluster_#{mod}"/ }
  func_regex = Regexp.escape func
  found = false
  if line
    for i in (line...(@stdout.size))
      if @stdout[i] =~ /^\s*\}\s*$/
        break
      elsif @stdout[i] =~ /node.*"#{func_regex}";/
        found = true
      end
    end
  end
  found.should == true
end

Then /^the output lines must match "([^\"]*)"$/ do |pattern|
  unless @stdout.join.match(pattern)
    raise AnalizoException.new("Output does not match %s! (expected to match)!" % pattern.inspect, @stdout, @stderr)
  end
end

Then /^the output must match "([^\"]*)"$/ do |pattern|
  unless @stdout.any? {|item| item.match(pattern) }
    raise AnalizoException.new("Output does not match %s! (expected to match)!" % pattern.inspect, @stdout, @stderr)
  end
end

Then /^the output must not match "([^\"]*)"$/ do |pattern|
  if @stdout.any? { |item| item.match(pattern) }
    raise AnalizoException.new("Output matches %s! (expected to NOT match)" % pattern.inspect, @stdout, @stderr)
  end
end

Then /^the output from "(.+)" must match "([^\"]*)"$/ do |file, pattern|
  @out = File.readlines(file).join
  @out.should match(pattern)
end

Then /^analizo must emit a warning matching "([^\"]*)"$/ do |pattern|
  @stderr.join.should match(pattern)
end

Then /^analizo must report that the project has (.+) = ([\d\.]+)$/ do |metric,n|
  stream = YAML.load_stream(@stdout.join)
  stream.documents.first[metric].should == n.to_f
end

Then /^analizo must report that module (.+) has (.+) = (\d+|\d+\.\d+)$/ do |mod, metric, n|
  stream = YAML.load_stream(@stdout.join)
  module_metrics = stream.documents.find { |doc| doc['_module'] == mod }
  module_metrics[metric].should == n.to_f
end

Then /^analizo must present a list of metrics$/ do
  @stdout.size.should > 0

  @stdout.each do |line|
    line.should match(/(^[^-]+ - .+$)|(^Global Metrics:\n$)|(^Module Metrics:\n)|(^\n$)/)
  end
end

