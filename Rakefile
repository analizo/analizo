# encoding: utf-8

version = File.readlines('lib/Analizo.pm').find { |item| item =~ /VERSION =/ }.strip.gsub(/.*VERSION = '(.*)'.*/, '\1')

desc 'prepares a release tarball and a debian package'
task :release => [:check_repo, :check_tag, :check_debian_version] do
  sh "perl Makefile.PL"
  sh "make"
  sh "make test"
  sh "make dist"
  sh "mv analizo-#{version}.tar.gz ../analizo_#{version}.tar.gz"
  sh 'git buildpackage'
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

desc 'checks if debian version is in sync with "upstream" version'
task :check_debian_version do
  debian_version = `dpkg-parsechangelog | grep Version | awk '{print $2}'`.strip
  if debian_version != version
    raise "******** Upstream version is #{version}, but Debian version is #{debian_version}."
  end
end
