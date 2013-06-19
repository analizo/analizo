require 'fileutils'
require 'tmpdir'
require 'digest/sha1'

top_dir = FileUtils.pwd
saved_path = ENV["PATH"]
ENV['LC_ALL'] = 'C'

Before do
  ENV['PATH'] = top_dir + ':' + ENV['PATH']
  ENV["ANALIZO_CACHE"] = Dir.mktmpdir
end

After do
  FileUtils.rm_f('tmp.out')
  FileUtils.rm_f('tmp.err')
  FileUtils.rm_f(Dir.glob('*.tmp'))
  FileUtils.cd(top_dir)
  ENV['PATH'] = saved_path
  FileUtils.rm_rf(ENV["ANALIZO_CACHE"])
end

Given /^I am in (.+)$/ do |dir|
  FileUtils.cd(dir)
end

def get_tmpdir
  Dir.mktmpdir([Process.pid.to_s, '.analizo.tmpdir'])
end

Given /^I explode (.+)$/ do |tarball|
  tarball_full_path = File.expand_path(tarball)
  dirname = File.basename(tarball).sub('.tar.gz', '')
  tmpdir = get_tmpdir
  Dir.chdir(tmpdir) do
    system("tar xzf #{tarball_full_path}")
  end
  FileUtils.cd(File.join(tmpdir, dirname))
end

When /^I copy (.*) into a temporary directory$/ do |files|
  tmpdir = get_tmpdir
  FileUtils.cp_r(Dir.glob(files), tmpdir)
  FileUtils.cd(tmpdir)
end

When /^I change to an empty temporary directory$/ do
  FileUtils.cd(get_tmpdir)
end

def run(command)
  system("(#{command}) >tmp.out 2>tmp.err")
  if $?.is_a?(Fixnum)
    @exit_status = $?
  else
    @exit_status = $?.exitstatus
  end
  @stdout = File.readlines('tmp.out')
  @stderr = File.readlines('tmp.err')
end

When /^I run "([^\"]*)"$/ do |command|
  run command
end

at_exit do
  FileUtils.rm_rf(Dir.glob(File.join(Dir.tmpdir, '*.analizo.{out,err,tmpdir}')))
end

When /^I run "([^\"]*)" only once$/ do |command|
  run_marker = Digest::SHA1.hexdigest(Dir.pwd) + Digest::SHA1.hexdigest(command)
  stdout = File.join(Dir.tmpdir, run_marker + '.analizo.out')
  stderr = File.join(Dir.tmpdir, run_marker + '.analizo.err')
  if File.exist?(stdout) && File.exist?(stderr)
    @stdout = File.readlines(stdout)
    @stderr = File.readlines(stderr)
  else
    run command
    FileUtils.cp('tmp.out', stdout)
    FileUtils.cp('tmp.err', stderr)
  end
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

Then /^the contents of "(.+)" must match "([^\"]*)"$/ do |file, pattern|
  @out = File.readlines(file).join
  @out.should match(pattern)
end

Then /^analizo must emit a warning matching "([^\"]*)"$/ do |pattern|
  @stderr.join.should match(pattern)
end

module AnalizoRuby18Compatibiliy
  include Enumerable
  def each(&block)
    self.documents.each(&block)
  end
end

def __load_yaml_stream(data)
  stream = YAML.load_stream(data)
  if RUBY_VERSION < '1.9'
    stream.extend(AnalizoRuby18Compatibiliy)
  end
  stream
end

Then /^analizo must report that the project has (.+) = ([\d\.]+)$/ do |metric,n|
  __load_yaml_stream(@stdout.join).first[metric].should == n.to_f
end

Then /^analizo must report that module (.+) has (.+) = (.+)$/ do |mod, metric, value|
  module_metrics = __load_yaml_stream(@stdout.join).find { |doc| doc['_module'] == mod }
  case value
  when /^\d+|\d+\.\d+$/
    value = value.to_f
  when /^\[(.*)\]$/
    value = $1.split(/\s*,\s*/)
  end
  module_metrics[metric].should == value
end

Then /^analizo must present a list of metrics$/ do
  @stdout.size.should > 0

  @stdout.each do |line|
    line.should match(/(^[^-]+ - .+$)|(^Global Metrics:\n$)|(^Module Metrics:\n)|(^\n$)/)
  end
end

Given /^I create a file called (.+) with the following content$/ do |filename, table|
  File.open(filename, 'w') do |file|
    table.raw.each do |line|
      file.puts(line)
    end
  end
end

Then /^the file "([^\"]*)" should exist$/ do |file|
  File.exist?(file).should == true
end

Then /^the file "(.*?)" should have type (.*)$/ do |file, type|
  `file --brief --mime-type #{file}`.strip.should == type
end

Then /^analizo must present a list of languages$/ do
  @stdout.size.should > 0

  @stdout.each do |line|
    line.should match(/(^Languages:\n$)|(^\w+\n$)/)
  end
end
