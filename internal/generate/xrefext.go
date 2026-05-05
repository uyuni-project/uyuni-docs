package generate

import (
	"fmt"
	"os"
	"path/filepath"
)

// xrefConverterRuby is the Asciidoctor-PDF xref-converter extension embedded
// as a Go string constant. It overrides cross-document xref rendering in PDF
// output so that inter-module links display as "Module › Subdir" in bold
// instead of broken hyperlinks.
//
// Source: extensions/xref-converter.rb (Joseph Cayouette / Klaus Kaempf, 2019)
const xrefConverterRuby = `class PDFConverter < (Asciidoctor::Converter.for 'pdf')
  register_for 'pdf'
  def convert_inline_anchor node
    unless node.attr('path')
      return super
    end
    @caret ||= (load_theme node.document).menu_caret_content || %( \u203a )
    refid = node.attr('refid')
    unless refid
      return super
    end
    fragment = node.attr('fragment')
    if fragment
      return super
    end
    xmodule, path = refid.split(':')
    unless path
      return super
    end
    subdir, _filename = path.split('/')
    out = [ xmodule.capitalize ]
    out << subdir.capitalize if subdir
    %(<strong>#{out.join(@caret)}</strong>)
  end
end
`

// WriteXrefExtension writes the embedded xref-converter Ruby extension to
// destPath (e.g. .bin/xref-converter.rb). Safe to call repeatedly — it
// overwrites the file if it already exists.
func WriteXrefExtension(destPath string) error {
	if err := os.MkdirAll(filepath.Dir(destPath), 0o755); err != nil {
		return fmt.Errorf("xref-converter: mkdir: %w", err)
	}
	if err := os.WriteFile(destPath, []byte(xrefConverterRuby), 0o644); err != nil {
		return fmt.Errorf("xref-converter: write %s: %w", destPath, err)
	}
	return nil
}
