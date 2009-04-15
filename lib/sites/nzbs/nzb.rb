require 'open-uri'
require 'hpricot'
require 'zip/zip'
require 'mechanize'

require File.join(File.dirname(__FILE__), 'nfo')
require File.join(File.dirname(__FILE__), 'mechanize_hack')


module Nzbs
  class NZB
  
    URL = 'http://www.nzbs.org'
  
    attr_accessor :nzbs, :agent
  
    def initialize(options = {})
      @options = options
      @options[:age] ||= 160
      @options[:pages] ||= 2
    
      @nzb_urls = []
      @nzbs = []
    
      (1..(@options[:pages].to_i)).each do |page|
        @nzb_urls << "#{URL}/index.php?action=browse&catid=4&page=#{(page)}"
      end
      
      login
      parse_nzbs
    end
    
    def download(movie)
      @agent.get_file(movie.nzb_link)
    end
    
  private
  
    def login
      @agent = WWW::Mechanize.new
      page = @agent.get "#{URL}/index.php?action=browse&catid=4"

      form = page.forms[1]
      form.username = @options[:login]
      form.password = @options[:pass]

      @agent.submit form
    end
    
    def parse_nzbs
      $stdout.print "Parsing #{URL} for new x264 HD nzb movies, with age <= #{@options[:age]}, in last #{@options[:pages]} page(s)\n"
      @nzb_urls.each do |url|
        page = @agent.get url
        page.search("#nzbtable tr").each do |tr|
          if raw_name = raw_name(tr)
            if (age = age(tr)) <= @options[:age].to_f
              if nfo_link = nfo_link(tr)
                @nfo = Nfo.new(@agent, nfo_link(tr))
              end
              
              name, year, score = get_info_from_imdb_title(tr)
              movie = Movie.new(raw_name, :name => name,
                                          :year => year,
                                          :score => score,
                                          :imdb_link => imdb_link(tr),
                                          :nzb_link => nzb_link(tr, page),
                                          :age => age,
                                          :nfo => @nfo)
              @nzbs << movie
            
              $stdout.print '.'
              $stdout.flush
            end
          end
        end
      end
      $stdout.print "\n"
    end
    
    def raw_name(tr)
      (a = tr.search("a.nzb").first) && a.inner_html
    end
    
    def age(tr)
      age_text = (td = tr.search("td[@align='right']").first) && td.inner_html
      if age_text.include?("days ago")
        age_text.to_f
      else
        $stdout.print "AGE NOT FOUND\n"
      end 
    end
  
    def nfo_link(tr)
      (a = tr.search("small a[@href$='#nfo']").first) && a[:href]
    end
    
    def get_info_from_imdb_title(tr)
      title = (a = tr.search("small a.viewimdb").first) && a[:title]
      if title
        if matched = title.match(/^(.*)\s\(([0-9]{4}).*\s\((.*)\/10\)/)
          name = matched[1]
          year = matched[2]
          score = matched[3]
          return name, year.to_i, score.to_f
        end
      end
    end
  
    def imdb_link(tr)
      (a = tr.search("small a.viewimdb").first) && a[:href].match(/^http:\/\/anonym.to\/\?(.*)/)[1]
    end
  
    def nzb_link(tr, page)
      (a = tr.search("a.dlnzb").first) && "#{URL}/#{a[:href]}"
    end
    
  end
end