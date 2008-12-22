require 'open-uri'
require 'hpricot'
require 'zip/zip'

require File.join(File.dirname(__FILE__), 'movie')

class NZB
  
  URL = 'http://www.newzleech.com'
  
  attr_accessor :movies, :agent
  
  def initialize(inspector, download_path, options = {})
    @options = options
    @options[:age] ||= 160
    @options[:page] ||= 0
    
    @nzb_url = "#{URL}/?group=143&minage=&age=160&min=4000&max=max&q=&m=search&adv=1&offset=#{@options[:page].to_i * 60}"
    @movies = []
    
    parse_newzleech
    movies.each do |movie|
      $stdout.print "#{movie.dirname}, imdb score: #{movie.score} age: #{movie.age.to_i} day(s)\n"
      if inspector.need?(movie)
        $stdout.print  " => DOWNLOAD: #{movie.name} (#{movie.year})\n"
        download_nzb(download_path, movie)
      end
    end
    $stdout.print "No nzb found, maybe change -age or -page setting\n" if @movies.empty?
  end
  
  def download_nzb(download_path, movie)
    path = download_path.gsub(/\/$/,'') # removed / at the end
    Tempfile.open("movie.nzb") do |tempfile|
      tempfile.write(open(movie.nzb_link).read) # download the nzb
      tempfile.close
      File.move(tempfile.path, "#{path}/#{movie.dirname}.nzb")
    end
  end
  
private
    
  def parse_newzleech
    $stdout.print "Parsing #{URL} for new x264 HD nzb movies\n"
    doc = Hpricot(open(@nzb_url))
    doc.search("table.contentt").each do |table|
      if (a = table.search("td.subject a[@href^='posts/?p=']").first) && a.inner_html !=~ /^\<img/
        age = parse_age(table.search("td.age").first.inner_html) # get age of the nzb
        if age <= @options[:age].to_f
          raw_name = a.inner_html
          nfo_link = (nfo = table.search("td.subject a[@href^='nfo.php?id=']").first) && "#{URL}/#{nfo[:href]}"
          imdb_link = (imdb = table.search("td.subject a[@href^='http://anonym.to/?http://www.imdb.com']").first) && imdb[:href].match(/\?(.*)/)[1]
          nzb_link = (nzb = table.search("td.get a[@href^='?m=gen&dl=1']").first) && "#{URL}/#{nzb[:href]}"
          
          movie = Movie.new(raw_name, :nfo_link => nfo_link, :imdb_link => imdb_link, :nzb_link => nzb_link, :age => age)
          @movies << movie
          
          $stdout.print '.'
          $stdout.flush
        end
      end
    end
    $stdout.print "\n"
  end
  
  def parse_age(string)
    case string
    when /h/i
      string.to_f / 24
    when /d/i
      string.to_f
    end
  end
    
end