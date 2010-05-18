local_lib = File.expand_path(File.dirname(__FILE__) + '/../../lib')

if ENV['PERL5LIB']
  ENV['PERL5LIB'] = [local_lib, ENV['PERL5LIB']].join(':')
else
  ENV['PERL5LIB'] = local_lib
end
