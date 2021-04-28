require 'bundler'
Bundler.require

local_dir =File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(local_dir)

require 'scrapper'

test = Scrapper.new("val-d-oise")

test.save_as_spreadsheet