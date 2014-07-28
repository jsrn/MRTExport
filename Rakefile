task :test do
  Dir["test/*_spec.rb"].each do |file|
    puts `rspec #{file}`
  end
end

task :clean do
  `rm test/test_output/*.pdf`
end

task :default => :test