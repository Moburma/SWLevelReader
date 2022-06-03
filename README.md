# Syndicate Wars Level Reader
Powershell script to process level files from the game Syndicate Wars into human readable format. 
Heavily based on http://syndicate.lubiki.pl/downloads/bullfrog_utils_swars_level_reader.zip but with some new features

Run with SWLevelReader.ps1 {filename}
  
  e.g. SWLevelReader.ps1 C006L001.DAT

Features:
* Lists all characters and vehicles in a level
* Lists character's person type
* Lists character's weapons (if any)
* lists misc interesting data, including X/Y/Z position and Thing Type
* Lists all NPC groups and membership of them
* Outputs to CSV file
