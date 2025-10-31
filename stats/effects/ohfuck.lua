function init()
end

function update(dt)
   	if status.isResource("food") and status.resource("food") < 100 then
		status.modifyResource("food", 5/69420)		
	end
end

function uninit()

end