class Places

  attr_reader :address, :phone_number, :name, :rating

  def initialize(lat, lon)
    @lat = lat
    @lon = lon

    parse_nearby_restaurants

  end



  def call_google_places_api(url)

    json_response = HTTParty.get(url).body
    return JSON.parse( json_response )

  end

  def parse_nearby_restaurants

    restaurants = Hash.new()

    #do a places search to get the name of restaurants and their place_id within a given radius
    #search_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location="+ @lat + "," + @lon + "&radius=1000&types=food&key=AIzaSyB3xKb4v0cK805_F1ApSX0Os0KS-XzDoO4"
    search_url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=restaurants&location="+ @lat + "," + @lon + "&radius=1000&types=restaurant&key=AIzaSyB3xKb4v0cK805_F1ApSX0Os0KS-XzDoO4"


    parsed_result = call_google_places_api(search_url)

    parsed_result['results'].each do |result|

      restaurants[result['name']] = result['place_id']

    end

    place_id = restaurants[restaurants.keys.sample]

    #do a details search to retrieve details about the selected location
    details_url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + place_id + "&key=AIzaSyB3xKb4v0cK805_F1ApSX0Os0KS-XzDoO4"

    details_result = call_google_places_api(details_url)

    if details_result['result']['formatted_address'] != nil
      @address = details_result['result']['formatted_address']
    end

    if details_result['result']['formatted_phone_number'] != nil
      @phone_number = details_result['result']['formatted_phone_number']
    end

    if details_result['result']['name'] != nil
      @name = details_result['result']['name']
    end

    if  details_result['result']['rating'] != nil
      @rating = details_result['result']['rating']
    end

  end


end


get '/places' do
  @lat = params[:lat]
  @lon = params[:lon]

  place = Places.new(@lat, @lon)

  @address = place.address
  @phone_number = place.phone_number
  @name = place.name
  @rating = place.rating


  erb :restaurant

  # open_now = ""
  #
  # if result.include? "opening_hours"
  #   result['opening_hours']['open_now'] == true ? open_now = "Open" : open_now = "Closed"
  # end
  #
  # @restaurant[result['name']] = open_now;
end