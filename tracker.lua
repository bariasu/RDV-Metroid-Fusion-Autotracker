--written by baria and clue :D

-- Settings for the tracker, can be changed in settings.ini
local TRACKER_DIRECTION = "left" -- values are "left" and "right"
local INCLUDE_L0 = false  -- values are true and false

-- Get directory from lua script
local pwd = ""
local dir_seperator = package.config:sub(1,1)
if dir_seperator == "\\" then
    pwd = io.popen("cd"):read()
else
    pwd = io.popen("pwd"):read()
end

-- Check if settings file exists and read them
local settings = pwd .. dir_seperator .. "settings.ini"
local file = io.open(settings, "r")
if file then
    file:close()
    -- read settings from file
    for line in io.lines(settings) do
        local key, value = line:match("([%w_]+)%s*=%s*(.+)")
        if key and value then
            if key == "TRACKER_DIRECTION" then
                TRACKER_DIRECTION = value:gsub('"', '') -- remove quotes
            elseif key == "INCLUDE_L0" then
                INCLUDE_L0 = (value == "true") -- convert to boolean
            end
        end
    end
end


local CHECK_INTERVAL = 120 --number of frames between memory reads

--this variable chooses which memory read to perform on a given frame, then increments itself
local ADDRESS_SELECTOR = 1

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

local GRAY_VALUE = 1 << 0
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
-- Per-item definitions: images + default coordinates (relative to `offset`)
local ITEM_DEFS = {
    charge = { active = "images/charge.gif", inactive = "images/charge_gray.gif", x = 2, y = 50 },
    wide = { active = "images/wide.gif", inactive = "images/wide_gray.gif", x = 19, y = 50 },
    plasma = { active = "images/plasma.gif", inactive = "images/plasma_gray.gif", x = 36, y = 50 },
    wave = { active = "images/wave.gif", inactive = "images/wave_gray.gif", x = 53, y = 50 },
    icebeam = { active = "images/icebeam.gif", inactive = "images/icebeam_gray.gif", x = 70, y = 50 },

    missiles = { active = "images/missiles.gif", inactive = "images/missiles_gray.gif", x = 10, y = 68 },
    supers = { active = "images/supers.gif", inactive = "images/supers_gray.gif", x = 26, y = 68 },
    icemissiles = { active = "images/icemissiles.gif", inactive = "images/icemissiles_gray.gif", x = 43, y = 68 },
    diffusion = { active = "images/diffusion.gif", inactive = "images/diffusion_gray.gif", x = 60, y = 68 },

    morph = { active = "images/morph.gif", inactive = "images/morph_gray.gif", x = 2, y = 86 },
    bombs = { active = "images/bombs.gif", inactive = "images/bombs_gray.gif", x = 19, y = 86 },
    powerbombs = { active = "images/powerbombs.gif", inactive = "images/powerbombs_gray.gif", x = 36, y = 86 },
    varia = { active = "images/varia.gif", inactive = "images/varia_gray.gif", x = 53, y = 86 },
    gravity = { active = "images/gravity.gif", inactive = "images/gravity_gray.gif", x = 70, y = 86 },

    highjump = { active = "images/highjump.gif", inactive = "images/highjump_gray.gif", x = 9, y = 104 },
    speed = { active = "images/speed.gif", inactive = "images/speed_gray.gif", x = 26, y = 104 },
    spacejump = { active = "images/spacejump.gif", inactive = "images/spacejump_gray.gif", x = 43, y = 104 },
    screwattack = { active = "images/screwattack.gif", inactive = "images/screwattack_gray.gif", x = 60, y = 104 },

    l0 = { active = "images/l0.gif", inactive = "images/l0_gray.gif", x = 2, y = 122 },
    l1 = { active = "images/l1.gif", inactive = "images/l1_gray.gif", x = 9, y = 122 },
    l2 = { active = "images/l2.gif", inactive = "images/l2_gray.gif", x = 26, y = 122 },
    l3 = { active = "images/l3.gif", inactive = "images/l3_gray.gif", x = 43, y = 122 },
    l4 = { active = "images/l4.gif", inactive = "images/l4_gray.gif", x = 60, y = 122 },

    metroid = { active = "images/metroid.gif", inactive = "images/metroid.gif", x = 20, y = 140 },
}

--creates the empty space within the bizhawk window
local padding = 88
local global_offset = 0
if TRACKER_DIRECTION == "left" then
    client.SetGameExtraPadding(padding, 0, 0, 0)
elseif TRACKER_DIRECTION == "right" then
    client.SetGameExtraPadding(0, 0, padding, 0)
    global_offset = 240
else 
    error("Invalid configuration for TRACKER_DIRECTION")
end

local l0offset = 0
if INCLUDE_L0 then
    l0offset = 10
end


--bizhawk function, necessary for drawing images
gui.use_surface("emucore")

-- helper to draw an item by key, using ITEM_DEFS
local function draw_item(active, def, x_offset)
    local img = active and def.active or def.inactive
    local x = def.x + global_offset
    if x_offset then
        x = x + x_offset
    end
    gui.drawImage(img, x, def.y, nil, nil, false)
end

