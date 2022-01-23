local utils = require 'mp.utils'

local defaultAR = 2.4
local defaultVerticalShift = 0.0

local panScanTimes = {}
local lastAR = defaultAR
local lastVerticalShift = defaultVerticalShift


function cleanUp()
	panScanTimes = {}
	ApplyAspectRatio(defaultAR)
	ApplyVerticalShift(defaultVerticalShift)
	lastAR = 0.0
	lastVerticalShift = 0.0
	mp.unobserve_property(panScanByTimeStamp)
end

function existsFile(name)
	local f = io.open(name,"r")
	if f ~= nil then 
	io.close(f)return true else return false end
end

function on_loaded()
	local filename = mp.get_property("path")
	local movieDir, file = utils.split_path(filename)
	local panScanFile = movieDir .. "/" .. file .. ".panscan"
	
	cleanUp()
	
	if not existsFile(panScanFile) then
		print("No time based pan and scan file found!")
		return
	end
	
	-- read file with time based aspect ratios and shifts
	for line in io.lines(panScanFile) do
		local timeFrom, ar, verticalShift = line:match("(%d*%.?%d+) (%d*%.?%d+) (%d*%.?%d+)")
		panScanTimes[#panScanTimes + 1] = { timeFrom = tonumber(timeFrom), timeTo = 1000000.0, ar = tonumber(ar), verticalShift = verticalShift }
	end
	
	-- set timeTo for each time block
	for i = 1, #panScanTimes - 1 do
		panScanTimes[i].timeTo = panScanTimes[i + 1].timeFrom
	end
	
	-- register event for frame change
	if(#panScanTimes > 0) then
		mp.observe_property("time-pos", "number", panScanByTimeStamp)
		print("Time based pan and scan file loaded.")
	end
end

function AspectRatioToZoom(ar)
	if(ar == 2.35) then
		return "-0.022"
	elseif(ar == 2.2) then
		return "-0.115"
	elseif(ar == 2) then
		return "-0.252"
	elseif(ar == 1.85) then
		return "-0.361"
	elseif(ar <= 1.78) then
		return "-0.419"
	end
	
	return "0"
end

function ApplyAspectRatio(ar)
	mp.set_property("video-zoom", AspectRatioToZoom(ar))
end

function ApplyVerticalShift(verticalShift)
	mp.set_property("video-pan-y", verticalShift)
end

function panScanByTimeStamp(name, value)
	print(value)
	
	if(value == nil) then return end
	
	for i = 1, #panScanTimes do
		if(value >= panScanTimes[i].timeFrom and value < panScanTimes[i].timeTo) then
			if(panScanTimes[i].ar ~= lastAR) then
				ApplyAspectRatio(panScanTimes[i].ar)
			end
			lastAR = panScanTimes[i].ar
			
			if(panScanTimes[i].verticalShift ~= lastVerticalShift) then
				ApplyVerticalShift(panScanTimes[i].verticalShift)
			end
			lastVerticalShift = panScanTimes[i].verticalShift
			break
		end
	end
end

mp.register_event('file-loaded', on_loaded)