require 'fileutils'

saved_dir = FileUtils.pwd
saved_path = ENV["PATH"]
saved_perl5lib = ENV["PERL5LIB"]

Before do
  ENV['PATH'] = saved_dir + ':' + ENV['PATH']
  ENV['PERL5LIB'] = saved_dir + (ENV['PERL5LIB'] ? ':' + ENV['PERL5LIB'] : '')
end

After do
  FileUtils.rm_f('tmp.out')
  FileUtils.rm_f('tmp.err')
  FileUtils.cd(saved_dir)
  ENV['PATH'] = saved_path
  ENV['PERL5LIB'] = saved_perl5lib
end

Given /^I am in (.+)$/ do |dir|
  FileUtils.cd(dir)
end

When /^I run "([^\"]*)"$/ do |command|
  system("#{command} >tmp.out 2>tmp.err")
  @exit_status = $?
  @stdout = File.readlines('tmp.out')
  @stderr = File.readlines('tmp.err')
end

Then /^egypt must report that "([^\"]*)" depends on "([^\"]*)"$/ do |module1, module2|
  (@stdout.select { |line| line =~ /"#{module1}" -> "#{module2}"/ }).should have(1).items
end

Then /^the exit status must be (.+)$/ do |n|
  @exit_status.should == n.to_i
end

Then /^egypt must report that "([^\"]*)" is part of "([^\"]*)"$/ do |func,mod|
  line = (0...(@stdout.size)).find { |i| @stdout[i] =~ /subgraph "cluster_#{mod}"/ }
  found = false
  if line
    for i in (line...(@stdout.size))
      if @stdout[i] =~ /^\s*\}\s*$/
        break
      elsif @stdout[i] =~ /node.*"#{func}";/
        found = true
      end
    end
  end
  found.should == true
end

Then /^the output must match "([^\"]*)"$/ do |pattern|
  @stdout.select {|item| item.match(pattern)}.should have_at_least(1).items
end

Then /^the output must not match "([^\"]*)"$/ do |pattern|
  @stdout.select { |item| item.match(pattern) }.should have(0).items
end

Then /^egypt must emit a warning matching "([^\"]*)"$/ do |pattern|
  @stderr.select {|item| item.match(pattern)}.should have_at_least(1).items
end

