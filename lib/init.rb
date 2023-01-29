require "watir"

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

# Open Chrome browser
browser = Watir::Browser.new :chrome

# Navigate to Rotochamp home page and save page source
browser.goto("http://www.rotochamp.com")
page_source = browser.html

# Parse page source to extract playerNames JS object
puts exclusive_substring(page_source, "playerNames = [", "];")

#breakpoint = gets
browser.close

# {"value":"687659","label":"Kaden Polcovich","PlayerType":"B","Position":"SS","TeamID":"SEA"}

