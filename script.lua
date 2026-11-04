-- ==========================================
-- MEGA MENU v21.18: REMOTE LOADER (CLIENT)
-- ==========================================
local SERVER_URL = "https://gfdgregrg-production.up.railway.app"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- ===== HTTP адаптер =====
local function httpPost(url, body)
    local payload = {
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = body
    }
    if typeof(request) == "function" then
        local r = request(payload)
        return r and r.Body, r and r.StatusCode
    elseif syn and typeof(syn.request) == "function" then
        local r = syn.request(payload)
        return r and r.Body, r and r.StatusCode
    elseif typeof(http_request) == "function" then
        local r = http_request(payload)
        return r and r.Body, r and r.StatusCode
    elseif http and typeof(http.request) == "function" then
        local r = http.request(payload)
        return r and r.Body, r and r.StatusCode
    end
    error("HTTP-запросы не поддерживаются этим экзекутером")
end

-- ===== UI =====
local LoaderGui = Instance.new("ScreenGui")
LoaderGui.Name = "ScriptHubLoader"
LoaderGui.ResetOnSpawn = false
LoaderGui.IgnoreGuiInset = true
LoaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoaderGui.DisplayOrder = 1000

local parented = false
for _, fn in ipairs({
    function() if gethui then LoaderGui.Parent = gethui() end end,
    function() LoaderGui.Parent = game:GetService("CoreGui") end,
    function() LoaderGui.Parent = LocalPlayer.PlayerGui end
}) do
    if parented then break end
    pcall(fn); parented = LoaderGui.Parent ~= nil
end
if not parented then warn("[Loader] UI не привязан"); return end

local frame = Instance.new("Frame")
frame.Parent = LoaderGui
frame.Size = UDim2.new(0, 320, 0, 225)
frame.Position = UDim2.new(0.5, -160, 0.5, -112)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local fStroke = Instance.new("UIStroke", frame)
fStroke.Color = Color3.fromRGB(255, 50, 50)
fStroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
title.Text = "🔒 MEGA API PANEL v21.18"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.BorderSizePixel = 0
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local hint = Instance.new("TextLabel")
hint.Parent = frame
hint.Size = UDim2.new(1, -20, 0, 20)
hint.Position = UDim2.new(0, 10, 0, 55)
hint.BackgroundTransparency = 1
hint.Text = "Введите пароль для доступа"
hint.TextColor3 = Color3.fromRGB(150, 150, 150)
hint.Font = Enum.Font.Gotham
hint.TextSize = 11

local input = Instance.new("TextBox")
input.Parent = frame
input.Size = UDim2.new(1, -40, 0, 40)
input.Position = UDim2.new(0, 20, 0, 85)
input.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
input.Text = ""
input.PlaceholderText = "Пароль..."
input.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.BorderSizePixel = 0
input.ClearTextOnFocus = false
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
local iStroke = Instance.new("UIStroke", input)
iStroke.Color = Color3.fromRGB(80, 80, 100)

local button = Instance.new("TextButton")
button.Parent = frame
button.Size = UDim2.new(1, -40, 0, 40)
button.Position = UDim2.new(0, 20, 0, 140)
button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
button.Text = "ВОЙТИ"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.BorderSizePixel = 0
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Parent = frame
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 0, 188)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(255, 100, 100)
status.Font = Enum.Font.Gotham
status.TextSize = 11

-- Drag
local dragging, dragStart, startPos
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = i.Position; startPos = frame.Position
    end
end)
title.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- ===== JSON helpers =====
local function jsonEncode(t)
    local parts = {}
    for k, v in pairs(t) do
        local vs
        if type(v) == "string" then
            vs = '"' .. v:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r') .. '"'
        else
            vs = tostring(v)
        end
        table.insert(parts, '"' .. k .. '":' .. vs)
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

