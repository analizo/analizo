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
