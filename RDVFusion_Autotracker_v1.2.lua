--written by baria and clue :D

local CHECK_INTERVAL = 120 --number of frames between loops, set higher to decrease frequency of memory reads if you are experiencing performance issues

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

--these variables will cache the current state of the player's loadout after picking up a major item or a metroid
local CHECK_LOADOUT, BEAMS_PRIOR, WEAPONS_PRIOR, MOVEMENT_PRIOR, SECURITY_PRIOR, METROIDS_PRIOR

--storing image paths in a table
local IMAGES = {
	charge            = "images/charge.png",
	charge_gray       = "images/charge_gray.png",
	wide              = "images/wide.png",
	wide_gray         = "images/wide_gray.png",
	plasma            = "images/plasma.png",
	plasma_gray       = "images/plasma_gray.png",
	wave              = "images/wave.png",
	wave_gray         = "images/wave_gray.png",
	icebeam           = "images/icebeam.png",
	icebeam_gray      = "images/icebeam_gray.png",
	missiles          = "images/missiles.png",
	missiles_gray     = "images/missiles_gray.png",
	supers            = "images/supers.png",
	supers_gray       = "images/supers_gray.png",
	icemissiles       = "images/icemissiles.png",
	icemissiles_gray  = "images/icemissiles_gray.png",
	diffusion         = "images/diffusion.png",
	diffusion_gray    = "images/diffusion_gray.png",
	morph             = "images/morph.png",
	morph_gray        = "images/morph_gray.png",
	bombs             = "images/bombs.png",
	bombs_gray        = "images/bombs_gray.png",
	powerbombs        = "images/powerbombs.png",
	powerbombs_gray   = "images/powerbombs_gray.png",
	varia             = "images/varia.png",
	varia_gray        = "images/varia_gray.png",
	gravity           = "images/gravity.png",
	gravity_gray      = "images/gravity_gray.png",
	highjump          = "images/highjump.png",
	highjump_gray     = "images/highjump_gray.png",
	speed             = "images/speed.png",
	speed_gray        = "images/speed_gray.png",
	spacejump         = "images/spacejump.png",
	spacejump_gray    = "images/spacejump_gray.png",
	screwattack       = "images/screwattack.png",
	screwattack_gray  = "images/screwattack_gray.png",
	l1                = "images/l1.png",
	l1_gray           = "images/l1_gray.png",
	l2                = "images/l2.png",
	l2_gray           = "images/l2_gray.png",
	l3                = "images/l3.png",
	l3_gray           = "images/l3_gray.png",
	l4                = "images/l4.png",
	l4_gray           = "images/l4_gray.png",
	metroid           = "images/metroid.png"
}

--bizhawk function, necessary for drawing images
gui.use_surface("emucore")

--drawing images off screen to make sure they are cached
gui.drawImage(IMAGES.charge, -498, 50)
gui.drawImage(IMAGES.charge_gray, -481, 50)
gui.drawImage(IMAGES.wide, -464, 50)
gui.drawImage(IMAGES.wide_gray, -447, 50)
gui.drawImage(IMAGES.plasma, -430, 50)
gui.drawImage(IMAGES.plasma_gray, -413, 50)
gui.drawImage(IMAGES.wave, -396, 50)
gui.drawImage(IMAGES.wave_gray, -379, 50)
gui.drawImage(IMAGES.icebeam, -362, 50)
gui.drawImage(IMAGES.icebeam_gray, -345, 50)

gui.drawImage(IMAGES.missiles, -498, 68)
gui.drawImage(IMAGES.missiles_gray, -481, 68)
gui.drawImage(IMAGES.supers, -464, 68)
gui.drawImage(IMAGES.supers_gray, -447, 68)
gui.drawImage(IMAGES.icemissiles, -430, 68)
gui.drawImage(IMAGES.icemissiles_gray, -413, 68)
gui.drawImage(IMAGES.diffusion, -396, 68)
gui.drawImage(IMAGES.diffusion_gray, -379, 68)

gui.drawImage(IMAGES.morph, -498, 86)
gui.drawImage(IMAGES.morph_gray, -481, 86)
gui.drawImage(IMAGES.bombs, -464, 86)
gui.drawImage(IMAGES.bombs_gray, -447, 86)
gui.drawImage(IMAGES.powerbombs, -430, 86)
gui.drawImage(IMAGES.powerbombs_gray, -413, 86)
gui.drawImage(IMAGES.varia, -396, 86)
gui.drawImage(IMAGES.varia_gray, -379, 86)
gui.drawImage(IMAGES.gravity, -362, 86)
gui.drawImage(IMAGES.gravity_gray, -345, 86)

