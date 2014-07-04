Gem::Specification.new do |s|
  s.name        = 'mrtexport'
  s.version     = '0.0.5'
  s.date        = '2014-07-04'
  s.summary     = "A renderer for MRT files."
  s.description = "An exporter/renderer for .mrt report files."
  s.authors     = ["jsrn"]
  s.email       = 'james.srn@gmail.com'
  s.files       = [
                    "lib/mrtexport.rb",
                    "lib/dbdb_builder.rb",
                    "lib/data_band.rb",
                    "lib/stylist.rb",
                    "lib/util.rb"
                  ]
  s.homepage    = 'https://github.com/jsrn/MRTExport'
  s.license       = 'MIT'

  s.add_runtime_dependency "prawn",    '~> 1.1', '>= 1.1.0'
  s.add_runtime_dependency "nokogiri", '~> 1.6', '>= 1.6.2.1'
  s.add_runtime_dependency "mysql2",   '~> 0.3', '>= 0.3.16'
end