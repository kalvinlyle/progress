-- Title: Progress
-- Author: Kalvin Lyle
-- Version: 1.0
-- Description: Defold module for managing progress timers

local M = {}

local bars = {}

function M.clean() --delete all timers if all timers have stopped
	local totalcountdown = 0
	for x in ipairs(bars) do
		totalcountdown = totalcountdown + bars[x]["countdown"]
	end
	if totalcountdown == 0 then bars = {} end
end

function M.cancel(num)
	if bars[num] then
		timer.cancel(bars[num]["timer"])
	end
end

function M.remaining(num)
	local remaining = 1
	remaining = bars[num]["countdown"]
	return remaining
end

function M.percent(num)
	local percent = 1
	percent = bars[num]["countdown"] / bars[num]["delay"]
	return percent
end

function M.start(delay, tick, repeating, update, action)
	local num = #bars + 1
	local ticktimer = os.clock()
	bars[num] = {}
	bars[num]["delay"] = delay
	bars[num]["countdown"] = delay
	bars[num]["timer"] = timer.delay(tick, true, function()					-- start the timer
		local passed = math.max(os.clock() - ticktimer, tick)				-- used either the actual time passed or the tick (for when the tick is lower than the refresh speed)
		local remaining = (bars[num]["countdown"] - passed)					-- what is left on the timer
		local rounded = math.ceil(remaining * 100 / tick) / 100 * tick		-- rounded to 2 decimals past the tick accuracy
		bars[num]["countdown"] = math.max(0, rounded)						-- reduce the timer by the passedtime
		ticktimer = os.clock() + tick										-- reset the ticktimer
		update(num) 														-- process the update function
		if bars[num]["countdown"] <= 0 then 								-- if delay is zero
			if repeating then 
				bars[num]["countdown"] = delay 								-- resent the delay
			else 
				M.cancel(num) 												-- end the timer when the countdown reaches zero
			end
			action(num) 													-- process the action function
		end
	end)
	return num
end

return M