gui.drawImage(IMAGES.highjump, -498, 104)
gui.drawImage(IMAGES.highjump_gray, -481, 104)
gui.drawImage(IMAGES.speed, -464, 104)
gui.drawImage(IMAGES.speed_gray, -447, 104)
gui.drawImage(IMAGES.spacejump, -430, 104)
gui.drawImage(IMAGES.spacejump_gray, -413, 104)
gui.drawImage(IMAGES.screwattack, -396, 104)
gui.drawImage(IMAGES.screwattack_gray, -379, 104)

gui.drawImage(IMAGES.l1, -498, 122)
gui.drawImage(IMAGES.l1_gray, -481, 122)
gui.drawImage(IMAGES.l2, -464, 122)
gui.drawImage(IMAGES.l2_gray, -447, 122)
gui.drawImage(IMAGES.l3, -430, 122)
gui.drawImage(IMAGES.l3_gray, -413, 122)
gui.drawImage(IMAGES.l4, -396, 122)
gui.drawImage(IMAGES.l4_gray, -379, 122)
gui.drawImage(IMAGES.metroid, -498, 140)

--sets the padding within the bizhawk window, can be changed to move the black border to the right side, but you will have to change the coordinates of the items carefully to move the tracker
client.SetGameExtraPadding(88,0,0,0)

