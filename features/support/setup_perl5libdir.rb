require 'fileutils'

top_dir = FileUtils.pwd

ENV['PERL5LIB'] += ':' + top_dir + '/lib'
