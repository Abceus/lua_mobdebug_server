local wrapper = {}

function wrapper:init()
    print("Call init function")
    -- self.debugger = require('mobdebug')
    self.status = "inited"
    self.statusChangeCallback = nil

    local host = "*"
    local port = 8172
    
    local socket = require "socket"
    
    print("Lua Remote Debugger")
    print("Run the program you wish to debug")
    
    local server = socket.bind(host, port)
    self.client = server:accept()
    
    self.client:send("STEP\n")
    self.client:receive("*l")
    
    local breakpoint = self.client:receive("*l")
    local _, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")
    if file and line then
        print("Paused at file " .. file )
        -- print("Type 'help' for commands")
    else
        local _, _, size = string.find(breakpoint, "^401 Error in Execution (%d+)%s*$")
        if size then
        print("Error in remote application: ")
        print(self.client:receive(size))
        end
    end
end

function wrapper:run()
    print("Call run function")
    -- self.debugger.handle("run", self.client)
    self.client:send("RUN\n")
    self:setStatus("running")
end

function wrapper:update()
    local breakpoint = self.client:receive("*l")
    if not breakpoint then
      print("Program finished")
      return
    end
    local _, _, status = string.find(breakpoint, "^(%d+)")
    if status == "200" then
      -- don't need to do anything
    elseif status == "202" then
      _, _, file, line = string.find(breakpoint, "^202 Paused%s+(.-)%s+(%d+)%s*$")
      if file and line then
        self:setStatus("break")
        print(file, line)
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
    -- self.debugger.pause()
    self:setStatus("break")
end

function wrapper:setBreakpoint(filename, line)
    print("Call setBreakpoint function with argemunets", filename, line)
    self.client:send("SETB " .. filename .. " " .. line .. "\n")
    -- self.debugger.setbreakpoint(filename, line)
    -- print(type(line))
    -- self.debugger.handle("setb " .. filename .. " " .. line, self.client)
end

function wrapper:removeBreakpoint(filename, line)
    print("Call removeBreakpoint function with argemunets", filename, line)
    -- self.debugger.removebreakpoint(filename, line)
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
    local file, line = self.debugger.handle(command, self.client)
    if file or line then
        self:setStatus("break")
    end
end

return wrapper