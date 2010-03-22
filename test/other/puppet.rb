#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../lib/puppettest'

require 'puppet'
require 'puppettest'

# Test the different features of the main puppet module
class TestPuppetModule < Test::Unit::TestCase
    include PuppetTest
    include SignalObserver

    def mkfakeclient
        Class.new(Puppet::Network::Client) do
            def initialize
            end

            def runnow
                Puppet.info "fake client has run"
            end
        end
    end

    def mktestclass
        Class.new do
            def initialize(file)
                @file = file
            end

            def started?
                FileTest.exists?(@file)
            end

            def start
                File.open(@file, "w")  {|f| f.puts ""}
            end

            def shutdown
                File.unlink(@file)
            end
        end
    end

    def test_path
        oldpath = ENV["PATH"]
        cleanup do
            ENV["PATH"] = oldpath
        end
        newpath = oldpath + ":/something/else"
        assert_nothing_raised do
            Puppet[:path] = newpath
        end

        assert_equal(newpath, ENV["PATH"])
    end

    def test_libdir
        oldlibs = $LOAD_PATH.dup
        cleanup do
            $LOAD_PATH.each do |dir|
                $LOAD_PATH.delete(dir) unless oldlibs.include?(dir)
            end
        end
        one = tempfile
        two = tempfile
        Dir.mkdir(one)
        Dir.mkdir(two)

        # Make sure setting the libdir gets the dir added to $LOAD_PATH
        assert_nothing_raised do
            Puppet[:libdir] = one
        end

        assert($LOAD_PATH.include?(one), "libdir was not added")

        # Now change it, make sure it gets added and the old one gets
        # removed
        assert_nothing_raised do
            Puppet[:libdir] = two
        end

        assert($LOAD_PATH.include?(two), "libdir was not added")
        assert(! $LOAD_PATH.include?(one), "old libdir was not removed")
    end

    def test_name
        # Make sure it defaults to $0 without the rb
        should = $0.gsub(/.+#{File::SEPARATOR}/,'').sub(/\.rb$/, '')

        assert_equal(should, Puppet[:name], "default name was not right")

        assert_nothing_raised("Could not reset name") do
            Puppet[:name] = "puppetca"
        end

        assert_equal("puppetca", Puppet[:name], "name reset did not take")
    end
end

