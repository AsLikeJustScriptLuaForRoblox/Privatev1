local library = {}
library.Flags = {}
library.DefaultColor = Color3.fromRGB(56, 207, 154)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Rounded corner value
local CornerRadius = UDim.new(0, 10)

-- Destroy duplicate UIs
for _,v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "Revenant" then
        v:Destroy()
    end
end

-- Utility function
function library:GetXY(GuiObject)
	local Max, May = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	local Px, Py = math.clamp(Mouse.X - GuiObject.AbsolutePosition.X, 0, Max), math.clamp(Mouse.Y - GuiObject.AbsolutePosition.Y, 0, May)
	return Px/Max, Py/May
end

-- Window toggle
function library:Toggle()
    for _,v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "Revenant" then
            v.Enabled = not v.Enabled
        end
    end
end

-- Function to apply UICorner
local function applyCorner(gui)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = CornerRadius
    corner.Parent = gui
end

-- Add delay before window creation
local function delayExecution(seconds, callback)
    task.delay(seconds, callback)
end

-- Window creation
function library:Window(Info)
    Info.Text = Info.Text or "Revenant"
    local Pos = 0.05

    for _,v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "Revenant" then
            Pos = Pos + 0.12
        end
    end

    local revenant = Instance.new("ScreenGui")
    revenant.Name = "Revenant"
    revenant.Parent = game:GetService("CoreGui")

    local WindowOpened = Instance.new("BoolValue", revenant)
    WindowOpened.Value = true

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
    topbar.Position = UDim2.fromScale(Pos, 1.2) -- Start below the screen
    topbar.Size = UDim2.fromOffset(225, 38)
    topbar.Parent = revenant
    applyCorner(topbar)

    local backgroundFrame = Instance.new("Frame")
    backgroundFrame.Name = "BackgroundFrame"
    backgroundFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    backgroundFrame.Position = UDim2.fromScale(0, 1)
    backgroundFrame.Size = UDim2.fromOffset(225, 0)
    backgroundFrame.ClipsDescendants = true
    backgroundFrame.Parent = topbar
    applyCorner(backgroundFrame)

    local windowText = Instance.new("TextLabel")
    windowText.Name = "WindowText"
    windowText.Font = Enum.Font.GothamBold
    windowText.Text = Info.Text
    windowText.TextColor3 = Color3.fromRGB(214, 214, 214)
    windowText.TextSize = 14
    windowText.BackgroundTransparency = 1
    windowText.Size = UDim2.fromOffset(225, 38)
    windowText.Parent = topbar

    local close = Instance.new("ImageButton")
    close.Name = "Close"
    close.Image = "rbxassetid://7733717447"
    close.BackgroundTransparency = 1
    close.Position = UDim2.fromScale(0.876, 0.263)
    close.Size = UDim2.fromOffset(17, 17)
    close.Parent = topbar

    -- Add open/close animation
    close.MouseButton1Click:Connect(function()
        WindowOpened.Value = not WindowOpened.Value
        backgroundFrame.ClipsDescendants = not WindowOpened.Value

        if WindowOpened.Value then
            backgroundFrame.Visible = true
            backgroundFrame.Size = UDim2.new(0, 225, 0, 0)
            backgroundFrame.BackgroundTransparency = 1
            TweenService:Create(backgroundFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 225, 0, 150),
                BackgroundTransparency = 0
            }):Play()
        else
            TweenService:Create(backgroundFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 225, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.delay(0.3, function() backgroundFrame.Visible = false end)
        end

        TweenService:Create(close, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            Rotation = WindowOpened.Value and 0 or 180
        }):Play()
    end)

    -- Smooth animation from below, with delay
    delayExecution(1, function() -- Delay of 1 second
        TweenService:Create(topbar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(Pos, 0.1) -- Final position
        }):Play()
    end)

    return {}
end

return library
