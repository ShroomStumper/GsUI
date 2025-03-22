local GuiLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Name = "GuiLib"
gui.Parent = game.CoreGui

if game.CoreGui:FindFirstChild("GuiLib") then
    game.CoreGui:FindFirstChild("GuiLib"):Destroy()
end

local loader = Instance.new("Frame")
loader.Size = UDim2.new(1, 0, 1, 0)
loader.BackgroundColor3 = Color3.new(0, 0, 0)
loader.Parent = gui

local loaderText = Instance.new("TextLabel")
loaderText.Text = "Loading..."
loaderText.Size = UDim2.new(0, 200, 0, 50)
loaderText.Position = UDim2.new(0.5, -100, 0.5, -25)
loaderText.Parent = loader

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
main.Parent = gui

local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
title.Parent = main

local titleText = Instance.new("TextLabel")
titleText.Text = "GuiLib"
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.Parent = title

local dragging
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.Position = UDim2.new(0, 0, 0, 30)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabBar
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local tabs = {}
local activeTab

function GuiLib.AddTab(name)
    local button = Instance.new("TextButton")
    button.Text = name
    button.Size = UDim2.new(0, 100, 1, 0)
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button.Parent = tabBar

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -60)
    content.Position = UDim2.new(0, 0, 0, 60)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Parent = content
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    button.MouseButton1Click:Connect(function()
        GuiLib.ShowTab(name)
    end)

    table.insert(tabs, {name = name, button = button, content = content})
    return content
end

function GuiLib.ShowTab(name)
    for _, tab in pairs(tabs) do
        if tab.name == name then
            tab.button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
            tab.content.Visible = true
            activeTab = tab
        else
            tab.button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            tab.content.Visible = false
        end
    end
end

function GuiLib.AddCheckbox(tab, label, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = tab
    container.LayoutOrder = #tab:GetChildren()

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 5, 0, 5)
    box.BackgroundColor3 = default and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    box.Parent = container

    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(1, -30, 0, 30)
    text.Position = UDim2.new(0, 30, 0, 0)
    text.Parent = container

    local value = default
    box.MouseButton1Click:Connect(function()
        value = not value
        box.BackgroundColor3 = value and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        callback(value)
    end)

    return {
        GetValue = function() return value end,
        SetValue = function(newValue)
            value = newValue
            box.BackgroundColor3 = value and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        end
    }
end

function GuiLib.AddSlider(tab, label, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = tab
    container.LayoutOrder = #tab:GetChildren()

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0, 200, 0, 20)
    slider.Position = UDim2.new(0, 0, 0, 5)
    slider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    slider.Parent = container

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
    fill.Parent = slider

    local text = Instance.new("TextLabel")
    text.Text = label .. ": " .. default
    text.Size = UDim2.new(0, 100, 0, 30)
    text.Position = UDim2.new(0, 205, 0, 0)
    text.Parent = container

    local value = default
    local dragging = false

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local relativeX = mousePos.X - slider.AbsolutePosition.X
            local percent = math.clamp(relativeX / slider.AbsoluteSize.X, 0, 1)
            value = min + percent * (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            text.Text = label .. ": " .. math.floor(value)
            callback(value)
        end
    end)

    return {
        GetValue = function() return value end,
        SetValue = function(newValue)
            value = newValue
            local percent = (value - min) / (max - min)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            text.Text = label .. ": " .. math.floor(value)
        end
    }
end

local notifications = {}

function GuiLib.Notify(message)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 200, 0, 50)
    notif.Position = UDim2.new(1, -210, 1, -60 - (#notifications * 60))
    notif.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    notif.BackgroundTransparency = 1
    notif.Parent = gui

    local text = Instance.new("TextLabel")
    text.Text = message
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Parent = notif

    table.insert(notifications, notif)
    TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()

    task.wait(3)
    TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)

    notif:Destroy()
    table.remove(notifications, 1)

    for i, n in pairs(notifications) do
        n.Position = UDim2.new(1, -210, 1, -60 - (i * 60))
    end
end

function GuiLib.HideLoader()
    loader:Destroy()
end

return GuiLib
