-- server.lua
local socket = require("socket")

function love.load()
    -- Create server
    server = socket.bind('*', 3000)
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
        client:send("welcome from @server\n")
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
    love.graphics.print("Server running on port 3000", 10, 10)
    love.graphics.print("Connected clients: " .. #clients, 10, 30)
    
    -- Display last 10 messages
    local last = math.max(1, #messages - 10)
    for i = last, #messages do
        love.graphics.print(messages[i], 10, 50 + (i - last) * 20)
    end
end