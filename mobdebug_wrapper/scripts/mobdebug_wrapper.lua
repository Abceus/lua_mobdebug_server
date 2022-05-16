local wrapper = {}

function wrapper:init()
	self.breakpoints = {}
    self.watches = {}
	self.currentBreakpoint = nil
	self.currentWatchId = -1
    self:setPrintFunction(print)
    self.printFunction("Call init function")
    self.status = "inited"
    self.statusChangeCallback = nil
    self.client = require("mobdebug_wrapper/scripts/mobdebug_wrapper_client")
end

function wrapper:connect()
    self.printFunction("Call connect function")
    local host = "*"
    local port = 8172
    
    local socket = require "socket"
    
    self.printFunction("Lua Remote Debugger")
    self.printFunction("Run the program you wish to debug")
    
    local server = socket.bind(host, port)
    self.client:setClient(server:accept())
    self.client:removeAllBreakpoints()

    for filename, lines in pairs(self.breakpoints) do
        for line, _ in pairs(lines) do
            self.client:setBreakpoint(filename, line)
        end
    end

    self:removeAllWatchesClient()
    for _, watchExpression in pairs(self.watches) do
        self.client:setWatch(watchExpression)
    end
end

function wrapper:run()
    self.printFunction("Call run function")
    if self.client:run() then
        self.currentBreakpoint = nil
        self.currentWatchId = -1
        self:setStatus("running")
    end
end

function wrapper:step()
    self.printFunction("Call step function")
    if self.client:step() then
        self.currentBreakpoint = nil
        self.currentWatchId = -1
        self:setStatus("running")
    end
end

function wrapper:over()
    self.printFunction("Call over function")
    if self.client:over() then
        self.currentBreakpoint = nil
        self.currentWatchId = -1
        self:setStatus("running")
    end
end

function wrapper:out()
    self.printFunction("Call out function")
    if self.client:out() then
        self.currentBreakpoint = nil
        self.currentWatchId = -1
        self:setStatus("running")
    end
end

function wrapper:reload()
    self.printFunction("Call reload function")
    if self.client:reload() then
        self.currentBreakpoint = nil
        self.currentWatchId = -1
        self:setStatus("running")
    end
end

function wrapper:done()
    self.printFunction("Call done function")
    self.currentBreakpoint = nil
    self.currentWatchId = -1
    self:setStatus("inited")
    self.client:done()
end

function wrapper:exit()
    self.printFunction("Call exit function")
    if self.client:exit() then
        self.currentBreakpoint = nil
        self.currentWatchId = -1
        self:setStatus("inited")
    end
end

function wrapper:update()
    local status, breakpoint, watcherId = self.client:update()
    if status then
        if status == "200" then
            self.currentBreakpoint = nil
            self.currentWatchId = -1
        elseif status == "202" then
            self.currentBreakpoint = breakpoint
            self:setStatus("break")
        elseif status == "203" then
            self.currentBreakpoint = breakpoint
            self.currentWatchId = watcherId
            self:setStatus("break")
        end
    end
end

function wrapper:stop()
    self.client:stop()
end

function wrapper:pause()
    self.printFunction("Call pause function")
    if self.client:pause() then
        self:setStatus("break")
    end
end

function wrapper:setBreakpoint(filename, line)
    self.printFunction("Call setBreakpoint function with argemunets", filename, line)
	if self.client:setBreakpoint(filename, line) then
        self:setBreakpointServer(filename, line)
    end
end

function wrapper:setBreakpointServer(filename, line)
    self.printFunction("Call setBreakpointClient function with argemunets", filename, line)
	if self.breakpoints[filename] == nil then
		self.breakpoints[filename] = {}
	end
	self.breakpoints[filename][line] = true
end

function wrapper:removeBreakpoint(filename, line)
    self.printFunction("Call removeBreakpoint function with argemunets", filename, line)
    if self.client:removeBreakpoint(filename, line) then
        self:removeBreakpointServer(filename, line)
    end
