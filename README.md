# MRTExport

*Now in gem form!*

## About

Quick and dirty script for basic .mrt to .pdf export. The code is pretty appalling, and it only really works for the small test reports I've used. On the off chance that this is of interest to anyone else on the planet, pull requests are welcome!

## Usage

```ruby
MRTExport.new({
  :report_file   => "/path/to/report.mrt",
  :output_file   => "/path/to/output.pdf",
  :export_format => "pdf",
  :replacements  => {"PlaceholderA" => value_a}
})
```

## Licence

MIT

## TODO

- [ ] Increased feature coverage
  - [ ] Other DB types (only MySQL implemented so far)
- [ ] Formatting
  - [ ] Reasonable font alternatives
  - [ ] Proper footer positioning
  - [ ] Multi-page flow