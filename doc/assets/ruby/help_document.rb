require 'maruku'
require 'erb'
require 'ostruct'
require 'rexml/xpath'
require 'doc/assets/ruby/toc'
include REXML


class HelpDocument
  
  def initialize(source_file)
    @source_file = source_file
    @source_tree = Maruku.new(extract_metadata_from_string(IO.read(source_file))).
      to_html_document_tree
  end

  def toc
    toc = TOC.new(html_filename, @metadata['toc-title'] || @metadata['title'] || 'Untitled',
      @metadata['toc-sort-order'].to_i || 0)
    i = 0
    XPath.each(@source_tree, "//h2") do |element|
      containing_link = Element.new('a')
      containing_link.attributes['name'] = element.text
      header_copy = element.deep_clone()
      containing_link << header_copy
      entry = TOCEntry.new(element.text, element.text, i)
      element.replace_with(containing_link)
      toc.add_subentry(entry)
      i += 1
    end
    toc
  end
  
  def render_to_file(template_path, target_path, document_root)
    vars = OpenStruct.new('content' => @source_tree.to_s, 'document_root' => document_root)
    vars.title = @metadata['title'] || 'Untitled'
    vars.toc_title = @metadata['toc-title'] || 'Untitled'
    resolved = ERB.new(IO.read(template_path), nil, '>').
      result(vars.send(:binding))
    target_path = File.catname(html_filename,
      target_path)
    file = File.open(target_path, 'w')
    file.write(resolved)
    file.close
  end
  
  def html_filename
    File.basename(@source_file, File.extname(@source_file)) + '.html'
  end
  
  def extract_metadata_from_string(string)
    @metadata = {}
    lines = string.split("\n")
    lines_copy = Array.new(lines)
    lines.each do |line|
      match = line.match(/^([a-zA-Z0-9][0-9a-zA-Z _-]*?):\s*(.*)$/)
      break if match.nil?
      @metadata[match[1].downcase] = match[2]
      lines_copy.delete_at(0)
    end
    lines_copy.join("\n")
  end
  
end