--the main loop that reads the game's memory and draws the tracker images
while true do
    local CURRENT_FRAME = emu.framecount()

    --this allows the script to check the player's loadout only at the set interval, and only when in-game, unpaused, while not talking to Adam
    if CURRENT_FRAME % CHECK_INTERVAL == 0 and memory.read_u16_le(GAMEMODE_ADDRESS) == 1 then
        local BEAMS_VALUE = memory.read_u8(BEAMS_ADDRESS)
        local WEAPONS_VALUE = memory.read_u8(WEAPONS_ADDRESS)
        local MOVEMENT_VALUE = memory.read_u8(MOVEMENT_ADDRESS)
        local METROIDS_OBTAINED_VALUE = memory.read_u8(METROIDS_OBTAINED_ADDRESS)
        local SECURITY_VALUE = memory.read_u8(SECURITY_ADDRESS)

        --compares the above values read from memory to the cached loadout variables
        if (BEAMS_VALUE == BEAMS_PRIOR) and (WEAPONS_VALUE == WEAPONS_PRIOR) and (MOVEMENT_VALUE == MOVEMENT_PRIOR) and (METROIDS_OBTAINED_VALUE == METROIDS_PRIOR) and (SECURITY_VALUE == SECURITY_PRIOR) then
            CHECK_LOADOUT = true
        else
            CHECK_LOADOUT = false
        end

        --[[these statements use bitwise AND to determine which icon to draw for each item, and are only triggered if the player's loadout has changed.
        the coordinates can be changed to adjust the position of the tracker items in the bizhawk window.]]
        if CHECK_LOADOUT == false then
            if BEAMS_VALUE & CHARGE_VALUE == CHARGE_VALUE then
                gui.drawImage(IMAGES.charge, 2, 50)
            else
                gui.drawImage(IMAGES.charge_gray, 2, 50)
            end

            if BEAMS_VALUE & WIDE_VALUE == WIDE_VALUE then
                gui.drawImage(IMAGES.wide, 19, 50)
            else
                gui.drawImage(IMAGES.wide_gray, 19, 50)
            end

            if BEAMS_VALUE & PLASMA_VALUE == PLASMA_VALUE then
                gui.drawImage(IMAGES.plasma, 36, 50)
            else
                gui.drawImage(IMAGES.plasma_gray, 36, 50)
            end

            if BEAMS_VALUE & WAVE_VALUE == WAVE_VALUE then
                gui.drawImage(IMAGES.wave, 53, 50)
            else
                gui.drawImage(IMAGES.wave_gray, 53, 50)
            end

            if BEAMS_VALUE & ICE_VALUE == ICE_VALUE then
                gui.drawImage(IMAGES.icebeam, 70, 50)
            else
                gui.drawImage(IMAGES.icebeam_gray, 70, 50)
            end

            if WEAPONS_VALUE & BASE_MISSILE_VALUE == BASE_MISSILE_VALUE then
                gui.drawImage(IMAGES.missiles, 10, 68)
            else
                gui.drawImage(IMAGES.missiles_gray, 10, 68)
            end

            if WEAPONS_VALUE & SUPER_MISSILE_VALUE == SUPER_MISSILE_VALUE then
                gui.drawImage(IMAGES.supers, 26, 68)
            else
                gui.drawImage(IMAGES.supers_gray, 26, 68)
            end

            if WEAPONS_VALUE & ICE_MISSILE_VALUE == ICE_MISSILE_VALUE then
                gui.drawImage(IMAGES.icemissiles, 43, 68)
            else
                gui.drawImage(IMAGES.icemissiles_gray, 43, 68)
            end

            if WEAPONS_VALUE & DIFFUSION_MISSILE_VALUE == DIFFUSION_MISSILE_VALUE then
                gui.drawImage(IMAGES.diffusion, 60, 68)
            else
                gui.drawImage(IMAGES.diffusion_gray, 60, 68)
            end

            if MOVEMENT_VALUE & MORPH_BALL_VALUE == MORPH_BALL_VALUE then
                gui.drawImage(IMAGES.morph, 2, 86)
            else
                gui.drawImage(IMAGES.morph_gray, 2, 86)
            end

            if WEAPONS_VALUE & BOMBS_VALUE == BOMBS_VALUE then
                gui.drawImage(IMAGES.bombs, 19, 86)
            else
                gui.drawImage(IMAGES.bombs_gray, 19, 86)
            end

            if WEAPONS_VALUE & POWER_BOMBS_VALUE == POWER_BOMBS_VALUE then
                gui.drawImage(IMAGES.powerbombs, 36, 86)
            else
                gui.drawImage(IMAGES.powerbombs_gray, 36, 86)
            end

            if MOVEMENT_VALUE & VARIA_VALUE == VARIA_VALUE then
                gui.drawImage(IMAGES.varia, 53, 86)
            else
                gui.drawImage(IMAGES.varia_gray, 53, 86)
            end

            if MOVEMENT_VALUE & GRAVITY_VALUE == GRAVITY_VALUE then
                gui.drawImage(IMAGES.gravity, 70, 86)
            else
                gui.drawImage(IMAGES.gravity_gray, 70, 86)
            end

            if MOVEMENT_VALUE & HIGH_JUMP_VALUE == HIGH_JUMP_VALUE then
                gui.drawImage(IMAGES.highjump, 9, 104)
            else
                gui.drawImage(IMAGES.highjump_gray, 9, 104)
            end

            if MOVEMENT_VALUE & SPEEDBOOSTER_VALUE == SPEEDBOOSTER_VALUE then
                gui.drawImage(IMAGES.speed, 26, 104)
            else
                gui.drawImage(IMAGES.speed_gray, 26, 104)
            end

            if MOVEMENT_VALUE & SPACE_JUMP_VALUE == SPACE_JUMP_VALUE then
                gui.drawImage(IMAGES.spacejump, 43, 104)
            else
                gui.drawImage(IMAGES.spacejump_gray, 43, 104)
            end

            if MOVEMENT_VALUE & SCREW_ATTACK_VALUE == SCREW_ATTACK_VALUE then
                gui.drawImage(IMAGES.screwattack, 60, 104)
            else
                gui.drawImage(IMAGES.screwattack_gray, 60, 104)
            end

            if SECURITY_VALUE & BLUE_VALUE == BLUE_VALUE then
                gui.drawImage(IMAGES.l1, 9, 122)
            else
                gui.drawImage(IMAGES.l1_gray, 9, 122)
            end

            if SECURITY_VALUE & GREEN_VALUE == GREEN_VALUE then
                gui.drawImage(IMAGES.l2, 26, 122)
            else
                gui.drawImage(IMAGES.l2_gray, 26, 122)
            end

            if SECURITY_VALUE & YELLOW_VALUE == YELLOW_VALUE then
                gui.drawImage(IMAGES.l3, 43, 122)
            else
                gui.drawImage(IMAGES.l3_gray, 43, 122)
            end

            if SECURITY_VALUE & RED_VALUE == RED_VALUE then
                gui.drawImage(IMAGES.l4, 60, 122)
            else
                gui.drawImage(IMAGES.l4_gray, 60, 122)
            end

            gui.drawImage(IMAGES.metroid, 20, 140)
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
