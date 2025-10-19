--written by baria and clue :D

local CHECK_INTERVAL = 30 --number of frames between memory reads

--this variable chooses which memory read to perform on a given frame, then increments itself
local i = 1

--storing memory locations
local BEAMS_ADDRESS = 0x300003B
local WEAPONS_ADDRESS = 0x300003C
local MOVEMENT_ADDRESS = 0x300003D
local METROIDS_OBTAINED_ADDRESS = 0x300003E
local METROIDS_REQUIRED_ADDRESS = memory.read_u32_le(0x087FF010)
local METROIDS_REQUIRED_VALUE = memory.read_u8(METROIDS_REQUIRED_ADDRESS)
local SECURITY_ADDRESS = 0x300131D
local GAMEMODE_ADDRESS = 0x3000BDE

--storing immutable data
local CHARGE_VALUE = 1 << 0
local WIDE_VALUE = 1 << 1
local PLASMA_VALUE = 1 << 2
local WAVE_VALUE = 1 << 3
local ICE_VALUE = 1 << 4

local BASE_MISSILE_VALUE = 1 << 0
local SUPER_MISSILE_VALUE = 1 << 1
local ICE_MISSILE_VALUE = 1 << 2
local DIFFUSION_MISSILE_VALUE = 1 << 3
local BOMBS_VALUE = 1 << 4
local POWER_BOMBS_VALUE = 1 << 5

local HIGH_JUMP_VALUE = 1 << 0
local SPEEDBOOSTER_VALUE = 1 << 1
local SPACE_JUMP_VALUE = 1 << 2
local SCREW_ATTACK_VALUE = 1 << 3
local VARIA_VALUE = 1 << 4
local GRAVITY_VALUE = 1 << 5
local MORPH_BALL_VALUE = 1 << 6

local BLUE_VALUE = 1 << 1
local GREEN_VALUE = 1 << 2
local YELLOW_VALUE = 1 << 3
local RED_VALUE = 1 << 4

--initializing the loadout
local BEAMS_VALUE = memory.read_u8(BEAMS_ADDRESS)
local WEAPONS_VALUE = memory.read_u8(WEAPONS_ADDRESS)
local MOVEMENT_VALUE = memory.read_u8(MOVEMENT_ADDRESS)
local METROIDS_OBTAINED_VALUE = memory.read_u8(METROIDS_OBTAINED_ADDRESS)
local SECURITY_VALUE = memory.read_u8(SECURITY_ADDRESS)

--these variables will cache the state of the player's loadout after picking up a major item or a metroid, they're used to detect a change in loadout
local CHECK_LOADOUT, BEAMS_PRIOR, WEAPONS_PRIOR, MOVEMENT_PRIOR, SECURITY_PRIOR, METROIDS_PRIOR

--storing image paths in a table
local IMAGES = {
	charge            = "images/charge.gif",
	charge_gray       = "images/charge_gray.gif",
	wide              = "images/wide.gif",
	wide_gray         = "images/wide_gray.gif",
	plasma            = "images/plasma.gif",
	plasma_gray       = "images/plasma_gray.gif",
	wave              = "images/wave.gif",
	wave_gray         = "images/wave_gray.gif",
	icebeam           = "images/icebeam.gif",
	icebeam_gray      = "images/icebeam_gray.gif",
	missiles          = "images/missiles.gif",
	missiles_gray     = "images/missiles_gray.gif",
	supers            = "images/supers.gif",
	supers_gray       = "images/supers_gray.gif",
	icemissiles       = "images/icemissiles.gif",
	icemissiles_gray  = "images/icemissiles_gray.gif",
	diffusion         = "images/diffusion.gif",
	diffusion_gray    = "images/diffusion_gray.gif",
	morph             = "images/morph.gif",
	morph_gray        = "images/morph_gray.gif",
	bombs             = "images/bombs.gif",
	bombs_gray        = "images/bombs_gray.gif",
	powerbombs        = "images/powerbombs.gif",
	powerbombs_gray   = "images/powerbombs_gray.gif",
	varia             = "images/varia.gif",
	varia_gray        = "images/varia_gray.gif",
	gravity           = "images/gravity.gif",
	gravity_gray      = "images/gravity_gray.gif",
	highjump          = "images/highjump.gif",
	highjump_gray     = "images/highjump_gray.gif",
	speed             = "images/speed.gif",
	speed_gray        = "images/speed_gray.gif",
	spacejump         = "images/spacejump.gif",
	spacejump_gray    = "images/spacejump_gray.gif",
	screwattack       = "images/screwattack.gif",
	screwattack_gray  = "images/screwattack_gray.gif",
	l1                = "images/l1.gif",
	l1_gray           = "images/l1_gray.gif",
	l2                = "images/l2.gif",
	l2_gray           = "images/l2_gray.gif",
	l3                = "images/l3.gif",
	l3_gray           = "images/l3_gray.gif",
	l4                = "images/l4.gif",
	l4_gray           = "images/l4_gray.gif",
	metroid           = "images/metroid.gif"
}

