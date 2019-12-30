minetest.register_chatcommand("report", {
	func = function(name, param)
		param = param:trim()
		if param == "" then
			return false, "Please add a message to your report. " ..
				"If it's about (a) particular player(s), please also include their name(s)."
		end
		local _, count = string.gsub(param, " ", "")
		if count == 0 then
			minetest.chat_send_player(name, "If you're reporting a player, " ..
				"you should also include a reason why. (Eg: swearing, sabotage)")
		end

		-- Send to online moderators / admins
		-- Get comma separated list of online moderators and admins
		local mods = {}
		for _, player in pairs(minetest.get_connected_players()) do
			local toname = player:get_player_name()
			if minetest.check_player_privs(toname, {kick = true, ban = true}) then
				table.insert(mods, toname)
				minetest.chat_send_player(toname, "-!- " .. name .. " reported: " .. param)
			end
		end

		if #mods > 0 then
			mod_list = table.concat(mods, ", ")
			email.send_mail(name, minetest.setting_get("name"),
				"Report: " .. param .. " (mods online: " .. mod_list .. ")")
			return true, "Reported. Moderators currently online: " .. mod_list
		else
			email.send_mail(name, minetest.setting_get("name"),
				"Report: " .. param .. " (no mods online)")
			return true, "Reported. We'll get back to you."
		end
	end
})


if minetest.get_modpath("sfinv_buttons") ~= nil then
	sfinv_buttons.register_button("report", {
		image = "report.png",
		tooltip = S("Report message for admins"),
		title = S("Report"),
		action = report.get_formspec,
	})
end

report = {}

function report.get_formspec(name)
   local text = "Report message for admins"
    local formspec = {
       "size[6,3.476]",
      "real_coordinates[true]",
       "label[0.375,0.5;", minetest.formspec_escape(text), "]",
       "field[0.375,1.25;5.25,0.8;number;Number;]",
      "button[1.5,2.3;3,0.8;guess;Guess]"
   }

    -- table.concat is faster than string concatenation - `..`
    return table.concat(formspec, "")
end


