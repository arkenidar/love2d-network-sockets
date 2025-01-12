-- server.lua
local socket = require("socket")

function love.load()
    -- Create server
    server = socket.bind('*', 12345)
    server:settimeout(0)
    clients = {}
    messages = {}
end

function love.update(dt)
    -- Accept new clients
    local client = server:accept()
    if client then
        client:settimeout(0)
        table.insert(clients, client)
        print("New client connected!")
    end

    -- Receive messages from clients
    for i, client in ipairs(clients) do
        local message, err = client:receive()
        if message then
            table.insert(messages, message)
            -- Broadcast message to all clients
            for j, other_client in ipairs(clients) do
                other_client:send(message .. "\n")
            end
        elseif err ~= "timeout" then
            client:close()
            table.remove(clients, i)
            print("Client disconnected!")
        end
    end
end

function love.draw()
    love.graphics.print("Server running on port 12345", 10, 10)
    love.graphics.print("Connected clients: " .. #clients, 10, 30)
    
    -- Display last 10 messages
    for i = math.max(1, #messages - 10), #messages do
        love.graphics.print(messages[i], 10, 50 + (i - math.max(1, #messages - 10)) * 20)
    end
end

-- client.lua
local socket = require("socket")

function love.load()
    client = socket.connect("localhost", 12345)
    if client then
        client:settimeout(0)
        connected = true
        messages = {}
        input = ""
    else
        connected = false
    end
end

function love.update(dt)
    if connected then
        local message, err = client:receive()
        if message then
            table.insert(messages, message)
        elseif err ~= "timeout" then
            connected = false
            client:close()
            print("Disconnected from server!")
        end
    end
end

function love.draw()
    if connected then
        love.graphics.print("Connected to server", 10, 10)
        love.graphics.print("Current input: " .. input, 10, 30)
        
        -- Display last 10 messages
        for i = math.max(1, #messages - 10), #messages do
            love.graphics.print(messages[i], 10, 50 + (i - math.max(1, #messages - 10)) * 20)
        end
    else
        love.graphics.print("Not connected to server", 10, 10)
    end
end

function love.keypressed(key)
    if connected then
        if key == "return" and input ~= "" then
            client:send(input .. "\n")
            input = ""
        elseif key == "backspace" then
            input = input:sub(1, -2)
        end
    end
end

function love.textinput(text)
    if connected then
        input = input .. text
    end
end

function love.quit()
    if connected then
        client:close()
    end
end