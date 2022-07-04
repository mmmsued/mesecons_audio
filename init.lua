-- Copyright (C) 2020 Norbert Thien, multimediamobil - Region Süd, Lizenz: Creative Commons BY-SA 4.0
-- Kein Rezept, nur im Creative Modus verwendbar oder mit give <playername> mesecons_audio:audio_block
-- Privileg mesecons_audio erforderlich
-- Missing: falsche Angaben im Formspec abfangen (keine Dateiendung, keine Zahl) - nicht wirklich nötig

local just_playing = {} -- Tabelle, die die laufenden Töne speichert, um Doppelabspielung zu verhindern
local not_in_creative_inventory = 0 -- 0 = wird im Creative Mode angezeigt, 1 = wird nicht angezeigt, dann nur mit give erreichbar
local default_heardistance = "3"
local default_gain = "1.0"
local default_selected_audio = "No audio file selected"

local mesecons_audio_path = minetest.get_modpath(minetest.get_current_modname()) .."/sounds" -- Audiodateien im Ordner sounds finden

local function get_audio_list()
	-- Dateinamen aus dem Ordner sounds ermitteln
	local mesecons_audio_dir_list = minetest.get_dir_list(
		mesecons_audio_path
	)
	local new_audio_file = default_selected_audio
	local new_audio_index_list = {default_selected_audio}
	local new_location_list = {0}
	for i=1, #mesecons_audio_dir_list do
		new_audio_file = new_audio_file .. "," .. string.sub(
			mesecons_audio_dir_list[i],
			1,
			string.find (mesecons_audio_dir_list[i], "%.")-1
		)
		new_audio_index_list[i+1] = string.sub(
			mesecons_audio_dir_list[i],
			1,
			string.find (mesecons_audio_dir_list[i], "%.")-1
		)
		new_location_list[i+1] = mesecons_audio_path .. "/" .. mesecons_audio_dir_list[i]
	end
	return new_audio_file, new_audio_index_list, new_location_list
end

local audio_file, audio_index_list = get_audio_list()

local function update_audio_list(caller_name)
	local new_audio_file, new_audio_index_list, locations = get_audio_list()
	local known = {}
	for i, file in pairs(audio_index_list) do
		known[file] = true
	end
	for i, file in pairs(new_audio_index_list) do
		if not known[file] then
			local added = locations[i]
			if minetest.features.dynamic_add_media_table then
				added = {
					filepath = added
				}
			end
			if not minetest.dynamic_add_media(
				added,
				function ()
--					minetest.chat_send_player(
--						caller_name,
--						"audio " .. file .. " sent"
--					)
				end
			) then
				minetest.chat_send_player(
					caller_name,
					"audio " .. file .. " could not be sent"
				)
			end
		end
	end
	audio_file = new_audio_file
	audio_index_list = new_audio_index_list
end

local function initialize_data(meta) -- formspec generieren
	local owner = meta:get_string("owner")

	if not minetest.check_player_privs(owner,{mesecons_audio = true}) then --bei fehlendem Recht Formspec gar nicht erst öffnen
		minetest.chat_send_player(owner, "Dir fehlt das Privileg (mesecons_audio), um Audio-Dateien einzubinden.")
		return
	end

	local selected_audio = minetest.formspec_escape(meta:get_string("choice"))

	local audio_index = "1"
	for i=1, #audio_index_list do -- Index für formspec Dropdown-Element
		if audio_index_list[i] == selected_audio then
			audio_index = i
		end
	end

	local heardistance = minetest.formspec_escape(meta:get_string("heardistance")) or default_heardistance
	local gain = minetest.formspec_escape(meta:get_string("gain")) or default_gain
					-- local restart = minetest.formspec_escape(meta:get_string("restart")) -- für mehr Auswahlmöglichkeiten geplant

	meta:set_string("formspec",
		"size[6.0,5.0;]" ..
		"bgcolor[#0000;fullscreen]" ..
		"dropdown[0.7,0.5;4.7,1.0;choice;" .. audio_file .. ";" .. audio_index .. "]" ..
		"field[1.0,2.1;4.5,1.0;heardistance;Hearing distance (Range 1 -32);" .. heardistance .."]" ..
		"field[1.0,3.5;4.5,1.0;gain;Volume (Range 0.0 - 1.0);" .. gain .. "]" ..
					-- mehr Auswahlmöglichkeiten geplant; Abfrage der Checkbox funktioniert aber nicht.
					-- "checkbox[0.0,3.7;restart;next punch restarts sound (otherwise stops);true]" ..
		"button_exit[2.2,4.3;1.5,1.0;save;Save]")

	if owner == "" then
		owner = "no owner yet"
	else
		owner = "owned by " .. owner
	end

	meta:set_string("infotext", "Audio Block\n" ..
		"(" .. owner .. ")\n" ..
		"Audio: " .. selected_audio)
