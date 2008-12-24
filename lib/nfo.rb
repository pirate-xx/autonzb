require 'open-uri'

class NFO
  
  attr_accessor :srt, :imdb_link
  
  def initialize(url)
    @nfo = open(url.gsub(/\/$/,'')).read
    @srt = []
    
    parse_nfo
    @srt.uniq!
  end
  
private

  def parse_nfo
    @nfo.split(/\n/).each do |line|
      case line
      when /subtitle|sub/i
        @srt << 'fr' if line =~ /fr|fre|french/i
        @srt << 'en' if line =~ /en|eng|english/i
      when /imdb\.com\/title\//
        @imdb_link = (matched = line.match(/imdb.com\/title\/(tt[0-9]+)/)) && "http://imdb.com/title/#{matched[1]}"
      end
    end
  end
  
end
