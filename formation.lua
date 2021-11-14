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
				local midz = math.round(#chosen/2);
				
				--loop units !
				for i,v in pairs(drones:GetChildren()) do
					--check if placed in pos
					if v.Name == pos and not v.moved.Value and not placed[g][2] then
						v.moved.Value = true;
						placed[g] = {x..','..y, true};
						--print('('..x..','..y..') placed.');
						
						--placement
						v.Position = Vector3.new(x,.5,y);
						
						
					end;
				end;
			end;
		end;
	end;
	--reset
	for i,v in pairs(drones:GetChildren()) do
		v.moved.Value = false;
	end;
	--warn(string.rep('-',20))
end;

while wait() do movement(offset); end;