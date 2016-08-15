#!/usr/bin/env ruby
require 'csv'
require 'nokogiri'
require 'open-uri'

BASE_URL = 'http://tabroom.jp'

tabroom = Nokogiri::HTML(open(BASE_URL + '/shop'))

prefectures = tabroom.css('.areaName')

CSV do |csv|
  csv << %w{等道府県 店名前}
  prefectures.each do |prefecture|
    link_node = prefecture.at_xpath('a')
    todofuken = link_node.child
    shop_list = Nokogiri::HTML(open(link_node.attributes['href'].value))
    pages = shop_list.css('.cf.pager.fr')
    page_paths = shop_list.css('.cf.pager.fr').xpath('li/a').map do |node|
      node.attributes['href'].value
    end.uniq
    shop_list.css('.cassetteStoreName').each do |node|
      csv << [todofuken, node.child.child.text]
    end
    page_paths.each do |path|
      shop_list = Nokogiri::HTML(open(BASE_URL + path))
      shop_list.css('.cassetteStoreName').each do |node|
        csv << [todofuken, node.child.child.text]
      end
    end
  end
end
