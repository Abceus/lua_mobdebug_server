local wrapper = {}

local loadstring = loadstring or load -- "load" replaced "loadstring" in Lua 5.2
local unpack = table.unpack or unpack

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

function wrapper:step()
    print("Call client step function")
    if self.client then
        self.client:send("STEP\n")
        return self.client:receive("*l") == "200 OK"
    end
    return false
end

function wrapper:over()
    print("Call client over function")
    if self.client then
        self.client:send("OVER\n")
        return self.client:receive("*l") == "200 OK"
    end
    return false
end

function wrapper:out()
    print("Call client out function")
    if self.client then
        self.client:send("OUT\n")
        return self.client:receive("*l") == "200 OK"
    end
    return false
end

function wrapper:reload()
    print("Call client reload function")
    if self.client then
        self.client:send("LOAD 0 -\n")
        return self.client:receive("*l") == "200 OK"
    end
    return false
end

function wrapper:done()
    print("Call client done function")
    if self.client then
        self.client:send("DONE\n")
    end
end

function wrapper:exit()
    print("Call client exit function")
    if self.client then
        self.client:send("EXIT\n")
        return self.client:receive("*l") == "200 OK"
    end
    return true
end

local getEvalResult = function(client)
      local params, err = client:receive("*l")
      if not params then
        return nil, nil, "Debugger connection " .. (err or "error")
      end
      local _, _, status, len = string.find(params, "^(%d+).-%s+(%d+)%s*$")
      if status == "200" then
        len = tonumber(len)
        if len > 0 then
          local status, res
          local str = client:receive(len)
          -- handle serialized table with results
          local func, err = loadstring(str)
          if func then
            status, res = pcall(func)
            if not status then err = res
            elseif type(res) ~= "table" then
              err = "received "..type(res).." instead of expected 'table'"
            end
          end
          if err then
            print("Error in processing results: " .. err)
            return nil, nil, "Error in processing results: " .. err
          end
          print(unpack(res))
          return res[1], res
        end
      elseif status == "401" then
        len = tonumber(len)
        local res = client:receive(len)
        print("Error in expression: " .. res)
        return nil, nil, res
      else
        print("Unknown error")
        return nil, nil, "Debugger error: unexpected response after EXEC/LOAD '" .. params .. "'"
      end
end

function wrapper:execute(expression)
    print("Call client execute")
    expression = expression:gsub("\n", "\r")
    if self.client then
        self.client:send("EXEC " .. expression .. "\n")
        return getEvalResult(self.client)
    end
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
            local _, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")
            if file and line then
                return status, {
                    filename = file,
                    line = tonumber(line)
                }
            end
        elseif status == "203" then
            local _, _, file, line, watch_idx = string.find(breakpoint, "^203 Paused%s+(.-)%s+(%d+)%s+(%d+)%s*$")
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