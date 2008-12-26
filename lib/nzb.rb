require 'open-uri'
require 'hpricot'
require 'zip/zip'

require File.join(File.dirname(__FILE__), 'movie')

class NZB
  
  URL = 'http://www.newzleech.com'
  
  attr_accessor :movies, :agent
  
  def initialize(inspector, download_path, options = {})
    @inspector, @download_path = inspector, download_path.gsub(/\/$/,'')
    @options = options
    @options[:age] ||= 160
    @options[:pages] ||= 2
    
    @nzb_urls = []
    @movies = []
    
    (1..(@options[:pages].to_i)).each do |page|
      @nzb_urls << "#{URL}/?group=143&minage=&age=160&min=4000&max=max&q=&m=search&adv=1&offset=#{(page.to_i - 1) * 60}"
    end
    
    parse_newzleech
    parse_movies
    keep_only_best_nzb if @inspector.backup_path
  end
  
private
    
  def parse_newzleech
    $stdout.print "Parsing #{URL} for new x264 HD nzb movies in last #{@options[:pages]} page(s)\n"
    @nzb_urls.each do |url|
      doc = Hpricot(open(url))
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
    end
    $stdout.print "\n"
  end
  
  def parse_movies
    movies.each do |movie|
      $stdout.print "#{movie.dirname}, imdb score: #{movie.score}, age: #{movie.age.to_i} day(s)\n"
      if @inspector.need?(movie)
        $stdout.print " => DOWNLOAD: #{movie.name} (#{movie.year})\n"
        download_nzb(movie, @inspector.backup_path)
        @inspector.movies << movie
      end
    end
    $stdout.print "No nzb found, maybe change -age or -page setting\n" if @movies.empty?
  end
  
  def download_nzb(movie, backup_path = nil)
    Tempfile.open("movie.nzb") do |tempfile|
      tempfile.write(open(movie.nzb_link).read) # download the nzb
      tempfile.close
      File.move(tempfile.path, "#{@download_path}/#{movie.dirname}.nzb")
      File.copy("#{@download_path}/#{movie.dirname}.nzb", "#{backup_path}/#{movie.dirname}.nzb") if backup_path
    end
  end
  
  def parse_age(string)
    case string
    when /h/i
      string.to_f / 24
    when /d/i
      string.to_f
    end
  end
  
  def keep_only_best_nzb
    size = 0
    @inspector.nzbs.each do |nzb|
      nzbs = @inspector.nzbs.select { |item| item.path != nzb.path }
      unless @inspector.need?(nzb, true, nzbs, false)
        File.delete(nzb.path)
        size += 1
      end
    end
    if size > 0
      $stdout.print "#########################################################################\n"
      $stdout.print "Deleted #{size} useless backuped nzb(s) (keep only the best nzb by movie)\n"
    end
  end
    
end