-- ==========================================
-- MEGA MENU v21.18: FULL SCRIPT (CLEAN ESP)
-- ==========================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local pGui = LocalPlayer:WaitForChild("PlayerGui")

print("[ScriptHub] Запуск v21.18 (CLEAN ESP)")

-- === ФЛАГИ ===
local isESP = false
local isAutoArchery = false
local lastArchShot = 0

-- ==========================================
-- UI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptHubUI_v21"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = false
for _, fn in ipairs({
    function() if gethui then ScreenGui.Parent = gethui() end end,
    function() ScreenGui.Parent = game:GetService("CoreGui") end,
    function() ScreenGui.Parent = LocalPlayer.PlayerGui end
}) do
    if parented then break end
    pcall(fn); parented = ScreenGui.Parent ~= nil
end
if not parented then warn("[ScriptHub] UI не привязан") return end

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 70, 0, 45)
ToggleBtn.Position = UDim2.new(1, -90, 1, -110)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.Text = "MENU"
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.ZIndex = 10
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 350, 0, 620)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -310)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 5
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "MEGA API PANEL v21.18"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.BorderSizePixel = 0
Title.ZIndex = 6
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(0.9, 0, 0, 45)
StatusLabel.Position = UDim2.new(0.05, 0, 1, -55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Система готова..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextWrapped = true
StatusLabel.ZIndex = 6

local Scroll = Instance.new("ScrollingFrame")
Scroll.Parent = MainFrame
Scroll.Size = UDim2.new(0.95, 0, 0, 505)
Scroll.Position = UDim2.new(0.025, 0, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.ZIndex = 6
local UIList = Instance.new("UIListLayout")
UIList.Parent = Scroll
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
end)

-- Drag Main UI
local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
    end
end)
Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ==========================================
-- ХЕЛПЕРЫ
-- ==========================================
local function clickGui(button)
    if not button then return end
    if button.Active == false then pcall(function() button.Active = true end) end
    pcall(function() button.Activated:Fire() end)
    pcall(function() button.MouseButton1Click:Fire() end)
    pcall(function() button.MouseButton1Down:Fire() end)
    pcall(function() button.MouseButton1Up:Fire() end)
end

local function findInTree(root, name, className)
    if not root then return nil end
    if root.Name == name and (not className or root:IsA(className)) then return root end
    for _, child in ipairs(root:GetChildren()) do
        local found = findInTree(child, name, className)
        if found then return found end
    end
    return nil
end

local function createButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Parent = Scroll
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = text
    btn.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.ZIndex = 7
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local function createHeader(text)
    local lbl = Instance.new("TextLabel")
    lbl.Parent = Scroll
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    return lbl
end

local function toggleBtn(btn, state, onText, offText, onColor, offColor)
    if state then btn.Text = onText; btn.TextColor3 = onColor
    else btn.Text = offText; btn.TextColor3 = offColor end
end

local function isTyping()
    return UserInputService:GetFocusedTextBox() ~= nil
end

-- ==========================================
-- 📊 ИНФО-ТАБЛИЦА
-- ==========================================
local InfoTableGui = nil
local isInfoAutoQuiz = false

