require File.join(File.dirname(__FILE__), 'imdb')
require File.join(File.dirname(__FILE__), 'nfo')

class Movie
  include Comparable
  
  attr_accessor :path, :name, :format, :source, :sound, :encoding, :year, :srt, :lang, :score, :tags, :age,
                :imdb_link, :imdb_id, :nzb_link, :nfo
  
  def initialize(raw_name, attributes = {})
    @raw_name = raw_name.gsub(/\.|\_/,' ')
    attributes.each { |k,v| self.send("#{k}=", v) }
    @srt, @tags = [], []
    
    set_name
    set_year
    set_format
    set_source
    set_sound
    set_srt
    set_lang
    set_encoding
    set_tags
    set_imdb_id
    set_data_from_imdb unless path    
  end
    
  def score
    @score ||= imdb.score
  end

  def dirname
    "#{name} (#{year}) #{tags.join(' ')} #{format} #{source} #{sound} #{encoding} #{lang} {#{imdb_id}} [#{srt.join(',')}]".gsub(/\s+/,' ')
  end

  def <=>(other_movie)
    if imdb_id && other_movie.imdb_id
      imdb_id <=> other_movie.imdb_id
    else
      "#{name} #{year}".downcase <=> "#{other_movie.name} #{other_movie.year}".downcase
    end
  end
      
private
  
  def imdb
    @imdb ||= IMDB.new(name, year, imdb_link)
  end
    
  def imdb_link
    @imdb_link || (imdb_id && "http://imdb.com/title/#{imdb_id}")
  end
  
  def set_imdb_id
    if imdb_link
      @imdb_id = imdb_link.match(/tt[0-9]+/)[0]
    elsif matched = @raw_name.match(/\{(tt[0-9]+)\}/)
      @imdb_id = matched[1]
    elsif imdb
      @imdb_id = imdb.id
      add_imdb_id_to_file if path
    else
      nil
    end
  end
  
  def set_name
    if @name.nil?
      raw_name = @raw_name.gsub(/\(|\)|\[|\]|\{|\}|\//, ' ')
      if matched = raw_name.match(/(.*)(19[0-9]{2}|20[0-9]{2})[^p]/)
        @name = matched[1]
      elsif matched = raw_name.match(/(.*)1080p/i)
        @name = matched[1]
      elsif matched = raw_name.match(/(.*)720p/i)
        @name = matched[1]
      else
        @name = ''
      end
      @name.gsub!(/REPACK|LIMITED|UNRATED|PROPER|REPOST|Directors\sCut/iu,'')
      @name.gsub!(/^\s+|\s+$/u,'')
    end
  end
  
  def set_year
    if matched = @raw_name.match(/19[0-9]{2}|20[0-9]{2}/)
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
    if nfo
      @srt = nfo.srt
    elsif matched = @raw_name.match(/\[(.*)\]/)
      matched[1].split(',').each { |srt| @srt << srt }
    else
      @srt << 'no nfo'
    end
  end
  
  def set_lang
    @lang = case @raw_name
    when /FRENCH/i
      'FRENCH'
    when /GERMAN/i
      'GERMAN'
    when /DANISH/i
      'DANISH'
    when /NORDIC/i
      'NORDIC'
    end
  end
  
  def set_tags
    @tags << 'REPACK'        if @raw_name =~ /REPACK/i
    @tags << 'LIMITED'       if @raw_name =~ /LIMITED/i
    @tags << 'UNRATED'       if @raw_name =~ /UNRATED/i
    @tags << 'PROPER'        if @raw_name =~ /PROPER/i
    @tags << 'REPOST'        if @raw_name =~ /REPOST/i
    @tags << 'OUTDATED'      if @raw_name =~ /OUTDATED/i
    @tags << 'Directors Cut' if @raw_name =~ /Directors\sCut|DirCut/i
  end
  
  def set_data_from_imdb
    @name = imdb.name
    imdb_year = imdb.year
    if !imdb_year.nil? && imdb_year != 0
      @year = imdb_year
    end
  end
  
  def add_imdb_id_to_file_if_not_present
    dir_name = File.dirname(path)
    ext_name = File.extname(path)
    base_name = File.basename(path, ext_name)
    if matched = base_name.match(/^(.*)\s(\[{1}.*\]{1})$/)
      base_name_without_srts = matched[1]
      srts = matched[2]
      new_base_name = "#{base_name_without_srts} {#{imdb_id}} #{srts}#{ext_name}"
    else
      new_base_name = "#{base_name} {#{imdb_id}}#{ext_name}"
    end
    File.rename(path, "#{dir_name}/#{new_base_name}")
    $stdout.print "Added {#{imdb_id}} (imdb id) => #{dir_name}/#{new_base_name}\n"
  end
  
end