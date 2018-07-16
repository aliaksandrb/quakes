require_relative './test_helper'
require 'quakes/file_reader'
require 'tempfile'

module Quakes
  class TestFileReader < Minitest::Test
    def test_fails_if_source_is_nil
      assert_raises(FileNotFoundError) { FileReader.new(nil) }
    end

    def test_fails_if_source_is_empty
      assert_raises(FileNotFoundError) { FileReader.new('') }
    end

    def test_fails_if_source_is_not_found
      assert_raises(FileNotFoundError) { FileReader.new('dummy.json') }
    end

    def test_iterates_file_by_record
      fr = FileReader.new('tests/fixtures/sample.geojson')
      records = 0
      fr.call { |l| records +=1 }

      assert_equal 3, records
    end

    def test_emits_nothing_for_bad_file
      file = Tempfile.new(['test', '.geojson'])
      file.write('hello world')

      fr = FileReader.new(file.path)
      records = 0
      fr.call { |l| records += 1 }

      assert_equal 0, records
    ensure
      file.close
      file.unlink
    end

    def test_handles_removed_files_after_start
      file = Tempfile.new(['test', '.geojson'])
      fr = FileReader.new(file.path)
      file.close
      file.unlink

      records = 0
      fr.call { |l| records += 1 }

      assert_equal 0, records
    end
  end
end
