require 'open-uri'
require 'hpricot'
require 'zip/zip'

require File.join(File.dirname(__FILE__), 'nfo')

module Newzleech
  class NZB
  
    URL = 'http://www.newzleech.com'
    
    attr_accessor :nzbs
    
    def initialize(options = {})
      @options = options
      @options[:age] ||= 160
      @options[:pages] ||= 2
    
      @nzb_urls = []
      @nzbs = []
    
      (1..(@options[:pages].to_i)).each do |page|
        @nzb_urls << "#{URL}?group=143&minage=&age=160&min=4000&max=max&q=&m=search&adv=1&offset=#{(page.to_i - 1) * 60}"
      end
    
      parse_newzleech
    end
    
    def download(movie)
      open(movie.nzb_link).read
    end
  
  private
    
    def parse_newzleech
      $stdout.print "Parsing #{URL} for new x264 HD nzb movies, with age <= #{@options[:age]}, in last #{@options[:pages]} page(s)\n"
      @nzb_urls.each do |url|
        doc = Hpricot(open(url))
        doc.search("table.contentt").each do |table|
          raw_name = raw_name(table)
          if nfo_link = nfo_link(table)
            nfo = Nfo.new(nfo_link)
            imdb_link = nfo.imdb_link
          else
            imdb_link = imdb_link(table)
          end
          if raw_name && (imdb_link || (raw_name = find_clean_nzb_name(raw_name))) && raw_name.include?('x264')
            age = parse_age(table.search("td.age").first.inner_html) # get age of the nzb
            if age <= @options[:age].to_f
              raw_name = clean_raw_name(raw_name)
              movie = Movie.new(raw_name, :nfo => nfo, :imdb_link => imdb_link, :nzb_link => nzb_link(table), :age => age)
              @nzbs << movie
            
              $stdout.print '.'
              $stdout.flush
            end
          end
        end
      end
      $stdout.print "\n"
    end
  
    def clean_raw_name(raw_name)
      (find_clean_nzb_name(raw_name) || raw_name).strip
    end
  
    def find_clean_nzb_name(raw_name)
      if matched = raw_name.match(/^\[[0-9]*\]-\[.*\]-\[(.*)\]-/)
        matched[1]
      end
    end
  
    def raw_name(table)
      (a = table.search("td.subject a[@href^='?p=']").first) && a.inner_html
    end
  
    def nfo_link(table)
      (nfo = table.search("td.subject a[@href^='nfo.php?id=']").first) && "#{URL}/#{nfo[:href]}"
    end
  
    def imdb_link(table)
      (imdb = table.search("td.subject a[@href^='http://anonym.to/?http://www.imdb.com']").first) && imdb[:href].match(/\?(.*)/)[1]
    end
  
    def nzb_link(table)
      (nzb = table.search("td.get a[@href^='?m=gen&dl=1']").first) && "#{URL}/#{nzb[:href]}"
    end
          
    def parse_age(string)
      case string
      when /h/i
        ((string.to_f / 24) * 10).to_i / 10.0
      when /d/i
        string.to_f
      end
    end
    
  end
end