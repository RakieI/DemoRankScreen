-- Demo Rank Screen: Show rankings during Demo Mode
-- Version: 1.0
-- Date: 09/21/2025
-- Author: Rakíel
-- Compatible with: Ikemen GO v0.99 and nightly
-- Description: This mod lets you show rankings during Demo Mode, like some old Arcades and some newer games, you must declare specific parameters inside
-- system.def under [Hiscore Info].

-- [Hiscore Info]
-- demo.ranking.enabled = 1         - Set to 1 to enable rankings during Demo Mode.(Default is 0)  
-- demo.ranking.portraits = 1       - Set to 1 to show portraits in the ranking.(Default is 1)
-- demo.ranking.waittime = 400      - The delay (in frames) after Demo Mode starts before showing the Rankings.
-- demo.ranking.endtime = 500       - How long the ranking stays on screen.

t_base = {
    demo_ranking_enabled = 0,
    demo_ranking_waittime = 400,
    demo_ranking_endtime = 500,
    demo_ranking_portraits = 1,
}
motif.hiscore_info = main.f_tableMerge(t_base, motif.hiscore_info)
local clear = false
function demoRankingInit(mode)
    start.t_hiscore = { faces = {} }

    local t = stats.modes[mode].ranking
    for i = 1, motif.hiscore_info.window_visibleitems do
        table.insert(start.t_hiscore.faces, {})
        if t[i] == nil then
            break
        end
        for _, def in ipairs(t[i].chars) do
            if main.t_charDef[def] ~= nil then
                for _, v in pairs({
                    {motif.hiscore_info.item_face_anim, -1},
                    motif.hiscore_info.item_face_spr,
                }) do
                    if v[1] ~= -1 then
                        local a = animGetPreloadedCharData(main.t_charDef[def], v[1], v[2], true)
                        if a ~= nil then
                            animSetScale(
                                a,
                                motif.hiscore_info.item_face_scale[1] * start.f_getCharData(start.f_getCharRef(def)).portrait_scale / (main.SP_Viewport43[3] / main.SP_Localcoord[1]),
                                motif.hiscore_info.item_face_scale[2] * start.f_getCharData(start.f_getCharRef(def)).portrait_scale / (main.SP_Viewport43[3] / main.SP_Localcoord[1]),
                                false
                            )
                            animUpdate(a)
                            table.insert(start.t_hiscore.faces[#start.t_hiscore.faces], {anim_data = a, chardata = true})
                            break
                        end
                    end
                end
            else
                table.insert(start.t_hiscore.faces[#start.t_hiscore.faces], {anim_data = motif.hiscore_info.item_face_unknown_data, chardata = false})
            end
        end
    end

    return true
end

local lastHiscoreMode = nil

local function loadPortraits(mode)
    if lastHiscoreMode == mode and start.t_hiscore and start.t_hiscore.faces then
        return true
    end
    --reset
    if start.t_hiscore then
        start.t_hiscore.faces = {}
    end
    local ok = demoRankingInit(mode)
    if ok then
        lastHiscoreMode = mode
        return true
    end
    return false
end

local function lineY(v, i)
    local font = motif.hiscore_info["item_" .. v .. "_font"]
    local font_def = main.font_def[font[1] .. font[7]]
    local baseY = motif.hiscore_info.pos[2] + motif.hiscore_info.item_offset[2] + motif.hiscore_info["item_" .. v .. "_offset"][2]
    local step = main.f_round(
        (font_def.Size[2] + font_def.Spacing[2]) * start["txt_hiscore_item_" .. v].scaleY
        + (motif.hiscore_info.item_spacing[2] + motif.hiscore_info["item_" .. v .. "_spacing"][2])
    )
    return baseY + step * (i - 1)
end

local function lineX(v, i)
    return motif.hiscore_info.pos[1] + motif.hiscore_info.item_offset[1]
        + motif.hiscore_info["item_" .. v .. "_offset"][1]
        + (motif.hiscore_info.item_spacing[1] + motif.hiscore_info["item_" .. v .. "_spacing"][1]) * (i - 1)
end

function demoRanking(t)
    local t_ranking = (stats and stats.modes and stats.modes[t.mode]) and stats.modes[t.mode].ranking
    if type(t_ranking) ~= "table" then return end

    -- title
    start.txt_hiscore_title:update({
        text = main.f_itemnameUpper(
            motif.hiscore_info.title_text:gsub("%%s", t.title),
            motif.hiscore_info.title_uppercase == 1
        )
    })
    start.txt_hiscore_title:draw()

    -- portraits init
    if motif.hiscore_info.demo_ranking_portraits == 1 then
        start.txt_hiscore_title_face:draw()
        for i, subt in ipairs(start.t_hiscore.faces) do
            for j, v in ipairs(subt) do
                if j > motif.hiscore_info.item_face_num then break end

                local x = motif.hiscore_info.pos[1] + motif.hiscore_info.item_offset[1]
                        + motif.hiscore_info.item_face_offset[1]
                        + (i - 1) * motif.hiscore_info.item_spacing[1]
                        + (j - 1) * motif.hiscore_info.item_face_spacing[1]

                local y = motif.hiscore_info.pos[2] + motif.hiscore_info.item_offset[2]
                        + motif.hiscore_info.item_face_offset[2]
                        + (i - 1) * (motif.hiscore_info.item_spacing[2] + motif.hiscore_info.item_face_spacing[2])

                main.f_animPosDraw(motif.hiscore_info.item_face_bg_data, x, y, motif.hiscore_info.item_face_facing, false)
                main.f_animPosDraw(v.anim_data, x, y, motif.hiscore_info.item_face_facing, v.chardata)
            end
        end
    end
     -- ranking (rank, data, name)
    for _, v in ipairs({'rank', 'data', 'name'}) do
        -- draw subtitle
        start['txt_hiscore_title_' .. v]:draw()

        for i = 1, motif.hiscore_info.window_visibleitems do
            local entry = t_ranking[i]
            if not entry then break end

            local text = ""

            if v == "rank" then
                text = (motif.hiscore_info["item_rank_" .. i .. "_text"] or motif.hiscore_info.item_rank_text)
                text = text:gsub("%%s", tostring(i))

            elseif v == "data" then
                local subText = entry[t.data]
                local base = motif.hiscore_info["item_data_" .. t.data .. "_" .. i .. "_text"]
                        or motif.hiscore_info["item_data_" .. t.data .. "_text"]
                        or motif.hiscore_info["item_data_" .. i .. "_text"]
                        or motif.hiscore_info.item_data_text

                if t.data == "score" then
                    local pad = tonumber(base:match("%%([0-9]+)s")) or 0
                    subText = string.format("%0" .. pad .. "d", tonumber(subText) or 0)
                    text = base:gsub("%%[0-9]*s", subText)
                elseif t.data == "time" then
                    text = start.f_clearTimeText(base, tostring(subText))
                else
                    text = base:gsub("%%s", tostring(subText))
                end

            elseif v == "name" and entry.name ~= "" then
                text = (motif.hiscore_info["item_name_" .. i .. "_text"] or motif.hiscore_info.item_name_text)
                text = text:gsub("%%([0-9]*)s", main.f_itemnameUpper(entry.name, motif.hiscore_info.item_name_uppercase == 1))
            end

            -- draw cell
            start["txt_hiscore_item_" .. v]:update({
                text = text,
                x = lineX(v, i),
                y = lineY(v, i),
            })
            start["txt_hiscore_item_" .. v]:draw()
        end
    end
end

-- timers
local ranking_timer = 0
local ranking_active = false
local ranking_done = false

local function updateRankingTimer()
    if motif.hiscore_info.demo_ranking_enabled ~= 1 or ranking_done then
        ranking_active = false
        ranking_timer = 0
        return
    end

    if not ranking_active then
        ranking_timer = ranking_timer + 1
        if ranking_timer >= motif.hiscore_info.demo_ranking_waittime then
            ranking_active = true
            ranking_timer = 0
        end
    else
        ranking_timer = ranking_timer + 1
        if ranking_timer >= motif.hiscore_info.demo_ranking_endtime then
            ranking_active = false
            ranking_timer = 0
            ranking_done = true
        end
    end
end

local currentDemoMode = nil

local function ramdomRanking()
    if not main.t_hiscoreData then 
        return nil 
    end
    -- dynamically builds the list from the keys in main.t_hiscoreData
    local hiscoreModes = {}
    for mode, data in pairs(main.t_hiscoreData) do
        if data and stats.modes[mode] and stats.modes[mode].ranking and #stats.modes[mode].ranking > 0 then
            table.insert(hiscoreModes, mode)
        end
    end

    if #hiscoreModes == 0 then
        return nil
    end

    local startIndex = math.random(1, #hiscoreModes)
    for i = 0, #hiscoreModes - 1 do
        local idx = ((startIndex + i - 1) % #hiscoreModes) + 1
        local mode = hiscoreModes[idx]
        return main.t_hiscoreData[mode]
    end
    return nil
end

function drawRanking()
        if roundstart() then -- reset
            ranking_active = false
            ranking_timer = 0
            ranking_done = false
            currentDemoMode = nil
            lastHiscoreMode = nil
            if start.t_hiscore then
                start.t_hiscore.faces = {}
            end
        end
        if not currentDemoMode then
            currentDemoMode = ramdomRanking()
            if currentDemoMode then
                loadPortraits(currentDemoMode.mode)
            end
        end
        updateRankingTimer()
        if motif.hiscore_info.demo_ranking_enabled ~= 1 or not ranking_active then
            return
        end
        if currentDemoMode then
            demoRanking(currentDemoMode)
        end
end
hook.add("loop#demo", "demoRank", drawRanking)