local function createInfoTable()
    if InfoTableGui and InfoTableGui.Parent then
        InfoTableGui.Enabled = true
        InfoTableGui.DisplayOrder = 999
        return
    end
    InfoTableGui = Instance.new("ScreenGui")
    InfoTableGui.Name = "ScriptHubInfoTable"
    InfoTableGui.ResetOnSpawn = false
    InfoTableGui.IgnoreGuiInset = true
    InfoTableGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    InfoTableGui.DisplayOrder = 999
    if gethui then pcall(function() InfoTableGui.Parent = gethui() end) end
    if not InfoTableGui.Parent then pcall(function() InfoTableGui.Parent = game:GetService("CoreGui") end) end
    if not InfoTableGui.Parent then InfoTableGui.Parent = LocalPlayer.PlayerGui end

    local frame = Instance.new("Frame")
    frame.Parent = InfoTableGui
    frame.Size = UDim2.new(0, 560, 0, 460)
    frame.Position = UDim2.new(0.5, -280, 0.5, -230)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(80, 80, 120)

    local header = Instance.new("Frame")
    header.Parent = frame
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
    header.BorderSizePixel = 0
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Parent = header
    headerTitle.Size = UDim2.new(1, -100, 1, 0)
    headerTitle.Position = UDim2.new(0, 10, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "📊 Инфо-таблица"
    headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerTitle.Font = Enum.Font.GothamBold
    headerTitle.TextSize = 14
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left

    local d1, dS, dP
    headerTitle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d1 = true; dS = i.Position; dP = frame.Position
        end
    end)
    headerTitle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d1 = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d1 and i.UserInputType == Enum.UserInputType.MouseMovement then
            local dd = i.Position - dS
            frame.Position = UDim2.new(dP.X.Scale, dP.X.Offset + dd.X, dP.Y.Scale, dP.Y.Offset + dd.Y)
        end
    end)

    local function mkB(t, c, x)
        local b = Instance.new("TextButton")
        b.Parent = header; b.Size = UDim2.new(0, 28, 0, 25); b.Position = UDim2.new(1, x, 0, 5)
        b.BackgroundColor3 = c; b.Text = t; b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.GothamBold; b.TextSize = 13; b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        return b
    end
    local mnB = mkB("—", Color3.fromRGB(255, 180, 50), -95)
    local clB = mkB("✕", Color3.fromRGB(255, 100, 100), -62)
    local dlB = mkB("🗑", Color3.fromRGB(200, 50, 50), -29)

    local min = false
    mnB.MouseButton1Click:Connect(function()
        min = not min
        frame.Size = min and UDim2.new(0, 560, 0, 35) or UDim2.new(0, 560, 0, 460)
    end)
    clB.MouseButton1Click:Connect(function() InfoTableGui.Enabled = false end)
    dlB.MouseButton1Click:Connect(function() if InfoTableGui then InfoTableGui:Destroy(); InfoTableGui = nil end end)

    local tabs = Instance.new("Frame")
    tabs.Parent = frame; tabs.Size = UDim2.new(1, -20, 0, 30); tabs.Position = UDim2.new(0, 10, 0, 42)
    tabs.BackgroundTransparency = 1
    local tl = Instance.new("UIListLayout", tabs)
    tl.FillDirection = Enum.FillDirection.Horizontal; tl.Padding = UDim.new(0, 5)

    local qT = Instance.new("TextButton")
    qT.Parent = tabs; qT.Size = UDim2.new(0.33, -3, 1, 0)
    qT.BackgroundColor3 = Color3.fromRGB(50, 80, 150); qT.Text = "📝 Викторина"
    qT.TextColor3 = Color3.fromRGB(255,255,255); qT.Font = Enum.Font.GothamBold; qT.TextSize = 12; qT.BorderSizePixel = 0
    Instance.new("UICorner", qT).CornerRadius = UDim.new(0, 5)

    local pT = Instance.new("TextButton")
    pT.Parent = tabs; pT.Size = UDim2.new(0.33, -3, 1, 0)
    pT.BackgroundColor3 = Color3.fromRGB(40, 40, 50); pT.Text = "👥 Игроки"
    pT.TextColor3 = Color3.fromRGB(200,200,200); pT.Font = Enum.Font.GothamBold; pT.TextSize = 12; pT.BorderSizePixel = 0
    Instance.new("UICorner", pT).CornerRadius = UDim.new(0, 5)

    local qAutoBtn = Instance.new("TextButton")
    qAutoBtn.Parent = tabs; qAutoBtn.Size = UDim2.new(0.33, -3, 1, 0)
    qAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); qAutoBtn.Text = "🤖 Авто-ответ: ВЫКЛ"
    qAutoBtn.TextColor3 = Color3.fromRGB(200,200,200); qAutoBtn.Font = Enum.Font.GothamBold; qAutoBtn.TextSize = 12; qAutoBtn.BorderSizePixel = 0
    Instance.new("UICorner", qAutoBtn).CornerRadius = UDim.new(0, 5)

    local cF = Instance.new("Frame")
    cF.Parent = frame; cF.Size = UDim2.new(1, -20, 1, -85); cF.Position = UDim2.new(0, 10, 0, 78)
    cF.BackgroundColor3 = Color3.fromRGB(12, 12, 18); cF.BorderSizePixel = 0
    Instance.new("UICorner", cF).CornerRadius = UDim.new(0, 5)

    local qC = Instance.new("ScrollingFrame")
    qC.Parent = cF; qC.Size = UDim2.new(1, -10, 1, -10); qC.Position = UDim2.new(0, 5, 0, 5)
    qC.BackgroundTransparency = 1; qC.ScrollBarThickness = 4
    qC.CanvasSize = UDim2.new(0,0,0,0); qC.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local ql = Instance.new("UIListLayout", qC); ql.Padding = UDim.new(0, 5)

    local pC = Instance.new("ScrollingFrame")
    pC.Parent = cF; pC.Size = UDim2.new(1, -10, 1, -10); pC.Position = UDim2.new(0, 5, 0, 5)
    pC.BackgroundTransparency = 1; pC.ScrollBarThickness = 4; pC.Visible = false
    pC.CanvasSize = UDim2.new(0,0,0,0); pC.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local pl = Instance.new("UIListLayout", pC); pl.Padding = UDim.new(0, 5)

    qT.MouseButton1Click:Connect(function()
        qC.Visible = true; pC.Visible = false
        qT.BackgroundColor3 = Color3.fromRGB(50,80,150); qT.TextColor3 = Color3.fromRGB(255,255,255)
        pT.BackgroundColor3 = Color3.fromRGB(40,40,50); pT.TextColor3 = Color3.fromRGB(200,200,200)
    end)
    pT.MouseButton1Click:Connect(function()
        qC.Visible = false; pC.Visible = true
        pT.BackgroundColor3 = Color3.fromRGB(50,80,150); pT.TextColor3 = Color3.fromRGB(255,255,255)
        qT.BackgroundColor3 = Color3.fromRGB(40,40,50); qT.TextColor3 = Color3.fromRGB(200,200,200)
    end)
    
    qAutoBtn.MouseButton1Click:Connect(function()
        isInfoAutoQuiz = not isInfoAutoQuiz
        if isInfoAutoQuiz then
            qAutoBtn.BackgroundColor3 = Color3.fromRGB(50,150,80); qAutoBtn.Text = "🤖 Авто-ответ: ВКЛ"
            qAutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
        else
            qAutoBtn.BackgroundColor3 = Color3.fromRGB(40,40,50); qAutoBtn.Text = "🤖 Авто-ответ: ВЫКЛ"
            qAutoBtn.TextColor3 = Color3.fromRGB(200,200,200)
        end
    end)

    -- Викторина
    task.spawn(function()
        local lastQ = ""
        while InfoTableGui and InfoTableGui.Parent do
            task.wait(0.3)
            if qC.Visible then pcall(function()
                local qf = pGui:FindFirstChild("QuizExam")
                local qg = qf and qf:FindFirstChild("MainGameGui")
                local aq, ao = nil, nil
                if qg and qg.Enabled then
                    local bf = qg.HolderFrame.Frame.BlackFrame
                    for _, n in ipairs({"4ButtonsQuestion","4Buttons","4ButtonsColor"}) do
                        local f = bf:FindFirstChild(n)
                        if f and f.Visible then
                            aq = (f.DescriptionTextLabel and f.DescriptionTextLabel.Text) or ""
                            ao = f:FindFirstChild("Options"); break
                        end
                    end
                end
                
                if aq and aq ~= "" and aq ~= lastQ then
                    lastQ = aq
                    for _, c in ipairs(qC:GetChildren()) do
                        if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then c:Destroy() end
                    end
                    local qLbl = Instance.new("TextLabel", qC)
                    qLbl.Size = UDim2.new(1,-10,0,0); qLbl.AutomaticSize = Enum.AutomaticSize.Y
                    qLbl.BackgroundTransparency = 1; qLbl.Text = "❓ "..aq
                    qLbl.TextColor3 = Color3.fromRGB(255,255,100); qLbl.Font = Enum.Font.GothamBold
                    qLbl.TextSize = 13; qLbl.TextWrapped = true; qLbl.TextXAlignment = Enum.TextXAlignment.Left
                    
                    if ao then
                        for i = 1, 4 do
                            local n = ao:FindFirstChild("Normal"..i)
                            if n and n.Visible then
                                local rb = n:FindFirstChild("TextButton")
                                local lb = rb and rb:FindFirstChild("TextLabel")
                                local ans = lb and lb.Text or "?"
                                local ob = Instance.new("TextButton", qC)
                                ob.Size = UDim2.new(1,-10,0,32); ob.BackgroundColor3 = Color3.fromRGB(40,60,90)
                                ob.Text = "▸ "..ans; ob.TextColor3 = Color3.fromRGB(255,255,255)
                                ob.Font = Enum.Font.Gotham; ob.TextSize = 12; ob.TextXAlignment = Enum.TextXAlignment.Left
                                ob.BorderSizePixel = 0
                                Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 4)
                                ob.MouseButton1Click:Connect(function() clickGui(rb) end)
                            end
                        end
                        
                        if isInfoAutoQuiz then
                            task.spawn(function()
                                task.wait(0.5)
                                if lastQ ~= aq then return end
                                for i = 1, 4 do
                                    local n = ao:FindFirstChild("Normal"..i)
                                    if n and n.Visible then
                                        local rb = n:FindFirstChild("TextButton")
                                        if rb then
                                            clickGui(rb)
                                            break
                                        end
                                    end
                                end
                            end)
                        end
                    end
                elseif not qg or not qg.Enabled then
                    if lastQ ~= "OFF" then
                        lastQ = "OFF"
                        for _, c in ipairs(qC:GetChildren()) do
                            if c:IsA("Frame") or c:IsA("TextLabel") or c:IsA("TextButton") then c:Destroy() end
                        end
                        local i = Instance.new("TextLabel", qC)
                        i.Size = UDim2.new(1,-10,0,30); i.BackgroundTransparency = 1
                        i.Text = "Нет активной викторины"; i.TextColor3 = Color3.fromRGB(150,150,150)
                        i.Font = Enum.Font.Gotham; i.TextSize = 12; i.TextXAlignment = Enum.TextXAlignment.Left
                    end
                end
            end) end
        end
    end)

    -- Игроки
    task.spawn(function()
        while InfoTableGui and InfoTableGui.Parent do
            task.wait(1.2)
            if pC.Visible then pcall(function()
                for _, c in ipairs(pC:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
                for _, p in ipairs(Players:GetPlayers()) do
                    local d = p:FindFirstChild("Data")
                    local level, title, titleColor, wins, monthlyWins, vip = "?","—","—","0","0",false
                    local points, spins, candy, style, pity = "0","0","0","—","0"
                    local oaa = {P=0,A=0,Ad=0,S=0}
                    local hasClass = false
                    pcall(function()
                        if d then
                            local lv = d:FindFirstChild("Level")
                            if lv and lv:FindFirstChild("Level") then level = tostring(lv.Level.Value) end
                            local tll = d:FindFirstChild("TitleLoadout")
                            if tll then
                                local eq = tll:FindFirstChild("EquippedTitleName")
                                if eq and eq.Value ~= "" then title = eq.Value end
                                local ec = tll:FindFirstChild("EquippedTitleColorId")
                                if ec and ec.Value ~= "" then titleColor = ec.Value end
                            end
                            local st = d:FindFirstChild("Statistics")
                            if st then
                                if st:FindFirstChild("Wins") then wins = tostring(st.Wins.Value) end
                                if st:FindFirstChild("MonthlyWins") then monthlyWins = tostring(st.MonthlyWins.Value) end
                            end
                            local dp = d:FindFirstChild("DeveloperProducts")
                            if dp and dp:FindFirstChild("VIPOwned") then vip = dp.VIPOwned.Value end
                            local cur = d:FindFirstChild("Currency")
                            if cur and cur:FindFirstChild("PersonalPoints") then points = tostring(cur.PersonalPoints.Value) end
                            local sp = d:FindFirstChild("Spins")
                            if sp and sp:FindFirstChild("StyleRegular") then spins = tostring(sp.StyleRegular.Value) end
                            local cd = d:FindFirstChild("Candy")
                            if cd and cd:FindFirstChild("Balance") then candy = tostring(cd.Balance.Value) end
                            local sl = d:FindFirstChild("StyleLoadout")
                            if sl and sl:FindFirstChild("EquippedStyleId") then style = sl.EquippedStyleId.Value end
                            local si = d:FindFirstChild("StyleInventory")
                            if si and si:FindFirstChild("MythicPity") then pity = tostring(si.MythicPity.Value) end
                            local oa = d:FindFirstChild("OAA")
                            if oa then
                                if oa:FindFirstChild("PhysicalAbility") then oaa.P = oa.PhysicalAbility.Value end
                                if oa:FindFirstChild("AcademicAbility") then oaa.A = oa.AcademicAbility.Value end
                                if oa:FindFirstChild("Adaptability") then oaa.Ad = oa.Adaptability.Value end
                                if oa:FindFirstChild("SocialAbility") then oaa.S = oa.SocialAbility.Value end
                            end
                            local cm = d:FindFirstChild("ClassMembership")
                            if cm and cm:FindFirstChild("ClassId") then hasClass = cm.ClassId.Value ~= "" end
                        end
                    end)
                    
                    local inviteStatus = "✅ Можно"
                    local inviteColor = Color3.fromRGB(100, 255, 100)
                    if p == LocalPlayer then
                        inviteStatus = "👑 Вы"
                        inviteColor = Color3.fromRGB(255, 215, 0)
                    elseif hasClass then
                        inviteStatus = "❌ Уже в классе"
                        inviteColor = Color3.fromRGB(255, 100, 100)
                    elseif tonumber(level) and tonumber(level) < 2 then
                        inviteStatus = "❌ Новичок"
                        inviteColor = Color3.fromRGB(255, 100, 100)
                    end
                    
                    local row = Instance.new("Frame", pC)
                    row.Size = UDim2.new(1,-10,0,96)
                    row.BackgroundColor3 = p == LocalPlayer and Color3.fromRGB(40,70,40) or Color3.fromRGB(28,28,38)
                    row.BorderSizePixel = 0
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0,5)
                    local function mkL(y, h, t, c, b)
                        local l = Instance.new("TextLabel", row)
                        l.Size = UDim2.new(1,-10,0,h); l.Position = UDim2.new(0,5,0,y)
                        l.BackgroundTransparency = 1; l.Text = t; l.TextColor3 = c
                        l.Font = b and Enum.Font.GothamBold or Enum.Font.Gotham
                        l.TextSize = b and 12 or 11; l.TextXAlignment = Enum.TextXAlignment.Left
                    end
                    mkL(3,20,(vip and "⭐ " or "")..p.Name..(p==LocalPlayer and " (Вы)" or ""),vip and Color3.fromRGB(255,215,0) or Color3.fromRGB(255,255,255),true)
                    mkL(23,16,string.format("Ур:%s | Титул:%s(%s) | Побед:%s (мес:%s)",level,title,titleColor,wins,monthlyWins),Color3.fromRGB(180,180,180),false)
                    mkL(39,16,string.format("💰%s | 🎰%s | 🍬%s | Стиль:%s (Pity:%s)",points,spins,candy,style,pity),Color3.fromRGB(150,200,255),false)
                    mkL(55,16,string.format("OAA: Физ%d/Акад%d/Адапт%d/Соц%d",oaa.P,oaa.A,oaa.Ad,oaa.S),Color3.fromRGB(200,180,100),false)
                    mkL(71,16,string.format("Класс:%s | %s | %s",hasClass and "✅" or "❌",vip and "👑 VIP" or "👤 Студент", inviteStatus),inviteColor,false)
                end
            end) end
        end
    end)
