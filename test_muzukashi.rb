require File.expand_path(File.dirname(__FILE__), "muzukashi")
require 'shoulda'
require 'test/unit'
require 'fileutils'

class MuzukashiTest < Test::Unit::TestCase
  CAGE_DIR = '.cage'
  
  def check_cage
    if File.exist?(".cage")
      FileUtils.rm_rf(".cage")
    end 
  end

  context "making the cage" do
    setup do
      check_cage
    end
    
    should "succesfully create cage" do
      Muzukashi.create_cage(".")
      assert File.exist?(".cage")
    end

    should "fail if cage already exists" do
      Muzukashi.create_cage(".")
      assert_raises ArgumentError do 
        Muzukashi.create_cage(".")
      end
    end
   end
  
  context "adding bugs to the cage" do
    setup do 
      unless File.exist?(".cage")
        Dir.glob(".cage/*").each { |x| FileUtils.rm(x) }
      end
    end

    should "create a new bug in the cage" do
     assert Muzukashi.capture_bug("need to write more unit tests")
    end

  end

  context "reading the bugs" do
    setup do
      check_cage
      Muzukashi.create_cage(".")
      @bugs = Muzukashi.read_bugs
    end

    should "be successful" do
      assert @bugs
    end

    should "return hash of hashes of bugs" do
      assert @bugs.class == Hash
    end
  end

end
