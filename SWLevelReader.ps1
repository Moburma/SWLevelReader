#Syndicate Wars Level Reader by Moburma

#VERSION 0.5
#LAST MODIFIED: 26/06/2022

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

$fileexists = Test-Path -Path $filename -PathType Leaf

if ($fileexists -eq 0){
write-host "Error - No file with that name found. Please supply a target level file to read!"
write-host ""
write-host "Example: SWLevelReader.ps1 C006L001.DAT"
exit
}

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

function identifycharacter($chartype){ #Returns what the character type name is

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
     10{ return "Scientist"}
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
     default { return "Unknown" }
  

}
}


function identifycommand($Commandtype){ #Returns what the command type name is

Switch ($commandtype){  #PersonCommandType


            0{ return 'NONE'}
            1{ return 'STAY'}
            2{ return 'GO_TO_POINT'}
            3{ return 'GO_TO_PERSON'}
            4{ return 'KILL_PERSON'}
            5{ return 'KILL_MEM_GROUP'}
            6{ return 'KILL_ALL_GROUP'}
            7{ return 'PERSUADE_PERSON'}
            8{ return 'PERSUADE_MEM_GROUP'}
            9{ return 'PERSUADE_ALL_GROUP'}
            10{ return 'BLOCK_PERSON'}
            11{ return 'SCARE_PERSON'}
            12{ return 'FOLLOW_PERSON'}
            13{ return 'SUPPORT_PERSON'}
            14{ return 'PROTECT_PERSON'}
            15{ return 'HIDE'}
            16{ return 'GET_ITEM'}
            17{ return 'USE_WEAPON'}
            18{ return 'DROP_SPEC_ITEM'}
            19{ return 'AVOID_PERSON'}
            20{ return 'WAND_AVOID_GROUP'}
            21{ return 'DESTROY_BUILDING'}
            22{ return '16'}
            23{ return 'USE_VEHICLE'}
            24{ return 'EXIT_VEHICLE'}
            25{ return 'CATCH_TRAIN'}
            26{ return 'OPEN_DOME'}
            27{ return 'CLOSE_DOME'}
            28{ return 'DROP_WEAPON'}
            29{ return 'CATCH_FERRY'}
            30{ return 'EXIT_FERRY'}
            31{ return 'PING_EXIST'}
            32{ return 'GOTOPOINT_FACE'}
            33{ return 'SELF_DESTRUCT'}
            34{ return 'PROTECT_MEM_G'}
            35{ return 'RUN_TO_POINT'}
            36{ return 'KILL_EVERYONE'}
            37{ return 'GUARD_OFF'}
            38{ return 'EXECUTE_COMS'}
            39{ return '27'}
            50{ return '32'}
            51{ return 'WAIT_P_V_DEAD'}
            52{ return 'WAIT_MEM_G_DEAD'}
            53{ return 'WAIT_ALL_G_DEAD'}
            54{ return 'WAIT_P_V_I_NEAR'}
            55{ return 'WAIT_MEM_G_NEAR'}
            56{ return 'WAIT_ALL_G_NEAR'}
            57{ return 'WAIT_P_V_I_ARRIVES'}
            58{ return 'WAIT_MEM_G_ARRIVE'}
            59{ return 'WAIT_ALL_G_ARRIVE'}
            60{ return 'WAIT_P_PERSUADED'}
            61{ return 'WAIT_MEM_G_PERSUADED'}
            62{ return 'WAIT_ALL_G_PERSUADED'}
            63{ return 'WAIT_MISSION_SUCC'}
            64{ return 'WAIT_MISSION_FAIL'}
            65{ return 'WAIT_MISSION_START'}
            66{ return 'WAIT_OBJECT_DESTROYED'}
            67{ return 'WAIT_TIME'}
            71{ return 'WAND_P_V_DEAD'}
            72{ return 'WAND_MEM_G_DEAD'}
            73{ return 'WAND_ALL_G_DEAD'}
            74{ return 'WAND_P_V_I_NEAR'}
            75{ return 'WAND_MEM_G_NEAR'}
            76{ return 'WAND_ALL_G_NEAR'}
            77{ return 'WAND_P_V_I_ARRIVES'}
            78{ return 'WAND_MEM_G_ARRIVE'}
            79{ return 'WAND_ALL_G_ARRIVE'}
            80{ return 'WAND_P_PERSUADED'}
            81{ return 'WAND_MEM_G_PERSUADED'}
            82{ return 'WAND_ALL_G_PERSUADED'}
            83{ return 'WAND_MISSION_SUCC'}
            84{ return 'WAND_MISSION_FAIL'}
            85{ return 'WAND_MISSION_START'}
            86{ return 'WAND_OBJECT_DESTROYED'}
            87{ return 'WAND_TIME'}
            110{ return 'LOOP_COM'}
            111{ return 'UNTIL_P_V_DEAD'}
            112{ return 'UNTIL_MEM_G_DEAD'}
            113{ return 'UNTIL_ALL_G_DEAD'}
            114{ return 'UNTIL_P_V_I_NEAR'}
            115{ return 'UNTIL_MEM_G_NEAR'}
            116{ return 'UNTIL_ALL_G_NEAR'}
            117{ return 'UNTIL_P_V_I_ARRIVES'}
            118{ return 'UNTIL_MEM_G_ARRIVE'}
            119{ return 'UNTIL_ALL_G_ARRIVE'}
            120{ return 'UNTIL_P_PERSUADED'}
            121{ return 'UNTIL_MEM_G_PERSUADED'}
            122{ return 'UNTIL_ALL_G_PERSUADED'}
            123{ return 'UNTIL_MISSION_SUCC'}
            124{ return 'UNTIL_MISSION_FAIL'}
            125{ return 'UNTIL_MISSION_START'}
            126{ return 'UNTIL_OBJECT_DESTROYED'}
            127{ return 'UNTIL_TIME'}
            128{ return 'WAIT_OBJ'}
            129{ return 'WAND_OBJ'}
            130{ return 'UNTIL_OBJ'}
            131{ return 'WITHIN_AREA'}
            132{ return 'WITHIN_OFF'}
            133{ return 'LOCK_BUILD'}
            134{ return 'UNLOCK_BUILD'}
            135{ return 'SELECT_WEAPON'}
            136{ return 'HARD_AS_AGENT'}
            137{ return 'UNTIL_G_NOT_SEEN'}
            138{ return 'START_DANGER_MUSIC'}
            139{ return 'PING_P_V'}
            140{ return 'CAMERA_TRACK'}
            141{ return 'UNTRUCE_GROUP'}
            142{ return 'PLAY_SAMPLE'}
            143{ return 'IGNORE_ENEMIES'}
            144{ return '90'}
            145{ return '91'}



}


}