end

-- ==========================================
-- 🏹 АВТО-СТРЕЛЬБА (ЛУК)
-- ==========================================
createHeader("--- 🏹 АВТО-СТРЕЛЬБА (ЛУК) ---")
local ArchBtn = createButton("🏹 Авто-Идеальный выстрел: ВЫКЛ", Color3.fromRGB(255, 150, 150))

ArchBtn.MouseButton1Click:Connect(function()
    isAutoArchery = not isAutoArchery
    toggleBtn(ArchBtn, isAutoArchery, "🏹 Авто-Идеальный выстрел: ВКЛ", "🏹 Авто-Идеальный выстрел: ВЫКЛ", Color3.fromRGB(100,255,100), Color3.fromRGB(255,150,150))
end)

RunService.RenderStepped:Connect(function()
    if not isAutoArchery then return end
    if isTyping() then return end
    if tick() - lastArchShot < 0.5 then return end
    
    pcall(function()
        local sports = pGui:FindFirstChild("SportsExam")
        local arch = sports and sports:FindFirstChild("ArcheryGui")
        if arch and arch.Enabled then
            local holder = arch:FindFirstChild("Holder")
            local bar = holder and holder:FindFirstChild("Bar")
            local marker = bar and bar:FindFirstChild("Marker")
            local centerZone = bar and bar:FindFirstChild("CenterZone")
            
            if marker and centerZone then
                local mCenter = marker.AbsolutePosition.X + (marker.AbsoluteSize.X / 2)
                local czLeft = centerZone.AbsolutePosition.X
                local czRight = centerZone.AbsolutePosition.X + centerZone.AbsoluteSize.X
                
                if mCenter >= czLeft and mCenter <= czRight then
                    lastArchShot = tick()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                    StatusLabel.Text = "🏹 Идеальный выстрел!"
                end
            end
        end
    end)
end)

