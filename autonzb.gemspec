# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{autonzb}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pirate"]
  s.date = %q{2008-12-26}
  s.default_executable = %q{autonzb}
  s.description = %q{Ruby tool to automatically download x264 HD nzb movies files from newzleech.com}
  s.email = %q{pirate.2061@gmail.com}
  s.executables = ["autonzb"]
  s.extra_rdoc_files = ["bin/autonzb", "lib/imdb.rb", "lib/inspector.rb", "lib/movie.rb", "lib/nfo.rb", "lib/nzb.rb", "README.markdown"]
  s.files = ["asset/failure.png", "bin/autonzb", "lib/imdb.rb", "lib/inspector.rb", "lib/movie.rb", "lib/nfo.rb", "lib/nzb.rb", "Manifest", "Rakefile", "README.markdown", "autonzb.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/pirate/autonzb}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Autonzb", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{autonzb}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby tool to automatically download x264 HD nzb movies files from newzleech.com}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<optiflag>, [">= 0"])
      s.add_runtime_dependency(%q<rubyzip>, [">= 0"])
      s.add_runtime_dependency(%q<htmlentities>, [">= 0"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<optiflag>, [">= 0"])
      s.add_dependency(%q<rubyzip>, [">= 0"])
      s.add_dependency(%q<htmlentities>, [">= 0"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<optiflag>, [">= 0"])
    s.add_dependency(%q<rubyzip>, [">= 0"])
    s.add_dependency(%q<htmlentities>, [">= 0"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
