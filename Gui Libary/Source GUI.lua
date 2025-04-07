--[[
DeltaLib UI Library
A customizable UI library for Roblox with dark neon red theme
Features:
- Moveable on PC and Android
- Tabs with horizontal scrolling
- Sections with vertical scrolling
- Minimize functionality
- Enhanced dropdown menu
- Labels, buttons, toggles, sliders, dropdowns, and textboxes
- Responsive design
- User Avatar Icon
- Text scaling for all UI elements
- Comprehensive error handling
]]

local DeltaLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

-- Error handling utility function
local function SafeCall(func, ...)
    if type(func) ~= "function" then return nil end
    
    local success, result = pcall(func, ...)
    if not success then
        warn("DeltaLib Error: " .. tostring(result))
        return nil
    end
    return result
end

-- Colors
local Colors = {
    Background = Color3.fromRGB(25, 25, 25),
    DarkBackground = Color3.fromRGB(15, 15, 15),
    LightBackground = Color3.fromRGB(35, 35, 35),
    NeonRed = Color3.fromRGB(255, 0, 60),
    DarkNeonRed = Color3.fromRGB(200, 0, 45),
    LightNeonRed = Color3.fromRGB(255, 50, 90),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(200, 200, 200),
    Border = Color3.fromRGB(50, 50, 50)
}

-- Text Scaling System
local TextScaling = {
    BaseResolution = Vector2.new(1920, 1080), -- Base resolution for scaling
    MinTextSize = 8, -- Minimum text size
    MaxTextSize = 36, -- Maximum text size
    TextElements = {}, -- Store all text elements for updating
    BaseTextSizes = {}, -- Store original text sizes
    Enabled = true -- Toggle for text scaling
}

-- Function to safely handle errors
local function SafeCallback(callback, ...)
    if type(callback) ~= "function" then return end

    local success, result = pcall(callback, ...)
    if not success then
        warn("DeltaLib: Callback error: " .. tostring(result))
    end
    return success, result
end

-- Function to update text scale for a specific element
local function UpdateTextScale(textElement)
    if not TextScaling.Enabled or not textElement then return end
    
    -- Check if the element still exists and is valid
    local success, result = pcall(function()
        if not textElement.Parent then return false end
        if not TextScaling.TextElements[textElement] then return false end
        
        local baseSize = TextScaling.BaseTextSizes[textElement] or textElement.TextSize
        local gui = textElement:FindFirstAncestorOfClass("ScreenGui")

        if gui then
            local screenSize = gui.AbsoluteSize
            local scaleFactor = math.min(
                screenSize.X / TextScaling.BaseResolution.X,
                screenSize.Y / TextScaling.BaseResolution.Y
            )
            
            local newSize = math.clamp(
                math.floor(baseSize * scaleFactor),
                TextScaling.MinTextSize,
                TextScaling.MaxTextSize
            )
            
            textElement.TextSize = newSize
            return true
        end
        return false
    end)
    
    if not success then
        -- Clean up references to problematic elements
        TextScaling.TextElements[textElement] = nil
        TextScaling.BaseTextSizes[textElement] = nil
        warn("DeltaLib: Error updating text scale: " .. tostring(result))
    end
end

-- Function to register a text element for scaling
local function RegisterTextElement(textElement, baseSize)
    if not textElement then return end
    
    local success, result = pcall(function()
        if not (textElement:IsA("TextLabel") or textElement:IsA("TextButton") or textElement:IsA("TextBox")) then
            return false
        end
        
        baseSize = baseSize or textElement.TextSize
        TextScaling.TextElements[textElement] = true
        TextScaling.BaseTextSizes[textElement] = baseSize

        -- Apply initial scaling
        UpdateTextScale(textElement)
        return true
    end)
    
    if not success then
        warn("DeltaLib: Error registering text element: " .. tostring(result))
    end
end

-- Function to update all registered text elements
local function UpdateAllTextScales()
    if not TextScaling.Enabled then return end

    for textElement, _ in pairs(TextScaling.TextElements) do
        pcall(function()
            if textElement and textElement.Parent then
                UpdateTextScale(textElement)
            else
                -- Clean up references to destroyed elements
                TextScaling.TextElements[textElement] = nil
                TextScaling.BaseTextSizes[textElement] = nil
            end
        end)
    end
end