--sets the padding within the bizhawk window, can be changed to move the black border to the right side, but you will have to change the coordinates of the items carefully to move the tracker
client.SetGameExtraPadding(88,0,0,0)

--bizhawk function, necessary for drawing images
gui.use_surface("emucore")

--the main loop that reads the game's memory and draws the tracker images
while true do
    local CURRENT_FRAME = emu.framecount()

    --this allows the script to check the player's loadout only at the set interval, and only when in-game, unpaused, while not talking to Adam
    if CURRENT_FRAME % CHECK_INTERVAL == 0 and memory.read_u16_le(GAMEMODE_ADDRESS) == 1 then

        --stores the values of the player's entire loadout while distributing memory reads across different frames to prevent lag spikes
        if i == 1 then
            BEAMS_VALUE = memory.read_u8(BEAMS_ADDRESS)
        elseif i == 2 then
            WEAPONS_VALUE = memory.read_u8(WEAPONS_ADDRESS)
        elseif i == 3 then
            MOVEMENT_VALUE = memory.read_u8(MOVEMENT_ADDRESS)
        elseif i == 4 then
            METROIDS_OBTAINED_VALUE = memory.read_u8(METROIDS_OBTAINED_ADDRESS)
        else
            SECURITY_VALUE = memory.read_u8(SECURITY_ADDRESS)
            i = 0
        end
        i = i + 1

        --compares the above values read from memory to the cached loadout variables
        if (BEAMS_VALUE == BEAMS_PRIOR) and (WEAPONS_VALUE == WEAPONS_PRIOR) and (MOVEMENT_VALUE == MOVEMENT_PRIOR) and (METROIDS_OBTAINED_VALUE == METROIDS_PRIOR) and (SECURITY_VALUE == SECURITY_PRIOR) then
            CHECK_LOADOUT = false
        else
            CHECK_LOADOUT = true
        end

        --these statements use bitwise AND to determine which icon to draw for each item, and are only triggered if the player's loadout has changed.
        --the coordinates can be changed to adjust the position of the tracker items in the bizhawk window.
        if CHECK_LOADOUT then
            if BEAMS_VALUE & CHARGE_VALUE == CHARGE_VALUE then
                gui.drawImage(IMAGES.charge, 2, 50, nil, nil, false)
            else
                gui.drawImage(IMAGES.charge_gray, 2, 50, nil, nil, false)
            end

            if BEAMS_VALUE & WIDE_VALUE == WIDE_VALUE then
                gui.drawImage(IMAGES.wide, 19, 50, nil, nil, false)
            else
                gui.drawImage(IMAGES.wide_gray, 19, 50, nil, nil, false)
            end

            if BEAMS_VALUE & PLASMA_VALUE == PLASMA_VALUE then
                gui.drawImage(IMAGES.plasma, 36, 50)
            else
                gui.drawImage(IMAGES.plasma_gray, 36, 50)
            end

            if BEAMS_VALUE & WAVE_VALUE == WAVE_VALUE then
                gui.drawImage(IMAGES.wave, 53, 50, nil, nil, false)
            else
                gui.drawImage(IMAGES.wave_gray, 53, 50, nil, nil, false)
            end

            if BEAMS_VALUE & ICE_VALUE == ICE_VALUE then
                gui.drawImage(IMAGES.icebeam, 70, 50, nil, nil, false)
            else
                gui.drawImage(IMAGES.icebeam_gray, 70, 50, nil, nil, false)
            end

            if WEAPONS_VALUE & BASE_MISSILE_VALUE == BASE_MISSILE_VALUE then
                gui.drawImage(IMAGES.missiles, 10, 68, nil, nil, false)
            else
                gui.drawImage(IMAGES.missiles_gray, 10, 68, nil, nil, false)
            end

            if WEAPONS_VALUE & SUPER_MISSILE_VALUE == SUPER_MISSILE_VALUE then
                gui.drawImage(IMAGES.supers, 26, 68)
            else
                gui.drawImage(IMAGES.supers_gray, 26, 68, nil, nil, false)
            end

            if WEAPONS_VALUE & ICE_MISSILE_VALUE == ICE_MISSILE_VALUE then
                gui.drawImage(IMAGES.icemissiles, 43, 68, nil, nil, false)
            else
                gui.drawImage(IMAGES.icemissiles_gray, 43, 68, nil, nil, false)
            end

            if WEAPONS_VALUE & DIFFUSION_MISSILE_VALUE == DIFFUSION_MISSILE_VALUE then
                gui.drawImage(IMAGES.diffusion, 60, 68, nil, nil, false)
            else
                gui.drawImage(IMAGES.diffusion_gray, 60, 68, nil, nil, false)
            end

            if MOVEMENT_VALUE & MORPH_BALL_VALUE == MORPH_BALL_VALUE then
                gui.drawImage(IMAGES.morph, 2, 86, nil, nil, false)
            else
                gui.drawImage(IMAGES.morph_gray, 2, 86, nil, nil, false)
            end

            if WEAPONS_VALUE & BOMBS_VALUE == BOMBS_VALUE then
                gui.drawImage(IMAGES.bombs, 19, 86, nil, nil, false)
            else
                gui.drawImage(IMAGES.bombs_gray, 19, 86, nil, nil, false)
            end

            if WEAPONS_VALUE & POWER_BOMBS_VALUE == POWER_BOMBS_VALUE then
                gui.drawImage(IMAGES.powerbombs, 36, 86, nil, nil, false)
            else
                gui.drawImage(IMAGES.powerbombs_gray, 36, 86, nil, nil, false)
            end

            if MOVEMENT_VALUE & VARIA_VALUE == VARIA_VALUE then
                gui.drawImage(IMAGES.varia, 53, 86, nil, nil, false)
            else
                gui.drawImage(IMAGES.varia_gray, 53, 86, nil, nil, false)
            end

            if MOVEMENT_VALUE & GRAVITY_VALUE == GRAVITY_VALUE then
                gui.drawImage(IMAGES.gravity, 70, 86, nil, nil, false)
            else
                gui.drawImage(IMAGES.gravity_gray, 70, 86, nil, nil, false)
            end

            if MOVEMENT_VALUE & HIGH_JUMP_VALUE == HIGH_JUMP_VALUE then
                gui.drawImage(IMAGES.highjump, 9, 104, nil, nil, false)
            else
                gui.drawImage(IMAGES.highjump_gray, 9, 104, nil, nil, false)
            end

            if MOVEMENT_VALUE & SPEEDBOOSTER_VALUE == SPEEDBOOSTER_VALUE then
                gui.drawImage(IMAGES.speed, 26, 104, nil, nil, false)
            else
                gui.drawImage(IMAGES.speed_gray, 26, 104, nil, nil, false)
            end

            if MOVEMENT_VALUE & SPACE_JUMP_VALUE == SPACE_JUMP_VALUE then
                gui.drawImage(IMAGES.spacejump, 43, 104, nil, nil, false)
            else
                gui.drawImage(IMAGES.spacejump_gray, 43, 104, nil, nil, false)
            end

            if MOVEMENT_VALUE & SCREW_ATTACK_VALUE == SCREW_ATTACK_VALUE then
                gui.drawImage(IMAGES.screwattack, 60, 104, nil, nil, false)
            else
                gui.drawImage(IMAGES.screwattack_gray, 60, 104, nil, nil, false)
            end

            if SECURITY_VALUE & BLUE_VALUE == BLUE_VALUE then
                gui.drawImage(IMAGES.l1, 9, 122, nil, nil, false)
            else
                gui.drawImage(IMAGES.l1_gray, 9, 122, nil, nil, false)
            end

            if SECURITY_VALUE & GREEN_VALUE == GREEN_VALUE then
                gui.drawImage(IMAGES.l2, 26, 122, nil, nil, false)
            else
                gui.drawImage(IMAGES.l2_gray, 26, 122, nil, nil, false)
            end

            if SECURITY_VALUE & YELLOW_VALUE == YELLOW_VALUE then
                gui.drawImage(IMAGES.l3, 43, 122, nil, nil, false)
            else
                gui.drawImage(IMAGES.l3_gray, 43, 122, nil, nil, false)
            end

            if SECURITY_VALUE & RED_VALUE == RED_VALUE then
                gui.drawImage(IMAGES.l4, 60, 122, nil, nil, false)
            else
                gui.drawImage(IMAGES.l4_gray, 60, 122, nil, nil, false)
            end

            gui.drawImage(IMAGES.metroid, 20, 140, nil, nil, false)
            gui.drawString(37, 142, " " .. METROIDS_OBTAINED_VALUE .. "/" .. METROIDS_REQUIRED_VALUE,"white")

            --caches the player's loadout after obtaining an item
            BEAMS_PRIOR = BEAMS_VALUE
            WEAPONS_PRIOR = WEAPONS_VALUE
            MOVEMENT_PRIOR = MOVEMENT_VALUE
            METROIDS_PRIOR = METROIDS_OBTAINED_VALUE
            SECURITY_PRIOR = SECURITY_VALUE
        end
    end
    emu.frameadvance()
end
