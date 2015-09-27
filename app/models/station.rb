class Station
  require 'rexml/document'

  STATIONS_URL = 'http://www.ekidata.jp/api/l/11302.xml'

  # 駅データAPIから山手線の駅一覧を取得
  def self.list
    xml_data = Net::HTTP.get_response(URI.parse(STATIONS_URL)).body
    Hash.from_xml(xml_data.to_s)['ekidata']['station']
  end

  # 駅名から駅情報を取得
  def self.find_by_name(station_name)
    list.select{ |s| s['station_name'] == station_name }.first
  end
end
