local library = {}
library.Flags = {}
library.DefaultColor = Color3.fromRGB(56, 207, 154)

local TweenService = game:GetService("TweenService")

-- Notification function
function library:Notification(Info)
    Info = Info or {}
    Info.Title = Info.Title or "Notification"
    Info.Text = Info.Text or "This is a notification."
    Info.Duration = Info.Duration or 5 -- Default duration (in seconds)

    -- Create ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "NotificationGui"
    gui.Parent = game:GetService("CoreGui")

    -- Create Notification Frame
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(0, 300, 0, 100)
    frame.Position = UDim2.new(0.5, -150, 1, -120) -- Start off-screen
    frame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Parent = gui

    -- Add UICorner for rounded edges
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    -- Add Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = Info.Title
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0.4, 0)
    title.Parent = frame

    -- Add Text
    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.Text = Info.Text
    text.Font = Enum.Font.Gotham
    text.TextSize = 14
    text.TextColor3 = Color3.fromRGB(200, 200, 200)
    text.BackgroundTransparency = 1
    text.Position = UDim2.new(0, 0, 0.4, 0)
    text.Size = UDim2.new(1, 0, 0.6, 0)
    text.Parent = frame

    -- Slide-in animation
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.8, 0) -- Move into view
    }):Play()

    -- Auto-destroy after the duration
    task.delay(Info.Duration, function()
        -- Slide-out animation
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -150, 1, -120) -- Move out of view
        }):Play()

        -- Wait for animation to finish before destroying
        task.delay(0.5, function()
            gui:Destroy()
        end)
    end)
end

return library
