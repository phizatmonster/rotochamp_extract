require "csv"
require "watir"

# Only scrape values for Steamer, ATC, THE BAT, THE BAT X
PROJECTION_ROWS = ["3","5","6","7","8"]

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
        total_value += value
        values += 1
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
    negative_check = nil
    grid_columns.each_with_index do |column, i|
        metric_values = []
        PROJECTION_ROWS.each do |row|
            grid_cell = @browser.element(:xpath => "//*[@id=\"MainContent_grid#{projection_type}Projections\"]/tbody/tr[#{row}]/td[#{column}]")   
            grid_cell.text.include?("(") ? negative_check = true : negative_check = false 

            # Adjust pitcher value up 5% and hitter value down 5%
            if player_type == "P" && i == 6
                if negative_check
                    cell_value = -grid_cell.text.gsub(/[^0-9\.]/, "").to_f
                else
                    cell_value = grid_cell.text.gsub(/[^0-9\.]/, "").to_f
                end
                cell_value = cell_value + (cell_value.abs * 0.05)
            elsif player_type == "B" && i == 6
                if negative_check
                    cell_value = -grid_cell.text.gsub(/[^0-9\.]/, "").to_f
                else
                    cell_value = grid_cell.text.gsub(/[^0-9\.]/, "").to_f
                end
                cell_value = cell_value - (cell_value.abs * 0.05)
            else
                cell_value = grid_cell.text.gsub(/[^0-9\.]/, "").to_f
            end
            metric_values << cell_value
        end
        player_output << average_metric_values(metric_values).to_s
    end
    player_output
end

# Open Chrome browser
@browser = Watir::Browser.new :chrome

# Navigate to Rotochamp home page and save page source
@browser.goto("http://www.rotochamp.com")
page_source = @browser.html

# Parse page source to extract playerNames JS object
all_player_names = exclusive_substring(page_source, "playerNames = [", "];")

# Substitute characters to make string easier to parse
all_player_names =  all_player_names.gsub("},", "|")
all_player_names =  all_player_names.gsub("}", "")
all_player_names =  all_player_names.gsub("{", "")
all_player_names =  all_player_names.gsub(":", ",")
all_player_names =  all_player_names.gsub("\"", "")

all_player_array = all_player_names.split("|")

# Write all players to a CSV file
all_players_path = File.join(File.dirname(__FILE__), "../data/all_players.csv")
File.open(all_players_path, "w") do |f|
    all_player_array.each { |element| f.puts(element) }
end

# Read player_subset.csv into a two-dimensional array
players_to_project = CSV.read(File.join(File.dirname(__FILE__), "../data/player_subset.csv"))

# Write custom player projections and values to a CSV file
player_values_path = File.join(File.dirname(__FILE__), "../data/player_values.csv")
CSV.open(player_values_path, "ab") do |csv|
    players_to_project.each do |player|
        csv << aggregate_custom_player_metrics(player[0].to_s, player[1].to_s, player[2].to_s)
    end
end

@browser.close