-- Function to scan and register all text elements in a parent
local function RegisterAllTextElements(parent)
    if not parent then return end
    
    pcall(function()
        for _, descendant in ipairs(parent:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                RegisterTextElement(descendant)
            end
        end

        -- Also register any future text elements
        parent.DescendantAdded:Connect(function(descendant)
            pcall(function()
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                    RegisterTextElement(descendant)
                end
            end)
        end)
    end)
end

-- Improved Draggable Function with Delta Movement
local function MakeDraggable(frame, dragArea)
    if not frame or not dragArea then return end
    
    local dragToggle = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        pcall(function()
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end)
    end

    pcall(function()
        dragArea.InputBegan:Connect(function(input)
            pcall(function()
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragToggle = true
                    dragStart = input.Position
                    startPos = frame.Position
                    
                    -- Track when input ends
                    input.Changed:Connect(function()
                        pcall(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragToggle = false
                            end
                        end)
                    end)
                end
            end)
        end)

        dragArea.InputChanged:Connect(function(input)
            pcall(function()
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput = input
                end
            end)
        end)

        UserInputService.InputChanged:Connect(function(input)
            pcall(function()
                if input == dragInput and dragToggle then
                    updateInput(input)
                end
            end)
        end)
    end)
end

-- Get Player Avatar
local function GetPlayerAvatar(userId, size)
    local success, result = pcall(function()
        size = size or "420x420"
        return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=" .. size:split("x")[1] .. "&height=" .. size:split("x")[2] .. "&format=png"
    end)
    
    if success then
        return result
    else
        warn("DeltaLib: Error getting player avatar: " .. tostring(result))
        return "rbxassetid://0" -- Default blank image
    end
end

-- Create UI Elements
function DeltaLib:CreateWindow(title, size)
    local Window = {}
    size = size or UDim2.new(0, 500, 0, 350)

    -- Main GUI
    local DeltaLibGUI = Instance.new("ScreenGui")
    DeltaLibGUI.Name = "DeltaLibGUI"
    DeltaLibGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    DeltaLibGUI.ResetOnSpawn = false

    -- Try to parent to CoreGui if possible (for exploits)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(DeltaLibGUI)
            DeltaLibGUI.Parent = CoreGui
        elseif gethui then
            DeltaLibGUI.Parent = gethui()
        else
            DeltaLibGUI.Parent = CoreGui
        end
    end)

    if not DeltaLibGUI.Parent then
        pcall(function()
            DeltaLibGUI.Parent = Player:WaitForChild("PlayerGui")
        end)
        
        if not DeltaLibGUI.Parent then
            warn("DeltaLib: Failed to parent GUI to PlayerGui or CoreGui")
            DeltaLibGUI.Parent = game:GetService("StarterGui")
        end
    end

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = DeltaLibGUI

    -- Store MainFrame in Window for access
    Window.MainFrame = MainFrame

    -- Add rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame

    -- Add shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 35, 1, 35)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Colors.NeonRed
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Colors.DarkBackground
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 6)
    TitleBarCorner.Parent = TitleBar

    local TitleBarCover = Instance.new("Frame")
    TitleBarCover.Name = "TitleBarCover"
    TitleBarCover.Size = UDim2.new(1, 0, 0.5, 0)
    TitleBarCover.Position = UDim2.new(0, 0, 0.5, 0)
    TitleBarCover.BackgroundColor3 = Colors.DarkBackground
    TitleBarCover.BorderSizePixel = 0
    TitleBarCover.Parent = TitleBar

    -- User Avatar
    local AvatarContainer = Instance.new("Frame")
    AvatarContainer.Name = "AvatarContainer"
    AvatarContainer.Size = UDim2.new(0, 24, 0, 24)
    AvatarContainer.Position = UDim2.new(0, 5, 0, 3)
    AvatarContainer.BackgroundColor3 = Colors.NeonRed
    AvatarContainer.BorderSizePixel = 0
    AvatarContainer.Parent = TitleBar

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarContainer

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "AvatarImage"
    AvatarImage.Size = UDim2.new(1, -2, 1, -2)
    AvatarImage.Position = UDim2.new(0, 1, 0, 1)
    AvatarImage.BackgroundTransparency = 1
    
    -- Safely get player avatar with error handling
    pcall(function()
        AvatarImage.Image = GetPlayerAvatar(Player.UserId, "100x100")
    end)
    
    AvatarImage.Parent = AvatarContainer

    local AvatarImageCorner = Instance.new("UICorner")
    AvatarImageCorner.CornerRadius = UDim.new(1, 0)
    AvatarImageCorner.Parent = AvatarImage

    -- Username
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Name = "UsernameLabel"
    UsernameLabel.Size = UDim2.new(0, 150, 1, 0)
    UsernameLabel.Position = UDim2.new(0, 34, 0, 0)
    UsernameLabel.BackgroundTransparency = 1
    
    -- Safely get player name with error handling
    pcall(function()
        UsernameLabel.Text = Player.Name
    end)
    
    UsernameLabel.TextColor3 = Colors.Text
    UsernameLabel.TextSize = 14
    UsernameLabel.Font = Enum.Font.GothamSemibold
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.Parent = TitleBar

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 190, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Delta UI"
    TitleLabel.TextColor3 = Colors.NeonRed
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.Parent = TitleBar

    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
    MinimizeButton.Position = UDim2.new(1, -54, 0, 3) -- Position it to the left of the close button
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Text = "−" -- Minus symbol
    MinimizeButton.TextColor3 = Colors.Text
    MinimizeButton.TextSize = 16
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = TitleBar

    pcall(function()
        MinimizeButton.MouseEnter:Connect(function()
            MinimizeButton.TextColor3 = Colors.NeonRed
        end)

        MinimizeButton.MouseLeave:Connect(function()
            MinimizeButton.TextColor3 = Colors.Text
        end)
    end)

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -27, 0, 3)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Colors.Text
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar

    pcall(function()
        CloseButton.MouseEnter:Connect(function()
            CloseButton.TextColor3 = Colors.NeonRed
        end)

        CloseButton.MouseLeave:Connect(function()
            CloseButton.TextColor3 = Colors.Text
        end)

        CloseButton.MouseButton1Click:Connect(function()
            pcall(function()
                DeltaLibGUI:Destroy()
            end)
        end)
    end)

    -- Make window draggable with improved function
    MakeDraggable(MainFrame, TitleBar)

    -- Container for tabs with horizontal scrolling
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 35)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundColor3 = Colors.LightBackground
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame

    -- Left Scroll Button
    local LeftScrollButton = Instance.new("TextButton")
    LeftScrollButton.Name = "LeftScrollButton"
    LeftScrollButton.Size = UDim2.new(0, 25, 0, 35)
    LeftScrollButton.Position = UDim2.new(0, 0, 0, 0)
    LeftScrollButton.BackgroundColor3 = Colors.DarkBackground
    LeftScrollButton.BorderSizePixel = 0
    LeftScrollButton.Text = "←"
    LeftScrollButton.TextColor3 = Colors.Text
    LeftScrollButton.TextSize = 18
    LeftScrollButton.Font = Enum.Font.GothamBold
    LeftScrollButton.ZIndex = 3
    LeftScrollButton.Parent = TabContainer

    -- Right Scroll Button
    local RightScrollButton = Instance.new("TextButton")
    RightScrollButton.Name = "RightScrollButton"
    RightScrollButton.Size = UDim2.new(0, 25, 0, 35)
    RightScrollButton.Position = UDim2.new(1, -25, 0, 0)
    RightScrollButton.BackgroundColor3 = Colors.DarkBackground
    RightScrollButton.BorderSizePixel = 0
    RightScrollButton.Text = "→"
    RightScrollButton.TextColor3 = Colors.Text
    RightScrollButton.TextSize = 18
    RightScrollButton.Font = Enum.Font.GothamBold
    RightScrollButton.ZIndex = 3
    RightScrollButton.Parent = TabContainer

    -- Tab Scroll Frame
    local TabScrollFrame = Instance.new("ScrollingFrame")
    TabScrollFrame.Name = "TabScrollFrame"
    TabScrollFrame.Size = UDim2.new(1, -50, 1, 0) -- Leave space for scroll buttons
    TabScrollFrame.Position = UDim2.new(0, 25, 0, 0) -- Center between scroll buttons
    TabScrollFrame.BackgroundTransparency = 1
    TabScrollFrame.BorderSizePixel = 0
    TabScrollFrame.ScrollBarThickness = 0 -- Hide scrollbar
    TabScrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
    TabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
    TabScrollFrame.Parent = TabContainer

    -- Tab Buttons Container
    local TabButtons = Instance.new("Frame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, 0, 1, 0)
    TabButtons.BackgroundTransparency = 1
    TabButtons.Parent = TabScrollFrame

    local TabButtonsLayout = Instance.new("UIListLayout")
    TabButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
    TabButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabButtonsLayout.Padding = UDim.new(0, 5)
    TabButtonsLayout.Parent = TabButtons

    -- Add padding to the first tab
    local TabButtonsPadding = Instance.new("UIPadding")
    TabButtonsPadding.PaddingLeft = UDim.new(0, 5)
    TabButtonsPadding.PaddingRight = UDim.new(0, 5)
    TabButtonsPadding.Parent = TabButtons

    -- Update tab scroll canvas size when tabs change
    pcall(function()
        TabButtonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pcall(function()
                TabScrollFrame.CanvasSize = UDim2.new(0, TabButtonsLayout.AbsoluteContentSize.X, 0, 0)
            end)
        end)
    end)

    -- Scroll buttons functionality
    local scrollAmount = 150 -- Amount to scroll in pixels
    local scrollDuration = 0.3 -- Duration of scroll animation

    -- Function to scroll with animation
    local function ScrollTabs(direction)
        pcall(function()
            local currentPos = TabScrollFrame.CanvasPosition.X
            local targetPos
            
            if direction == "left" then
                targetPos = math.max(currentPos - scrollAmount, 0)
            else
                local maxScroll = TabScrollFrame.CanvasSize.X.Offset - TabScrollFrame.AbsoluteSize.X
                targetPos = math.min(currentPos + scrollAmount, maxScroll)
            end
            
            -- Create a smooth scrolling animation
            local tweenInfo = TweenInfo.new(scrollDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local tween = TweenService:Create(TabScrollFrame, tweenInfo, {CanvasPosition = Vector2.new(targetPos, 0)})
            tween:Play()
        end)
    end

    -- Button hover effects
    pcall(function()
        LeftScrollButton.MouseEnter:Connect(function()
            pcall(function()
                TweenService:Create(LeftScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
            end)
        end)

        LeftScrollButton.MouseLeave:Connect(function()
            pcall(function()
                TweenService:Create(LeftScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkBackground}):Play()
            end)
        end)

        RightScrollButton.MouseEnter:Connect(function()
            pcall(function()
                TweenService:Create(RightScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
            end)
        end)

        RightScrollButton.MouseLeave:Connect(function()
            pcall(function()
                TweenService:Create(RightScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkBackground}):Play()
            end)
        end)
    end)

    -- Connect scroll buttons
    pcall(function()
        LeftScrollButton.MouseButton1Click:Connect(function()
            ScrollTabs("left")
        end)

        RightScrollButton.MouseButton1Click:Connect(function()
            ScrollTabs("right")
        end)
    end)

    -- Add continuous scrolling when holding the button
    local isScrollingLeft = false
    local isScrollingRight = false

    pcall(function()
        LeftScrollButton.MouseButton1Down:Connect(function()
            isScrollingLeft = true
            
            -- Initial scroll
            ScrollTabs("left")
            
            -- Continue scrolling while button is held
            spawn(function()
                local initialDelay = 0.5 -- Wait before starting continuous scroll
                wait(initialDelay)
                
                while isScrollingLeft do
                    ScrollTabs("left")
                    wait(0.2) -- Scroll interval
                end
            end)
        end)

        LeftScrollButton.MouseButton1Up:Connect(function()
            isScrollingLeft = false
        end)

        LeftScrollButton.MouseLeave:Connect(function()
            isScrollingLeft = false
        end)

        RightScrollButton.MouseButton1Down:Connect(function()
            isScrollingRight = true
            
            -- Initial scroll
            ScrollTabs("right")
            
            -- Continue scrolling while button is held
            spawn(function()
                local initialDelay = 0.5 -- Wait before starting continuous scroll
                wait(initialDelay)
                
                while isScrollingRight do
                    ScrollTabs("right")
                    wait(0.2) -- Scroll interval
                end
            end)
        end)

        RightScrollButton.MouseButton1Up:Connect(function()
            isScrollingRight = false
        end)

        RightScrollButton.MouseLeave:Connect(function()
            isScrollingRight = false
        end)
    end)

    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, 0, 1, -65)
    ContentContainer.Position = UDim2.new(0, 0, 0, 65)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- Track minimized state
    local isMinimized = false
    local originalSize = size

    -- Minimize/Restore function
    pcall(function()
        MinimizeButton.MouseButton1Click:Connect(function()
            pcall(function()
                isMinimized = not isMinimized
                
                if isMinimized then
                    -- Save current size before minimizing if it's been resized
                    originalSize = MainFrame.Size
                    
                    -- Minimize animation
                    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30)
                    }):Play()
                    
                    -- Hide content
                    ContentContainer.Visible = false
                    TabContainer.Visible = false
                    
                    -- Change minimize button to restore symbol
                    MinimizeButton.Text = "+"
                else
                    -- Restore animation
                    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = originalSize
                    }):Play()
                    
                    -- Show content (with slight delay to match animation)
                    task.delay(0.1, function()
                        ContentContainer.Visible = true
                        TabContainer.Visible = true
                    end)
                    
                    -- Change restore button back to minimize symbol
                    MinimizeButton.Text = "−"
                end
            end)
        end)
    end)

    -- Tab Management
    local Tabs = {}
    local SelectedTab = nil

    -- Create Tab Function
    function Window:CreateTab(tabName)
        local Tab = {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName.."Button"
        
        -- Safely get text size with error handling
        local textSize = pcall(function()
            return TextService:GetTextSize(tabName, 14, Enum.Font.GothamSemibold, Vector2.new(math.huge, 20)).X + 20
        end) and TextService:GetTextSize(tabName, 14, Enum.Font.GothamSemibold, Vector2.new(math.huge, 20)).X + 20 or 100
        
        TabButton.Size = UDim2.new(0, textSize, 1, -10)
        TabButton.Position = UDim2.new(0, 0, 0, 0)
        TabButton.BackgroundColor3 = Colors.DarkBackground
        TabButton.BorderSizePixel = 0
        TabButton.Text = tabName
        TabButton.TextColor3 = Colors.SubText
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Parent = TabButtons
        
        -- Register for text scaling
        RegisterTextElement(TabButton)
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 4)
        TabButtonCorner.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName.."Content"
        TabContent.Size = UDim2.new(1, -20, 1, -10)
        TabContent.Position = UDim2.new(0, 10, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 2
        TabContent.ScrollBarImageColor3 = Colors.NeonRed
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentLayout.Padding = UDim.new(0, 10)
        TabContentLayout.Parent = TabContent
        
        local TabContentPadding = Instance.new("UIPadding")
        TabContentPadding.PaddingTop = UDim.new(0, 5)
        TabContentPadding.PaddingBottom = UDim.new(0, 5)
        TabContentPadding.Parent = TabContent
        
        -- Auto-size the scrolling frame content
        pcall(function()
            TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                pcall(function()
                    TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 10)
                end)
            end)
        end)
        
        -- Tab Selection Logic
        pcall(function()
            TabButton.MouseButton1Click:Connect(function()
                pcall(function()
                    if SelectedTab then
                        -- Deselect current tab
                        SelectedTab.Button.BackgroundColor3 = Colors.DarkBackground
                        SelectedTab.Button.TextColor3 = Colors.SubText
                        SelectedTab.Content.Visible = false
                    end
                    
                    -- Select new tab
                    TabButton.BackgroundColor3 = Colors.NeonRed
                    TabButton.TextColor3 = Colors.Text
                    TabContent.Visible = true
                    SelectedTab = {Button = TabButton, Content = TabContent}
                    
                    -- Scroll to make the selected tab visible
                    local buttonPosition = TabButton.AbsolutePosition.X - TabScrollFrame.AbsolutePosition.X
                    local buttonEnd = buttonPosition + TabButton.AbsoluteSize.X
                    local viewportWidth = TabScrollFrame.AbsoluteSize.X
                    
                    if buttonPosition < 0 then
                        -- Button is to the left of the visible area
                        local targetPos = TabScrollFrame.CanvasPosition.X + buttonPosition - 10
                        TweenService:Create(TabScrollFrame, TweenInfo.new(0.3), {
                            CanvasPosition = Vector2.new(math.max(targetPos, 0), 0)
                        }):Play()
                    elseif buttonEnd > viewportWidth then
                        -- Button is to the right of the visible area
                        local targetPos = TabScrollFrame.CanvasPosition.X + (buttonEnd - viewportWidth) + 10
                        local maxScroll = TabScrollFrame.CanvasSize.X.Offset - viewportWidth
                        TweenService:Create(TabScrollFrame, TweenInfo.new(0.3), {
                            CanvasPosition = Vector2.new(math.min(targetPos, maxScroll), 0)
                        }):Play()
                    end
                end)
            end)
        end)
        
        -- Add to tabs table
        table.insert(Tabs, {Button = TabButton, Content = TabContent})
        
        -- If this is the first tab, select it
        if #Tabs == 1 then
            pcall(function()
                TabButton.BackgroundColor3 = Colors.NeonRed
                TabButton.TextColor3 = Colors.Text
                TabContent.Visible = true
                SelectedTab = {Button = TabButton, Content = TabContent}
            end)
        end
        
        -- Section Creation Function
        function Tab:CreateSection(sectionName)
            local Section = {}
            
            -- Section Container
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Name = sectionName.."Section"
            SectionContainer.Size = UDim2.new(1, 0, 0, 30) -- Will be resized based on content
            SectionContainer.BackgroundColor3 = Colors.LightBackground
            SectionContainer.BorderSizePixel = 0
            SectionContainer.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 4)
            SectionCorner.Parent = SectionContainer
            
            -- Section Title
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Size = UDim2.new(1, -10, 0, 25)
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = sectionName
            SectionTitle.TextColor3 = Colors.NeonRed
            SectionTitle.TextSize = 14
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionContainer
            
            -- Register for text scaling
            RegisterTextElement(SectionTitle)
            
            -- Section Content with Scrolling
            local SectionScrollFrame = Instance.new("ScrollingFrame")
            SectionScrollFrame.Name = "SectionScrollFrame"
            SectionScrollFrame.Size = UDim2.new(1, -20, 0, 100) -- Initial height, will be adjusted
            SectionScrollFrame.Position = UDim2.new(0, 10, 0, 25)
            SectionScrollFrame.BackgroundTransparency = 1
            SectionScrollFrame.BorderSizePixel = 0
            SectionScrollFrame.ScrollBarThickness = 2
            SectionScrollFrame.ScrollBarImageColor3 = Colors.NeonRed
            SectionScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated dynamically
            SectionScrollFrame.Parent = SectionContainer
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "SectionContent"
            SectionContent.Size = UDim2.new(1, 0, 0, 0) -- Will be resized based on content
            SectionContent.BackgroundTransparency = 1
            SectionContent.Parent = SectionScrollFrame
            
            local SectionContentLayout = Instance.new("UIListLayout")
            SectionContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionContentLayout.Padding = UDim.new(0, 8)
            SectionContentLayout.Parent = SectionContent
            
            -- Auto-size the section based on content
            pcall(function()
                SectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    pcall(function()
                        local contentHeight = SectionContentLayout.AbsoluteContentSize.Y
                        SectionContent.Size = UDim2.new(1, 0, 0, contentHeight)
                        
                        -- Update the canvas size for scrolling
                        SectionScrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
                        
                        -- Adjust the section height (capped at 200 for scrolling)
                        local newHeight = math.min(contentHeight, 200)
                        SectionScrollFrame.Size = UDim2.new(1, -20, 0, newHeight)
                        SectionContainer.Size = UDim2.new(1, 0, 0, newHeight + 35) -- +35 for the title
                    end)
                end)
            end)
            
            -- Label Creation Function
            function Section:AddLabel(labelText)
                local LabelContainer = Instance.new("Frame")
                LabelContainer.Name = "LabelContainer"
                LabelContainer.Size = UDim2.new(1, 0, 0, 20)
                LabelContainer.BackgroundTransparency = 1
                LabelContainer.Parent = SectionContent
                
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Size = UDim2.new(1, 0, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = labelText
                Label.TextColor3 = Colors.Text
                Label.TextSize = 14
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = LabelContainer
                
                -- Register for text scaling
                RegisterTextElement(Label)
                
                local LabelFunctions = {}
                
                function LabelFunctions:SetText(newText)
                    pcall(function()
                        Label.Text = newText
                    end)
                end
                
                return LabelFunctions
            end
            
            -- Button Creation Function
            function Section:AddButton(buttonText, callback)
                callback = callback or function() end
                
                local ButtonContainer = Instance.new("Frame")
                ButtonContainer.Name = "ButtonContainer"
                ButtonContainer.Size = UDim2.new(1, 0, 0, 30)
                ButtonContainer.BackgroundTransparency = 1
                ButtonContainer.Parent = SectionContent
                
                local Button = Instance.new("TextButton")
                Button.Name = "Button"
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.BackgroundColor3 = Colors.DarkBackground
                Button.BorderSizePixel = 0
                Button.Text = buttonText
                Button.TextColor3 = Colors.Text
                Button.TextSize = 14
                Button.Font = Enum.Font.Gotham
                Button.Parent = ButtonContainer
                
                -- Register for text scaling
                RegisterTextElement(Button)
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 4)
                ButtonCorner.Parent = Button
                
                -- Button Effects
                pcall(function()
                    Button.MouseEnter:Connect(function()
                        pcall(function()
                            Button.BackgroundColor3 = Colors.NeonRed
                        end)
                    end)
                    
                    Button.MouseLeave:Connect(function()
                        pcall(function()
                            Button.BackgroundColor3 = Colors.DarkBackground
                        end)
                    end)
                    
                    Button.MouseButton1Click:Connect(function()
                        SafeCallback(callback)
                    end)
                end)
                
                local ButtonFunctions = {}
                
                function ButtonFunctions:SetText(newText)
                    pcall(function()
                        Button.Text = newText
                    end)
                end
                
                return ButtonFunctions
            end
            
            -- Toggle Creation Function
            function Section:AddToggle(toggleText, default, callback)
                default = default or false
                callback = callback or function() end
                
                local ToggleContainer = Instance.new("Frame")
                ToggleContainer.Name = "ToggleContainer"
                ToggleContainer.Size = UDim2.new(1, 0, 0, 25)
                ToggleContainer.BackgroundTransparency = 1
                ToggleContainer.Parent = SectionContent
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = "ToggleLabel"
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = toggleText
                ToggleLabel.TextColor3 = Colors.Text
                ToggleLabel.TextSize = 14
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleContainer
                
                -- Register for text scaling
                RegisterTextElement(ToggleLabel)
                
                local ToggleButton = Instance.new("Frame")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Size = UDim2.new(0, 40, 0, 20)
                ToggleButton.Position = UDim2.new(1, -40, 0, 2)
                ToggleButton.BackgroundColor3 = Colors.DarkBackground
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Parent = ToggleContainer
                
                local ToggleButtonCorner = Instance.new("UICorner")
                ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
                ToggleButtonCorner.Parent = ToggleButton
                
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Name = "ToggleCircle"
                ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
                ToggleCircle.Position = UDim2.new(0, 2, 0, 2)
                ToggleCircle.BackgroundColor3 = Colors.Text
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Parent = ToggleButton
                
                local ToggleCircleCorner = Instance.new("UICorner")
                ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
                ToggleCircleCorner.Parent = ToggleCircle
                
                -- Make the entire container clickable
                local ToggleClickArea = Instance.new("TextButton")
                ToggleClickArea.Name = "ToggleClickArea"
                ToggleClickArea.Size = UDim2.new(1, 0, 1, 0)
                ToggleClickArea.BackgroundTransparency = 1
                ToggleClickArea.Text = ""
                ToggleClickArea.Parent = ToggleContainer
                
                -- Toggle State
                local Enabled = default
                
                -- Update toggle appearance based on state
                local function UpdateToggle()
                    pcall(function()
                        if Enabled then
                            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
                            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 22, 0, 2)}):Play()
                        else
                            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkBackground}):Play()
                            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
                        end
                    end)
                end
                
                -- Set initial state
                UpdateToggle()
                
                -- Toggle Logic
                pcall(function()
                    ToggleClickArea.MouseButton1Click:Connect(function()
                        pcall(function()
                            Enabled = not Enabled
                            UpdateToggle()
                            SafeCallback(callback, Enabled)
                        end)
                    end)
                end)
                
                local ToggleFunctions = {}
                
                function ToggleFunctions:SetState(state)
                    pcall(function()
                        Enabled = state
                        UpdateToggle()
                        SafeCallback(callback, Enabled)
                    end)
                end
                
                function ToggleFunctions:GetState()
                    return Enabled
                end
                
                return ToggleFunctions
            end
            
            -- Slider Creation Function - Improved for PC and Android
            function Section:AddSlider(sliderText, min, max, default, callback)
                min = min or 0
                max = max or 100
                default = default or min
                callback = callback or function() end
                
                local SliderContainer = Instance.new("Frame")
                SliderContainer.Name = "SliderContainer"
                SliderContainer.Size = UDim2.new(1, 0, 0, 45)
                SliderContainer.BackgroundTransparency = 1
                SliderContainer.Parent = SectionContent
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "SliderLabel"
                SliderLabel.Size = UDim2.new(1, 0, 0, 20)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = sliderText
                SliderLabel.TextColor3 = Colors.Text
                SliderLabel.TextSize = 14
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderContainer
                
                -- Register for text scaling
                RegisterTextElement(SliderLabel)
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Name = "SliderValue"
                SliderValue.Size = UDim2.new(0, 30, 0, 20)
                SliderValue.Position = UDim2.new(1, -30, 0, 0)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Text = tostring(default)
                SliderValue.TextColor3 = Colors.NeonRed
                SliderValue.TextSize = 14
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderContainer
                
                -- Register for text scaling
                RegisterTextElement(SliderValue)
                
                local SliderBackground = Instance.new("Frame")
                SliderBackground.Name = "SliderBackground"
                SliderBackground.Size = UDim2.new(1, 0, 0, 10)
                SliderBackground.Position = UDim2.new(0, 0, 0, 25)
                SliderBackground.BackgroundColor3 = Colors.DarkBackground
                SliderBackground.BorderSizePixel = 0
                SliderBackground.Parent = SliderContainer
                
                local SliderBackgroundCorner = Instance.new("UICorner")
                SliderBackgroundCorner.CornerRadius = UDim.new(1, 0)
                SliderBackgroundCorner.Parent = SliderBackground
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Name = "SliderFill"
                SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Colors.NeonRed
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBackground
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                local SliderButton = Instance.new("TextButton")
                SliderButton.Name = "SliderButton"
                SliderButton.Size = UDim2.new(1, 0, 1, 0)
                SliderButton.BackgroundTransparency = 1
                SliderButton.Text = ""
                SliderButton.Parent = SliderBackground
                
                -- Slider Logic
                local function UpdateSlider(value)
                    pcall(function()
                        value = math.clamp(value, min, max)
                        value = math.floor(value + 0.5) -- Round to nearest integer
                        
                        SliderValue.Text = tostring(value)
                        SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        SafeCallback(callback, value)
                    end)
                end
                
                -- Set initial value
                UpdateSlider(default)
                
                -- Improved Slider Interaction for PC and Android
                local isDragging = false
                
                pcall(function()
                    SliderButton.InputBegan:Connect(function(input)
                        pcall(function()
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                isDragging = true
                                
                                -- Calculate value directly from initial press position
                                local relativePos = input.Position.X - SliderBackground.AbsolutePosition.X
                                local percent = math.clamp(relativePos / SliderBackground.AbsoluteSize.X, 0, 1)
                                local value = min + (max - min) * percent
                                
                                UpdateSlider(value)
                            end
                        end)
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        pcall(function()
                            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                                isDragging = false
                            end
                        end)
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        pcall(function()
                            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                                -- Use delta movement for smoother control
                                local relativePos = input.Position.X - SliderBackground.AbsolutePosition.X
                                local percent = math.clamp(relativePos / SliderBackground.AbsoluteSize.X, 0, 1)
                                local value = min + (max - min) * percent
                                
                                UpdateSlider(value)
                            end
                        end)
                    end)
                end)
                
                local SliderFunctions = {}
                
                function SliderFunctions:SetValue(value)
                    pcall(function()
                        UpdateSlider(value)
                    end)
                end
                
                function SliderFunctions:GetValue()
                    return tonumber(SliderValue.Text)
                end
                
                return SliderFunctions
            end
            
            -- Dropdown Creation Function - Updated with the new implementation
            function Section:AddDropdown(dropdownText, options, default, callback)
                -- Error handling for options
                pcall(function()
                    if type(options) ~= "table" then
                        warn("DeltaLib: Dropdown options must be a table. Converting to table.")
                        if options == nil then
                            options = {}
                        else
                            options = {tostring(options)}
                        end
                    end
                    
                    -- Error handling for empty options
                    if #options == 0 then
                        warn("DeltaLib: Dropdown has no options. Adding placeholder.")
                        options = {"No options available"}
                    end
                    
                    -- Error handling for default value
                    default = default or options[1]
                    if not table.find(options, default) then
                        warn("DeltaLib: Default value not found in options. Using first option.")
                        default = options[1]
                    end
                    
                    -- Error handling for callback
                    if callback ~= nil and type(callback) ~= "function" then
                        warn("DeltaLib: Callback must be a function. Using empty function.")
                        callback = function() end
                    else
                        callback = callback or function() end
                    end
                end)
                
                local DropdownContainer = Instance.new("Frame")
                DropdownContainer.Name = "DropdownContainer"
                DropdownContainer.Size = UDim2.new(1, 0, 0, 40)
                DropdownContainer.BackgroundTransparency = 1
                DropdownContainer.Parent = SectionContent
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Name = "DropdownLabel"
                DropdownLabel.Size = UDim2.new(1, 0, 0, 20)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = dropdownText
                DropdownLabel.TextColor3 = Colors.Text
                DropdownLabel.TextSize = 14
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownContainer
                
                -- Register for text scaling
                RegisterTextElement(DropdownLabel)
                
                -- Main dropdown button with textbox for selected value
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Name = "DropdownButton"
                DropdownButton.Size = UDim2.new(1, 0, 0, 25)
                DropdownButton.Position = UDim2.new(0, 0, 0, 20)
                DropdownButton.BackgroundColor3 = Colors.DarkBackground
                DropdownButton.BorderSizePixel = 0
                DropdownButton.Text = ""
                DropdownButton.ClipsDescendants = true
                DropdownButton.Parent = DropdownContainer
                
                local DropdownButtonCorner = Instance.new("UICorner")
                DropdownButtonCorner.CornerRadius = UDim.new(0, 4)
                DropdownButtonCorner.Parent = DropdownButton
                
                -- Create a textbox for the selected value
                local SelectedTextBox = Instance.new("TextBox")
                SelectedTextBox.Name = "SelectedTextBox"
                SelectedTextBox.Size = UDim2.new(1, -50, 1, 0)
                SelectedTextBox.Position = UDim2.new(0, 10, 0, 0)
                SelectedTextBox.BackgroundTransparency = 1
                SelectedTextBox.Text = default
                SelectedTextBox.PlaceholderText = "..."
                SelectedTextBox.TextColor3 = Colors.Text
                SelectedTextBox.TextSize = 14
                SelectedTextBox.Font = Enum.Font.Gotham
                SelectedTextBox.TextXAlignment = Enum.TextXAlignment.Left
                SelectedTextBox.ClearTextOnFocus = false
                SelectedTextBox.TextEditable = false
                SelectedTextBox.Parent = DropdownButton
                
                -- Register for text scaling
                RegisterTextElement(SelectedTextBox)
                
                -- Dropdown toggle arrow
                local DropdownArrow = Instance.new("ImageLabel")
                DropdownArrow.Name = "DropdownArrow"
                DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
                DropdownArrow.Position = UDim2.new(1, -25, 0, 2)
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Image = "rbxassetid://6031094670"
                DropdownArrow.ImageColor3 = Colors.NeonRed
                DropdownArrow.Rotation = 270
                DropdownArrow.Parent = DropdownButton
                
                -- Dropdown options container
                local DropdownOptionsContainer = Instance.new("Frame")
                DropdownOptionsContainer.Name = "DropdownOptionsContainer"
                DropdownOptionsContainer.Size = UDim2.new(1, 0, 0, 0)
                DropdownOptionsContainer.Position = UDim2.new(0, 0, 1, 0)
                DropdownOptionsContainer.BackgroundTransparency = 1
                DropdownOptionsContainer.ClipsDescendants = true
                DropdownOptionsContainer.Parent = DropdownButton
                
                local DropdownScrollFrame = Instance.new("ScrollingFrame")
                DropdownScrollFrame.Name = "DropdownScrollFrame"
                DropdownScrollFrame.Size = UDim2.new(1, -4, 1, 0)
                DropdownScrollFrame.Position = UDim2.new(0, 2, 0, 0)
                DropdownScrollFrame.BackgroundTransparency = 1
                DropdownScrollFrame.BorderSizePixel = 0
                DropdownScrollFrame.ScrollBarThickness = 4
                DropdownScrollFrame.ScrollBarImageColor3 = Colors.NeonRed
                DropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                DropdownScrollFrame.Parent = DropdownOptionsContainer
                
                local DropdownOptionsLayout = Instance.new("UIListLayout")
                DropdownOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownOptionsLayout.Padding = UDim.new(0, 5)
                DropdownOptionsLayout.Parent = DropdownScrollFrame
                
                local DropdownOptionsPadding = Instance.new("UIPadding")
                DropdownOptionsPadding.PaddingLeft = UDim.new(0, 5)
                DropdownOptionsPadding.PaddingRight = UDim.new(0, 5)
                DropdownOptionsPadding.PaddingTop = UDim.new(0, 5)
                DropdownOptionsPadding.PaddingBottom = UDim.new(0, 5)
                DropdownOptionsPadding.Parent = DropdownScrollFrame
                
                -- Track dropdown state
                local isOpen = false
                
                -- Toggle dropdown function
                local function ToggleDropdown()
                    pcall(function()
                        isOpen = not isOpen
                        
                        -- Animate the dropdown arrow
                        TweenService:Create(DropdownArrow, TweenInfo.new(0.5), {
                            Rotation = isOpen and 90 or 270
                        }):Play()
                        
                        -- Animate the dropdown container
                        if isOpen then
                            -- Calculate height based on number of options (max 120px)
                            local optionsHeight = math.min(#options * 30 + 10, 120)
                            DropdownOptionsContainer:TweenSize(
                                UDim2.new(1, 0, 0, optionsHeight),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quart,
                                0.5,
                                true
                            )
                            DropdownButton:TweenSize(
                                UDim2.new(1, 0, 0, 25 + optionsHeight),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quart,
                                0.5,
                                true
                            )
                        else
                            DropdownOptionsContainer:TweenSize(
                                UDim2.new(1, 0, 0, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quart,
                                0.5,
                                true
                            )
                            DropdownButton:TweenSize(
                                UDim2.new(1, 0, 0, 25),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quart,
                                0.5,
                                true
                            )
                        end
                    end)
                end
                
                -- Create option buttons
                local OptionButtons = {}
                
                local function CreateOptionButton(option, index)
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = option.."Option"
                    OptionButton.Size = UDim2.new(1, 0, 0, 25)
                    OptionButton.BackgroundColor3 = Colors.DarkBackground
                    OptionButton.BorderSizePixel = 0
                    OptionButton.Text = ""
                    OptionButton.LayoutOrder = index
                    OptionButton.Parent = DropdownScrollFrame
                    
                    local OptionButtonCorner = Instance.new("UICorner")
                    OptionButtonCorner.CornerRadius = UDim.new(0, 4)
                    OptionButtonCorner.Parent = OptionButton
                    
                    local OptionText = Instance.new("TextLabel")
                    OptionText.Name = "OptionText"
                    OptionText.Size = UDim2.new(1, -10, 1, 0)
                    OptionText.Position = UDim2.new(0, 10, 0, 0)
                    OptionText.BackgroundTransparency = 1
                    OptionText.Text = option
                    OptionText.TextColor3 = Colors.Text
                    OptionText.TextSize = 14
                    OptionText.Font = Enum.Font.Gotham
                    OptionText.TextXAlignment = Enum.TextXAlignment.Left
                    OptionText.Parent = OptionButton
                    
                    -- Register for text scaling
                    RegisterTextElement(OptionText)
                    
                    -- Hover effect
                    pcall(function()
                        OptionButton.MouseEnter:Connect(function()
                            pcall(function()
                                TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                                    BackgroundColor3 = Colors.NeonRed
                                }):Play()
                            end)
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            pcall(function()
                                TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                                    BackgroundColor3 = Colors.DarkBackground
                                }):Play()
                            end)
                        end)
                        
                        -- Select option
                        OptionButton.MouseButton1Click:Connect(function()
                            pcall(function()
                                SelectedTextBox.Text = option
                                ToggleDropdown()
                                SafeCallback(callback, option)
                            end)
                        end)
                    end)
                    
                    return OptionButton
                end
                
                -- Create initial options
                pcall(function()
                    for i, option in ipairs(options) do
                        local optionButton = CreateOptionButton(option, i)
                        table.insert(OptionButtons, optionButton)
                        
                        -- Update canvas size
                        DropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, DropdownOptionsLayout.AbsoluteContentSize.Y + 10)
                    end
                end)
                
                -- Toggle dropdown when clicking the button
                pcall(function()
                    DropdownButton.MouseButton1Click:Connect(function()
                        ToggleDropdown()
                    end)
                end)
                
                -- Close dropdown when clicking elsewhere
                pcall(function()
                    UserInputService.InputBegan:Connect(function(input)
                        pcall(function()
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                local mousePos = UserInputService:GetMouseLocation()
                                if isOpen and not (mousePos.X >= DropdownButton.AbsolutePosition.X and 
                                                  mousePos.X <= DropdownButton.AbsolutePosition.X + DropdownButton.AbsoluteSize.X and
                                                  mousePos.Y >= DropdownButton.AbsolutePosition.Y and 
                                                  mousePos.Y <= DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y) then
                                    isOpen = false
                                    DropdownOptionsContainer:TweenSize(
                                        UDim2.new(1, 0, 0, 0),
                                        Enum.EasingDirection.Out,
                                        Enum.EasingStyle.Quart,
                                        0.5,
                                        true
                                    )
                                    DropdownButton:TweenSize(
                                        UDim2.new(1, 0, 0, 25),
                                        Enum.EasingDirection.Out,
                                        Enum.EasingStyle.Quart,
                                        0.5,
                                        true
                                    )
                                    TweenService:Create(DropdownArrow, TweenInfo.new(0.5), {
                                        Rotation = 270
                                    }):Play()
                                end
                            end
                        end)
                    end)
                end)
                
                -- Return functions for the dropdown
                local DropdownFunctions = {}
                
                function DropdownFunctions:SetValue(value)
                    pcall(function()
                        if table.find(options, value) then
                            SelectedTextBox.Text = value
                            SafeCallback(callback, value)
                        else
                            warn("DeltaLib: Value '" .. tostring(value) .. "' not found in dropdown options.")
                        end
                    end)
                end
                
                function DropdownFunctions:GetValue()
                    return SelectedTextBox.Text
                end
                
                function DropdownFunctions:Refresh(newOptions, newDefault)
                    pcall(function()
                        -- Error handling for options
                        if type(newOptions) ~= "table" then
                            warn("DeltaLib: Dropdown options must be a table. Converting to table.")
                            if newOptions == nil then
                                newOptions = {}
                            else
                                newOptions = {tostring(newOptions)}
                            end
                        end
                        
                        -- Error handling for empty options
                        if #newOptions == 0 then
                            warn("DeltaLib: Dropdown has no options. Adding placeholder.")
                            newOptions = {"No options available"}
                        end
                        
                        options = newOptions
                        
                        -- Error handling for default value
                        newDefault = newDefault or options[1]
                        if not table.find(options, newDefault) then
                            warn("DeltaLib: Default value not found in options. Using first option.")
                            newDefault = options[1]
                        end
                        
                        -- Clear existing options
                        for _, button in ipairs(OptionButtons) do
                            pcall(function()
                                button:Destroy()
                            end)
                        end
                        
                        OptionButtons = {}
                        DropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                        
                        -- Create new options
                        for i, option in ipairs(options) do
                            local optionButton = CreateOptionButton(option, i)
                            table.insert(OptionButtons, optionButton)
                            
                            -- Update canvas size
                            DropdownScrollFrame.CanvasSize = UDim2.new(0, 0, 0, DropdownOptionsLayout.AbsoluteContentSize.Y + 10)
                        end
                        
                        -- Set default value
                        SelectedTextBox.Text = newDefault
                    end)
                end
                
                return DropdownFunctions
            end
            
            -- TextBox Creation Function
            function Section:AddTextBox(boxText, placeholder, default, callback)
                placeholder = placeholder or ""
                default = default or ""
                callback = callback or function() end
                
                local TextBoxContainer = Instance.new("Frame")
                TextBoxContainer.Name = "TextBoxContainer"
                TextBoxContainer.Size = UDim2.new(1, 0, 0, 45)
                TextBoxContainer.BackgroundTransparency = 1
                TextBoxContainer.Parent = SectionContent
                
                local TextBoxLabel = Instance.new("TextLabel")
                TextBoxLabel.Name = "TextBoxLabel"
                TextBoxLabel.Size = UDim2.new(1, 0, 0, 20)
                TextBoxLabel.BackgroundTransparency = 1
                TextBoxLabel.Text = boxText
                TextBoxLabel.TextColor3 = Colors.Text
                TextBoxLabel.TextSize = 14
                TextBoxLabel.Font = Enum.Font.Gotham
                TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextBoxLabel.Parent = TextBoxContainer
                
                -- Register for text scaling
                RegisterTextElement(TextBoxLabel)
                
                local TextBox = Instance.new("TextBox")
                TextBox.Name = "TextBox"
                TextBox.Size = UDim2.new(1, 0, 0, 25)
                TextBox.Position = UDim2.new(0, 0, 0, 20)
                TextBox.BackgroundColor3 = Colors.DarkBackground
                TextBox.BorderSizePixel = 0
                TextBox.PlaceholderText = placeholder
                TextBox.Text = default
                TextBox.TextColor3 = Colors.Text
                TextBox.PlaceholderColor3 = Colors.SubText
                TextBox.TextSize = 14
                TextBox.Font = Enum.Font.Gotham
                TextBox.TextXAlignment = Enum.TextXAlignment.Left
                TextBox.ClearTextOnFocus = false
                TextBox.Parent = TextBoxContainer
                
                -- Register for text scaling
                RegisterTextElement(TextBox)
                
                local TextBoxPadding = Instance.new("UIPadding")
                TextBoxPadding.PaddingLeft = UDim.new(0, 10)
                TextBoxPadding.Parent = TextBox
                
                local TextBoxCorner = Instance.new("UICorner")
                TextBoxCorner.CornerRadius = UDim.new(0, 4)
                TextBoxCorner.Parent = TextBox
                
                -- TextBox Logic
                pcall(function()
                    TextBox.Focused:Connect(function()
                        pcall(function()
                            TweenService:Create(TextBox, TweenInfo.new(0.2), {BorderSizePixel = 1, BorderColor3 = Colors.NeonRed}):Play()
                        end)
                    end)
                    
                    TextBox.FocusLost:Connect(function(enterPressed)
                        pcall(function()
                            TweenService:Create(TextBox, TweenInfo.new(0.2), {BorderSizePixel = 0}):Play()
                            SafeCallback(callback, TextBox.Text, enterPressed)
                        end)
                    end)
                end)
                
                local TextBoxFunctions = {}
                
                function TextBoxFunctions:SetText(text)
                    pcall(function()
                        TextBox.Text = text
                        SafeCallback(callback, text, false)
                    end)
                end
                
                function TextBoxFunctions:GetText()
                    return TextBox.Text
                end
                
                return TextBoxFunctions
            end
            
            return Section
        end
        
        return Tab
    end

    -- Add User Profile Section
    function Window:AddUserProfile(displayName)
        displayName = displayName or Player.DisplayName
        
        -- Update username label
        pcall(function()
            UsernameLabel.Text = displayName
        end)
        
        -- Create a function to update the avatar
        local function UpdateAvatar(userId)
            pcall(function()
                AvatarImage.Image = GetPlayerAvatar(userId or Player.UserId, "100x100")
            end)
        end
        
        return {
            SetDisplayName = function(name)
                pcall(function()
                    UsernameLabel.Text = name
                end)
            end,
            UpdateAvatar = UpdateAvatar
        }
    end

    -- Register all text elements in the window for scaling
    RegisterAllTextElements(MainFrame)

    -- Set up text scaling update on window resize
    pcall(function()
        MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            UpdateAllTextScales()
        end)
    end)

    -- Add text scaling controls to the Window object
    Window.TextScaling = {
        Enable = function()
            pcall(function()
                TextScaling.Enabled = true
                UpdateAllTextScales()
            end)
        end,
        
        Disable = function()
            pcall(function()
                TextScaling.Enabled = false
            end)
        end,
        
        SetMinTextSize = function(size)
            pcall(function()
                TextScaling.MinTextSize = size
                UpdateAllTextScales()
            end)
        end,
        
        SetMaxTextSize = function(size)
            pcall(function()
                TextScaling.MaxTextSize = size
                UpdateAllTextScales()
            end)
        end,
        
        SetBaseResolution = function(resolution)
            pcall(function()
                TextScaling.BaseResolution = resolution
                UpdateAllTextScales()
            end)
        end,
        
        UpdateAllText = function()
            pcall(function()
                UpdateAllTextScales()
            end)
        end
    }

    return Window
end

-- Return the library
return DeltaLib

