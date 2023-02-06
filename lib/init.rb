require "watir"

# Only scrape values for Steamer, ATC, THE BAT, THE BAT X
PROJECTION_ROWS = ["3","5","6","7"]

# Set columns to scripr for Hitters and Pitchers
HITTER_COLUMNS = ["4", "5", "6", "7", "8", "9", "15"]
PITCHER_COLUMNS = ["4", "5", "7", "8", "9", "11", "12"]


# Returns a substring of a target string between the start and end strings 
def exclusive_substring(substring_target,exclusive_start, exclusive_end)
    # Get the exclusive starting position
    starting_pos = substring_target.index(exclusive_start) + exclusive_start.length
    
    # Remove characters from the beginning to the exclusive starting position
    temp_string = substring_target[starting_pos..]

    # Derive the exclusive ending position
    ending_pos = temp_string.index(exclusive_end)
    
    # Renove the characters from the exclusive starting position to the end
    return temp_string[1...ending_pos]
end

def average_metric_values(metric_value_array=[])
    values = 0
    total_value = 0
    metric_value_array.each do |value|
        total_value = total_value + value.to_f
        values = values + 1
    end
    (total_value / values).to_s
end

def aggregate_custom_player_metrics(player_id="", player_name="", player_type="P")
    # Go to player projection page
    @browser.goto("https://rotochamp.com/Baseball/Player.aspx?MLBAMID=#{player_id}")

    # Set attributes that differ by player_type
    player_type == "P" ? projection_type = "Pitcher" : projection_type = "Hitter"
    player_type == "P" ? grid_columns = PITCHER_COLUMNS : grid_columns = HITTER_COLUMNS
    
    player_output = [player_id, player_name]
    grid_columns.each do |column|
        metric_values = []
        PROJECTION_ROWS.each do |row|
            grid_cell = @browser.element(:xpath => "//*[@id=\"MainContent_grid#{projection_type}Projections\"]/tbody/tr[#{row}]/td[#{column}]")
            metric_values << grid_cell.text.gsub(/[^0-9\.]/, "")
        end
        player_output << average_metric_values(metric_values)
    end
    player_output
end

# Open Chrome browser
@browser = Watir::Browser.new :chrome

# Navigate to Rotochamp home page and save page source
@browser.goto("http://www.rotochamp.com")
page_source = @browser.html

# Parse page source to extract playerNames JS object
player_names = exclusive_substring(page_source, "playerNames = [", "];")

# Substitute characters to make string easier to parse
player_names =  player_names.gsub("},", "|")
player_names =  player_names.gsub("}", "")
player_names =  player_names.gsub("{", "")
player_names =  player_names.gsub(":", ",")


player_array = player_names.split("|")
# puts player_array
puts aggregate_custom_player_metrics("592450", "Aaron Judge", "B")
# aggregate_custom_player_metrics("669203", "Corbin Burnes", "P")


breakpoint = gets
@browser.close

# {"value":"687659","label":"Kaden Polcovich","PlayerType":"B","Position":"SS","TeamID":"SEA"}

