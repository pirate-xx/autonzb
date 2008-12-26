require File.join(File.dirname(__FILE__), 'movie')

class Inspector
  
  attr_accessor :backup_path, :movies, :nzbs
  
  def initialize(paths, options = {})
    @paths = paths.split(',').map { |p| p.gsub(/\/$/,'') }
    @options = options
    @options[:srt] = @options[:srt] ? @options[:srt].split(',') : ['none']
    @options[:imdb_score] = @options[:imdb_score] ? @options[:imdb_score].to_f : 7.0
    @options[:year] = @options[:year] ? @options[:year].to_i : 1950
    
    @movies = []
    initialize_movies
    
    if @options[:backup]
      @backup_path = @options[:backup].gsub(/\/$/,'') 
      @nzbs = []
      initialize_nzbs
      @movies = @nzbs + @movies
    end
    
    $stdout.print "Movie criteria: imdb score >= #{@options[:imdb_score]}, year >= #{@options[:year]} and srt [#{@options[:srt].join(',')}]\n"
  end
  
  def need?(movie, not_validate = false, movies = @movies, log = true)
    if not_validate || valid?(movie)
      $stdout.print " => movie has required criteria " if log
      if m = movies.detect { |m| m == movie }
        $stdout.print "but is already owned " if log
        if srt_score(movie) > srt_score(m)
          $stdout.print "but new movie has better subtitle: [#{movie.srt.join(',')}]\n" if log
          true
        elsif srt_score(movie) == srt_score(m)
          if format_score(movie) > format_score(m)
            $stdout.print "but new movie has better format: #{movie.format}\n" if log
            true
          elsif format_score(movie) == format_score(m)
            if source_score(movie) > source_score(m)
              $stdout.print "but new movie has better source: #{movie.source}\n" if log
              true
            elsif source_score(movie) == source_score(m)
              if sound_score(movie) > sound_score(m)
                $stdout.print "but new movie has better sound: #{movie.sound}\n" if log
                true
              else
                $stdout.print "with same srt, format, source and sound\n" if log
                false
              end
            else
              $stdout.print "with same srt, format and better source: #{m.source}\n" if log
              false
            end
          else
            $stdout.print "with same srt and better format: #{m.format}\n" if log
            false
          end
        else
          $stdout.print "with better subtitle: [#{m.srt.join(',')}]\n" if log
          false
        end
      else
        $stdout.print "and is not already owned\n" if log
        true
      end
    else
      $stdout.print " => movie doesn't have required criteria\n" if log
      false
    end
  end
  
  def self.growl(title, msg, pri = 0)
    system("/usr/local/bin/growlnotify -w -n autonzb --image #{File.dirname(__FILE__) + "/../asset/failure.png"} -p #{pri} -m #{msg.inspect} #{title} &") 
  end
  
private

  def initialize_movies
    @paths.each do |path|
      old_movies_size = @movies.size
      base_dir = clean_dir(Dir.new(path))
      base_dir.each do |movie|
        movie_path = "#{path}/#{movie}"
        @movies << Movie.new(movie, :path => movie_path) if File.directory?(movie_path)
      end
      $stdout.print "Found #{@movies.size - old_movies_size} movie(s) in #{path}\n"
    end
  end
  
  def initialize_nzbs
    base_dir = clean_dir(Dir.new(@backup_path))
    base_dir.each do |nzb|
      nzb_path = "#{@backup_path}/#{nzb}"
      @nzbs << Movie.new(nzb, :path => nzb_path) if File.extname(nzb_path) == '.nzb'
    end
    $stdout.print "Found #{@nzbs.size} backuped nzb(s) in #{@backup_path}\n"
  end

  def clean_dir(dir)
    dir.select { |e| !["..", ".", ".DS_Store"].include?(e) }
  end
  
  def valid?(movie)
    srt_size = @options[:srt].size
    (((@options[:srt] - movie.srt).size < srt_size) || @options[:srt].include?('none')) &&
    movie.year >= @options[:year] && movie.score >= @options[:imdb_score]
  end
  
  def srt_score(movie)
    srts = @options[:srt].reverse
    movie.srt.inject(-1) do |score, srt|
      s = (i = srts.index(srt)) ? i : -1
      score = s if s > score
      score
    end
  end
  
  def format_score(movie)
    case movie.format
    when '1080p'; 2
    when '720p';  1
    else;         0
    end
  end
  
  def source_score(movie)
    case movie.format
    when 'BluRay'; 4
    when 'HDDVD';  3
    when 'HDTV';   2
    when 'DVD';    1
    else;          0
    end
  end
  
  def sound_score(movie)
    movie.format == 'DTS' ? 1 : 0    
  end

end