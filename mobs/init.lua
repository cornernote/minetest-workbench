-- init.lua
-- roof minetest mod, by darkrose
-- Copyright (C) Lisa Milne 2012 <lisa@ltmnet.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>

mobs = {}

mobs.pig = {}

mobs.move = function(pos, node)
		local inf = {x=pos.x+math.random(-1,1), y=pos.y, z=pos.z+math.random(-1,1)}
		local und = {x=inf.x, y=pos.y-1.0, z=inf.z}
		local infn = minetest.env:get_node(inf)
		local undn = minetest.env:get_node(und)
		local npos = pos
		print(node.param2..' '..minetest.pos_to_string(pos)..' --> '..minetest.pos_to_string(inf))
		if infn.name == 'mobs:pig' or undn.name == 'mobs:pig' then return end
		if minetest.registered_nodes[minetest.env:get_node({x=pos.x,y=pos.y-1,z=pos.z}).name].walkable == false then
			npos = {x=pos.x,y=pos.y-1,z=pos.z}
		elseif minetest.registered_nodes[infn.name].walkable == false and minetest.registered_nodes[undn.name].walkable then
			-- Create node and remove entity
			if undn.name == 'air' then
				local uu = minetest.env:get_node({und.x,und.y-1,und.z})
				if minetest.registered_nodes[uu.name].walkable == false then return end
				inf.y = pos.y-1
			end
			npos = inf
		elseif minetest.registered_nodes[infn.name].walkable then
			local abv = {x=inf.x,y=inf.y+1,z=inf.z}
			local abvn = minetest.env:get_node(abv)
			if abvn.name ~= 'air' then return end
			npos = abv
		end

		print(node.param2..' '..minetest.pos_to_string(pos)..' --> '..minetest.pos_to_string(npos))
		if pos.x-npos.x > 0 then
			node.param2 = 1
		elseif pos.x-npos.x < 0 then
			node.param2 = 3
		elseif pos.z-npos.z > 0 then
			node.param2 = 0
		elseif pos.z-npos.z < 0 then
			node.param2 = 2
		end
		minetest.env:remove_node(pos)
		minetest.env:add_node(npos,node)
	end

minetest.register_node("mobs:pig", {
	description = "pig",
	drawtype = "nodebox",
	tiles = {"mobs_pig.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {fleshy=2,crumbly=2},
	drop = "mobs:pork_raw",
	on_punch =mobs.move,
	node_box = {
		type = "fixed",
		fixed = {
			-- x,y,z,x,y,z
			-- body
			{-0.2, 0, -0.5, 0.2, 0.5, -0.1},
			-- head
			{-0.3, -0.2, -0.3, 0.3, 0.3, 0.5},
			-- front right leg
			{-0.4, -0.5, -0.3, -0.2, 0.1, -0.1},
			-- front left leg
			{0.2, -0.5, -0.3, 0.4, 0.1, -0.1},
			-- back right leg
			{-0.4, -0.5, 0.3, -0.2, 0.1, 0.1},
			-- back left leg
			{0.2, -0.5, 0.3, 0.4, 0.1, 0.1},
		},
	},
})

minetest.register_craftitem("mobs:pork_raw", {
	description = "Raw Pork",
	inventory_image = "mobs_pork_raw.png",
	on_use = minetest.item_eat(-1),
})

minetest.register_craftitem("mobs:pork_cooked", {
	description = "Cooked Pork",
	inventory_image = "mobs_pork_cooked.png",
	on_use = minetest.item_eat(6),
})

minetest.register_craft({
	type = "cooking",
	output = "mobs:pork_cooked",
	recipe = "mobs:pork_raw",
})

minetest.register_abm({
	nodenames = {"mobs:pig"},
	interval = 2.0,
	chance = 2.0,
	action = mobs.move
})
