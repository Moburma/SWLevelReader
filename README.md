# Syndicate Wars Level Reader
Powershell 5 script to process level files from the game Syndicate Wars into human readable CSV format to aid in reverse engineering and editing. 
Heavily based on http://syndicate.lubiki.pl/downloads/bullfrog_utils_swars_level_reader.zip but with some new features

Run with SWLevelReader.ps1 {filename}
  
  e.g. SWLevelReader.ps1 C006L001.DAT

Features:
* Lists all characters and vehicles in a level
* Lists character's person type
* Lists character's weapons (if any)
* Includes vehicle type (e.g. Yellow Taxi, Metallic Bike)
* lists misc interesting data, including X/Y/Z position 
* Lists all NPC groups and membership of them
* Outputs Commands section with cross-referenced Group names and objectives to make NPC behaviour human-readable
* Outputs floor items in level
* Outputs to CSV files
