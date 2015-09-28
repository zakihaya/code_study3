# 山手線の駅からハラルレストラン検索

駅選択 → レストラン一覧表示

# 使用しているAPI

* HGJ地図API
* 駅データ.jp（http://www.ekidata.jp/api/api_station.php）

# 3分クッキング用素材

#### ターミナルでプロジェクト作成

```
rails new halal_station_search
```

#### Gem追加

1 Gemfile

```
gem 'haml'
```

```
bundle install
```

#### 駅探索APIインターフェイス

2 app/models/station.rb

```ruby
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
```

動作確認

```
bundle exec rails c

Station.list
=> （一覧データが表示される）

Station.find_by_name '目黒'
=> （目黒駅の情報が表示される）
```

#### 画面作成

app/controllers/home_controller.rb

```ruby
class HomeController < ApplicationController
  def index
  end
end
```

app/views/home/index.html.erb

```haml
= form_tag root_path, method: 'GET' do
  = select_tag "station", options_for_select(Station.list.map{ |s| s['station_name'] }, params[:station])
  = submit_tag "ハラルレストランを検索する"
```

config/routes.rb

```
root 'home#index'
```

サーバ起動して確認

```
bundle exec rails s
```

http://localhost:3000 にアクセス → 駅一覧と検索ボタンがある

#### ハラル店舗一覧取得インターフェイス

app/models/halal_shop.rb

```ruby
class HalalShop
  HALAL_SHOP_URL = "https://www.halalgourmet.jp/api/map.json?zoom=15&x=%{latitude}&y=%{longtitude}"

  # 指定した位置を中心にしたハラル店舗を取得
  def self.list(latitude, longtitude)
    shops_url = HALAL_SHOP_URL % { latitude: latitude, longtitude: longtitude }
    halal_shops_json = Net::HTTP.get_response(URI.parse(shops_url)).body
    JSON.parse(halal_shops_json)['shops']
  end
end
```

コンソールを起動して確認

```
bundle exec rails c

station = Station.find_by_name '新宿'
shops = HalalShop.list station['lat'], station['lon']
=> （店舗一覧データが表示される）
```

#### 画面に駅から店舗検索機能を実装

app/controllers/home_controller.rb

```ruby
class HomeController < ApplicationController
  def index
    if params[:station]
      selected_station = Station.find_by_name params['station']
      @shops = HalalShop.list selected_station['lat'], selected_station['lon']
    end
  end
end
```

app/views/home/index.html.haml

```haml
= form_tag root_path, method: 'GET' do
  = select_tag "station", options_for_select(Station.list.map{ |s| s['station_name'] }, params[:station])
  = submit_tag "ハラルレストランを検索する"

- if @shops && @shops.any?
  %br
  .shops
    %table{ border:1, cellspacing:0, cellpadding:0 }
      %tr
        %th image
        %th shop name
        %th category
        %th detail
      - @shops.each do |shop|
        %tr
          %td= image_tag shop['image'], style: 'width:78px;', class: 'image-rounded'
          %td= shop['name']
          %td= shop['category']
          %td
            = link_to "https://www.halalgourmet.jp/restaurant/#{shop['shop_id']}", "https://www.halalgourmet.jp/restaurant/#{shop['shop_id']}", target: '_blank'
```

http://localhost:3000 にアクセス

#### Bootstrapのデザインを適用する

app/views/layouts/application.html.erb

```erb
<!DOCTYPE html>
<html>
<head>
  <title>CodeStudy3</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>

<%= yield %>

</body>
</html>
```

app/views/home/index.html.haml

```haml
.container
  %h1 山手線の駅からハラルレストラン検索

  = form_tag root_path, method: 'GET', class: 'well form-inline' do
    = select_tag "station", options_for_select(Station.list.map{ |s| s['station_name'] }, params[:station]), class: 'form-control'
    駅　
    = submit_tag "ハラルレストランを検索する", class: 'btn btn-primary'

  - if @shops && @shops.any?
    %br
    .shops
      %table.table.table-striped
        %tr
          %th image
          %th shop name
          %th category
          %th detail
        - @shops.each do |shop|
          %tr
            %td= image_tag shop['image'], style: 'width:78px;'
            %td= shop['name']
            %td= shop['category']
            %td
              = link_to "https://www.halalgourmet.jp/restaurant/#{shop['shop_id']}", "https://www.halalgourmet.jp/restaurant/#{shop['shop_id']}", target: '_blank'
  - else
    レストランが見つかりませんでした
```