end


local function construct(pos)
	local meta = minetest.get_meta(pos)

	meta:set_string("heardistance", default_heardistance)
	meta:set_string("gain", default_gain)
	meta:set_string("audiofile", "")
	meta:set_string("choice", default_selected_audio)
	meta:set_string("restart", "true")
	meta:set_string("owner", "")

	initialize_data(meta)
end


local function after_place(pos, placer)
	if placer then
		local meta = minetest.get_meta(pos)
		meta:set_string("owner", placer:get_player_name())
		initialize_data(meta)
	end
end


local function receive_fields(pos, formname, fields, sender)
	if not fields.save then
		return
	end

	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	if owner ~= "" and sender:get_player_name() ~= owner then
		return
	end

	meta:set_string("heardistance", fields.heardistance)
	meta:set_string("gain", fields.gain)
	meta:set_string("audiofile", fields.audiofile)
	meta:set_string("restart", fields.restart)
	meta:set_string("choice",fields.choice)

	initialize_data(meta)
end


local function commandblock_action_on(pos, node)
	if node.name ~= "mesecons_audio:audio_block" then
		return
	end

	local meta = minetest.get_meta(pos)
	local msg = meta:get_string("choice") or default_selected_audio
	local heardistance = tonumber(meta:get_string("heardistance")) or default_heardistance
	local gain = tonumber(meta:get_string("gain")) or default_gain
	local pos_object = minetest.pos_to_string(pos) -- Position des aktuell angeklickten Mese-Soundblocks ermitteln
	local restart = meta:get_string("restart")

	if not just_playing[pos_object] then -- falls der Mese-Soundblock noch nie (per Mese-Schalter) gestartet wurde, Soundblock in die Tabelle just_playing schreiben
		just_playing[pos_object] = {}
	end

	if not just_playing[pos_object][1] then -- Sound wird aktuell noch nicht abgespielt
		just_playing[pos_object][1] = minetest.sound_play(
			msg, {
				pos = pos,
				max_hear_distance = heardistance,
				gain = gain,
			})
	else
		minetest.sound_stop(just_playing[pos_object][1]) -- den gerade spielenden Ton abbrechen
		just_playing[pos_object][1] = nil -- Handler auf den gestarteten Mese-Soundblock löschen
					-- PROBLEM: Abfrage von Checkboxen scheinen nicht zu funktionieren -  ansonsten gedacht für Wahlmöglichkeiten, wie Mesecon-Schalter reagiert
					-- if restart == "true" then
					just_playing[pos_object][1] = minetest.sound_play( -- ausgewählten Sound neu starten
						msg, {
							pos = pos,
							max_hear_distance = heardistance,
							gain = gain,
						})
	end
end


minetest.register_node("mesecons_audio:audio_block", {
	description = "mesecons_audio",
	tiles = {"mesecons_audio_top.png","mesecons_audio_side.png"},
	is_ground_content = false,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = not_in_creative_inventory},

	mesecons = {effector = {
		action_on = commandblock_action_on
	}},

	on_construct = construct,
	after_place_node = after_place,
	on_receive_fields = receive_fields,
})


minetest.register_privilege( -- formspec des Soundblocks ist nur mit entsprechendem privilege aufrufbar
    'mesecons_audio',
    {
        description = (
            "Gives player privilege for use off mesecons_audio"
        ),
        give_to_singleplayer = true,
        give_to_admin = true,
    }
)

minetest.register_chatcommand(
	"sync_mesecons_audio",
	{   
		params = "",
		description = "sync newly available audio files to clients",
		privs = {
			server = true
		},
		func = update_audio_list
	}
)
