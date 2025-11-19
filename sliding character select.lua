newGrid = {}
currentColumn = 1
totalRows = 1
newGrid[1] = {}
currentRow = {0, 0}
shownTopRow = {1, 1}
local cursorActive = {}
controllingPlayer = 1
multiplayer = true
swapOccured = false
remainingTime = {0, 0}
slideDir = {0, 0}
teammate = {1, 2}

if motif.select_info['cell_slide'] == nil then
	motif.select_info['cell_slide'] = 1
end


for i = 1, #main.t_selGrid do
	start.t_grid[totalRows][currentColumn] = start.f_selGrid(i)
	start.t_grid[totalRows][currentColumn].x = (currentColumn - 1) * (motif.select_info['cell_spacing'][1] + motif.select_info['cell_size'][1])
	start.t_grid[totalRows][currentColumn].y = (totalRows - 1) * (motif.select_info['cell_spacing'][2] + motif.select_info['cell_size'][2])
	if currentColumn >= motif.select_info.columns then
		totalRows = totalRows + 1
		if start.t_grid[totalRows] == nil then
			start.t_grid[totalRows] = {}
		end
		currentColumn = 1
	else
		currentColumn = currentColumn + 1
	end
end

for i = 1, motif.select_info.columns do
	if start.t_grid[#start.t_grid][i] == nil then
		table.insert(start.t_grid[#start.t_grid], {char = "", char_ref = 0, hidden = 2, cell = 0})
	end
end

--returns correct cell position after moving the cursor
function start.f_cellMovement(selX, selY, cmd, side, snd, dir)
	local tmpX = selX
	local tmpY = selY
	local found = false
	if multiplayer and motif.select_info['p1_pos'] ~= nil then
		if (cmd == teammate[side]) or not main.coop then
			if main.f_input({cmd}, {'$U'}) or dir == 'U' then
				for i = 1, #start.t_grid do
					selY = selY - 1
					if selY < 0 then
						if motif.select_info.wrapping == 1 or dir ~= nil then
							selY = #start.t_grid - 1
						else
							selY = tmpY
						end
					end
					if currentRow[side] == 0 then
						if shownTopRow[side] ~= 1 then
							shownTopRow[side] = shownTopRow[side] - 1
						else
							if motif.select_info.wrapping == 1 then
								shownTopRow[side] = #start.t_grid - motif.select_info.rows
								currentRow[side] = motif.select_info.rows
							end
						end
						remainingTime[side] = motif.select_info['cell_slide']
						slideDir[side] = -1
					else
						currentRow[side] = currentRow[side] - 1
					end
					if dir ~= nil then
						found, selX = start.f_searchEmptyBoxes(selX, selY, side, -1)
					elseif (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes == 1) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
						break
					elseif motif.select_info.searchemptyboxesup ~= 0 then
						found, selX = start.f_searchEmptyBoxes(selX, selY, side, motif.select_info.searchemptyboxesup)
					end
					if found then
						break
					end
				end
			elseif main.f_input({cmd}, {'$D'}) or dir == 'D' then
				for i = 1, #start.t_grid do
					if currentRow[side] == motif.select_info.rows - 1 then
						if currentRow[side] + shownTopRow[side] ~= #start.t_grid then
							shownTopRow[side] = shownTopRow[side] + 1
						else
							if motif.select_info.wrapping == 1 then
								shownTopRow[side] = 1
								currentRow[side] = 0
							end
						end
						remainingTime[side] = motif.select_info['cell_slide']
						slideDir[side] = 1
					else
						currentRow[side] = currentRow[side] + 1
					end
					selY = selY + 1
					if selY >= #start.t_grid then
						if motif.select_info.wrapping == 1 or dir ~= nil then
							selY = 0
						else
							selY = tmpY
						end
					end		
					if dir ~= nil then
						found, selX = start.f_searchEmptyBoxes(selX, selY, side, 1)
					elseif (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes == 1) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
						break
					elseif motif.select_info.searchemptyboxesdown ~= 0 then
						found, selX = start.f_searchEmptyBoxes(selX, selY, side, motif.select_info.searchemptyboxesdown)
					end
					if found then
						break
					end
				end
			elseif main.f_input({cmd}, {'$B'}) or dir == 'B' then
				if dir ~= nil then
					found, selX = start.f_searchEmptyBoxes(selX, selY, side, -1)
				else
					for i = 1, motif.select_info.columns do
						selX = selX - 1
						if selX < 0 then
							if motif.select_info.wrapping == 1 then
								selX = motif.select_info.columns - 1
							else
								selX = tmpX
							end
						end
						if (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes == 1) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
							break
						end
					end
				end
			elseif main.f_input({cmd}, {'$F'}) or dir == 'F' then
				if dir ~= nil then
					found, selX = start.f_searchEmptyBoxes(selX, selY, side, 1)
				else
					for i = 1, motif.select_info.columns do
						selX = selX + 1
						if selX >= motif.select_info.columns then
							if motif.select_info.wrapping == 1 then
								selX = 0
							else
								selX = tmpX
							end
						end
						if (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes == 1) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
							break
						end
					end
				end
			end
		end
		if (tmpX ~= selX or tmpY ~= selY) then
			if dir == nil then
				sndPlay(motif.files.snd_data, snd[1], snd[2])
				start.needUpdateDrawList = true
			end
		end
	else
		if (cmd == teammate[side]) or not main.coop then
			if main.f_input({cmd}, {'$U'}) or dir == 'U' then
				for i = 1, #start.t_grid do
					selY = selY - 1
					if selY < 0 then
						if motif.select_info.wrapping == 1 or dir ~= nil then
							selY = #start.t_grid - 1
						else
							selY = tmpY
						end
					end
					if currentRow[side] == 0 then
						if controllingPlayer == side then
							if shownTopRow[1] ~= 1 then
								shownTopRow[1] = shownTopRow[1] - 1
							else
								if motif.select_info.wrapping == 1 then
									shownTopRow[1] = #start.t_grid - motif.select_info.rows
									currentRow[side] = motif.select_info.rows
								end
							end
						remainingTime[1] = motif.select_info['cell_slide']
						slideDir[1] = -1
						end
					else
						currentRow[side] = currentRow[side] - 1
					end
					if dir ~= nil then
						found, selX = start.f_searchEmptyBoxes(selX, selY, side, -1)
					elseif (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes == 1) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
						break
					elseif motif.select_info.searchemptyboxesup ~= 0 then
						found, selX = start.f_searchEmptyBoxes(selX, selY, side, motif.select_info.searchemptyboxesup)
					end
					if found then
						break
					end
				end
			elseif main.f_input({cmd}, {'$D'}) or dir == 'D' then
				for i = 1, #start.t_grid do
					if currentRow[side] == motif.select_info.rows - 1 then
						if controllingPlayer == side then
							if currentRow[side] + shownTopRow[1] ~= #start.t_grid then
								shownTopRow[1] = shownTopRow[1] + 1
							else
								if motif.select_info.wrapping == 1 then
									shownTopRow[1] = 1
									currentRow[side] = 0
								end
							end
						remainingTime[1] = motif.select_info['cell_slide']
						slideDir[1] = 1
						end
					else
						currentRow[side] = currentRow[side] + 1
					end
					selY = selY + 1
					if selY >= #start.t_grid then
						if motif.select_info.wrapping == 1 or dir ~= nil then
							selY = 0
						else
							selY = tmpY
						end
					end		
					if dir ~= nil then
						found, selX = start.f_searchEmptyBoxes(selX, selY, side, 1)
					elseif (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes == 1) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
						break
					elseif motif.select_info.searchemptyboxesdown ~= 0 then
						found, selX = start.f_searchEmptyBoxes(selX, selY, side, motif.select_info.searchemptyboxesdown)
					end
					if found then
						break
					end
				end
			elseif main.f_input({cmd}, {'$B'}) or dir == 'B' then
				if dir ~= nil then
					found, selX = start.f_searchEmptyBoxes(selX, selY, side, -1)
				else
					for i = 1, motif.select_info.columns do
						selX = selX - 1
						if selX < 0 then
							if motif.select_info.wrapping == 1 then
								selX = motif.select_info.columns - 1
							else
								selX = tmpX
							end
						end
						if (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes == 1) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
							break
						end
					end
				end
			elseif main.f_input({cmd}, {'$F'}) or dir == 'F' then
				if dir ~= nil then
					found, selX = start.f_searchEmptyBoxes(selX, selY, side, 1)
				else
					for i = 1, motif.select_info.columns do
						selX = selX + 1
						if selX >= motif.select_info.columns then
							if motif.select_info.wrapping == 1 then
								selX = 0
							else
								selX = tmpX
							end
						end
						if (start.t_grid[selY + 1][selX + 1].char ~= nil or motif.select_info.moveoveremptyboxes == 1) and start.t_grid[selY + 1][selX + 1].skip ~= 1 and (gameOption('Options.Team.Duplicates') or start.t_grid[selY + 1][selX + 1].char == 'randomselect' or not t_reservedChars[side][start.t_grid[selY + 1][selX + 1].char_ref]) and start.t_grid[selY + 1][selX + 1].hidden ~= 2 then
							break
						end
					end
				end
			end
		end
		if (tmpX ~= selX or tmpY ~= selY) then
			if dir == nil then
				sndPlay(motif.files.snd_data, snd[1], snd[2])
			end
		end
	end
	start.needUpdateDrawList = true
	return selX, selY
end


function start.updateDrawList()
	local drawList = {}
	multiplayer = not main.cpuSide[2]
	if multiplayer and motif.select_info['p1_pos'] ~= nil then
		for side = 1, 2 do
			if main.coop then
				if teammate[side] ~= (#start.p[side].t_selected * 2 + side) and teammate[side] ~= 0 then
					start.c[teammate[side] + 2].selX = start.c[teammate[side]].selX
					start.c[teammate[side] + 2].selY = start.c[teammate[side]].selY
					teammate[side] = (teammate[side] + 2) or side
				end
			end
			for row = 1, motif.select_info.rows do
				for col = 1, motif.select_info.columns do
					local cellIndex = (shownTopRow[side] + row - 2) * motif.select_info.columns + col
					local t = start.t_grid[row][col]

					if t.skip ~= 1 then
						local charData = start.f_selGrid(cellIndex)

						if (charData and charData.char ~= nil and (charData.hidden == 0 or charData.hidden == 3)) or motif.select_info.showemptyboxes == 1 then
							table.insert(drawList, {
								anim = motif.select_info.cell_bg_data,
								x = motif.select_info['p' .. side .. '_pos'][1] + t.x,
								y = motif.select_info['p' .. side .. '_pos'][2] + ((row - 1) * (motif.select_info['cell_spacing'][2] + motif.select_info['cell_size'][2])) + (slideDir[side] * ((remainingTime[side] / motif.select_info['cell_slide']) * (motif.select_info['cell_size'][2] + motif.select_info['cell_spacing'][2]))),
								facing = motif.select_info['cell_' .. col .. '_' .. row .. '_facing'] or motif.select_info.cell_bg_facing or 1
							})
						end

						if charData and (charData.char == 'randomselect' or charData.hidden == 3) then
							table.insert(drawList, {
								anim = motif.select_info.cell_random_data,
								x = motif.select_info['p' .. side .. '_pos'][1] + t.x + motif.select_info.portrait_offset[1],
								y = motif.select_info['p' .. side .. '_pos'][2] + t.y + motif.select_info.portrait_offset[2] + (slideDir[side] * ((remainingTime[side] / motif.select_info['cell_slide']) * (motif.select_info['cell_size'][2] + motif.select_info['cell_spacing'][2]))),
								facing = motif.select_info['cell_' .. col .. '_' .. row .. '_facing'] or motif.select_info.cell_random_facing or 1
							})
						end
						
						if charData and charData.char_ref ~= nil and charData.hidden == 0 then
							table.insert(drawList, {
								anim = charData.cell_data,
								x = motif.select_info['p' .. side .. '_pos'][1] + t.x + motif.select_info.portrait_offset[1],
								y = motif.select_info['p' .. side .. '_pos'][2] + t.y + motif.select_info.portrait_offset[2] + (slideDir[side] * ((remainingTime[side] / motif.select_info['cell_slide']) * (motif.select_info['cell_size'][2] + motif.select_info['cell_spacing'][2]))),
								facing = motif.select_info['cell_' .. col .. '_' .. row .. '_facing'] or motif.select_info.portrait_facing or 1
							})
						end
					end
				end
			end
		end
	else
		if not main.coop then
			for member = 1, start.p[1].numChars or 4 do
				if start.p[1].t_selected[start.p[1].numChars] == nil then
					swapOccured = false
					controllingPlayer = 1
					if teammate[1] ~= #start.p[1].t_selected + 1 then
						teammate[1] = #start.p[1].t_selected + 1
					end
					break
				else
					if swapOccured then
					
					else
						if multiplayer then
							if start.c[2].selY < shownTopRow[1] then
								shownTopRow[1] = start.c[2].selY + 1
								currentRow[2] = 0
							
							elseif start.c[2].selY > shownTopRow[1] + motif.select_info.rows - 2 then
								shownTopRow[1] = start.c[2].selY + 1
								currentRow[2] = 0
								if #start.t_grid - start.c[2].selY <= motif.select_info.rows then
									currentRow[2] = motif.select_info.rows - (#start.t_grid - start.c[2].selY - 1)
									shownTopRow[1] = #start.t_grid - motif.select_info.rows
								end
							else
								currentRow[2] = start.c[2].selY - shownTopRow[1] + 1
							end
							controllingPlayer = 2
							swapOccured = true
						else
							if start.c[2].selY < shownTopRow[1] then
								shownTopRow[1] = start.c[2].selY + 1
								currentRow[1] = 0
							
							elseif start.c[1].selY > shownTopRow[1] + motif.select_info.rows - 2 then
								shownTopRow[1] = start.c[2].selY + 1
								currentRow[1] = 0
								if #start.t_grid - start.c[2].selY <= motif.select_info.rows then
									currentRow[1] = motif.select_info.rows - (#start.t_grid - start.c[2].selY - 1)
									shownTopRow[1] = #start.t_grid - motif.select_info.rows
								end
							else
								currentRow[2] = start.c[2].selY - shownTopRow[1] + 1
							end
							swapOccured = true
						end
					end
				end
			end
		end
		if main.coop then
			if not multiplayer then
				if start.c[teammate[1]].selY < shownTopRow[1] then
					shownTopRow[1] = start.c[teammate[1]].selY + 1
					currentRow[1] = 0
				
				elseif start.c[1].selY > shownTopRow[1] + motif.select_info.rows - 2 then
					shownTopRow[1] = start.c[teammate[1]].selY + 1
					currentRow[1] = 0
					if #start.t_grid - start.c[teammate[1]].selY <= motif.select_info.rows then
						currentRow[1] = motif.select_info.rows - (#start.t_grid - start.c[teammate[1]].selY - 1)
						shownTopRow[1] = #start.t_grid - motif.select_info.rows
					end
				else
					currentRow[teammate[1]] = start.c[teammate[1]].selY - shownTopRow[1] + 1
				end
				
				if teammate[1] ~= (#start.p[1].t_selected + 1) and #start.p[1].t_selected ~= 0 then
					start.c[#start.p[1].t_selected + 1].selX = start.c[#start.p[1].t_selected].selX
					start.c[#start.p[1].t_selected + 1].selY = start.c[#start.p[1].t_selected].selY
				end
				teammate[1] = (#start.p[1].t_selected + 1) or 1
			else
				side = 1
				if #start.p[1].t_selected == start.p[1].numChars then
					side = 2
					controllingPlayer = 2
				else
					swapOccured = false
				end
				if side == 2 and not swapOccured then
					if start.c[teammate[side]].selY < shownTopRow[1] then
						shownTopRow[1] = start.c[teammate[side]].selY + 1
						currentRow[side] = 0
					
					elseif start.c[1].selY > shownTopRow[1] + motif.select_info.rows - 2 then
						shownTopRow[1] = start.c[teammate[side]].selY + 1
						currentRow[side] = 0
						if #start.t_grid - start.c[teammate[side]].selY <= motif.select_info.rows then
							currentRow[side] = motif.select_info.rows - (#start.t_grid - start.c[teammate[side]].selY - 1)
							shownTopRow[1] = #start.t_grid - motif.select_info.rows
						end
					else
						currentRow[side] = start.c[teammate[side]].selY - shownTopRow[1] + 1
					end
					swapOccured = true
				end
				if teammate[side] ~= (#start.p[side].t_selected * 2 + side) and teammate[side] ~= 0 then
					start.c[teammate[side] + 2].selX = start.c[teammate[side]].selX
					start.c[teammate[side] + 2].selY = start.c[teammate[side]].selY
					teammate[side] = (teammate[side] + 2) or side
				end
			end
		end
		for row = 1, motif.select_info.rows do
			for col = 1, motif.select_info.columns do
				local cellIndex = (shownTopRow[1] + row - 2) * motif.select_info.columns + col
				local t = start.t_grid[row][col]

				if t.skip ~= 1 then
					local charData = start.f_selGrid(cellIndex)

					if (charData and charData.char ~= nil and (charData.hidden == 0 or charData.hidden == 3)) or motif.select_info.showemptyboxes == 1 then
						table.insert(drawList, {
							anim = motif.select_info.cell_bg_data,
							x = motif.select_info.pos[1] + t.x,
							y = motif.select_info.pos[2] + ((row - 1) * (motif.select_info['cell_spacing'][2] + motif.select_info['cell_size'][2])) + (slideDir[1] * ((remainingTime[1] / motif.select_info['cell_slide']) * (motif.select_info['cell_size'][2] + motif.select_info['cell_spacing'][2]))),
							facing = motif.select_info['cell_' .. col .. '_' .. row .. '_facing'] or motif.select_info.cell_bg_facing or 1
						})
					end

					if charData and (charData.char == 'randomselect' or charData.hidden == 3) then
						table.insert(drawList, {
							anim = motif.select_info.cell_random_data,
							x = motif.select_info.pos[1] + t.x + motif.select_info.portrait_offset[1],
							y = motif.select_info.pos[2] + t.y + motif.select_info.portrait_offset[2] + (slideDir[1] * ((remainingTime[1] / motif.select_info['cell_slide']) * (motif.select_info['cell_size'][2] + motif.select_info['cell_spacing'][2]))),
							facing = motif.select_info['cell_' .. col .. '_' .. row .. '_facing'] or motif.select_info.cell_random_facing or 1
						})
					end
					
					if charData and charData.char_ref ~= nil and charData.hidden == 0 then
						table.insert(drawList, {
							anim = charData.cell_data,
							x = motif.select_info.pos[1] + t.x + motif.select_info.portrait_offset[1],
							y = motif.select_info.pos[2] + t.y + motif.select_info.portrait_offset[2] + (slideDir[1] * ((remainingTime[1] / motif.select_info['cell_slide']) * (motif.select_info['cell_size'][2] + motif.select_info['cell_spacing'][2]))),
							facing = motif.select_info['cell_' .. col .. '_' .. row .. '_facing'] or motif.select_info.portrait_facing or 1
						})
					end
				end
			end
		end
	end

	return drawList
end

--calculate cursor.tween
local function f_cursorTween(val, target, factor)
	if not factor or not target then
		return val
	end
	for i = 1, 2 do
		local t = target[i] or 0
		local f = math.min(math.abs(factor[i] or 0.5), 1)
		val[i] = val[i] + (t - val[i]) * f
	end
	return val
end

--draw cursor
function start.f_drawCursor(pn, x, y, param, done)
	if multiplayer and motif.select_info['p1_pos'] ~= nil then
		if pn == teammate[(pn - 1) % 2 + 1] then
			-- in non-coop modes only p1 and p2 cursors are used
			pn = (pn - 1) % 2 + 1
			local prefix = 'p' .. pn .. param .. '_' .. x + 1 .. '_' .. currentRow[pn] + 1
			-- create spr/anim data, if not existing yet
			if y < (motif.select_info.rows + shownTopRow[pn]) - 1 and y >= shownTopRow[pn] - 1 then
				if motif.select_info[prefix .. '_data'] == nil then
					-- if cell based variants are not defined we're defaulting to standard pX parameters
					for _, v in ipairs({'_anim', '_spr', '_offset', '_scale', '_facing'}) do
						if motif.select_info[prefix .. v] == nil then
							motif.select_info[prefix .. v] = start.f_getCursorData(pn, param .. v)
						end
					end
					motif.f_loadSprData(motif.select_info, {s = prefix .. '_'})
				end

				-- select appropriate cursor table and initialize if needed
				local store = done and cursorDone or cursorActive
				if store[pn] == nil then
					store[pn] = {
						currentPos = {0, 0},
						targetPos  = {0, 0},
						startPos   = {0, 0},
						slideOffset= {0, 0},
						init       = false,
						snap       = false -- only used by active cursors
					}
				end
				local cd = store[pn]

				-- calculate target cell coordinates
				local baseX = motif.select_info['p' .. pn .. '_pos'][1] + x * (motif.select_info.cell_size[1] + motif.select_info.cell_spacing[1]) + start.f_faceOffset(x + 1, currentRow[pn] + 1, 1)
				local baseY = motif.select_info['p' .. pn .. '_pos'][2] + (y - shownTopRow[pn] + 1) * (motif.select_info.cell_size[2] + motif.select_info.cell_spacing[2]) + start.f_faceOffset(x + 1, (y - shownTopRow[pn]) + 1, 2)

				-- initialization or snap: set cursor directly
				if not cd.init or done or cd.snap then
					for i = 1, 2 do
						cd.currentPos[i] = (i == 1) and baseX or baseY
						cd.targetPos[i]  = cd.currentPos[i]
						cd.startPos[i]   = cd.currentPos[i]
						cd.slideOffset[i]= 0
					end
					cd.init, cd.snap = true, false
				-- new cell selected: recalc tween offsets
				elseif cd.targetPos[1] ~= baseX or cd.targetPos[2] ~= baseY then
					cd.startPos[1], cd.startPos[2] = cd.currentPos[1], cd.currentPos[2]
					cd.targetPos[1], cd.targetPos[2] = baseX, baseY
					cd.slideOffset[1] = cd.startPos[1] - baseX
					cd.slideOffset[2] = cd.startPos[2] - baseY
				end
				local t_factor = { -- we also remap pn to p1/p2 to avoid crashes in vs coop when motif lacks other players tween data
					motif.select_info['p' .. 2-pn%2 .. '_cursor_tween_factor'][1],
					motif.select_info['p' .. 2-pn%2 .. '_cursor_tween_factor'][2]
				}
				-- apply tween if enabled, otherwise snap to target
				if not done and t_factor[1] > 0 and t_factor[2] > 0 then
					f_cursorTween(cd.slideOffset, {0, 0}, t_factor)
				else
					cd.slideOffset[1], cd.slideOffset[2] = 0, 0
				end

				if motif.select_info['p' .. pn .. '_cursor_tween_wrap_snap'] == 1 then
					local dx = cd.targetPos[1] - cd.startPos[1]
					local dy = cd.targetPos[2] - cd.startPos[2]
					if math.abs(dx) > motif.select_info.cell_size[1] * (motif.select_info.columns - 1) or math.abs(dy) > motif.select_info.cell_size[2] * (motif.select_info.rows - 1) then
					cd.slideOffset[1], cd.slideOffset[2] = 0, 0	
					end
				end
				-- update final cursor position
				cd.currentPos[1] = cd.targetPos[1] + cd.slideOffset[1]
				cd.currentPos[2] = cd.targetPos[2] + cd.slideOffset[2]

				-- draw
				main.f_animPosDraw(
					motif.select_info[prefix .. '_data'],
					cd.currentPos[1],
					cd.currentPos[2],
					(motif.select_info['cell_' .. x + 1 .. '_' .. currentRow[pn] + 1 .. '_facing'] or motif.select_info['p' .. pn .. param .. '_facing'])
				)
			end
			if remainingTime[pn] ~= 0 then
				remainingTime[pn] = remainingTime[pn] - 1
			end
		end
	else
		-- in non-coop modes only p1 and p2 cursors are used
		if pn == teammate[(pn - 1) % 2 + 1] then
			pn = (pn - 1) % 2 + 1
			local prefix = 'p' .. pn .. param .. '_' .. x + 1 .. '_' .. currentRow[pn] + 1
			-- create spr/anim data, if not existing yet
			if y < (motif.select_info.rows + shownTopRow[1]) - 1 and y >= shownTopRow[1] - 1 then
				if motif.select_info[prefix .. '_data'] == nil then
					-- if cell based variants are not defined we're defaulting to standard pX parameters
					for _, v in ipairs({'_anim', '_spr', '_offset', '_scale', '_facing'}) do
						if motif.select_info[prefix .. v] == nil then
							motif.select_info[prefix .. v] = start.f_getCursorData(pn, param .. v)
						end
					end
					motif.f_loadSprData(motif.select_info, {s = prefix .. '_'})
				end

				-- select appropriate cursor table and initialize if needed
				local store = done and cursorDone or cursorActive
				if store[pn] == nil then
					store[pn] = {
						currentPos = {0, 0},
						targetPos  = {0, 0},
						startPos   = {0, 0},
						slideOffset= {0, 0},
						init       = false,
						snap       = false -- only used by active cursors
					}
				end
				local cd = store[pn]

				-- calculate target cell coordinates
				local baseX = motif.select_info.pos[1] + x * (motif.select_info.cell_size[1] + motif.select_info.cell_spacing[1]) + start.f_faceOffset(x + 1, currentRow[pn] + 1, 1)
				local baseY = motif.select_info.pos[2] + (y - shownTopRow[1] + 1) * (motif.select_info.cell_size[2] + motif.select_info.cell_spacing[2]) + start.f_faceOffset(x + 1, (y - shownTopRow[1]) + 1, 2)

				-- initialization or snap: set cursor directly
				if not cd.init or done or cd.snap then
					for i = 1, 2 do
						cd.currentPos[i] = (i == 1) and baseX or baseY
						cd.targetPos[i]  = cd.currentPos[i]
						cd.startPos[i]   = cd.currentPos[i]
						cd.slideOffset[i]= 0
					end
					cd.init, cd.snap = true, false
				-- new cell selected: recalc tween offsets
				elseif cd.targetPos[1] ~= baseX or cd.targetPos[2] ~= baseY then
					cd.startPos[1], cd.startPos[2] = cd.currentPos[1], cd.currentPos[2]
					cd.targetPos[1], cd.targetPos[2] = baseX, baseY
					cd.slideOffset[1] = cd.startPos[1] - baseX
					cd.slideOffset[2] = cd.startPos[2] - baseY
				end
				local t_factor = { -- we also remap pn to p1/p2 to avoid crashes in vs coop when motif lacks other players tween data
					motif.select_info['p' .. 2-pn%2 .. '_cursor_tween_factor'][1],
					motif.select_info['p' .. 2-pn%2 .. '_cursor_tween_factor'][2]
				}
				-- apply tween if enabled, otherwise snap to target
				if not done and t_factor[1] > 0 and t_factor[2] > 0 then
					f_cursorTween(cd.slideOffset, {0, 0}, t_factor)
				else
					cd.slideOffset[1], cd.slideOffset[2] = 0, 0
				end

				if motif.select_info['p' .. pn .. '_cursor_tween_wrap_snap'] == 1 then
					local dx = cd.targetPos[1] - cd.startPos[1]
					local dy = cd.targetPos[2] - cd.startPos[2]
					if math.abs(dx) > motif.select_info.cell_size[1] * (motif.select_info.columns - 1) or math.abs(dy) > motif.select_info.cell_size[2] * (motif.select_info.rows - 1) then
					cd.slideOffset[1], cd.slideOffset[2] = 0, 0	
					end
				end
				-- update final cursor position
				cd.currentPos[1] = cd.targetPos[1] + cd.slideOffset[1]
				cd.currentPos[2] = cd.targetPos[2] + cd.slideOffset[2]

				-- draw
				main.f_animPosDraw(
					motif.select_info[prefix .. '_data'],
					cd.currentPos[1],
					cd.currentPos[2],
					(motif.select_info['cell_' .. x + 1 .. '_' .. currentRow[pn] + 1 .. '_facing'] or motif.select_info['p' .. pn .. param .. '_facing'])
				)
			end
		end
		if remainingTime[1] ~= 0 then
			remainingTime[1] = remainingTime[1] - 1
		end
	end
end

--returns player cursor data
function start.f_getCursorData(pn, suffix)
	if suffix == '_cursor_startcell' then
		currentRow = {0, 0}
		shownTopRow = {1, 1}
		teammate = {1, 2}
	end
	if main.coop and motif.select_info['p' .. pn .. suffix] ~= nil then
		return motif.select_info['p' .. pn .. suffix]
	end
	return motif.select_info['p' .. (pn - 1) % 2 + 1 .. suffix]
end

--loading loop called after versus screen is finished
function start.f_selectLoading()
	clearAllSound()
	currentRow = {0, 0}
	shownTopRow = {1, 1}
	teammate = {1, 2}
	for side = 1, 2 do
		for member, v in ipairs(start.p[side].t_selected) do
			if start.p[side] ~= nil and start.p[side].t_cursor and start.p[side].t_cursor[member] ~= nil then
				start.p[side].t_cursor[member].x = 0
				start.p[side].t_cursor[member].y = 0
			end
			if not v.loading then
				selectChar(side, v.ref, v.pal)
				v.loading = true
			end
		end
	end
	--TODO: fix gameOption('Config.BackgroundLoading') setting
	--if not gameOption('Config.BackgroundLoading') then
		loadStart()
	--end
	-- calling refresh() during netplay data loading can lead to synchronization error
	--while motif.vs_screen.loading_data ~= nil and loading() and not network() do
	--	animDraw(motif.vs_screen.loading_data)
	--	animUpdate(motif.vs_screen.loading_data)
	--	refresh()
	--end
end
