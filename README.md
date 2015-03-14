# MRTExport

**Note: This repository is no longer maintained. It's pretty limited in its current state, but if anyone wants to take it over, feel free.**

This gem is for operating on and rendering .mrt report files. It supports most of the obvious text formatting features, as well as database queries and parameters.

Currently, only MySQL data connections are supported.

## Usage

```ruby
MRTExport.new({
  :report_file   => "/path/to/report.mrt",
  :output_file   => "/path/to/output.pdf",
  :replacements  => { "PlaceholderA" => value_a }
})
```

The export format can be accessed by the attribute `export_format`. Currently, `"pdf"` is the default, and only supported format.

## Future

 - Test with multi-page reports
 - Better support for different fonts
 - Other database types

## Licence

The MIT License (MIT)

Copyright (c) 2014 jsrn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
