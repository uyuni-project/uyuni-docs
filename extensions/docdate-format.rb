###
### This is the AsciiDoctor-PDF {docdate} publication date converter template for SUSE/Uyuni Documentation
### This template converts from ISO 8601 to US Long Format in preface pages and elsewhere
###
### Joseph Cayouette (jcayouette@suse.com), 2025
###
Asciidoctor::Extensions.register do
    document.attributes['docdate'] = Time.now.strftime("%B %d, %Y") # Example: "March 19, 2025"
  end
  