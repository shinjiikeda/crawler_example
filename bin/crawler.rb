#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
Bundler.require

require 'uri'
require 'json'

BIN_PATH = File.expand_path(File.dirname(__FILE__))

DB_DIR  = BIN_PATH + '/../data/'
DB_FILE = DB_DIR + 'crawl.db'

if ! Dir.exists?(DB_DIR)
  Dir.mkdir(DB_DIR)
end

if File.exists?(DB_FILE)
  BASE_URL=nil
else
  BASE_URL=["http://news.yahoo.co.jp/"]
end

options = {
  :user_agent => "NewsCrawler/0.0.1",
  :storage => AnemoneKai::Storage::SQLite3(file = DB_FILE),
  :delay => 0.5,
  :depth_limit => 3,
  :read_timeout => 30,
  :verbose => true,
  :discard_page_bodies => true,
  :allow_hosts => ["headlines.yahoo.co.jp"],
  :recrawl_interval => 24*3600
}

AnemoneKai.crawl(BASE_URL, options) do |anemone|
  
  anemone.focus_crawl do |page|
    page.links.keep_if do |link|
      #link.to_s.match(PATTERN)
      #p link.to_s
      true
    end
  end

  anemone.on_every_page do |page|
    next if ! page.url.to_s.start_with?("http://headlines.yahoo.co.jp/hl?a=")
    if page.doc
      title = page.doc.title
      desc = nil
      page.doc.search("meta").each do | node |
        if node["property"] == "og:description"
          desc = node["content"]
        end
      end
      puts [page.url.to_s, title, desc ].to_json
    end
  end
  
end

