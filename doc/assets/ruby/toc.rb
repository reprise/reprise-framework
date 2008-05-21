class TOCEntry

  attr_reader :title
  attr_reader :html_name
  attr_reader :subentries
  attr_reader :order
  
  def initialize(title, html_name, order)
    @title = title
    @html_name = html_name
    @subentries = []
    @order = order
  end

  def add_subentry(subentry)
    @subentries << subentry
    @subentries.sort! {|a,b| a.order <=> b.order}
  end

end

class TOC < TOCEntry
  
  attr_reader :filepath
  
  def initialize(filepath, title, order)
    super(title, '', order)
    @filepath = filepath
  end
  
end