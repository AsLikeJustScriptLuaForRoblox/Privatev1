function library:Notification(NotificationInfo)
    NotificationInfo.Title = NotificationInfo.Title or "Notification Title"
    NotificationInfo.Text = NotificationInfo.Text or "This is a notification."
    NotificationInfo.Duration = NotificationInfo.Duration or 5
    NotificationInfo.Color = NotificationInfo.Color or library.DefaultColor

    -- Create Notification Text
    local notificationText = Instance.new("TextLabel")
    notificationText.Name = "NotificationText"
    notificationText.ClipsDescendants = true
    notificationText.Font = Enum.Font.GothamBold
    notificationText.Text = NotificationInfo.Text
    notificationText.TextColor3 = Color3.fromRGB(214, 214, 214)
    notificationText.TextSize = 14
    notificationText.BackgroundColor3 = Color3.fromRGB(29, 29, 29)
    notificationText.BorderSizePixel = 0
    notificationText.Position = UDim2.fromScale(0, 0.954)
    notificationText.Size = UDim2.fromOffset(0, 38)
    notificationText.Parent = Holder

    -- Create Notification Title
    local notificationTitle = Instance.new("TextLabel")
    notificationTitle.Name = "NotificationTitle"
    notificationTitle.Font = Enum.Font.GothamBold
    notificationTitle.Text = NotificationInfo.Title
    notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationTitle.TextSize = 16
    notificationTitle.BackgroundTransparency = 1
    notificationTitle.Position = UDim2.fromScale(0.05, 0.2)
    notificationTitle.Size = UDim2.fromScale(0.9, 0.3)
    notificationTitle.Parent = notificationText

    -- Outer Frame for Progress Bar
    local outerFrame = Instance.new("Frame")
    outerFrame.Name = "OuterFrame"
    outerFrame.AnchorPoint = Vector2.new(0, 1)
    outerFrame.BackgroundColor3 = NotificationInfo.Color
    outerFrame.BorderSizePixel = 0
    outerFrame.Position = UDim2.fromScale(0, 1)
    outerFrame.Size = UDim2.new(1, 0, 0, 3)
    outerFrame.ZIndex = 2
    outerFrame.Parent = notificationText

    -- Notification UI Corner
    local notificationUICorner = Instance.new("UICorner")
    notificationUICorner.Name = "NotificationUICorner"
    notificationUICorner.CornerRadius = UDim.new(0, 4)
    notificationUICorner.Parent = notificationText

    -- Inner Frame for Background
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "InnerFrame"
    innerFrame.AnchorPoint = Vector2.new(0, 1)
    innerFrame.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    innerFrame.BorderSizePixel = 0
    innerFrame.Position = UDim2.fromScale(0, 1)
    innerFrame.Size = UDim2.new(1, 0, 0, 3)
    innerFrame.Parent = notificationText

    -- Tween Animations
    coroutine.wrap(function()
        -- Tween for Notification Text (Slide In)
        local InTween = TweenService:Create(notificationText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, notificationText.TextBounds.X + 20, 0, 38)})
        InTween:Play()
        InTween.Completed:Wait()

        -- Tween for Notification Title (Fade In)
        local TitleTween = TweenService:Create(notificationTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
        TitleTween:Play()

        -- Progress Bar Animation
        local LineTween = TweenService:Create(outerFrame, TweenInfo.new(NotificationInfo.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 3)})
        LineTween:Play()
        LineTween.Completed:Wait()

        -- Tween for Notification Text (Slide Out)
        local OutTween = TweenService:Create(notificationText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(0, 0, 0, 38)})
        OutTween:Play()
        OutTween.Completed:Wait()

        -- Cleanup
        notificationText:Destroy()
    end)()
end
