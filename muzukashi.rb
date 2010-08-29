require 'active_support/secure_random'
require 'fileutils'
require 'pathname'
require 'yaml'

module Muzukashi
   mapping = {}
   CACHE = "/tmp/muzukashi_cache.tmp"
  def self.create_cage(dir)
    if File.exist?(File.join(dir, '/.cage'))
      raise ArgumentError, "already a cage in #{dir}"
    end
   FileUtils.mkdir(File.join(dir, '/.cage')) 
  end
  
 def self.random_filename
   random_string = ActiveSupport::SecureRandom.hex(16)
   name = random_string + ".txt"
 end

  def self.capture_bug(bug)
    raise ArgumentError, "cage doesn't exist" if !File.exist?(".cage")
    name = self.random_filename
    contents = {
     :name => bug,
     :created => Time.now.strftime("%A %B %Y"),
     :state => :new
    }
    old_path = Dir.pwd
    Dir.chdir(".cage")
    File.open(name, "w") do |f|
      YAML.dump(contents, f)
    end
    Dir.chdir(old_path)
    
  end

  def self.read_bugs(print=true)
    finished_hash = {}
    @bugs = Dir.glob(".cage/*")
    if @bugs.nil? || @bugs.empty?
      puts "no bugs"
      exit
    end

   mapping = {}

   @bugs.each_with_index do |f, i|
      name = Pathname.new(f).basename.to_s
      content = File.open(f) { |z| z.read }
      hashed_content = YAML.load(content).to_hash
      hashed_content[:id] = (i + 1).to_s
      mapping[hashed_content[:id]] = f

      cache = get_cache
      cache.invert
      if cache[f]
       begining = cache[f] + "." + hashed_content[:name]
      else
       begining = hashed_content[:id] + "." + hashed_content[:name]
      end

     ending = hashed_content[:created].to_s + "(" + hashed_content[:state].to_s + ")"
      puts begining.ljust(50) + ending.rjust(20) if print
   end
   self.write_cache(mapping) 
  end 
 
 def self.write_cache(map)
   Dir.chdir("/tmp")
    File.open("muzukashi_cache.tmp", "w") do |cache|
      YAML.dump(map, cache)
    end
 end

 def self.cache?
  File.exist?(CACHE) 
 end


 def self.get_cache(mapping=nil)
   if cache?
     File.open(CACHE) do |cache|
       return YAML.load(cache.read)
     end
   end
 end

 def update_cache(id)
   cache = get_cache
   if cache[id]
     cache.delete(id)
   end 
 end 

  def self.remove_bug(id)
    mapping = get_cache  
    delete = mapping[id.to_s]
    if delete
      FileUtils.rm(delete)
      true
     end
   end
end
