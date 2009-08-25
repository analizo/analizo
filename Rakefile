task :default => ['test', 'features']

task 'test' do
  sh('prove t/')
end

task 'features' do
  sh('cucumber t/features/')
end
