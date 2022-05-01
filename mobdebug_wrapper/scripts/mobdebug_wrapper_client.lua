local wrapper = {}

function wrapper:setClient(client)
    self.client = client
end

function wrapper:run()
    print("Call client run function")
    if self.client then
        self.client:send("RUN\n")
        return self.client:receive("*l") == "200 OK"
    end
    return false
end

function wrapper:update()
    if self.client then
        self.client:settimeout(0)
        local breakpoint = self.client:receive("*l")
        self.client:settimeout()
        if not breakpoint then
        --   print("Program finished")
            return nil
        end
        local _, _, status = string.find(breakpoint, "^(%d+)")
        if status == "200" then
            self.currentBreakpoint = nil
        elseif status == "202" then
            _, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")
            if file and line then
                return status, {
                    filename = file,
                    line = tonumber(line)
                }
            end
        end
        return status
    end
end

function wrapper:stop()
    if self.client then
        self.client:close()
        self.client = nil
    end
end

function wrapper:pause()
    print("Call client pause function")
    if self.client then
        self.client:send("STEP\n")
        return self.client:receive("*l") == "200 OK"
    end
    return false
end

function wrapper:setBreakpoint(filename, line)
    print("Call client setBreakpoint function with argemunets", filename, line)
	if self.client then
    	self.client:send("SETB " .. filename .. " " .. line .. "\n")
	end
	return self.client == nil or self.client:receive("*l") == "200 OK"
end

function wrapper:removeBreakpoint(filename, line)
    print("Call client removeBreakpoint function with argemunets", filename, line)
    if self.client then
        self.client:send("DELB " .. filename .. " " .. line .. "\n")
    end
	return self.client == nil or self.client:receive("*l") == "200 OK"
end

function wrapper:removeAllBreakpoints()
    print("Call client removeAllBreakpoints function with argemunets")
    if self.client then
        self.client:send("DELB * 0 \n")
    end
	return self.client == nil or self.client:receive("*l") == "200 OK"
end

function wrapper:handle(command, needAnswer)
    print("Call client handle function with command: " .. command)
    if self.client then
        self.client:send(command .. "\n")
        if needAnswer then
            return self.client:receive("*l")
        end
    end
end

return wrapper