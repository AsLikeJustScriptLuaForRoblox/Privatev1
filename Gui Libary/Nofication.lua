local library = {}
library.DefaultColor = Color3.fromRGB(56, 207, 154)

local TweenService = game:GetService("TweenService")

-- Function to apply UICorner
local function applyCorner(gui)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = gui
end

-- Notification function
function library:Notification(Info)
    Info.Text = Info.Text or "Notification"
    Info.Title = Info.Title or "Title"
    Info.Duration = Info.Duration or 5

    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "NotificationUI"
    notificationGui.Parent = game:GetService("CoreGui")

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "NotificationFrame"
    notificationFrame.BackgroundColor3 = library.DefaultColor
    notificationFrame.Position = UDim2.new(0.5, -125, 1.2, 0) -- Start off-screen (below)
    notificationFrame.Size = UDim2.new(0, 250, 0, 70)
    notificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    notificationFrame.Parent = notificationGui
    applyCorner(notificationFrame)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = Info.Title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Parent = notificationFrame

    local notificationText = Instance.new("TextLabel")
    notificationText.Name = "NotificationText"
    notificationText.Font = Enum.Font.Gotham
    notificationText.Text = Info.Text
    notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationText.TextSize = 14
    notificationText.BackgroundTransparency = 1
    notificationText.Position = UDim2.new(0, 0, 0, 30)
    notificationText.Size = UDim2.new(1, 0, 0, 40)
    notificationText.Parent = notificationFrame

    -- Show animation (moving from below)
    TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -125, 0.9, 0) -- Final position
    }):Play()

    -- Fade out and destroy after duration
    task.delay(Info.Duration, function()
        -- Fade out animation
        TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -125, 1.2, 0), -- Move back below the screen
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            TextTransparency = 1
        }):Play()
        TweenService:Create(notificationText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            TextTransparency = 1
        }):Play()

        -- Destroy after animation
        task.delay(0.5, function()
            notificationGui:Destroy()
        end)
    end)
end

return library
