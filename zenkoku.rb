#!/usr/bin/env ruby
require 'csv'
require 'nokogiri'
require 'open-uri'

STDERR.puts("[#{Time.now}] Starting script...")

BASE_URL = 'http://tabroom.jp'

tabroom = Nokogiri::HTML(open(BASE_URL + '/shop'))
prefectures = tabroom.css('.areaName')
$http_calls = 1
$retries = 0

def get_shop_list(path)
  shop_list = nil
  until shop_list
    begin
      $http_calls += 1
      shop_list = Nokogiri::HTML(open(path))
    rescue OpenURI::HTTPError
      sleep(1)
      $retries += 1
    end
  end
  shop_list
end

CSV do |csv|
  csv << %w{等道府県 店名前}
  prefectures.each do |prefecture|
    link_node = prefecture.at_xpath('a')
    todofuken = link_node.child
    shop_list = get_shop_list(link_node.attributes['href'].value)
    shop_list.css('.cassetteStoreName').each do |node|
      csv << [todofuken, node.child.child.text]
    end
    while next_page = shop_list.at_css('.rightSingle') do
      path = next_page.attributes['href'].value
      shop_list = get_shop_list(BASE_URL + path)
      shop_list.css('.cassetteStoreName').each do |node|
        csv << [todofuken, node.child.child.text]
      end
    end
  end
end

STDERR.puts("[#{Time.now}] #{$http_calls} calls (#{$retries} retries)")
