class PDFConverter < (Asciidoctor::Converter.for 'pdf')
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
