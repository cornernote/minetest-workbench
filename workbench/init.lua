-- init.lua
--
-- workbench minetest mod, by darkrose
-- Copyright (C) Lisa Milne 2012 <lisa@ltmnet.com>
--
-- updated by cornernote
-- Copyright (C) Brett O'Donnell 2012 <cornernote@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 2.1 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this program.  If not, see
-- <http://www.gnu.org/licenses/>


-- set inventory_craft_small=1 in minetest.conf to limit inventory craft to 2x2
if minetest.setting_getbool("inventory_craft_small")
	and not minetest.setting_getbool("creative_mode")
	and not minetest.get_modpath("inventory_plus") then
		minetest.register_on_joinplayer(function(player)
			player:get_inventory():set_width("craft", 2)
			player:get_inventory():set_size("craft", 2*2)
			player:set_inventory_formspec("size[8,7.5]"
				.."list[current_player;main;0,3.5;8,4;]"
				.."list[current_player;craft;3,0.5;2,2;]"
				.."list[current_player;craftpreview;6,1;1,1;]")
		end)
else
	minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_width("craft", 3)
		player:get_inventory():set_size("craft", 3*3)
	end)
end

-- expose api
workbench = {}

-- on_construct
workbench.on_construct = function(pos,width)
	width = tonumber(width)
	local meta = minetest.env:get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("craftresult", 1)
	inv:set_size("table", width*width)
	inv:set_width("craft", width)
	meta:set_string("formspec", "size[8,"..(width+4.5).."]"
		.."list[current_name;craftresult;6,2;1,1;]"
		.."list[current_player;main;0,"..(width+0.5)..";8,4;]"
		.."list[current_name;table;0,0;"..width..","..width..";]")
	meta:set_string("infotext", width.."x"..width.." WorkBench")
	meta:set_int("width", width)
end

-- can_dig
workbench.can_dig = function(pos,player)
	local meta = minetest.env:get_meta(pos);
	local inv = meta:get_inventory()
	if inv:is_empty("table") and inv:is_empty("craftresult") then
		return true
	end
	return false
end

-- allow_metadata_inventory_move
workbench.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	if to_list == "craftresult" then
		return 0
	end
	if to_list == "table" then
		workbench.update_inventory(pos, true, true)
	end
	return count
end

-- allow_metadata_inventory_put
workbench.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	if listname == "craftresult" then
		return 0
	end
	return stack:get_count()
end

-- allow_metadata_inventory_take
workbench.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	return stack:get_count()
end

-- on_metadata_inventory_move
workbench.on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	if to_list == "table" then
		workbench.update_inventory(pos)
	end
end

-- on_metadata_inventory_put
workbench.on_metadata_inventory_put = function(pos, listname, index, stack, player)
	if listname == "table" then
		workbench.update_inventory(pos)
	end
end

-- on_metadata_inventory_take
workbench.on_metadata_inventory_take = function(pos, listname, index, count, player)
	if listname == "table" then
		workbench.update_inventory(pos)
	elseif listname == "craftresult" then
		workbench.update_inventory(pos, true)
	end
end

-- update_inventory
workbench.update_inventory = function(pos,update_table,skip_update_craft)
	local meta = minetest.env:get_meta(pos)
	local inv = meta:get_inventory()
	local width = meta:get_int("width")
	local tablelist = inv:get_list("table")
	local crafted = nil
	local table_dec = nil

	-- update table
	if update_table then
		-- get craft result
		if tablelist then
			_, table_dec = minetest.get_craft_result({method = "normal", width = width, items = tablelist})
		end
		-- update table
		if table_dec then
			inv:set_list("table", table_dec.items)
		else
			inv:set_list("table", nil)
		end
		tablelist = table_dec.items
	end	

	-- update craft result
	if not skip_update_craft then
		-- get craft result
		if tablelist then
			crafted = minetest.get_craft_result({method = "normal", width = width, items = tablelist})
		end
		-- update craft result
		if crafted then
			inv:set_stack("craftresult", 1, crafted.item)
		else
			inv:set_stack("craftresult", 1, nil)
		end
	end
	
end

-- register
workbench.register = function(width, recipe)
	minetest.register_node("workbench:"..width.."x"..width, {
		description = "WorkBench",
		tile_images = {"workbench_"..width.."x"..width.."_top.png","workbench_"..width.."x"..width.."_bottom.png","workbench_"..width.."x"..width.."_side.png"},
		paramtype2 = "facedir",
		groups = {cracky=2},
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		on_construct = function(pos)
			workbench.on_construct(pos, width)
		end,
		can_dig = workbench.can_dig,
		allow_metadata_inventory_move = workbench.allow_metadata_inventory_move,
		allow_metadata_inventory_put = workbench.allow_metadata_inventory_put,
		allow_metadata_inventory_take = workbench.allow_metadata_inventory_take,
		on_metadata_inventory_move = workbench.on_metadata_inventory_move,
		on_metadata_inventory_put = workbench.on_metadata_inventory_put,
		on_metadata_inventory_take = workbench.on_metadata_inventory_take,
	})
	minetest.register_craft({
		output = "workbench:"..width.."x"..width,
		recipe = recipe,
	})
end

-- register workbenches
workbench.register(3, {
	{"default:wood","default:wood"},
	{"default:wood","default:wood"},
})
workbench.register(4, {
	{"default:stone","default:stone","default:stone"},
	{"default:wood","default:wood","default:wood"},
	{"default:wood","default:wood","default:wood"},
})
workbench.register(5, {
	{"default:steel_ingot","default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	{"default:wood","default:wood","default:wood","default:wood"},
	{"default:wood","default:wood","default:wood","default:wood"},
	{"default:wood","default:wood","default:wood","default:wood"},
})

-- register test crafts
minetest.register_craft({
	output = "default:mese",
	recipe = {
		{"default:steelblock","default:steelblock","default:steelblock","default:steelblock","default:steelblock"},
		{"default:steelblock","default:steelblock","default:steelblock","default:steelblock","default:steelblock"},
		{"default:steelblock","default:steelblock","default:steelblock","default:steelblock","default:steelblock"},
		{"default:steelblock","default:steelblock","default:steelblock","default:steelblock","default:steelblock"},
		{"default:steelblock","default:steelblock","default:steelblock","default:steelblock","default:steelblock"},
	}
})
minetest.register_craft({
    type = "shapeless",
    output = 'default:mese',
    recipe = {
        "default:lava_source",
        "default:lava_source",
        "default:lava_source",
        "default:water_source",
        "default:water_source",
        "default:water_source",
        "default:water_source",
        "default:water_source",
        "default:water_source",
        "default:water_source",
    },
})