-- ==========================================
-- ESP
-- ==========================================
createHeader("--- ESP ---")
local EspBtn = createButton("ESP: ВЫКЛ", Color3.fromRGB(255, 150, 150))
EspBtn.MouseButton1Click:Connect(function()
    isESP = not isESP
    toggleBtn(EspBtn, isESP, "ESP: ВКЛ", "ESP: ВЫКЛ", Color3.fromRGB(100,255,100), Color3.fromRGB(255,150,150))
    if isESP then task.spawn(function()
        while isESP do
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local c = p.Character
                    local vip = false
                    pcall(function() vip = p.Data.DeveloperProducts.VIPOwned.Value end)
                    local rt, col = p.Name, Color3.fromRGB(255,255,255)
                    if vip then rt = "⭐ VIP: "..p.Name; col = Color3.fromRGB(255, 215, 0) end
                    local bb = c:FindFirstChild("ScriptHubESP")
                    if not bb then bb = Instance.new("BillboardGui", c); bb.Name = "ScriptHubESP" end
                    bb.Adornee = c.HumanoidRootPart
                    bb.Size = UDim2.new(0, 200, 0, 30); bb.StudsOffset = Vector3.new(0, 5, 0); bb.AlwaysOnTop = true
                    local txt = bb:FindFirstChild("Txt")
                    if not txt then txt = Instance.new("TextLabel", bb); txt.Name = "Txt"; txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1 end
                    txt.TextStrokeTransparency = 0; txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 14; txt.Text = rt; txt.TextColor3 = col
                    local hl = c:FindFirstChild("ScriptHubHL")
                    if not hl then hl = Instance.new("Highlight", c); hl.Name = "ScriptHubHL" end
                    hl.Adornee = c; hl.FillColor = col; hl.OutlineColor = Color3.fromRGB(255,255,255)
                    hl.FillTransparency = 0.5; hl.OutlineTransparency = 0
                end
            end
            task.wait(1)
        end
    end) else
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local bb = p.Character:FindFirstChild("ScriptHubESP"); if bb then bb:Destroy() end
                local hl = p.Character:FindFirstChild("ScriptHubHL"); if hl then hl:Destroy() end
            end
        end
    end
end)

