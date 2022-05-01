local wrapper = {}

function wrapper:init()
	self.breakpoints = {}
	self.currentBreakpoint = nil
    print("Call init function")
    self.status = "inited"
    self.statusChangeCallback = nil
    self.client = require("mobdebug_wrapper/scripts/mobdebug_wrapper_client")
end

function wrapper:connect()
    print("Call connect function")
    local host = "*"
    local port = 8172
    
    local socket = require "socket"
    
    print("Lua Remote Debugger")
    print("Run the program you wish to debug")
    
    local server = socket.bind(host, port)
    self.client:setClient(server:accept())
    self.client:removeAllBreakpoints()

    for filename, lines in pairs(self.breakpoints) do
        for line, _ in pairs(lines) do
            self.client:setBreakpoint(filename, line)
        end
    end
end

function wrapper:run()
    print("Call run function")
    if self.client:run() then
        self:setStatus("running")
    end
end

function wrapper:update()
    local status, breakpoint = self.client:update()
    if status then
        if status == "200" then
            self.currentBreakpoint = nil
        elseif status == "202" then
            self.currentBreakpoint = breakpoint
            self:setStatus("break")
        end
    end
end

function wrapper:stop()
    self.client:stop()
end

function wrapper:pause()
    print("Call pause function")
    if self.client:pause() then
        self:setStatus("break")
    end
end

function wrapper:setBreakpoint(filename, line)
    print("Call setBreakpoint function with argemunets", filename, line)
	if self.client:setBreakpoint(filename, line) then
        self:setBreakpointServer(filename, line)
    end
end

function wrapper:setBreakpointServer(filename, line)
    print("Call setBreakpointClient function with argemunets", filename, line)
	if self.breakpoints[filename] == nil then
		self.breakpoints[filename] = {}
	end
	self.breakpoints[filename][line] = true
end

function wrapper:removeBreakpoint(filename, line)
    print("Call removeBreakpoint function with argemunets", filename, line)
    if self.client:removeBreakpoint(filename, line) then
        self:removeBreakpointServer(filename, line)
    end
end

function wrapper:removeBreakpointServer(filename, line)
    print("Call removeBreakpointClient function with argemunets", filename, line)
    if self.breakpoints[filename] then
        self.breakpoints[filename][line] = nil
    end
end

function wrapper:removeAllBreakpoints()
    print("Call removeAllBreakpoints function with argemunets")
    if self.client:removeAllBreakpoints() then
        self:removeAllBreakpointsServer()
    end
end

function wrapper:removeAllBreakpointsServer()
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
    if self.client:send(command) then
    end
end

return wrapper