local function jsonDecode(str)
    local t = {}
    for k, v in str:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
        t[k] = v:gsub('\\n', '\n'):gsub('\\r', '\r'):gsub('\\"', '"'):gsub('\\\\', '\\')
    end
    for k, v in str:gmatch('"([^"]+)"%s*:%s*([%d%.%-eE]+)') do
        if t[k] == nil then t[k] = tonumber(v) end
    end
    for k, v in str:gmatch('"([^"]+)"%s*:%s*(%a+)') do
        if t[k] == nil then
            if v == "true" then t[k] = true
            elseif v == "false" then t[k] = false
            elseif v == "null" then t[k] = nil end
        end
    end
    return t
end

-- ===== Base64 decode =====
local function base64Decode(s)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local lookup = {}
    for i = 1, #b do lookup[b:sub(i, i)] = i - 1 end
    s = s:gsub('[^A-Za-z0-9+/=]', '')
    local out = {}
    local buf, bits = 0, 0
    for i = 1, #s do
        local c = s:sub(i, i)
        if c == '=' then break end
        local v = lookup[c]
        if v then
            buf = (buf * 64 + v) % 0x1000000
            bits = bits + 6
            if bits >= 8 then
                bits = bits - 8
                local byte = math.floor(buf / 2^bits) % 256
                table.insert(out, string.char(byte))
            end
        end
    end
    return table.concat(out)
end

-- ===== Логика =====
local function setStatus(text, color)
    status.Text = text
    status.TextColor3 = color
end

local function tryLogin()
    if button.Active == false then return end
    if input.Text == "" then
        setStatus("❌ Введите пароль", Color3.fromRGB(255, 100, 100))
        return
    end

    button.Active = false
    button.Text = "ПРОВЕРКА..."
    setStatus("⏳ Связь с сервером...", Color3.fromRGB(200, 200, 100))

    task.spawn(function()
        -- 1) /auth
        local ok1, body1, status1 = pcall(httpPost, SERVER_URL .. "/auth", jsonEncode({ password = input.Text }))
        if not ok1 or not body1 then
            button.Active = true; button.Text = "ВОЙТИ"
            setStatus("❌ Нет связи с сервером", Color3.fromRGB(255, 100, 100))
            return
        end

        local resp1 = jsonDecode(body1)
        if status1 ~= 200 or resp1.ok ~= true or not resp1.token then
            button.Active = true; button.Text = "ВОЙТИ"
            input.Text = ""
            setStatus("❌ Неверный пароль", Color3.fromRGB(255, 100, 100))
            iStroke.Color = Color3.fromRGB(255, 80, 80)
            task.delay(0.9, function()
                if iStroke and iStroke.Parent then iStroke.Color = Color3.fromRGB(80, 80, 100) end
            end)
            return
        end

        setStatus("⏳ Получение скрипта...", Color3.fromRGB(200, 200, 100))

        -- 2) /script
        local ok2, body2, status2 = pcall(httpPost, SERVER_URL .. "/script", jsonEncode({ token = resp1.token }))
        if not ok2 or not body2 then
            button.Active = true; button.Text = "ВОЙТИ"
            setStatus("❌ Токен не принят", Color3.fromRGB(255, 100, 100))
            return
        end

        local resp2 = jsonDecode(body2)
        local code = resp2.code_b64 and base64Decode(resp2.code_b64) or nil

        if status2 ~= 200 or not code or #code < 50 then
            button.Active = true; button.Text = "ВОЙТИ"
            setStatus("❌ Сервер не отдал скрипт", Color3.fromRGB(255, 100, 100))
            return
        end

        setStatus("✅ Доступ разрешён, загрузка...", Color3.fromRGB(100, 255, 100))
        button.Text = "ЗАГРУЗКА..."
        button.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        task.wait(0.3)
        LoaderGui:Destroy()

        local fn = loadstring or load
        if not fn then
            warn("[Loader] loadstring недоступен")
            return
        end
        local ok, err = pcall(function()
            local f = fn(code)
            if f then f() end
        end)
        if not ok then warn("[Loader] Ошибка выполнения: " .. tostring(err)) end
    end)
end

button.MouseButton1Click:Connect(tryLogin)
input.FocusLost:Connect(function(enterPressed) if enterPressed then tryLogin() end end)

print("[Loader] Ожидание пароля...")
