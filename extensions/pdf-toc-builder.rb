require 'asciidoctor-pdf'

class CustomPdfConverter < Asciidoctor::PDF::Converter
  register_for 'pdf'

  def convert_document(doc)
    puts "🚀 CustomPdfConverter is active"
    @custom_doc = doc
    @start_time = Time.now
    super
  end

  def layout(doc)
    puts "📄 Beginning layout phase..."
    super

    if @page.nil?
      puts "❌ No pages initialized. Cannot render custom TOC."
      return
    end

    puts "📘 Starting custom TOC generation..."
    allocate_custom_toc(@custom_doc)
    puts "✅ Custom TOC generation complete in #{(Time.now - @start_time).round(2)}s"
  end

  def allocate_custom_toc(doc)
    start_new_page

    margin = (theme && theme[:vertical_rhythm]) || 12
    move_down margin

    theme_font :heading, level: 1 do
      toc_title = doc.attr('toc-title') || 'Contents'
      puts "📝 TOC Title: #{toc_title}"
      layout_prose toc_title, align: :left, margin_bottom: margin
    end

    doc.sections.each_with_index do |section, idx|
      next unless section.level == 1

      title = section.numbered_title || section.title
      page_num = (section.attr 'pdf-page-start').to_s rescue '?'

      leader = theme&.dig(:toc, :dot_leader, :content) || ''
      spacing = [2, 72 - title.length].max
      dots = leader.empty? ? ' ' * spacing : leader * spacing

      puts "📘 TOC: #{idx + 1}. #{title} .... #{page_num}"
      layout_prose "#{idx + 1}. #{title} #{dots} #{page_num}", margin_bottom: margin / 3

      subs = section.sections.select { |s| s.level == 2 }
      if subs.any?
        flattened = subs.map do |sub|
          sub_title = sub.title.to_s.tr("\n", ' ')
          sub_page = (sub.attr('pdf-page-start') || '?').to_s
          puts "  ↳ #{sub_title} .... #{sub_page}"
          "#{sub_title} #{sub_page}"
        end.join(' • ')

        theme_font :base do
          indent 20 do
            layout_prose flattened, margin_bottom: margin / 2
          end
        end
      end
    end
  end
end
