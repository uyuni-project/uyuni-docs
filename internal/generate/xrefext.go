package generate

import (
	"fmt"
	"os"
	"path/filepath"
)

// xrefConverterRuby is the Asciidoctor-PDF xref-converter extension embedded
// as a Go string constant. It overrides cross-document xref rendering in PDF
// output so that inter-module links display as human-readable bold breadcrumbs
// instead of broken hyperlinks.
//
// Breadcrumb construction rules:
//   Module  — always included; hyphens→spaces, title-cased
//   Subdir  — first path component before a '/', if present; same treatment
//   Label   — if xref has an explicit label []  it becomes the final segment as-is
//   Fragment— if no label but an anchor (#section) exists, filename + humanised fragment
//   Filename— fallback when neither label nor fragment; hyphens→spaces, title-cased
//
// Examples:
//   xref:installation-and-upgrade:container-deployment/mlm/page.adoc[Air-gapped Deployment]
//     → Installation and Upgrade Guide › Container Deployment › Air-gapped Deployment
//   xref:installation-and-upgrade:network-requirements.adoc#ports[]
//     → Installation and Upgrade Guide › Network Requirements › Ports
//   xref:administration:troubleshooting/tshoot-firewalls.adoc[]
//     → Administration Guide › Troubleshooting › Tshoot Firewalls
//
// Source: extensions/xref-converter.rb (Joseph Cayouette / Klaus Kaempf, 2019)
const xrefConverterRuby = `class PDFConverter < (Asciidoctor::Converter.for 'pdf')
  register_for 'pdf'

  MINOR_WORDS = %w[and or the in of to for a an at by from with].freeze

  def title_case(str)
    str.sub(/\.adoc$/i, '').gsub(/[-_]/, ' ').split(' ').each_with_index.map do |word, i|
      (i == 0 || !MINOR_WORDS.include?(word.downcase)) ? word.capitalize : word.downcase
    end.join(' ')
  end

  def convert_inline_anchor node
    unless node.attr('path')
      return super
    end
    @caret ||= (load_theme node.document).menu_caret_content || %( \u203a )
    refid = node.attr('refid').to_s.sub(/#.*$/, '')
    unless refid && !refid.empty?
      return super
    end
    xmodule, path = refid.split(':')
    unless path
      return super
    end
    parts      = path.split('/')
    filename   = parts.last
    first_sub  = parts.length > 1 ? parts.first : nil

    module_label = title_case(xmodule)
    module_label += ' Guide' unless xmodule == 'specialized-guides'
    out = [ module_label ]
    out << title_case(first_sub) if first_sub

    label_text = node.text.to_s
    fragment   = node.attr('fragment').to_s

    if !label_text.empty?
      out << label_text
    elsif !fragment.empty?
      out << title_case(filename)
      out << title_case(fragment)
    else
      out << title_case(filename)
    end

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
