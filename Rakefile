task :default => ['test', 'features']

desc 'Run unit tests'
task 'test' do
  sh('prove t/')
end

desc 'Run unit tests'
task 'features' do
  sh('cucumber features/')
  sh('make clean -C t/sample/')
end

desc 'updates MANIFEST from contents of git repository'
task 'manifest' do
  sh('git ls-tree -r --name-only HEAD > MANIFEST')
end

version = File.readlines('egypt').find { |item| item =~ /VERSION =/ }.strip.gsub(/.*VERSION = '(.*)'.*/, '\1')

desc 'prepares a release tarball'
task :release => [:manifest, :check_repo, :check_tag, :default] do
  sh "perl Makefile.PL"
  sh "make"
  sh "make test"
  sh "make dist"
  sh "git tag #{version}"
end

desc 'checks if there are uncommitted changes in the repo'
task :check_repo do
  sh "git status | grep 'nothing to commit'" do |ok, res|
    if !ok
      raise "******** There are uncommited changes in the repository, cannot continue"
    end
  end
end

desc 'checks if there is already a tag for the curren version'
task :check_tag do
  sh "git tag | grep '^#{version}$' >/dev/null" do |ok, res|
    if ok
      raise "******** There is already a tag for version #{version}, cannot continue"
    end
  end
  puts "Not found tag for version #{version}, we can go on."
end
