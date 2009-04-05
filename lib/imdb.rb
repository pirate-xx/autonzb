require 'cgi'
require 'hpricot'
require 'open-uri'
require 'htmlentities'

class IMDB
  
  attr_accessor :link, :doc, :id
  
  def initialize(name, year = nil, link = nil)
    # $stdout.print 'i'
    @try = 3
    @name, @year, @link = name, year, link
    @coder = HTMLEntities.new
    set_doc
    set_id
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
    if @link
      @doc = Hpricot(open(@link.gsub(/\/\s*$/,'')))
      @id = @link.match(/tt[0-9]+/)[0]
    else
      query = "#{@name} (#{@year})"
      search_url = "http://www.imdb.com/find?q=#{CGI::escape(query)}"
      doc = Hpricot(open(search_url))
      case doc.search("title").inner_html
      when "IMDb Title Search", "IMDb Search" # search result page
        if !doc.search("b[text()*='Media from'] a").empty?        
          imdb_id = doc.search("b[text()*='Media from'] a").first[:href]
          movie_url = "http://www.imdb.com#{imdb_id}"
        elsif !doc.search("td[@valign='top'] a[@href^='/title/tt']").empty?
          imdb_id = doc.search("td[@valign='top'] a[@href^='/title/tt']").first[:href]
          movie_url = "http://www.imdb.com#{imdb_id}"
        else
          movie_url = nil
        end
        if movie_url
          @doc = Hpricot(open(movie_url))
          @id = movie_url.match(/tt[0-9]+/)[0]
        end
      else # direct in movie page
        @doc = doc
      end
    end
  rescue
    if @try > 0
      @try -= 1
      $stdout.print '*'
      sleep 2
      set_doc #retry
    else
      @doc = nil
    end
  end
  
  def set_id
    @id ||= doc.search("a[@href*='/title/tt']").first[:href].match(/tt[0-9]+/)[0] if doc
  end
    
end