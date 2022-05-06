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

function wrapper:getStack()
    print("Call getStack function")
    local result, error_ = self.client:getStack()
    if result == nil then
        print("Stack error: " .. error_)
    end
    return result
end

function wrapper:test()
    print("Call test function")
    if self.client.client then
        self.client.client:send("STACK\n")
        local resp = self.client.client:receive("*l")
        local _, _, status, res = string.find(resp, "^(%d+)%s+%w+%s+(.+)%s*$")
        
        local func, err = load(res)
        if func == nil then
          print("Error in stack information: " .. err)
          return nil, nil, err
        end
        local ok, stack = pcall(func)
        if not ok then
          print("Error in stack information: " .. stack)
          return nil, nil, stack
        end
        local frames = {}
        -- for _,frame in ipairs(stack) do
        -- print(mobdebug.line(frame[1], {comment = false}))
        -- frames[#frames+1] = {
            --     func = frame[1][1],
            
            -- -- }
            -- for q, w in pairs(frame) do
            --     print(q, w)
            -- end
            -- print(frame[1])
            -- serpent = require("mobdebug_wrapper/scripts/serpent")
            -- print(serpent.line(frame[1]))
            -- for f, s in pairs(frame[1]) do
            --     print(f, s)
            -- end
            
            -- print(frame)
            -- for q, w in pairs(frame) do
            --     print(q, w)
            --     for f, s in pairs(w) do
            --         print(f, s)
            --     end
            -- end
            -- local function printTable(key, value, level)
            --     if level > 5 then
            --         return
            --     end
            --     print(string.rep(">",level), key, value)
            --     if type(value) == "table" then
            --         for k, v in pairs(value) do
            --             printTable(k, v, level+1)
            --         end
            --     end
            -- end
            
            -- printTable("", frame, 0)
        -- end
        return stack
    end
end

return wrapper