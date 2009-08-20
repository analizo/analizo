task :default => ['test:unit', 'test:cucumber']

task 'test:unit' do
  sh('prove t/')
end

task 'test:cucumber' do
  sh('cucumber t/features/')
end
