--written by baria and clue :D

local CHECK_INTERVAL = 120

local BEAMS_ADDRESS = 0x300003B
local WEAPONS_ADDRESS = 0x300003C
local MOVEMENT_ADDRESS = 0x300003D
local METROIDS_OBTAINED_ADDRESS = 0x300003E
local METROIDS_REQUIRED_ADDRESS = memory.read_u32_le(0x087FF010)
local SECURITY_ADDRESS = 0x300131D
local GAMEMODE_ADDRESS = 0x3000BDE

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

client.SetGameExtraPadding(88,0,0,0)
gui.use_surface("emucore")
while true do
    local CURRENT_FRAME = emu.framecount()
    if CURRENT_FRAME % CHECK_INTERVAL == 0 and memory.read_u16_le(GAMEMODE_ADDRESS) == 1 then
        local BEAMS_VALUE = memory.read_u8(BEAMS_ADDRESS)
        local WEAPONS_VALUE = memory.read_u8(WEAPONS_ADDRESS)
        local MOVEMENT_VALUE = memory.read_u8(MOVEMENT_ADDRESS)
        local METROIDS_OBTAINED_VALUE = memory.read_u8(METROIDS_OBTAINED_ADDRESS)
        local METROIDS_REQUIRED_VALUE = memory.read_u8(METROIDS_REQUIRED_ADDRESS)
        local SECURITY_VALUE = memory.read_u8(SECURITY_ADDRESS)

        if BEAMS_VALUE & CHARGE_VALUE == CHARGE_VALUE then
            gui.drawImage("bariatracker/charge.png", 2, 50)
        else
            gui.drawImage("bariatracker/charge_gray.png", 2, 50)
        end

        if BEAMS_VALUE & WIDE_VALUE == WIDE_VALUE then
            gui.drawImage("bariatracker/wide.png", 19, 50)
        else
            gui.drawImage("bariatracker/wide_gray.png", 19, 50)
        end

        if BEAMS_VALUE & PLASMA_VALUE == PLASMA_VALUE then
            gui.drawImage("bariatracker/plasma.png", 36, 50)
        else
            gui.drawImage("bariatracker/plasma_gray.png", 36, 50)
        end

        if BEAMS_VALUE & WAVE_VALUE == WAVE_VALUE then
            gui.drawImage("bariatracker/wave.png", 53, 50)
        else
            gui.drawImage("bariatracker/wave_gray.png", 53, 50)
        end

        if BEAMS_VALUE & ICE_VALUE == ICE_VALUE then
            gui.drawImage("bariatracker/icebeam.png", 70, 50)
        else
            gui.drawImage("bariatracker/icebeam_gray.png", 70, 50)
        end

        if WEAPONS_VALUE & BASE_MISSILE_VALUE == BASE_MISSILE_VALUE then
            gui.drawImage("bariatracker/missiles.png", 10, 68)
        else
            gui.drawImage("bariatracker/missiles_gray.png", 10, 68)
        end

        if WEAPONS_VALUE & SUPER_MISSILE_VALUE == SUPER_MISSILE_VALUE then
            gui.drawImage("bariatracker/supers.png", 26, 68)
        else
            gui.drawImage("bariatracker/supers_gray.png", 26, 68)
        end

        if WEAPONS_VALUE & ICE_MISSILE_VALUE == ICE_MISSILE_VALUE then
            gui.drawImage("bariatracker/icemissiles.png", 43, 68)
        else
            gui.drawImage("bariatracker/icemissiles_gray.png", 43, 68)
        end

        if WEAPONS_VALUE & DIFFUSION_MISSILE_VALUE == DIFFUSION_MISSILE_VALUE then
            gui.drawImage("bariatracker/diffusion.png", 60, 68)
        else
            gui.drawImage("bariatracker/diffusion_gray.png", 60, 68)
        end

        if MOVEMENT_VALUE & MORPH_BALL_VALUE == MORPH_BALL_VALUE then
            gui.drawImage("bariatracker/morph.png", 2, 86)
        else
            gui.drawImage("bariatracker/morph_gray.png", 2, 86)
        end

        if WEAPONS_VALUE & BOMBS_VALUE == BOMBS_VALUE then
            gui.drawImage("bariatracker/bombs.png", 19, 86)
        else
            gui.drawImage("bariatracker/bombs_gray.png", 19, 86)
        end

        if WEAPONS_VALUE & POWER_BOMBS_VALUE == POWER_BOMBS_VALUE then
            gui.drawImage("bariatracker/powerbombs.png", 36, 86)
        else
            gui.drawImage("bariatracker/powerbombs_gray.png", 36, 86)
        end

        if MOVEMENT_VALUE & VARIA_VALUE == VARIA_VALUE then
            gui.drawImage("bariatracker/varia.png", 53, 86)
        else
            gui.drawImage("bariatracker/varia_gray.png", 53, 86)
        end

        if MOVEMENT_VALUE & GRAVITY_VALUE == GRAVITY_VALUE then
            gui.drawImage("bariatracker/gravity.png", 70, 86)
        else
            gui.drawImage("bariatracker/gravity_gray.png", 70, 86)
        end

        if MOVEMENT_VALUE & HIGH_JUMP_VALUE == HIGH_JUMP_VALUE then
            gui.drawImage("bariatracker/highjump.png", 9, 104)
        else
            gui.drawImage("bariatracker/highjump_gray.png", 9, 104)
        end

        if MOVEMENT_VALUE & SPEEDBOOSTER_VALUE == SPEEDBOOSTER_VALUE then
            gui.drawImage("bariatracker/speed.png", 26, 104)
        else
            gui.drawImage("bariatracker/speed_gray.png", 26, 104)
        end

        if MOVEMENT_VALUE & SPACE_JUMP_VALUE == SPACE_JUMP_VALUE then
            gui.drawImage("bariatracker/spacejump.png", 43, 104)
        else
            gui.drawImage("bariatracker/spacejump_gray.png", 43, 104)
        end

        if MOVEMENT_VALUE & SCREW_ATTACK_VALUE == SCREW_ATTACK_VALUE then
            gui.drawImage("bariatracker/screwattack.png", 60, 104)
        else
            gui.drawImage("bariatracker/screwattack_gray.png", 60, 104)
        end

        if SECURITY_VALUE & BLUE_VALUE == BLUE_VALUE then
            gui.drawImage("bariatracker/l1.png", 9, 122)
        else
            gui.drawImage("bariatracker/l1_gray.png", 9, 122)
        end

        if SECURITY_VALUE & GREEN_VALUE == GREEN_VALUE then
            gui.drawImage("bariatracker/l2.png", 26, 122)
        else
            gui.drawImage("bariatracker/l2_gray.png", 26, 122)
        end

        if SECURITY_VALUE & YELLOW_VALUE == YELLOW_VALUE then
            gui.drawImage("bariatracker/l3.png", 43, 122)
        else
            gui.drawImage("bariatracker/l3_gray.png", 43, 122)
        end

        if SECURITY_VALUE & RED_VALUE == RED_VALUE then
            gui.drawImage("bariatracker/l4.png", 60, 122)
        else
            gui.drawImage("bariatracker/l4_gray.png", 60, 122)
        end

        gui.drawImage("bariatracker/metroid.png", 20, 140)
        gui.drawString(37, 140, METROIDS_OBTAINED_VALUE .. "/" .. METROIDS_REQUIRED_VALUE, "white")
    end
    emu.frameadvance()
end