require File.join(File.dirname(__FILE__), 'imdb')
require File.join(File.dirname(__FILE__), 'nfo')

class Movie
  include Comparable
  
  attr_accessor :path, :name, :format, :source, :sound, :encoding, :year, :srt, :lang, :score, :tags, :age,
                :imdb_link, :nfo_link, :nzb_link
  
  def initialize(raw_name, attributes = {})
    @raw_name = raw_name.gsub(/\.|\_/,' ')
    attributes.each { |k,v| send("#{k}=", v) }
    @srt, @tags = [], []
    
    set_imdb_link
    set_name
    set_format
    set_source
    set_sound
    set_srt
    set_lang
    set_encoding
    set_tags
    set_year
  end
    
  def score
    @score ||= imdb.score
  end

  def dirname
    "#{name} (#{year}) #{tags.join(' ')} #{format} #{source} #{sound} #{encoding} #{lang} [#{srt.join(',')}]".gsub(/\s+/,' ')
  end

  def <=>(other_movie)
    "#{name} #{year}".downcase <=> "#{other_movie.name} #{other_movie.year}".downcase
  end
      
private
  
  def imdb
    @imdb ||= IMDB.new(name, year, imdb_link)
  end
  
  def nfo
    @nfo ||= NFO.new(nfo_link)
  end
  
  def set_imdb_link
    @imdb_link = nfo.imdb_link if imdb_link.nil? && nfo_link
  end
  
  def set_name
    @name = imdb.name if imdb_link
    if @name.nil?
      raw_name = @raw_name.gsub(/\(|\)|\[|\]|\{|\}|\//, ' ')
      if matched = raw_name.match(/(.*)[0-9]{4}[^p]/)
        @name = matched[1]
      elsif matched = raw_name.match(/(.*)[0-9]{3,4}p/)
        @name = matched[1]
      else
        @name = ''
      end
      @name.gsub!(/REPACK|LIMITED|UNRATED|PROPER|REPOST|Directors\sCut/iu,'')
      @name.gsub!(/^\s+|\s+$/u,'')
    end
  end
  
  def set_year
    @year = imdb.year if imdb_link
    if (year.nil? || year == 0) && matched = @raw_name.match(/19[0-9]{2}|20[0-9]{2}/)
      @year = matched[0].to_i
    end
  end
  
  def set_format
    @format = case @raw_name
    when /1080p/i
      '1080p'
    when /720p/i
      '720p'
    end
  end
  
  def set_encoding
    @encoding = case @raw_name
    when /x264/i
      'x264'
    when /VC1/i
      'VC1'
    when /PS3/i
      'PS3'
    when /divx/i
      'DIVX'
    when /xvid/i
      'XVID'
    end
  end
  
  def set_source
    @source = case @raw_name
    when /Blu\s?Ray|Blu-Ray|BDRip/i
      'BluRay'
    when /HDDVD/i
      'HDDVD'
    when /HDTV/i
      'HDTV'
    when /DVD/i
      'DVD'
    end
  end
  
  def set_sound
    @sound = case @raw_name
    when /DTS/i
      'DTS'
    when /AC3/i
      'AC3'
    end
  end
  
  def set_srt
    if nfo_link
      @srt = nfo.srt
    elsif matched = @raw_name.match(/\[(.*)\]/)
      matched[1].split(',').each { |srt| @srt << srt }
    end
  end
  
  def set_lang
    @lang = case @raw_name
    when /FRENCH/
      'FRENCH'
    when /GERMAN/
      'GERMAN'
    end
  end
  
  def set_tags
    @tags << 'REPACK'        if @raw_name =~ /REPACK/i
    @tags << 'LIMITED'       if @raw_name =~ /LIMITED/i
    @tags << 'UNRATED'       if @raw_name =~ /UNRATED/i
    @tags << 'PROPER'        if @raw_name =~ /PROPER/i
    @tags << 'REPOST'        if @raw_name =~ /REPOST/i
    @tags << 'OUTDATED'      if @raw_name =~ /OUTDATED/i
    @tags << 'Directors Cut' if @raw_name =~ /Directors\sCut/i
  end
  
end