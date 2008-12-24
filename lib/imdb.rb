require 'cgi'
require 'hpricot'
require 'open-uri'
require 'htmlentities'

class IMDB
  
  attr_accessor :link
  
  def initialize(name, year = nil, link = nil)
    @name, @year, @link = name, year, link
    @coder = HTMLEntities.new
    set_doc
  end

  def score
    if @doc && score_text = @doc.search("div.meta b").first
      score_text.inner_html.match(/(.*)\/10/)[1].to_f
    else
      0
    end
  end
  
  def year
    @doc ? @doc.search("title").inner_html.match(/\s\(([0-9]{4})/)[1].to_i : @year.to_i
  end
  
  def name
    $KCODE = 'utf-8'
    @doc ? @coder.decode(@doc.search("title").inner_html.match(/(.*)\s\(/u)[1]) : @name
  end
  
private
  
  def set_doc
    if link
      @doc = Hpricot(open(link.gsub(/\/$/,'')))
    else
      query = "#{@name} (#{@year})"
      search_url = "http://www.imdb.com/find?q=#{CGI::escape(query)}"
      doc = Hpricot(open(search_url))
      case doc.search("title").inner_html
      when "IMDb Title Search" # search result page
        if !doc.search("b[text()*='Media from'] a").empty?        
          imdb_id = doc.search("b[text()*='Media from'] a").first[:href]
          movie_url = "http://www.imdb.com#{imdb_id}"
        elsif !doc.search("td[@valign='top'] a[@href^='/title/tt']").empty?
          imdb_id = doc.search("td[@valign='top'] a[@href^='/title/tt']").first[:href]
          movie_url = "http://www.imdb.com#{imdb_id}"
        end
        @doc = Hpricot(open(movie_url))
      when "IMDb Search"
        @doc = nil
      else # direct in movie page
        @doc = doc
      end
    end
  end
    
end