-- ==========================================
-- ИНФО-ТАБЛИЦА (КНОПКА)
-- ==========================================
createHeader("--- ИНФО-ТАБЛИЦА ---")
local infoBtn = createButton("📊 Открыть инфо-таблицу", Color3.fromRGB(150, 200, 255))
infoBtn.MouseButton1Click:Connect(function()
    createInfoTable()
    StatusLabel.Text = "Инфо-таблица открыта"
end)

-- ==========================================
-- СИСТЕМА
-- ==========================================
createHeader("--- СИСТЕМА ---")
local UnloadBtn = createButton("ВЫГРУЗИТЬ СКРИПТ", Color3.fromRGB(255, 50, 50))
UnloadBtn.MouseButton1Click:Connect(function()
    isESP, isAutoArchery = false, false
    if InfoTableGui then InfoTableGui:Destroy(); InfoTableGui = nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local bb = p.Character:FindFirstChild("ScriptHubESP"); if bb then bb:Destroy() end
            local hl = p.Character:FindFirstChild("ScriptHubHL"); if hl then hl:Destroy() end
        end
    end
    task.wait(0.2)
    if ScreenGui then ScreenGui:Destroy() end
end)

print("[ScriptHub] ✅ v21.18 FULL SCRIPT (Clean ESP) загружено.")
