#Syndicate Wars Level Reader by Moburma

#VERSION 0.1
#LAST MODIFIED: 03/06/2022

<#
.SYNOPSIS
   This script can read Syndicate Wars level files (.dat, .d1, d2, etc) and output human readable information 
   on all characters placed in that level, including their weaponry, group membership, 3D coordinates and 
   what type of person or vehicle they are.

.DESCRIPTION    
    Reads Syndicate Wars Level files and outputs character definitions as human readable data. Also exports the details to a CSV 
    in current directory. Heavily based on the tool SWLevelEd by Mefistotelis.
    

.PARAMETER Filename
   
   The level file to open. E.g. c070l011.dat


.RELATED LINKS
    
    SWLevelEd: http://syndicate.lubiki.pl/downloads/bullfrog_utils_swars_level_reader.zip

    
#>

Param ($filename)

if ($filename -eq $null){
write-host "Error - No argument provided. Please supply a target level file to read!"
write-host ""
write-host "Example: SWLevelReader.ps1 C006L001.DAT"
}
Else{
$levfile = Get-Content $filename -Encoding Byte -ReadCount 0

function convert16bitint($Byteone, $Bytetwo) {
   
$converbytes16 = [byte[]]($Byteone,$Bytetwo)
$converted16 =[bitconverter]::ToInt16($converbytes16,0)

return $converted16

}

function convert32bitint($Byteone, $Bytetwo, $Bytethree, $ByteFour) {
   
$converbytes32 = [byte[]]($Byteone,$Bytetwo,$Bytethree,$ByteFour)
$converted32 =[bitconverter]::ToUInt32($converbytes32,0)

return $converted32

}

Function Find-Bytes([byte[]]$Bytes, [byte[]]$Search, [int]$Start, [Switch]$All) {
    For ($Index = $Start; $Index -le $Bytes.Length - $Search.Length ; $Index++) {
        For ($i = 0; $i -lt $Search.Length -and $Bytes[$Index + $i] -eq $Search[$i]; $i++) {}
        If ($i -ge $Search.Length) { 
            $Index
            If (!$All) { Return }
        } 
    }
}

function identifycharacter($chartype){

switch ($chartype)
{

    0{ return "Invalid"}
      1{ return "Agent"}
      2{ return "Zealot"}
      3{ return "Unguided Female"}
      4{ return "Civ - Briefcase Man"}
      5{ return "Civ - White Dress Woman"}
      6{ return "Soldier/Mercenary"}
      7{ return "Mechanical Spider"}
      8{ return "Police"}
      9{ return "Unguided Male"}
     10{ return "scientist"}
     11{ return "Shady Guy"}
     12{ return "Elite Zealot"}
     13{ return "Civ - Blonde Woman 1"}
     14{ return "Civ - Leather Jacket Man"}
     15{ return "Civ - Blonde Woman 2"} 
     40{ return "Ground Car"}
     50{ return "Flying vehicle"}
     51{ return "Tank"}
     54{ return "Ship"}
     59{ return "Moon Mech"}
  

}
}

$counter = 0

#Check File type

$filetype = $levfile[0]
write-host "Level is of type $filetype"


#Check if count is two bytes or not
if( $levfile[5] -ne 0){
$charcount = convert16bitint $levfile[4] $levfile[5]
}
else{
$charcount = $levfile[4]
}


write-host "$charcount characters detected"

if($Charcount -eq 0){
write-host "No characters found, is this actually a Syndicate Wars level file?"
write-host "Nothing to do - Exiting"
exit
}


#Find start of group names

$b = [byte[]] $another_array = 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07

$groupstart = Find-Bytes -all $levfile $b
$groupsarray = @()

if ($groupstart -eq $null){   #Don't bother trying to find group names if no header - some level files don't have 'em
Write-host "No group name header found in file"

}
Else{


$gpos = $groupstart
$gpos = $gpos + 43

$estring = 0


DO{   #Extract all Group names    
    
    $groupbytes = [System.IO.File]::ReadAllBytes("$filename")
    # Decode first 12 bytes to a text assuming ASCII encoding.
    $gtext = [System.Text.Encoding]::ASCII.GetString($groupbytes, $gpos, 40)
    
    write-host $gtext 
    if ($gtext -match "[a-z]"){   #We don't know when groups end in the file, so look for the first blank entry to end on
    #echo "group had text"
    $gpos = $gpos + 40
    $groupsarray += $gtext
    }
    Else{
    
   # echo "group had no text"
    $estring = 1
    } #>
    
}
UNTIL ($estring -eq 1) 
}

write-host "Char No, Char type, Character Name, Thing Type, Weapons Carried Number, Weapons Carried List, Group No, Group Name, Effective Group, Map Position (X, Y, Z), vehicle" 
$Fileoutput = @()


$fpos = 6

#These filetypes have an extra 48 bytes of data at the top before the characters start 
if ($filetype -eq 9 -or $filetype -eq 11 -or $filetype -eq 12){
$fpos = $fpos + 48
}

DO
{

$counter = $counter +1

$Parent = $levfile[$fpos]
$Next = $levfile[$fpos+1]
$LinkParent
$LinkChild
$type = $levfile[$fpos+8]
$charactername = identifycharacter $type
$thingtype = $levfile[$fpos+9]
$state = $levfile[$fpos+10]
$Flag
$LinkSame
$LinkSameGroup
$Radius
$ThingOffset
$map_posx = convert32bitint $levfile[$fpos+24] $levfile[$fpos+25] $levfile[$fpos+26] $levfile[$fpos+27]
$map_posy = convert32bitint $levfile[$fpos+28] $levfile[$fpos+29] $levfile[$fpos+30] $levfile[$fpos+31]
$map_posz = convert32bitint $levfile[$fpos+32] $levfile[$fpos+33] $levfile[$fpos+34] $levfile[$fpos+35]
$Frame
$StartFrame
$Timer1
$StartTimer1
$VX
$VY
$VZ
$Speed
$Health
$Owner
$PathOffset
$SubState
$PTarget
$Flag2
$GotoThingIndex
$OldTarget
$PathIndex
$UniqueID
$Group = $levfile[$fpos+80]
$GroupName = $groupsarray[$group]
$EffectiveGroup = $levfile[$fpos+81]
$ComHead
$ComCur
$SpecialTimer
$Angle
$WeaponTurn
$Brightness
$ComRange
$BumpMode
$BumpCount
$Vehicle =  convert16bitint $levfile[$fpos+94] $levfile[$fpos+95]
$LinkPassenger
$Within
$LastDist
$ComTimer
$Timer2
$StartTimer2
$AnimMode
$OldAnimMode
$OnFace
$UMod
$Mood
$FrameId
$Shadows
$RecoilTimer
$MaxHealth
$Flag3
$OldSubType
$ShieldEnergy
$ShieldGlowTimer
$WeaponDir
$SpecialOwner
$WorkPlace
$LeisurePlace
$WeaponTimer
$Target2
$MaxShieldEnergy
$PersuadePower
$MaxEnergy
$Energy
$RecoilDir
$CurrentWeapon
$GotoX
$GotoZ
$TempWeapon
$Stamina
$MaxStamina


$WeaponsCarried = convert32bitint $levfile[$fpos+164] $levfile[$fpos+165] $levfile[$fpos+166] $levfile[$fpos+167]
$weaponscarried2 = $WeaponsCarried
$weaponstext = $null
    if ($WeaponsCarried -ge 1){    

         		if ($WeaponsCarried / 2147483648 -ge 1) {
                    $WeaponsCarried = $WeaponsCarried % 2147483648
					$Weaponstext = $Weaponstext+" Unknown 2, " 
				}
				
				if ($WeaponsCarried / 1073741824 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 1073741824
					$Weaponstext = $Weaponstext+" Unknown 1, " 
				}
				
				if ($WeaponsCarried / 536870912 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 536870912
					$Weaponstext = $Weaponstext+" Clone Shield, " 
				}
				
				if ($WeaponsCarried / 268435456 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 268435456
					$Weaponstext = $Weaponstext+" Trigger Wire, " 
				}
				
				if ($WeaponsCarried / 134217728 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 134217728
					$Weaponstext = $Weaponstext+" Automedikit, " 
				}
				
				if ($WeaponsCarried / 67108864 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 67108864
					$Weaponstext = $Weaponstext+" Medikit, " 
				}
				
				if ($WeaponsCarried / 33554432 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 33554432
					$Weaponstext = $Weaponstext+" Cerberus IFF, " 
				}
				
				if ($WeaponsCarried / 16777216 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 16777216
					$Weaponstext = $Weaponstext+" Displacertron, " 
				}
				
				if ($WeaponsCarried / 8388608 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 8388608
					#Energy Shield - nothing
				}
				
				if ($WeaponsCarried / 2097152 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 2097152
					$Weaponstext = $Weaponstext+" Stasis Field, " 
				}
				
				if ($WeaponsCarried / 1048576 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 1048576
					$Weaponstext = $Weaponstext+" Persuadertron II, " 
				}
				
				if ($WeaponsCarried / 524288 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 524288
					$Weaponstext = $Weaponstext+" Graviton Gun, " 
				}
				
				if ($WeaponsCarried / 262144 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 262144
					$Weaponstext = $Weaponstext+" Sonic Blast, " 
				}
				
				if ($WeaponsCarried / 131072 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 131072
					$Weaponstext = $Weaponstext+" Razor Wire, " 
				}
				
				if ($WeaponsCarried / 65536 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 65536
					$Weaponstext = $Weaponstext+" Plasma Lance, " 
				}
				
				if ($WeaponsCarried / 32768 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 32768
					$Weaponstext = $Weaponstext+" Satellite Rain, " 
				}
				
				if ($WeaponsCarried / 16384 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 16384
					$Weaponstext = $Weaponstext+" LR Rifle, " 
				}
				
				if ($WeaponsCarried / 8192 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 8192
					$Weaponstext = $Weaponstext+" Napalm Mine, " 
				}
				
				if ($WeaponsCarried / 4096 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 4096
					$Weaponstext = $Weaponstext+" Explosives, " 
				}
				
				if ($WeaponsCarried / 2048 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 2048
					$Weaponstext = $Weaponstext+" Ion Mine, " 
				}
				
				if ($WeaponsCarried / 1024 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 1024
					$Weaponstext = $Weaponstext+" Knockout Gas, " 
				}
				
				if ($WeaponsCarried / 512 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 512
					$Weaponstext = $Weaponstext+" Psycho Gas, " 
				}
				
				if ($WeaponsCarried / 256 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 256
					$Weaponstext = $Weaponstext+" Disrupter, " 
				}
				
				if ($WeaponsCarried / 128 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 128
					$Weaponstext = $Weaponstext+" Flamer, " 
				}
				
				if ($WeaponsCarried / 64 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 64
					$Weaponstext = $Weaponstext+" Persuadertron, " 
				}
				
				if ($WeaponsCarried / 32 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 32
					$Weaponstext = $Weaponstext+" Nuclear Grenade, " 
				}	
				
				if ($WeaponsCarried / 16 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 16
					$Weaponstext = $Weaponstext+" Launcher, " 
				}
				
				if ($WeaponsCarried / 8 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 8
					$Weaponstext = $Weaponstext+" Electron Mace, " 
				}
				
				if ($WeaponsCarried / 4 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 4
					$Weaponstext = $Weaponstext+" Pulse Laser, " 
				}
				
				if ($WeaponsCarried / 2 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 2
					$Weaponstext = $Weaponstext+" Minigun, " 
				}
				
				if ($WeaponsCarried / 1 -ge 1) {
					$WeaponsCarried = $WeaponsCarried % 1
					$Weaponstext = $Weaponstext+" Uzi, " 
				}		



    }
    Else{
        $weaponstext ="Unarmed"
        }

#Output to console

$consoleoutput = "$counter, $type, $charactername, $thingtype, $WeaponsCarried2, $weaponstext, $group, $GroupName, $EffectiveGroup, ($map_posx, $map_posy, $map_posz), $vehicle" 
write-host $consoleoutput


$CharacterEntry = New-Object PSObject
$CharacterEntry | Add-Member -type NoteProperty -Name 'Character No.' -Value $counter
$CharacterEntry | Add-Member -type NoteProperty -Name 'Character Type' -Value $type
$CharacterEntry | Add-Member -type NoteProperty -Name 'Character Name' -Value $charactername
$CharacterEntry | Add-Member -type NoteProperty -Name 'Thing Type' -Value $thingtype
$CharacterEntry| Add-Member -type NoteProperty -Name 'Weapons Carried Value' -Value $WeaponsCarried2
$CharacterEntry | Add-Member -type NoteProperty -Name 'Weapons Carried List' -Value $weaponstext
$CharacterEntry | Add-Member -type NoteProperty -Name 'Group' -Value $Group
$CharacterEntry | Add-Member -type NoteProperty -Name 'Group Name' -Value $GroupName
$CharacterEntry | Add-Member -type NoteProperty -Name 'Effective Group' -Value $EffectiveGroup
$CharacterEntry | Add-Member -type NoteProperty -Name 'X Position' -Value $map_posx
$CharacterEntry | Add-Member -type NoteProperty -Name 'Y Position' -Value $map_posy
$CharacterEntry | Add-Member -type NoteProperty -Name 'Z Position' -Value $map_posz
$CharacterEntry | Add-Member -type NoteProperty -Name 'Vehicle' -Value $Vehicle

$Fileoutput += $characterentry

$charcount = $charcount - 1
if ($state -eq 33 -OR $state -eq 61 -or $state -eq 64){
$fpos = $fpos + 36
}



$fpos = $fpos + 168
}
UNTIL ($charcount -eq 0)

#Output to CSV
$csvname = [io.path]::GetFileNameWithoutExtension("$filename")

$fileext = $csvname+".csv"
write-host "Exporting to $fileext"

$Fileoutput | export-csv -NoTypeInformation $fileext

}