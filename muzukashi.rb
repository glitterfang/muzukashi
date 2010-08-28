require 'active_support/secure_random'
require 'fileutils'
require 'pathname'
require 'yaml'

module Muzukashi
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

  def self.read_bugs
    finished_hash = {}
   Dir.glob(".cage/*").each do |f|
      name = Pathname.new(f).basename.to_s
      content = File.open(f) { |z| z.read }
      finished_hash[name.to_sym] = YAML.load(content)
   end
   finished_hash
  end
end
