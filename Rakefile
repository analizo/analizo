task :default => ['test', 'features']

task 'test' do
  sh('prove t/')
end

task 'features' do
  sh('cucumber features/')
  sh('make clean -C t/sample/')
end
