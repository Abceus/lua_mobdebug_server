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
        elseif status == "203" then
            _, _, file, line, watch_idx = string.find(breakpoint, "^203 Paused%s+(.-)%s+(%d+)%s+(%d+)%s*$")
            if file and line and watch_idx then
                return status, {
                    filename = file,
                    line = tonumber(line)
                }, tonumber(watch_idx)
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
    print("Call client removeAllBreakpoints function")
    if self.client then
        self.client:send("DELB * 0 \n")
    end
	return self.client == nil or self.client:receive("*l") == "200 OK"
end

function wrapper:setWatch(expression)
    print("Call client setWatch function with argemunets " .. expression)
    if self.client then
        self.client:send("SETW " .. expression .. "\n")
        local answer = self.client:receive("*l")
        local _, _, watch_idx = string.find(answer, "^200 OK (%d+)%s*$")
        return watch_index and tonumber(watch_idx) or watch_idx
    end
	return 0
end

function wrapper:removeWatch(index)
    print("Call client removeWatch function with argemunets " .. index)
    if self.client then
        self.client:send("DELW " .. index .. "\n")
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

function wrapper:getStack()
    print("Call client getStack function")
    if self.client then
        self.client:send("STACK\n")
        local resp = self.client:receive("*l")
        local _, _, status, res = string.find(resp, "^(%d+)%s+%w+%s+(.+)%s*$")
        
        local func, err = load(res)
        if func == nil then
          return nil, err
        end
        local ok, stack = pcall(func)
        if not ok then
          return nil, stack
        end
        return stack
    end
    return nil, "Client not connected"
end

return wrapper