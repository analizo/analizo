# encoding: utf-8

version = File.readlines('lib/Analizo.pm').find { |item| item =~ /VERSION =/ }.strip.gsub(/.*VERSION = '(.*)'.*/, '\1')

desc 'prepares a release tarball and a debian package'
task :release => [:check_debian_version] do
  sh "perl Makefile.PL"
  sh "make"
  sh "make test"
  sh "make dist"
  sh "mv analizo-#{version}.tar.gz ../analizo_#{version}.tar.gz"
  sh 'git buildpackage'
  sh "git tag #{version}"
end

desc 'checks if debian version is in sync with "upstream" version'
task :check_debian_version do
  debian_version = `dpkg-parsechangelog | grep Version | awk '{print $2}'`.strip
  if debian_version != version
    raise "******** Upstream version is #{version}, but Debian version is #{debian_version}."
  end
end
