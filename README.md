# VarySVG (vary_svg)

VarySVG is a CLI tool that replaces placeholders in SVG templates to generate customized files.

VarySVG can help you to produce a series of files from a template and fill data. The example showcases how to produce business cards for employees.

## Requirements

VarySVG relies on an Inkscape Installation to export svg files to pdf, and on a Ghostscript Installation to merge multiple pdf files into one.

- Inkscape installation with `inkscape` executable in `PATH` (e.g. `C:\Program Files\Inkscape\bin`)
- Ghostscript installation with `gs` executable in `PATH` (e.g. `C:\Program Files\gs\gs9.54.0\bin\gs`)

If you only want to produce svg file variants from your template, you dont need those and VarySVG will be enough on its own.

## Usage

Following limitations apply to placeholder:

- Dont use `"` or `'` in placeholders, since those symbols are reserved in XPath
- Currently Boolean placeholders are not supported for modification of the template, only as enablers

## Development

- entrypoint in `bin/`
- library code in `lib/`
- example in `example`
