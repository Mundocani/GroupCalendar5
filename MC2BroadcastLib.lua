local _, Addon = ...

----------------------------------------
Addon.BroadcastLib =
----------------------------------------
{
	Version = 1,
	SourceListeners = {}
}

setmetatable(Addon.BroadcastLib.SourceListeners, {__mode = "k"}) -- Make the source keys weak

function Addon.BroadcastLib:Listen(pSource, pFunction, pFunctionRef)
	-- Parameter checking
	
	if type(pFunction) ~= "function" then
		error("Expected function, got "..type(pFunction))
	end
	
	-- Allocate the source
	
	local vListeners = self.SourceListeners[pSource]
	
	if not vListeners then
		vListeners = {}
		self.SourceListeners[pSource] = vListeners
	end
	
	-- Make sure there isn't a duplicate
	
	for _, vSubscriber in ipairs(vListeners) do
		if vSubscriber.Function == pFunction
		and vSubscriber.FunctionRef == pFunctionRef then
			return
		end
	end
	
	-- Register the subscriber
	
	table.insert(vListeners, {
		Function = pFunction,
		FunctionRef = pFunctionRef,
	})
end

function Addon.BroadcastLib:StopListening(pSource, pFunction, pFunctionRef)
	-- Parameter checking
	
	if type(pFunction) ~= "function" then
		error("Expected function, got "..type(pFunction))
	end
	
	-- Recurse on ourselves using each source if no source is specified
	
	if not pSource then
		for vSource, vListeners in pairs(self.SourceListeners) do
			self:StopListening(vSource, pFunction, pFunctionRef)
		end
		
		return
	end
	
	--
	
	local vListeners = self.SourceListeners[pSource]
	
	if not vListeners then
		return
	end
	
	for vIndex, vSubscriber in ipairs(vListeners) do
		if vSubscriber.Function == pFunction
		and vSubscriber.FunctionRef == pFunctionRef then
			table.remove(vListeners, vIndex)
			
			if not next(vListeners) then
				self.SourceListeners[pSource] = nil
			end
			
			return
		end
	end
end

function Addon.BroadcastLib:Broadcast(pSource, pTopicID, ...)
	-- Parameter checking
	
	if not pSource then
		error("Expected source, got nil")
	end
	
	local vListeners = self.SourceListeners[pSource]
	
	if not vListeners then
		return
	end
	
	for _, vSubscriber in ipairs(vListeners) do
		vSubscriber.Function(vSubscriber.FunctionRef, pSource, pTopicID, ...)
	end
end
