--orrin's brain goes brrrr

--// General Variables
replicatedstorage	=	game:GetService('ReplicatedStorage');
rssquad				=	replicatedstorage.squad;
units				=	workspace.units;
config				=	workspace.config;

squads = {};

--quick mafs
sin,cos,abs,round,pi,rad = math.sin,math.cos,math.rad,math.round,math.pi,math.rad;

--|| Ranks
ranks = {
	general = {
		name		=	'General';
		description	=	'Highest rank';
		tier		=	1;
		color		=	Color3.fromRGB(16, 60, 127);
	};
	officer = {
		name		=	'Officer';
		description	=	'Second-highest rank';
		tier		=	2;
		color		=	Color3.fromRGB(255, 237, 94);
	};
	unit = {
		name		=	'Unit';
		description	=	'Lowest possible rank.';
		tier		=	3;
		color		=	Color3.fromRGB(85, 38, 38);
	};
};


--|| Formations
formations = {
	
	arrowhead	= {
		'__1__';
		'_2_2_';
		'3___3';
	};
	
	column		= {
		'1';
		'2';
		'2';
		'3';
		'3';
	};
	
	rowl		= {
		'12233';
	};
	
	rowr		= {
		'33221';
	};
	
};

--rotate around CENTER:
--column/certain formations would look funky when orbiting leader.

--// Functions


finddir = function(x,y,midx,midy)
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

rotate = function(part,center,difx,dify)
	local angle = config.angle.Value;
	local offset = config.offset.Value;
	--restrict to only Y axis
	local crX, crY = center.CFrame:ToOrientation();
	part.CFrame =
		CFrame.new(center.CFrame.Position)
		* CFrame.Angles(0,crY,0)
		--offset
		* CFrame.new(difx*offset,.5,dify*offset);
	
	return part.Position;
end;

choose = function(squad)
	for i,unit in pairs(squad:GetChildren()) do
		if unit:FindFirstChild('Humanoid') then
			local moved = unit.config.moved;
			if not moved.Value then
				moved.Value = true;

				--[[
					sorting by tier
					then return
				]]


				return unit;
			end;
		end;
	end;
end;

movement = function(squad)
	local g;
	local placed = {};
	local count = 0;
	local chosen = formations[squad.formation.Value];
	for y,row in pairs(chosen) do
		for x=1,#row do
			local pos = string.sub(row,x,x);
			if pos ~= '_' then
				--print(pos,': ('..x..','..y..')');
				
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
				
				--mafs (fun 👀)
				local midx = round(#row/2);
				local midy = round(#chosen/2);
				
				--local unit = choose(squad);
				
				--loop units !
				for i,unit in pairs(squad:GetChildren()) do
					--check if unit and placed in pos
					if unit.Name == pos and not unit.config.moved.Value and not placed[g][2] then
						count += 1;
						unit.config.moved.Value = true;
						placed[g][2] = true;
						
						local dirx,difx,diry,dify = finddir(x,y,midx,midy);
						--print('('..x,y..'):',difx,dirx,'|',dify,diry)
						--placement
						if diry == 'up' then
							dify = -dify;
						elseif dirx == 'left' then
							difx = -difx;
						end;
						local visual = squad.visual;
						local dest = rotate(visual:GetChildren()[count],squad.center,difx,dify);
						unit:FindFirstChild('Humanoid'):MoveTo(dest);
					end;
				end;
				
			end;
		end;
	end;
	--reset
	for i,unit in pairs(squad:GetChildren()) do
		if unit:FindFirstChild('config') then
			unit.config.moved.Value = false;
		end;
	end;
	--warn(string.rep('-',20)) --divide output
end;

newunit = function(squad,rank)
	local unit = replicatedstorage.dummy:Clone();
	unit.Parent = squad;
	unit.Name = rank.tier;
	unit.config.tier.Value = rank.tier;
	unit['Body Colors'].TorsoColor3 = rank.color; --individual unit customization later
	
	local part = Instance.new('Part',squad.visual);
	print(part.Parent.Name)
	part.Anchored = true;
	part.CanCollide = false;
	part.BrickColor = BrickColor.Red();
	part.Transparency = 2/3;
	part.Size = Vector3.new(2,1,2);
	
	return unit;
end;

newsquad = function(name)
	local newsquad = rssquad:Clone();
	local quantity = 1;
	for i,v in pairs(units:GetChildren()) do	
		if string.find(tostring(v),name) then
			quantity += 1;
		end;
	end;
	if quantity > 1 then
		warn('Name already exists, adding number.');
		newsquad.Name = (name..' ['..quantity..']');
	else
		newsquad.Name = name;
	end;
	
	local visual = Instance.new('Folder',newsquad);
	visual.Name = 'visual';

	local center = Instance.new('Part',newsquad);
	center.Anchored = true;
	center.CanCollide = false;
	center.Name = 'center';
	center.Transparency = 1/3;
	center.Position = Vector3.new(0,2,0);
	center.Size = Vector3.new(1,3,1);
	
	local gen = newunit(newsquad,ranks.general);
	gen.config.main.Value = true;
	local of1 = newunit(newsquad,ranks.officer);
	local of2 = newunit(newsquad,ranks.officer);
	local un1 = newunit(newsquad,ranks.unit);
	local un2 = newunit(newsquad,ranks.unit);
	
	newsquad.Parent = units;
	table.insert(squads,newsquad);
	print(newsquad,'created')
	
	return newsquad;
end;

roaches = newsquad('Roaches');
roaches = newsquad('Roaches');
roaches = newsquad('Crickets');

print('Squads:\n',squads);
while wait() do
	for i,v in pairs(squads) do
		movement(v);
	end;
end;
