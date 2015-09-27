class HalalShop
  HALAL_SHOP_URL = "https://www.halalgourmet.jp/api/map.json?zoom=15&x=%{latitude}&y=%{longtitude}"

  # 指定した位置を中心にしたハラル店舗を取得
  def self.list(latitude, longtitude)
    shops_url = HALAL_SHOP_URL % { latitude: latitude, longtitude: longtitude }
    halal_shops_json = Net::HTTP.get_response(URI.parse(shops_url)).body
    JSON.parse(halal_shops_json)['shops']
  end
end
