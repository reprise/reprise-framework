require 'erb'
require 'ostruct'
require 'pathname'

class HelpBuilder
  
  DEFAULT_CONTENT_TEMPLATE = 'default_content.rhtml'
  TOC_TEMPLATE = 'toc.rhtml'
  
  def initialize(docs_path, template_path)
    @docs_path = Pathname.new(docs_path)
    @template_path = template_path
  end
  
  def copy_resource_files_to_path(path)
    target_path = Pathname.new(path)
    FileList["#{@docs_path}/**/*"].each do |item|
      item_path = Pathname.new(item)
      next if item_path.extname.downcase == '.md' || item_path.basename.to_s[0,1] == '.'
      item_target_path = target_path + item_path.relative_path_from(@docs_path)
      next if item_target_path.exist?
      if (item_path.directory?)
        item_target_path.mkpath
      else
        File.copy(item_path, item_target_path)
      end
    end
  end
  
  def render_toc_of_documents_to_path(docs, path, document_root)
    toc = TOC.new('', '', 0)
    docs.each do |doc|
      toc.add_subentry(doc.toc)
    end
    vars = OpenStruct.new('toc' => toc, 'document_root' => document_root)
    resolved = ERB.new(IO.read(File.catname(TOC_TEMPLATE, @template_path)), nil, '>').
      result(vars.send(:binding))
    target_path = File.catname('toc.html', path)
    file = File.open(target_path, 'w')
    file.write(resolved)
    file.close
  end
  
  def render_contents_of_dir_to_path(source_path, target_path, document_root)
    docs = []
    relative_document_root = document_root.realpath.relative_path_from(source_path.realpath).to_s
    source_path.each_entry do |item|
      next if item.to_s[0,1] == '.'
      item_target_path = target_path.realpath + item
      item = source_path.realpath + item
      if (item.directory?)
        render_contents_of_dir_to_path(item.realpath, item_target_path, document_root.realpath)
        next
      elsif item.extname.downcase != '.md'
        next
      end
      target_file_name = item.basename(item.extname).to_s + '.html'
      doc = HelpDocument.new(item.to_s)
      doc.render_to_file(File.catname(DEFAULT_CONTENT_TEMPLATE, @template_path), 
        item_target_path.dirname + target_file_name, 
        relative_document_root.to_s)
      docs << doc
    end
    render_toc_of_documents_to_path(docs, target_path.to_s, relative_document_root.to_s) \
      if docs.length > 0
  end
  
  def render_to_path(path)
    copy_resource_files_to_path(path)
    render_contents_of_dir_to_path(@docs_path, Pathname.new(path), @docs_path.realpath)
  end
end