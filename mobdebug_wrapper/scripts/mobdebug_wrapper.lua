local wrapper = {}

function wrapper:init()
	self.breakpoints = {}
	self.currentBreakpoint = nil
    print("Call init function")
    self.status = "inited"
    self.statusChangeCallback = nil
    self.client = nil
end

function wrapper:connect()
    self.client = nil

    print("Call connect function")
    local host = "*"
    local port = 8172
    
    local socket = require "socket"
    
    print("Lua Remote Debugger")
    print("Run the program you wish to debug")
    
    local server = socket.bind(host, port)
    self.client = server:accept()

    self:removeAllBreakpointsServer()

    for filename, lines in pairs(self.breakpoints) do
        for line, _ in pairs(lines) do
            self:setBreakpointServer(filename, line)
        end
    end
end

function wrapper:run()
    print("Call run function")
    -- self.debugger.handle("run", self.client)
    if self.client then
        self.client:send("RUN\n")
        self:setStatus("running")
    end
end

function wrapper:update()
    if self.client then
        self.client:settimeout(0)
        local breakpoint = self.client:receive("*l")
        self.client:settimeout()
        if not breakpoint then
        --   print("Program finished")
        return
        end
        local _, _, status = string.find(breakpoint, "^(%d+)")
        if status == "200" then
            self.currentBreakpoint = nil
        elseif status == "202" then
        _, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")
        if file and line then
            self.currentBreakpoint = {
                filename = file,
                line = tonumber(line)
            }
            self:setStatus("break")
        end
        end
    end
end

function wrapper:stop()
    if self.client then
        self.client:close()
        self.client = nil
    end
end

function wrapper:pause()
    print("Call pause function")
    self:setStatus("break")
end

function wrapper:setBreakpoint(filename, line)
    print("Call setBreakpoint function with argemunets", filename, line)
	if self:setBreakpointServer(filename, line) then
        self:setBreakpointClient(filename, line)
    end
end

function wrapper:setBreakpointServer(filename, line)
    print("Call setBreakpointServer function with argemunets", filename, line)
	if self.client then
    	self.client:send("SETB " .. filename .. " " .. line .. "\n")
	end
	return self.client == nil or self.client:receive("*l") == "200 OK"
end

function wrapper:setBreakpointClient(filename, line)
    print("Call setBreakpointClient function with argemunets", filename, line)
	if self.breakpoints[filename] == nil then
		self.breakpoints[filename] = {}
	end
	self.breakpoints[filename][line] = true
end

function wrapper:removeBreakpoint(filename, line)
    print("Call removeBreakpoint function with argemunets", filename, line)
    if self:removeBreakpointServer(filename, line) then
        self:removeBreakpointClient(filename, line)
    end
end

function wrapper:removeBreakpointServer(filename, line)
    print("Call removeBreakpointServer function with argemunets", filename, line)
    if self.client then
        self.client:send("DELB " .. filename .. " " .. line .. "\n")
    end
	return self.client == nil or self.client:receive("*l") == "200 OK"
end

function wrapper:removeBreakpointClient(filename, line)
    print("Call removeBreakpointClient function with argemunets", filename, line)
    if self.breakpoints[filename] then
        self.breakpoints[filename][line] = nil
    end
end

function wrapper:removeAllBreakpoints()
    print("Call removeAllBreakpoints function with argemunets")
    if self:removeAllBreakpointsServer() then
        self:removeAllBreakpointsClient()
    end
end

function wrapper:removeAllBreakpointsServer()
    print("Call removeAllBreakpointsServer function with argemunets")
    if self.client then
        self.client:send("DELB * 0 \n")
    end
	return self.client == nil or self.client:receive("*l") == "200 OK"
end

function wrapper:removeAllBreakpointsClient()
    print("Call removeAllBreakpointsClient function with argemunets")
    self.breakpoints = {}
end

function wrapper:hasBreakpoint(filename, line)
    print("Call hasBreakpoint function with argemunets", filename, line)
	return self.breakpoints[filename] and self.breakpoints[filename][line]
end

function wrapper:getCurrentBreakpoint()
    print("Call getCUrrentBreakpoint function")
	return self.currentBreakpoint
end

function wrapper:getStatus()
    print("Call getStatus function")
    return self.status
end

function wrapper:setStatus(newStatus)
    self.status = newStatus
    if self.statusChangeCallback then
        self.statusChangeCallback(self.status)
    end
end

function wrapper:setStatusChangeCallback(clb)
    print("Call setStatusChangeCallback function")
    self.statusChangeCallback = clb
end

function wrapper:handle(command)
    print("Call handle function with command: " .. command)
    if self.client then
        self.client:send(command .. "\n")
    end
end

return wrapper