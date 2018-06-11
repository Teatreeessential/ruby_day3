require 'sinatra'
require 'sinatra/reloader'
require 'rest-client'
require 'nokogiri'
require 'json'
require 'csv'
require 'uri'

get '/' do
    
    erb :index
end

get '/webtoon' do
    #내가 받아온 웹툰 데이터를 저장할 배열생성
    toons = []
    # 웹툰 데이터를 받아올 url 파악 및 요청 보내기
    url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
    result = RestClient.get(url)
    # 응답으로 온 내용을 해쉬 형태로 바꾸기
    webtoons = JSON.parse(result)
    # 해쉬에서 웹툰 리스트에 해당하는 부분 순환하기
    webtoons["data"].each do |toon|
    # http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon 에서 
        # 웹툰 제목
        title = toon["title"]
        # 웹툰 이미지 주소
        image = toon["thumbnailImage2"]["url"]  # 썸네일 안에서 url을 뽑아야됨.
        # 웹툰을 볼 수 있는 주소
        link = "http://webtoon.daum.net/webtoon/view#{toon['nickname']}"
    # 필요한 부분을 분리해서 처음 만든 배열에 push 
        toons << {"title" => title,
                "image" => image,
                "link" => link
            
        }
        
    end
    
    # 완성된 배열 중에서 3개의 웹툰만 랜덤 추출
    @daum_webtoons = toons.sample(3)
    erb :webtoon
end


get '/test' do
    url = RestClient.get("http://comic.naver.com/webtoon/weekday.nhn")
    result = Nokogiri::HTML(url)
    name = result.css("#content > div.list_area.daily_all > div.col.col_selected > div > ul > li > a")
    img = result.css("#content > div.list_area.daily_all > div.col.col_selected > div > ul > li > div > a > img")
    puts name.length.to_s + "/" + img.length.to_s
    
    @day = ["mon", "tue","wed","thu","fri","sat","sun"]
    
    @name_arr = []
    @img_arr = []
    for i in name
        @name_arr.push(i.text)
    end
    
    for i in img
        @img_arr.push(i.attr('src')) if not(i.attr('src').to_s.include?"new")
    end
   # puts @name_arr[0]
    erb :test
end

get '/test2' do
    url = RestClient.get("http://comic.naver.com/webtoon/weekday.nhn")
    result = Nokogiri::HTML(url)
    name = result.css("#content > div.list_area.daily_all > div.col.col_selected > div > ul > li > a")
    img = result.css("#content > div.list_area.daily_all > div.col.col_selected > div > ul > li > div > a > img")
    puts name.length.to_s + "/" + img.length.to_s
    
    @day = ["mon", "tue","wed","thu","fri","sat","sun"]
    
    @name_arr = []
    @img_arr = []
    for i in name
        @name_arr.push(i.text)
    end
    
    for i in img
        @img_arr.push(i.attr('src')) if not(i.attr('src').to_s.include?"new")
    end
   # puts @name_arr[0]
    erb :test
end

get '/check_file' do
 
    unless File.file?('./webtoon.csv')
            #CSV 파일을 새로 생성하는 코드
            toons = []
            # 웹툰 데이터를 받아올 url 파악 및 요청 보내기
            url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon"
            result = RestClient.get(url)
            # 응답으로 온 내용을 해쉬 형태로 바꾸기
            webtoons = JSON.parse(result)
            # 해쉬에서 웹툰 리스트에 해당하는 부분 순환하기
            webtoons["data"].each do |toon|
            # http://webtoon.daum.net/data/pc/webtoon/list_serialized/mon 에서 
                # 웹툰 제목
                title = toon["title"]
                # 웹툰 이미지 주소
                image = toon["thumbnailImage2"]["url"]  # 썸네일 안에서 url을 뽑아야됨.
                # 웹툰을 볼 수 있는 주소
                link = "http://webtoon.daum.net/webtoon/view#{toon['nickname']}"
            # 필요한 부분을 분리해서 처음 만든 배열에 push 
            toons << [title,
                    image,
                    link
            ]
            
        end
        CSV.open('./webtoon.csv', 'w+') do |row|
            toons.each_with_index do |toon,index|
               row << [index,toon[0],toon[1],toon[2]]  
            end
        end
        erb :check_file
    else
        #존재하는 CSV 파일을 불러오는 코드
        @webtoons = []
        CSV.open('./webtoon.csv', 'r').each do |row|
            @webtoons << row
        end
        erb :webtoons
    end
        
end

get '/board/:name' do
    puts params[:name]
end