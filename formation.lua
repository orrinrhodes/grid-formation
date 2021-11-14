--// General Variables
mother = workspace.mother;
drones = workspace.drones;
choice = workspace.formation;

offset = 5;

formations = {	
	arrowhead = {
		'__1__';
		'_2_2_';
		'3___3';
	};

	column = {
		'1';
		'2';
		'2';
		'3';
		'3';
	};
};

--rotate around CENTER:
--column/certain formations would look funky when orbiting leader.

--// Functions

movement = function(ofs)
	local g;
	local placed = {};
	local chosen = formations[choice.Value];
	--run through array, find unit positions
	for y,row in pairs(chosen) do
		for x=1,#row do
			local pos = string.sub(row,x,x);
			if pos ~= '_' then
				
				--sometimes #row is > #columns: account for all units
				if #row > #chosen then
					g = x;
				else
					g = y;
				end;
				
				--setup for pos reservations
				if not placed[g] then
					placed[g] = {x..','..y, false};
				end;
				
				--maths (fun 👀)
				local midx = math.round(#row/2);
				local midy = math.round(#chosen/2);
				
				
				--loop units !
				for i,v in pairs(drones:GetChildren()) do
					--check if placed in pos
					if v.Name == pos and not v.moved.Value and not placed[g][2] then
						v.moved.Value = true;
						placed[g][2] = true;
						
						local finddir = function()
							local difx = math.abs(x-midx);
							local dify = math.abs(y-midy);
							local dirx;
							local diry;
							if x-midx < 0 then
								dirx = 'left';
							elseif x-midx > 0 then
								dirx = 'right';
							end;
							if y-midy < 0 then
								diry = 'up'
							elseif y-midy > 0 then
								diry = 'down';
							end;
							if dirx == nil then
								dirx,difx = '-',0;
							end;
							if diry == nil then
								diry,dify = '-',0;
							end;
							
							return dirx,difx,diry,dify
						end;
						local dirx,difx,diry,dify = finddir();
						--print('('..x,y..'):',difx,dirx,'|',dify,diry)
						--placement
						local center = Vector3.new(midx,.5,midy)
						mother.Position = center;
						if diry == 'up' then
							dify = -dify;
							print('switched')
						elseif dirx == 'left' then
							difx = -difx;
						end;
						v.Position = center + Vector3.new(difx,.5,dify);
						
						--print('('..x..','..y..') placed.');
						
					end;
				end;
			end;
		end;
	end;
	
	--reset
	for i,v in pairs(drones:GetChildren()) do
		v.moved.Value = false;
	end;
	--warn(string.rep('-',20)) --divide output
end;

while wait() do movement(offset); end;