function identifyvehicle ($vehicletype){ #Returns what the vehicle type name is based on startframe

Switch ($vehicletype) {

            0{ return 'Civilian car (grey)'}
            1{ return 'Delorean (grey)'}
            2{ return 'Bike'}
            3{ return 'Brown flyer'}
            4{ return 'Train engine'}
            5{ return 'Train carriage'}
            6{ return 'APC'}
            7{ return 'Large APC'}
            8{ return 'Police car'}
            9{ return 'Police Truck'}
            10{ return 'Small industrial vehicle'}
            11{ return 'Bullfrog Van'}
            12{ return 'Fire  Engine'}
            13{ return 'Ambulance'}
            14{ return 'Taxi (Yellow)'}
            15{ return 'Barge'}
            16{ return 'Missile Frigate'}
            17{ return 'Luxury Yacht'}
            18{ return 'Tank'}
            19{ return 'Tank missile battery?'}
            20{ return 'Missile (small)'}
            21{ return 'Civilian car (Red)'}
            22{ return 'Delorean (Yellow)'}
            23{ return 'Zealot Imperial Shuttle'}
            24{ return 'Taxi (Red)'}
            25{ return 'Missile (Large)'}
            26{ return 'Head of moon Mech'}
            27{ return 'Chest of mech?'}
            28{ return 'Bike (Metallic)'}
            29{ return 'Claw Mech (black)'}
            30{ return 'Claw Mech (Red)'}
            31{ return '2000AD/Manga Truck'}
            32{ return 'Moon Mech leg'}
            33{ return 'Moon Mech leg'}
            34{ return 'Moon Mech leg'}
            35{ return 'Moon Mech leg'}
            36{ return 'Moon Mech Arm'}
            37{ return 'Moon Mech Arm'}
            38{ return 'Moon Mech Gun'}
            39{ return 'Moon Mech Gun'}



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
$groupmethod = 1


if ($groupstart -eq $null){ #Another header signature
    $b = [byte[]] $another_array = 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E
    $groupstart = Find-Bytes -all $levfile $b
    $groupmethod = 1
   }

if ($groupstart -eq $null){ #Try second method, just relying on the first group containing "PLAYER"
    $b = [byte[]]("PLAYER".ToCharArray())
    $groupstart = Find-Bytes -all $levfile $b
    $groupmethod = 2
    echo $groupstart
   }

if ($groupstart -eq $null){ #Try second method, just relying on the first group containing "AGENT"
    $b = [byte[]]("AGENT".ToCharArray())
    $groupstart = Find-Bytes -all $levfile $b
    $groupmethod = 3
    
    $groupstart = $groupstart[0]
    }



if ($groupstart -eq $null){   #Don't bother trying to find group names if none found - some level files don't have 'em
Write-host "No group name header found in file"
write-host ""
}
Else{


$gpos = $groupstart
if ($groupmethod -eq 1){
    $gpos = $gpos + 43
}

$estring = 0

write-host ""
write-host "Group Names Found:"

DO{   #Extract all Group names
    
    # Decode 40 bytes to text assuming ASCII encoding.
    $gtext = [System.Text.Encoding]::ASCII.GetString($levfile, $gpos, 40)
    
    write-host $gtext 
    if ($gtext -match "[a-z]"){   #We don't know when groups end in the file, so look for the first blank entry to end on
    #echo "group had text"
    $gpos = $gpos + 40
    $groupsarray += $gtext
    
    }
    Else{
    
   # echo "group had no text"
    $estring = 1
    } 
    
}
UNTIL ($estring -eq 1) 
}

write-host "Char No, Char type, Character Name, Thing Type, Vehicle Type, Weapons Carried Number, Weapons Carried List, Group No, Group Name, Effective Group, State, Map Position (X, Y, Z), MaxEnergy"   #console headers
$Fileoutput = @()


$fpos = 6


DO
{

$counter = $counter +1

#echo $fpos

$Parent =  convert16bitint $levfile[$fpos] $levfile[$fpos+1]
$Next =  convert16bitint $levfile[$fpos+2] $levfile[$fpos+3]
$LinkParent = convert16bitint $levfile[$fpos+4] $levfile[$fpos+5]
$LinkChild =  convert16bitint $levfile[$fpos+6] $levfile[$fpos+7]
$type = $levfile[$fpos+8]
$charactername = identifycharacter $type
$thingtype = $levfile[$fpos+9]
$state = convert16bitint $levfile[$fpos+10] $levfile[$fpos+11]
$Flag =  convert32bitint $levfile[$fpos+12] $levfile[$fpos+13] $levfile[$fpos+14] $levfile[$fpos+15]
$LinkSame = convert16bitint $levfile[$fpos+16] $levfile[$fpos+17]
$LinkSameGroup = convert16bitint $levfile[$fpos+18] $levfile[$fpos+19]
$Radius = convert16bitint $levfile[$fpos+20] $levfile[$fpos+21]
$ThingOffset = convert16bitint $levfile[$fpos+22] $levfile[$fpos+23]
$map_posx = convert32bitint $levfile[$fpos+24] $levfile[$fpos+25] $levfile[$fpos+26] $levfile[$fpos+27]
$map_posy = convert32bitint $levfile[$fpos+28] $levfile[$fpos+29] $levfile[$fpos+30] $levfile[$fpos+31]
$map_posz = convert32bitint $levfile[$fpos+32] $levfile[$fpos+33] $levfile[$fpos+34] $levfile[$fpos+35]
$Frame = convert16bitint $levfile[$fpos+36] $levfile[$fpos+37]
$StartFrame = convert16bitint $levfile[$fpos+38] $levfile[$fpos+39]
$Timer1 = convert16bitint $levfile[$fpos+40] $levfile[$fpos+41]
$StartTimer1 = convert16bitint $levfile[$fpos+42] $levfile[$fpos+43]
$VX = convert32bitint $levfile[$fpos+44] $levfile[$fpos+45] $levfile[$fpos+46] $levfile[$fpos+47]
$VY = convert32bitint $levfile[$fpos+48] $levfile[$fpos+49] $levfile[$fpos+50] $levfile[$fpos+51]
$VZ = convert32bitint $levfile[$fpos+52] $levfile[$fpos+53] $levfile[$fpos+54] $levfile[$fpos+55]
$Speed = convert16bitint $levfile[$fpos+56] $levfile[$fpos+57]
$Health = convert16bitint $levfile[$fpos+58] $levfile[$fpos+59]
$Owner = convert16bitint $levfile[$fpos+60] $levfile[$fpos+61]
$PathOffset = $levfile[$fpos+62]
$SubState = $levfile[$fpos+63]
$PTarget = convert32bitint $levfile[$fpos+64] $levfile[$fpos+65] $levfile[$fpos+66] $levfile[$fpos+67]
$Flag2 = convert32bitint $levfile[$fpos+68] $levfile[$fpos+69] $levfile[$fpos+70] $levfile[$fpos+71]
$GotoThingIndex = convert16bitint $levfile[$fpos+72] $levfile[$fpos+73]
$OldTarget = convert16bitint $levfile[$fpos+74] $levfile[$fpos+75]
$PathIndex = convert16bitint $levfile[$fpos+76] $levfile[$fpos+77]
$UniqueID = convert16bitint $levfile[$fpos+78] $levfile[$fpos+79]
$Group = $levfile[$fpos+80]
$GroupName = $groupsarray[$group]
$EffectiveGroup = $levfile[$fpos+81]
$ComHead = convert16bitint $levfile[$fpos+82] $levfile[$fpos+83]
$ComCur = convert16bitint $levfile[$fpos+84] $levfile[$fpos+85]
$SpecialTimer = $levfile[$fpos+86]
$Angle = $levfile[$fpos+87]
$WeaponTurn = convert16bitint $levfile[$fpos+88] $levfile[$fpos+89]
$Brightness = $levfile[$fpos+90]
$ComRange = $levfile[$fpos+91]
$BumpMode = $levfile[$fpos+92]
$BumpCount = $levfile[$fpos+93]
$Vehicle =  convert16bitint $levfile[$fpos+94] $levfile[$fpos+95]
$LinkPassenger = convert16bitint $levfile[$fpos+96] $levfile[$fpos+97]
$Within = convert16bitint $levfile[$fpos+98] $levfile[$fpos+99]
$LastDist = convert16bitint $levfile[$fpos+100] $levfile[$fpos+101]
$ComTimer = convert16bitint $levfile[$fpos+102] $levfile[$fpos+103]
$Timer2 = convert16bitint $levfile[$fpos+104] $levfile[$fpos+105]
$StartTimer2 = convert16bitint $levfile[$fpos+106] $levfile[$fpos+107]
$AnimMode = $levfile[$fpos+108]
$OldAnimMode = $levfile[$fpos+109]
$OnFace = convert16bitint $levfile[$fpos+110] $levfile[$fpos+111]
$UMod = convert16bitint $levfile[$fpos+112] $levfile[$fpos+113]
$Mood = convert16bitint $levfile[$fpos+114] $levfile[$fpos+115]
$FrameId = convert32bitint $levfile[$fpos+116] $levfile[$fpos+117] $levfile[$fpos+118] $levfile[$fpos+119] $levfile[$fpos+120]
$Shadows = convert32bitint $levfile[$fpos+121] $levfile[$fpos+122] $levfile[$fpos+123] $levfile[$fpos+124]
$RecoilTimer = $levfile[$fpos+125]
$MaxHealth = convert16bitint $levfile[$fpos+126] $levfile[$fpos+127]
$Flag3 = $levfile[$fpos+128]
$OldSubType = $levfile[$fpos+129]
$ShieldEnergy = convert16bitint $levfile[$fpos+130] $levfile[$fpos+131]
$ShieldGlowTimer = $levfile[$fpos+132]
$WeaponDir = $levfile[$fpos+133]
$SpecialOwner = convert16bitint $levfile[$fpos+134] $levfile[$fpos+135]
$WorkPlace = convert16bitint $levfile[$fpos+136] $levfile[$fpos+137]
$LeisurePlace = convert16bitint $levfile[$fpos+138] $levfile[$fpos+139]
$WeaponTimer = convert16bitint $levfile[$fpos+140] $levfile[$fpos+141]
$Target2 = convert16bitint $levfile[$fpos+142] $levfile[$fpos+143]
$MaxShieldEnergy = convert16bitint $levfile[$fpos+144] $levfile[$fpos+145]
$PersuadePower = convert16bitint $levfile[$fpos+146] $levfile[$fpos+147]
$MaxEnergy = convert16bitint $levfile[$fpos+148] $levfile[$fpos+149]
$Energy  = convert16bitint $levfile[$fpos+150] $levfile[$fpos+151]
$RecoilDir = $levfile[$fpos+152]
$CurrentWeapon = $levfile[$fpos+153]
$GotoX = convert16bitint $levfile[$fpos+154] $levfile[$fpos+155]
$GotoZ = convert16bitint $levfile[$fpos+156] $levfile[$fpos+157]
$TempWeapon = convert16bitint $levfile[$fpos+158] $levfile[$fpos+159]
$Stamina = convert16bitint $levfile[$fpos+160] $levfile[$fpos+161]
$MaxStamina = convert16bitint $levfile[$fpos+162] $levfile[$fpos+163]

if($type -eq 40 -or $type -eq 50 -or $type -eq 51 -or $type -eq 54 ){
$vehicletype = identifyvehicle $startframe
}
Else{
$vehicletype = "N/A"
}


if ($filetype -gt 12){
$WeaponsCarried = convert32bitint $levfile[$fpos+164] $levfile[$fpos+165] $levfile[$fpos+166] $levfile[$fpos+167]
$weaponscarried2 = $WeaponsCarried
}
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

if ($state -eq 33 -OR $state -eq 61 -or $state -eq 64){  #Vehicles data

$ObjectWidth = convert32bitint $levfile[$fpos+168] $levfile[$fpos+169] $levfile[$fpos+170] $levfile[$fpos+171]  #Default is normally 0400      
$Objectskewleft = convert32bitint $levfile[$fpos+172] $levfile[$fpos+173] $levfile[$fpos+174] $levfile[$fpos+175] 
$Objectskewright = convert32bitint $levfile[$fpos+176] $levfile[$fpos+177] $levfile[$fpos+178] $levfile[$fpos+179] 
$ObjectRoll = convert32bitint $levfile[$fpos+180] $levfile[$fpos+181] $levfile[$fpos+182] $levfile[$fpos+183] 
$ObjectHeight = convert32bitint $levfile[$fpos+184] $levfile[$fpos+185] $levfile[$fpos+186] $levfile[$fpos+187] #Default is normally 0400 
$ObjectPitch = convert32bitint $levfile[$fpos+188] $levfile[$fpos+189] $levfile[$fpos+190] $levfile[$fpos+191]
$ObjectSkew2 = convert32bitint $levfile[$fpos+192] $levfile[$fpos+193] $levfile[$fpos+194] $levfile[$fpos+195]
$ObjectStretch = convert32bitint $levfile[$fpos+196] $levfile[$fpos+197] $levfile[$fpos+198] $levfile[$fpos+199]
$ObjectLength = convert32bitint $levfile[$fpos+200] $levfile[$fpos+201] $levfile[$fpos+201] $levfile[$fpos+203] #Default is normally 0400 


$fpos = $fpos +36
}


if ($filetype -eq 9 -or $filetype -eq 11 -or $filetype -eq 12){  #scan for extended data in old files first
$Person1 = convert32bitint $levfile[$fpos+168] $levfile[$fpos+169] $levfile[$fpos+170] $levfile[$fpos+171]  
#$Person2 = convert16bitint $levfile[$fpos+171] $levfile[$fpos+172]
$Person3 = convert16bitint $levfile[$fpos+172] $levfile[$fpos+173]


$person4 = convert32bitint $levfile[$fpos+174] $levfile[$fpos+175] 
$person5 = convert32bitint $levfile[$fpos+176] $levfile[$fpos+177]
$person6 = convert32bitint $levfile[$fpos+178] $levfile[$fpos+179]

$person11 = convert16bitint $levfile[$fpos+190] $levfile[$fpos+191] 



$Person7 = convert16bitint $levfile[$fpos+181] $levfile[$fpos+182]
$Person8 = convert16bitint $levfile[$fpos+183] $levfile[$fpos+184]
$Person9 = convert16bitint $levfile[$fpos+185] $levfile[$fpos+186]
$Person10 = convert16bitint $levfile[$fpos+187] $levfile[$fpos+188]

$Person13 = convert16bitint $levfile[$fpos+193] $levfile[$fpos+194]
$Person14 = convert16bitint $levfile[$fpos+195] $levfile[$fpos+196]
$Person15 = convert16bitint $levfile[$fpos+197] $levfile[$fpos+198]
$Person16 = convert16bitint $levfile[$fpos+199] $levfile[$fpos+200]
$Person17 = convert16bitint $levfile[$fpos+201] $levfile[$fpos+202]
$Person18 = convert16bitint $levfile[$fpos+203] $levfile[$fpos+204]
$Person19 = convert16bitint $levfile[$fpos+203] $levfile[$fpos+204]
$Person20 = convert16bitint $levfile[$fpos+203] $levfile[$fpos+204]
$Person21 = convert16bitint $levfile[$fpos+203] $levfile[$fpos+204]
$Person22 = convert16bitint $levfile[$fpos+203] $levfile[$fpos+204]
$Person23 = convert32bitint $levfile[$fpos+205] $levfile[$fpos+206] $levfile[$fpos+207] $levfile[$fpos+208]
#$Person24 = convert16bitint $levfile[$fpos+207] $levfile[$fpos+208]
$Person25 = convert16bitint $levfile[$fpos+209] $levfile[$fpos+210]
$Person26 = convert16bitint $levfile[$fpos+211] $levfile[$fpos+212]

$Person27 = convert32bitint $levfile[$fpos+212] $levfile[$fpos+213] $levfile[$fpos+214] $levfile[$fpos+215]

}


#Output to console

$consoleoutput = "$counter, $type, $charactername, $thingtype, $vehicletype, $WeaponsCarried2, $weaponstext, $group, $GroupName, $EffectiveGroup, $state, ($map_posx, $map_posy, $map_posz), $maxenergy" 
write-host $consoleoutput

#output toarray to output CSV file 

$CharacterEntry = New-Object PSObject
$CharacterEntry | Add-Member -type NoteProperty -Name 'Character No.' -Value $counter
$CharacterEntry | Add-Member -type NoteProperty -Name 'Parent' -Value $Parent
$CharacterEntry | Add-Member -type NoteProperty -Name 'Next' -Value $Next
$CharacterEntry | Add-Member -type NoteProperty -Name 'LinkParent' -Value $LinkParent
$CharacterEntry | Add-Member -type NoteProperty -Name 'Link Child' -Value $LinkChild
$CharacterEntry | Add-Member -type NoteProperty -Name 'Character Type' -Value $type
$CharacterEntry | Add-Member -type NoteProperty -Name 'Character Name' -Value $charactername
$CharacterEntry | Add-Member -type NoteProperty -Name 'Thing Type' -Value $thingtype
$CharacterEntry | Add-Member -type NoteProperty -Name 'Vehicle Type' -Value $vehicletype
$CharacterEntry | Add-Member -type NoteProperty -Name 'State' -Value $state
$CharacterEntry | Add-Member -type NoteProperty -Name 'Flag' -Value $flag
$CharacterEntry | Add-Member -type NoteProperty -Name 'LinkSame' -Value $LinkSame
$CharacterEntry | Add-Member -type NoteProperty -Name 'LinkSame Group' -Value $LinkSameGroup
$CharacterEntry | Add-Member -type NoteProperty -Name 'Radius' -Value $Radius
$CharacterEntry | Add-Member -type NoteProperty -Name 'Thing Offset' -Value $ThingOffset
$CharacterEntry | Add-Member -type NoteProperty -Name 'Group' -Value $Group
$CharacterEntry | Add-Member -type NoteProperty -Name 'Group Name' -Value $GroupName
$CharacterEntry | Add-Member -type NoteProperty -Name 'Effective Group' -Value $EffectiveGroup
$CharacterEntry | Add-Member -type NoteProperty -Name 'X Position' -Value $map_posx
$CharacterEntry | Add-Member -type NoteProperty -Name 'Y Position' -Value $map_posy
$CharacterEntry | Add-Member -type NoteProperty -Name 'Z Position' -Value $map_posz
$CharacterEntry | Add-Member -type NoteProperty -Name 'Frame' -Value $Frame
$CharacterEntry | Add-Member -type NoteProperty -Name 'StartFrame' -Value $StartFrame
$CharacterEntry | Add-Member -type NoteProperty -Name 'Timer1' -Value $Timer1
$CharacterEntry | Add-Member -type NoteProperty -Name 'StartTimer1' -Value $StartTimer1
$CharacterEntry | Add-Member -type NoteProperty -Name 'VX' -Value $VX
$CharacterEntry | Add-Member -type NoteProperty -Name 'VY' -Value $VY
$CharacterEntry | Add-Member -type NoteProperty -Name 'VZ' -Value $VZ
$CharacterEntry | Add-Member -type NoteProperty -Name 'Speed' -Value $Speed
$CharacterEntry | Add-Member -type NoteProperty -Name 'Health' -Value $Health
$CharacterEntry | Add-Member -type NoteProperty -Name 'Owner' -Value $Owner
$CharacterEntry | Add-Member -type NoteProperty -Name 'PathOffSet' -Value $PathOffSet
$CharacterEntry | Add-Member -type NoteProperty -Name 'SubState' -Value $Substate
$CharacterEntry | Add-Member -type NoteProperty -Name 'PTarget' -Value $PTarget
$CharacterEntry | Add-Member -type NoteProperty -Name 'Flag2' -Value $Flag2
$CharacterEntry | Add-Member -type NoteProperty -Name 'GotoThingIndex' -Value $Gotothingindex
$CharacterEntry | Add-Member -type NoteProperty -Name 'OldTarget' -Value $OldTarget
$CharacterEntry | Add-Member -type NoteProperty -Name 'PathIndex' -Value $PathIndex
$CharacterEntry | Add-Member -type NoteProperty -Name 'UniqueID' -Value $UniqueID
$CharacterEntry | Add-Member -type NoteProperty -Name 'ComHead' -Value $ComHead
$CharacterEntry | Add-Member -type NoteProperty -Name 'ComCur' -Value $ComCur
$CharacterEntry | Add-Member -type NoteProperty -Name 'SpecialTimer' -Value $SpecialTimer
$CharacterEntry | Add-Member -type NoteProperty -Name 'Angle' -Value $Angle
$CharacterEntry | Add-Member -type NoteProperty -Name 'WeaponTurn' -Value $WeaponTurn
$CharacterEntry | Add-Member -type NoteProperty -Name 'Brightness' -Value $Brightness
$CharacterEntry | Add-Member -type NoteProperty -Name 'ComRange' -Value $ComRange
$CharacterEntry | Add-Member -type NoteProperty -Name 'BumpMode' -Value $BumpMode
$CharacterEntry | Add-Member -type NoteProperty -Name 'Vehicle' -Value $Vehicle
$CharacterEntry | Add-Member -type NoteProperty -Name 'LinkPassenger' -Value $LinkPassenger
$CharacterEntry | Add-Member -type NoteProperty -Name 'Within' -Value $Within
$CharacterEntry | Add-Member -type NoteProperty -Name 'LastDist' -Value $LastDist
$CharacterEntry | Add-Member -type NoteProperty -Name 'ComTimer' -Value $ComTimer
$CharacterEntry | Add-Member -type NoteProperty -Name 'Timer2' -Value $Timer2
$CharacterEntry | Add-Member -type NoteProperty -Name 'StartTimer2' -Value $StartTimer2
$CharacterEntry | Add-Member -type NoteProperty -Name 'AnimMode' -Value $AnimMode
$CharacterEntry | Add-Member -type NoteProperty -Name 'OldAnimMode' -Value $OldAnimMode
$CharacterEntry | Add-Member -type NoteProperty -Name 'OnFace' -Value $OnFace
$CharacterEntry | Add-Member -type NoteProperty -Name 'UMod' -Value $UMod
$CharacterEntry | Add-Member -type NoteProperty -Name 'Mood' -Value $Mood
$CharacterEntry | Add-Member -type NoteProperty -Name 'FrameId' -Value $FrameId
$CharacterEntry | Add-Member -type NoteProperty -Name 'Shadows' -Value $Shadows
$CharacterEntry | Add-Member -type NoteProperty -Name 'RecoilTimer' -Value $RecoilTimer
$CharacterEntry | Add-Member -type NoteProperty -Name 'MaxHealth' -Value $MaxHealth
$CharacterEntry | Add-Member -type NoteProperty -Name 'Flag3' -Value $Flag3
$CharacterEntry | Add-Member -type NoteProperty -Name 'OldSubType' -Value $OldSubType
$CharacterEntry | Add-Member -type NoteProperty -Name 'ShieldEnergy' -Value $ShieldEnergy
$CharacterEntry | Add-Member -type NoteProperty -Name 'ShieldGlowTimer' -Value $ShieldGlowTimer
$CharacterEntry | Add-Member -type NoteProperty -Name 'WeaponDir' -Value $WeaponDir
$CharacterEntry | Add-Member -type NoteProperty -Name 'SpecialOwner' -Value $SpecialOwner
$CharacterEntry | Add-Member -type NoteProperty -Name 'WorkPlace' -Value $WorkPlace
$CharacterEntry | Add-Member -type NoteProperty -Name 'LeisurePlace' -Value $LeisurePlace
$CharacterEntry | Add-Member -type NoteProperty -Name 'WeaponTimer' -Value $WeaponTimer
$CharacterEntry | Add-Member -type NoteProperty -Name 'Target2' -Value $Target2
$CharacterEntry | Add-Member -type NoteProperty -Name 'MaxShieldEnergy' -Value $MaxShieldEnergy
$CharacterEntry | Add-Member -type NoteProperty -Name 'PersuadePower' -Value $PersuadePower
$CharacterEntry | Add-Member -type NoteProperty -Name 'MaxEnergy' -Value $MaxEnergy
$CharacterEntry | Add-Member -type NoteProperty -Name 'Energy' -Value $Energy
$CharacterEntry | Add-Member -type NoteProperty -Name 'RecoilDir' -Value $RecoilDir
$CharacterEntry | Add-Member -type NoteProperty -Name 'CurrentWeapon' -Value $CurrentWeapon
$CharacterEntry | Add-Member -type NoteProperty -Name 'GotoX' -Value $GotoX
$CharacterEntry | Add-Member -type NoteProperty -Name 'GotoZ' -Value $GotoZ
$CharacterEntry | Add-Member -type NoteProperty -Name 'TempWeapon' -Value $TempWeapon
$CharacterEntry | Add-Member -type NoteProperty -Name 'Stamina' -Value $Stamina
$CharacterEntry | Add-Member -type NoteProperty -Name 'MaxStamina' -Value $MaxStamina
$CharacterEntry | Add-Member -type NoteProperty -Name 'Weapons Carried Value' -Value $WeaponsCarried2
$CharacterEntry | Add-Member -type NoteProperty -Name 'Weapons Carried List' -Value $weaponstext.Trim()

#Vehicle data here

if ($Thingtype -eq 2 -OR $counter -eq 1){ 
$CharacterEntry | Add-Member -type NoteProperty -Name 'ObjectWidth'  -Value $ObjectWidth
$CharacterEntry | Add-Member -type NoteProperty -Name 'Objectskewleft'  -Value $Objectskewleft
$CharacterEntry | Add-Member -type NoteProperty -Name 'Objectskewright'  -Value $Objectskewright
$CharacterEntry | Add-Member -type NoteProperty -Name 'ObjectRoll'  -Value $ObjectRoll
$CharacterEntry | Add-Member -type NoteProperty -Name 'ObjectHeight'  -Value $ObjectHeight
$CharacterEntry | Add-Member -type NoteProperty -Name 'ObjectPitch'  -Value $ObjectPitch
$CharacterEntry | Add-Member -type NoteProperty -Name 'ObjectSkew2'  -Value $ObjectSkew2
$CharacterEntry | Add-Member -type NoteProperty -Name 'ObjectStretch'  -Value $ObjectStretch
$CharacterEntry | Add-Member -type NoteProperty -Name 'ObjectLength'  -Value $ObjectLength
}

if ($filetype -eq 9 -or $filetype -eq 11 -or $filetype -eq 12){
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person1' -Value $Person1
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person2' -Value $Person2
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person3' -Value $Person3
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person4' -Value $Person4
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person5' -Value $Person5
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person6' -Value $Person6
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person7' -Value $Person7
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person8' -Value $Person8
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person9' -Value $Person9
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person10' -Value $Person10
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person11' -Value $Person11
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person12' -Value $Person12
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person13' -Value $Person13
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person14' -Value $Person14
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person15' -Value $Person15
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person16' -Value $Person16
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person17' -Value $Person17
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person18' -Value $Person18
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person19' -Value $Person19
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person20' -Value $Person20
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person21' -Value $Person21
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person22' -Value $Person22
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person23' -Value $Person23
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person24' -Value $Person24
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person25' -Value $Person25
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person26' -Value $Person26
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person27' -Value $Person27
$CharacterEntry | Add-Member -type NoteProperty -Name 'Person28' -Value $Person28
}


$Fileoutput += $characterentry

$charcount = $charcount - 1

if ($filetype -eq 9 -or $filetype -eq 11 -or $filetype -eq 12){
$fpos = $fpos + 48
}



$fpos = $fpos + 168
}
UNTIL ($charcount -eq 0)

#Output to CSV
$csvname = [io.path]::GetFileName("$filename")

$fileext = $csvname+"Characters.csv"
write-host "Exporting to $fileext"

$Fileoutput | export-csv -NoTypeInformation $fileext

#commands

$commandcount = convert16bitint $levfile[$fpos] $levfile[$fpos+1] #Read command count header number

write-host ""
write-host "File has $commandcount unit commands"

if ($commandcount -eq 0){
write-host "Bad data structure, quitting"
exit}

$commandnumber = 0
$commandoutput = @()

$fpos = $fpos+2
DO
{
$commandcount = $commandcount -1
$Next = convert16bitint $levfile[$fpos] $levfile[$fpos+1]
$OtherThing = convert16bitint $levfile[$fpos+2] $levfile[$fpos+3]
$X = convert16bitint $levfile[$fpos+4] $levfile[$fpos+5]
$Y = convert16bitint $levfile[$fpos+6] $levfile[$fpos+7]
$Z = convert16bitint $levfile[$fpos+8] $levfile[$fpos+9]
$Type = $levfile[$fpos+10]
$CommandName = identifycommand ($type)
$SubType = $levfile[$fpos+11]
$Arg1 = convert16bitint $levfile[$fpos+12] $levfile[$fpos+13]
$Arg2 = convert16bitint $levfile[$fpos+14] $levfile[$fpos+15]
$Time = convert16bitint $levfile[$fpos+16] $levfile[$fpos+17]
$MyThing = convert16bitint $levfile[$fpos+18] $levfile[$fpos+19]
$Parent = convert16bitint $levfile[$fpos+20] $levfile[$fpos+21]
$Flags = convert32bitint $levfile[$fpos+22] $levfile[$fpos+23] $levfile[$fpos+24] $levfile[$fpos+25]
$Field_1A = convert32bitint $levfile[$fpos+26] $levfile[$fpos+27] $levfile[$fpos+28] $levfile[$fpos+29]
$Field_1E = convert16bitint $levfile[$fpos+30] $levfile[$fpos+31]
if ($otherthing -lt 20 -and $commandname -like "KILL*" -or  $commandname -like "*DEAD" -or $commandname -like "*MEM_G*"   ){
$OtherThingName = $groupsarray[$otherthing]
}
Else{
$OtherThingName = ""
}



$CommandEntry = New-Object PSObject
$CommandEntry | Add-Member -type NoteProperty -Name 'CommandNumber' -Value $CommandNumber
$CommandEntry | Add-Member -type NoteProperty -Name 'Next' -Value $Next
$CommandEntry | Add-Member -type NoteProperty -Name 'OtherThing' -Value $OtherThing
$CommandEntry | Add-Member -type NoteProperty -Name 'OtherThingName' -Value $OtherThingname
$CommandEntry | Add-Member -type NoteProperty -Name 'X' -Value $X
$CommandEntry | Add-Member -type NoteProperty -Name 'Y' -Value $Y
$CommandEntry | Add-Member -type NoteProperty -Name 'Z' -Value $Z
$CommandEntry | Add-Member -type NoteProperty -Name 'Type' -Value $Type
$CommandEntry | Add-Member -type NoteProperty -Name 'CommandName' -Value $CommandName
$CommandEntry | Add-Member -type NoteProperty -Name 'SubType' -Value $SubType
$CommandEntry | Add-Member -type NoteProperty -Name 'Arg1' -Value $Arg1
$CommandEntry | Add-Member -type NoteProperty -Name 'Arg2' -Value $Arg2
$CommandEntry | Add-Member -type NoteProperty -Name 'Time' -Value $Time
$CommandEntry | Add-Member -type NoteProperty -Name 'MyThing' -Value $MyThing
$CommandEntry | Add-Member -type NoteProperty -Name 'Parent' -Value $Parent
$CommandEntry | Add-Member -type NoteProperty -Name 'Flags' -Value $Flags
$CommandEntry | Add-Member -type NoteProperty -Name 'field_1A' -Value $field_1A
$CommandEntry | Add-Member -type NoteProperty -Name 'field_1E' -Value $field_1E



$Commandoutput += $CommandEntry

$fpos = $fpos+32
$commandnumber = $commandnumber +1


}
UNTIL ($commandcount -eq 0)
echo $fpos
$fileext = $csvname+"Commands.csv"
write-host "Exporting to $fileext"

$commandoutput | export-csv -NoTypeInformation $fileext



}

