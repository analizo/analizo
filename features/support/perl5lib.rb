local_lib = File.dirname(File.dirname(__FILE__))

if ENV['PERL5LIB']
  ENV['PERL5LIB'] = [local_lib, ENV['PERL5LIB']].join(':')
else
  ENV['PERL5LIB'] = local_lib
end
