-- Verifies the core jewel-radius routine PassiveTree:GetNodesInRadius, which both the base
-- socket precompute and the build-specific radius increase (Disciple of Varashta's "Baryanic
-- Leylines" -> "Non-Unique Time-Lost Jewels have 40% increased radius") share. It must:
--   * reproduce the precomputed set when scale == 1 (same membership, recomputed)
--   * return a superset of the base set when scale > 1 (radius only grows)
--   * actually pull in additional nodes for a socket that has neighbours nearby
describe("TestTimelessRadius", function()
	before_each(function()
		newBuild()
	end)

	local function socketWithNeighbours(spec, radiusIndex)
		for nodeId in pairs(spec.tree.sockets) do
			local socket = spec.nodes[nodeId]
			if socket and socket.nodesInRadius and socket.nodesInRadius[radiusIndex] then
				return socket
			end
		end
	end

	local function count(t)
		local n = 0
		for _ in pairs(t) do n = n + 1 end
		return n
	end

	it("reproduces the precomputed radius set at scale 1", function()
		local spec = build.spec
		local radiusIndex = 3 -- Large
		local socket = socketWithNeighbours(spec, radiusIndex)
		assert.is_not_nil(socket)

		-- the base socket precompute and this routine are the same code, so scale 1 must agree
		local recomputed = spec.tree:GetNodesInRadius(socket, 1)[radiusIndex]
		local base = socket.nodesInRadius[radiusIndex]
		assert.are.equals(count(base), count(recomputed))
		for id in pairs(base) do
			assert.is_not_nil(recomputed[id])
		end
	end)

	it("grows the radius into a superset when scaled up by 40%", function()
		local spec = build.spec
		local radiusIndex = 3 -- Large

		-- find a socket where 40% more radius strictly increases the node set
		local grew = false
		for nodeId in pairs(spec.tree.sockets) do
			local socket = spec.nodes[nodeId]
			if socket and socket.nodesInRadius and socket.nodesInRadius[radiusIndex] then
				local base = socket.nodesInRadius[radiusIndex]
				local scaled = spec.tree:GetNodesInRadius(socket, 1.4)[radiusIndex]
				-- scaled radius must contain everything the base radius contained
				for id in pairs(base) do
					assert.is_not_nil(scaled[id])
				end
				if count(scaled) > count(base) then
					grew = true
				end
			end
		end
		assert.is_true(grew)
	end)
end)