end

function wrapper:removeBreakpointServer(filename, line)
    self.printFunction("Call removeBreakpointClient function with argemunets", filename, line)
    if self.breakpoints[filename] then
        self.breakpoints[filename][line] = nil
    end
end

function wrapper:removeAllBreakpoints()
    self.printFunction("Call removeAllBreakpoints function with argemunets")
    if self.client:removeAllBreakpoints() then
        self:removeAllBreakpointsServer()
    end
end

function wrapper:removeAllBreakpointsServer()
    self.printFunction("Call removeAllBreakpointsClient function with argemunets")
    self.breakpoints = {}
end

function wrapper:hasBreakpoint(filename, line)
    self.printFunction("Call hasBreakpoint function with argemunets", filename, line)
	return self.breakpoints[filename] and self.breakpoints[filename][line]
end

function wrapper:getCurrentBreakpoint()
    self.printFunction("Call getCUrrentBreakpoint function")
	return self.currentBreakpoint
end

function wrapper:getCurrentWatchId()
    self.printFunction("Call getCurrentWatchId function")
	return self.currentWatchId
end

function wrapper:getStatus()
    self.printFunction("Call getStatus function")
    return self.status
end

function wrapper:setStatus(newStatus)
    self.status = newStatus
    if self.statusChangeCallback then
        self.statusChangeCallback(self.status)
    end
end

function wrapper:setStatusChangeCallback(clb)
    self.printFunction("Call setStatusChangeCallback function")
    self.statusChangeCallback = clb
end

function wrapper:setPrintFunction(fnc)
    if fnc ~= nil then
        self.printFunction = fnc
    else
        self.printFunction = print
    end
    self.printFunction("Call setPrintFunction function")
end

function wrapper:handle(command)
    self.printFunction("Call handle function with command: " .. command)
    if self.client:send(command) then
    end
end

function wrapper:getStack()
    self.printFunction("Call getStack function")
    local result, error_ = self.client:getStack()
    if result == nil then
        self.printFunction("Stack error: " .. error_)
    end
    return result
end

function wrapper:setWatch(expression)
    self.printFunction("Call setWatch function with " .. expression)
    local index = self.client:setWatch(expression)
    if index ~= nil then
        if index == 0 then
            index = #self.watches+1
        end
        self:setWatchServer(index, expression)
    end
    return index
end

function wrapper:setWatchServer(index, expression)
    self.printFunction("Call setWatchServer function with " .. expression)
    self.watches[index] = expression
end

function wrapper:getWatch(index)
    self.printFunction("Call getWatch function with " .. index)
    return self.watches[index]
end

function wrapper:getAllWatches()
    return self.watches
end

function wrapper:removeWatch(index)
    self.printFunction("Call removeWatch function with " .. index)
    if self.client:removeWatch(index) then
        self:setWatchServer(index, nil)
    end
end

function wrapper:removeAllWatches()
    self.printFunction("Call removeAllWatches")
    self:removeAllWatchesClient()
    self:removeAllWatchesServer()
end

function wrapper:removeAllWatchesClient()
    self.printFunction("Call removeAllWatchesClient")
    for index, _ in pairs(self.watches) do
        if not self.client:removeWatch(index) then
            self.printFunction("Error when try remove watch with index " .. index)
        end
    end
end

function wrapper:removeAllWatchesServer()
    self.printFunction("Call removeAllWatchesServer")
    self.watches = {}
end

function wrapper:test()
    self.printFunction("Call test function")
    if self.client.client then
        self.client.client:send("STACK\n")
        local resp = self.client.client:receive("*l")
        local _, _, status, res = string.find(resp, "^(%d+)%s+%w+%s+(.+)%s*$")
        
        local func, err = load(res)
        if func == nil then
            self.printFunction("Error in stack information: " .. err)
          return nil, nil, err
        end
        local ok, stack = pcall(func)
        if not ok then
            self.printFunction("Error in stack information: " .. stack)
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