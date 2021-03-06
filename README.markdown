# AutoNZB
  
Ruby tool to automatically download x264 HD nzb movies files from newzleech.com
Currently only english and french subtitles are supported, but it's super easy to add your own language.
  
## Install

    sudo gem install pirate-autonzb --source http://gems.github.com

## Usage

In your terminal:

    autonzb -d /path/of/download/nzb/directory
    
Will download new x264 HD movies nzb from newzleech.com, with imdb score >= 7.0, year >= 1950 and nzb age <= 160 days

    autonzb -d /path/of/download/nzb/directory -backup /path/of/backuped/already/downloaded/nzb
    
-backup option it's very useful to prevent useless re-download of nzb already downloaded

    autonzb -d /path/of/download/nzb/directory -movies /path/with/already/downloaded/movies -age 1 -imdb 7.5 -year 1980 -srt fr,en
    
Will download only new nzb of the day with imdb score >= 7.5, year >= 1980 and subtitles french or english (and unknown srt).
The -movies setting prevents already owned movies to be re-downloaded (only if the owned movie is 'better' than the new release),
movies folder need to follow the name convention (especially {imdb_id})

more details with:

    autonzb -h
    
## Folder Name Convention

AutoNZB use (and needs if you want to use -movies options) specific folders name for your movies:

    name of the movie (year) tag(s) format source sound encoding lang {imdb_id} [srt(s)]
    
    Burn After Reading (2008) PROPER 1080p BluRay DTS x264 {tt0887883} [fr,en]
    Le Fabuleux Destin d'Amelie Poulain (2001) 720p BluRay x264 FRENCH {tt0211915} [en]
    ...
    
## MIT License

Copyright (c) 2008 Pirate
 
Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
 
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.