--the main loop that reads the game's memory and draws the tracker images
while true do
    local CURRENT_FRAME = emu.framecount()

    --this allows the script to check the player's loadout only at the set interval, and only when in-game, unpaused, while not talking to Adam
    if CURRENT_FRAME % CHECK_INTERVAL == 0 and memory.read_u16_le(GAMEMODE_ADDRESS) == 1 then
        --stores the values of the player's entire loadout, the memory reads are distributed across different frames to prevent lag spikes
        if ADDRESS_SELECTOR == 1 then
            BEAMS_VALUE = memory.read_u8(BEAMS_ADDRESS)
        elseif ADDRESS_SELECTOR == 2 then
            WEAPONS_VALUE = memory.read_u8(WEAPONS_ADDRESS)
        elseif ADDRESS_SELECTOR == 3 then
            MOVEMENT_VALUE = memory.read_u8(MOVEMENT_ADDRESS)
        elseif ADDRESS_SELECTOR == 4 then
            METROIDS_OBTAINED_VALUE = memory.read_u8(METROIDS_OBTAINED_ADDRESS)
        else
            SECURITY_VALUE = memory.read_u8(SECURITY_ADDRESS)
            ADDRESS_SELECTOR = 0
        end
        ADDRESS_SELECTOR = ADDRESS_SELECTOR + 1

        --compares the above values read from memory to the cached loadout variables
        if (BEAMS_VALUE == BEAMS_PRIOR) and (WEAPONS_VALUE == WEAPONS_PRIOR) and (MOVEMENT_VALUE == MOVEMENT_PRIOR) and (METROIDS_OBTAINED_VALUE == METROIDS_PRIOR) and (SECURITY_VALUE == SECURITY_PRIOR) then
            CHECK_LOADOUT = false
        else
            CHECK_LOADOUT = true
        end

        --these statements use bitwise AND to determine which icon to draw for each item, and are only triggered if the player's loadout has changed.
        --the coordinates can be changed to adjust the position of the tracker items in the bizhawk window.
        if CHECK_LOADOUT then
            draw_item((BEAMS_VALUE & CHARGE_VALUE) == CHARGE_VALUE, ITEM_DEFS.charge)
            draw_item((BEAMS_VALUE & WIDE_VALUE) == WIDE_VALUE, ITEM_DEFS.wide)
            draw_item((BEAMS_VALUE & PLASMA_VALUE) == PLASMA_VALUE, ITEM_DEFS.plasma)
            draw_item((BEAMS_VALUE & WAVE_VALUE) == WAVE_VALUE, ITEM_DEFS.wave)
            draw_item((BEAMS_VALUE & ICE_VALUE) == ICE_VALUE, ITEM_DEFS.icebeam)

            draw_item((WEAPONS_VALUE & BASE_MISSILE_VALUE) == BASE_MISSILE_VALUE, ITEM_DEFS.missiles)
            draw_item((WEAPONS_VALUE & SUPER_MISSILE_VALUE) == SUPER_MISSILE_VALUE, ITEM_DEFS.supers)
            draw_item((WEAPONS_VALUE & ICE_MISSILE_VALUE) == ICE_MISSILE_VALUE, ITEM_DEFS.icemissiles)
            draw_item((WEAPONS_VALUE & DIFFUSION_MISSILE_VALUE) == DIFFUSION_MISSILE_VALUE, ITEM_DEFS.diffusion)

            draw_item((MOVEMENT_VALUE & MORPH_BALL_VALUE) == MORPH_BALL_VALUE, ITEM_DEFS.morph)
            draw_item((WEAPONS_VALUE & BOMBS_VALUE) == BOMBS_VALUE, ITEM_DEFS.bombs)
            draw_item((WEAPONS_VALUE & POWER_BOMBS_VALUE) == POWER_BOMBS_VALUE, ITEM_DEFS.powerbombs)
            draw_item((MOVEMENT_VALUE & VARIA_VALUE) == VARIA_VALUE, ITEM_DEFS.varia)
            draw_item((MOVEMENT_VALUE & GRAVITY_VALUE) == GRAVITY_VALUE, ITEM_DEFS.gravity)

            draw_item((MOVEMENT_VALUE & HIGH_JUMP_VALUE) == HIGH_JUMP_VALUE, ITEM_DEFS.highjump)
            draw_item((MOVEMENT_VALUE & SPEEDBOOSTER_VALUE) == SPEEDBOOSTER_VALUE, ITEM_DEFS.speed)
            draw_item((MOVEMENT_VALUE & SPACE_JUMP_VALUE) == SPACE_JUMP_VALUE, ITEM_DEFS.spacejump)
            draw_item((MOVEMENT_VALUE & SCREW_ATTACK_VALUE) == SCREW_ATTACK_VALUE, ITEM_DEFS.screwattack)

            if INCLUDE_L0 then
                draw_item((SECURITY_VALUE & GRAY_VALUE) == GRAY_VALUE, ITEM_DEFS.l0)
            end
            draw_item((SECURITY_VALUE & BLUE_VALUE) == BLUE_VALUE, ITEM_DEFS.l1, l0offset)
            draw_item((SECURITY_VALUE & GREEN_VALUE) == GREEN_VALUE, ITEM_DEFS.l2, l0offset)
            draw_item((SECURITY_VALUE & YELLOW_VALUE) == YELLOW_VALUE, ITEM_DEFS.l3, l0offset)
            draw_item((SECURITY_VALUE & RED_VALUE) == RED_VALUE, ITEM_DEFS.l4, l0offset)
            
            draw_item(true, ITEM_DEFS.metroid)
            gui.drawString(global_offset+37, 142, " " .. METROIDS_OBTAINED_VALUE .. "/" .. METROIDS_REQUIRED_VALUE,"white")

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
