require 'colorize'

namespace :faker do
  namespace :generate do
    
    desc "Generate fake sources"
    task sources: :environment do
      
      puts ""
      puts "=== GENERATING FAKE SOURCES ==="
      
      puts "Deleting all current sources"
      Media::Source.delete_all
      
      sources = ['youtube', 'lastfm', 'soundcloud']
      
      [Media::Song, Media::Album, Media::Artist, Media::Event].each do |klass|
        
        puts "Generating sources for #{klass.to_s.demodulize.tableize}"
        
        klass.all.each do |obj|
          sources.shuffle
          (1..rand(0..2)).each do |n|
            obj.sources << Media::Source.create(
              foreign_id: SecureRandom.hex(10),
              name: sources[n-1]
            )
          end
        end
        
      end
      
    end
    
  end
end