-- DeltaLib UI Library
local DeltaLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

-- Colors - Dark Neon Theme
local Colors = {
   Background = Color3.fromRGB(13, 14, 16),       -- Darker background
   DarkBackground = Color3.fromRGB(10, 11, 13),   -- Even darker background
   LightBackground = Color3.fromRGB(19, 21, 25),  -- Slightly lighter background
   NeonRed = Color3.fromRGB(255, 0, 60),          -- Neon red accent
   DarkNeonRed = Color3.fromRGB(200, 0, 45),      -- Darker neon red
   LightNeonRed = Color3.fromRGB(255, 50, 90),    -- Lighter neon red
   Text = Color3.fromRGB(255, 255, 255),          -- White text
   SubText = Color3.fromRGB(200, 200, 200),       -- Light gray text
   Border = Color3.fromRGB(24, 25, 30)            -- Border color
}

-- Improved Draggable Function with Delta Movement
local function MakeDraggable(frame, dragArea)
   local dragToggle = nil
   local dragInput = nil
   local dragStart = nil
   local startPos = nil
   
   local function updateInput(input)
       local delta = input.Position - dragStart
       frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
   end
   
   dragArea.InputBegan:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
           dragToggle = true
           dragStart = input.Position
           startPos = frame.Position
           
           input.Changed:Connect(function()
               if input.UserInputState == Enum.UserInputState.End then
                   dragToggle = false
               end
           end)
       end
   end)
   
   dragArea.InputChanged:Connect(function(input)
       if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
           dragInput = input
       end
   end)
   
   UserInputService.InputChanged:Connect(function(input)
       if input == dragInput and dragToggle then
           updateInput(input)
       end
   end)
end

-- Get Player Avatar
local function GetPlayerAvatar(userId, size)
   size = size or "420x420"
   return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=" .. size:split("x")[1] .. "&height=" .. size:split("x")[2] .. "&format=png"
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
   DeltaLibGUI.IgnoreGuiInset = true
   
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
       DeltaLibGUI.Parent = Player:WaitForChild("PlayerGui")
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
   
   -- Add rounded corners
   local UICorner = Instance.new("UICorner")
   UICorner.CornerRadius = UDim.new(0, 6)
   UICorner.Parent = MainFrame
   
   -- Add shadow with neon effect
   local Shadow = Instance.new("ImageLabel")
   Shadow.Name = "Shadow"
   Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
   Shadow.BackgroundTransparency = 1
   Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
   Shadow.Size = UDim2.new(1, 45, 1, 45)
   Shadow.ZIndex = -1
   Shadow.Image = "rbxassetid://5554236805"
   Shadow.ImageColor3 = Colors.NeonRed
   Shadow.ImageTransparency = 0.4
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
   
   -- Add UIStroke to TitleBar for neon effect
   local TitleBarStroke = Instance.new("UIStroke")
   TitleBarStroke.Color = Colors.NeonRed
   TitleBarStroke.Transparency = 0.7
   TitleBarStroke.Thickness = 1.5
   TitleBarStroke.Parent = TitleBar
   
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
   AvatarImage.Image = GetPlayerAvatar(Player.UserId, "100x100")
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
   UsernameLabel.Text = Player.Name
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
   MinimizeButton.Position = UDim2.new(1, -54, 0, 3)
   MinimizeButton.BackgroundTransparency = 1
   MinimizeButton.Text = "−"
   MinimizeButton.TextColor3 = Colors.Text
   MinimizeButton.TextSize = 16
   MinimizeButton.Font = Enum.Font.GothamBold
   MinimizeButton.Parent = TitleBar
   
   MinimizeButton.MouseEnter:Connect(function()
       MinimizeButton.TextColor3 = Colors.NeonRed
   end)
   
   MinimizeButton.MouseLeave:Connect(function()
       MinimizeButton.TextColor3 = Colors.Text
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
   
   CloseButton.MouseEnter:Connect(function()
       CloseButton.TextColor3 = Colors.NeonRed
   end)
   
   CloseButton.MouseLeave:Connect(function()
       CloseButton.TextColor3 = Colors.Text
   end)
   
   CloseButton.MouseButton1Click:Connect(function()
       DeltaLibGUI:Destroy()
   end)
   
   -- Make window draggable
   MakeDraggable(MainFrame, TitleBar)
   
   -- Container for tabs with improved horizontal scrolling
   local TabContainer = Instance.new("Frame")
   TabContainer.Name = "TabContainer"
   TabContainer.Size = UDim2.new(1, 0, 0, 35)
   TabContainer.Position = UDim2.new(0, 0, 0, 30)
   TabContainer.BackgroundColor3 = Colors.LightBackground
   TabContainer.BorderSizePixel = 0
   TabContainer.Parent = MainFrame
   
   -- Add UIStroke to TabContainer for subtle neon effect
   local TabContainerStroke = Instance.new("UIStroke")
   TabContainerStroke.Color = Colors.NeonRed
   TabContainerStroke.Transparency = 0.9
   TabContainerStroke.Thickness = 1
   TabContainerStroke.Parent = TabContainer
   
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
   LeftScrollButton.Visible = false
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
   RightScrollButton.Visible = false
   RightScrollButton.Parent = TabContainer
   
   -- Tab Scroll Frame
   local TabScrollFrame = Instance.new("ScrollingFrame")
   TabScrollFrame.Name = "TabScrollFrame"
   TabScrollFrame.Size = UDim2.new(1, 0, 1, 0)
   TabScrollFrame.Position = UDim2.new(0, 0, 0, 0)
   TabScrollFrame.BackgroundTransparency = 1
   TabScrollFrame.BorderSizePixel = 0
   TabScrollFrame.ScrollBarThickness = 0
   TabScrollFrame.ScrollingDirection = Enum.ScrollingDirection.X
   TabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
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
   
   -- Function to update tab scroll visibility and layout
   local tabCount = 0
   local function UpdateTabScrollVisibility()
       local shouldShowScrollButtons = tabCount > 10 or TabButtonsLayout.AbsoluteContentSize.X > TabContainer.AbsoluteSize.X
       
       LeftScrollButton.Visible = shouldShowScrollButtons
       RightScrollButton.Visible = shouldShowScrollButtons
       
       if shouldShowScrollButtons then
           TabScrollFrame.Size = UDim2.new(1, -50, 1, 0)
           TabScrollFrame.Position = UDim2.new(0, 25, 0, 0)
       else
           TabScrollFrame.Size = UDim2.new(1, 0, 1, 0)
           TabScrollFrame.Position = UDim2.new(0, 0, 0, 0)
       end
   end
   
   -- Update tab scroll canvas size when tabs change
   TabButtonsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
       TabScrollFrame.CanvasSize = UDim2.new(0, TabButtonsLayout.AbsoluteContentSize.X, 0, 0)
       UpdateTabScrollVisibility()
   end)
   
   -- Scroll buttons functionality
   local scrollAmount = 150
   local scrollDuration = 0.3
   
   -- Function to scroll with animation
   local function ScrollTabs(direction)
       local currentPos = TabScrollFrame.CanvasPosition.X
       local targetPos
       
       if direction == "left" then
           targetPos = math.max(currentPos - scrollAmount, 0)
       else
           local maxScroll = TabScrollFrame.CanvasSize.X.Offset - TabScrollFrame.AbsoluteSize.X
           targetPos = math.min(currentPos + scrollAmount, maxScroll)
       end
       
       local tweenInfo = TweenInfo.new(scrollDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
       local tween = TweenService:Create(TabScrollFrame, tweenInfo, {CanvasPosition = Vector2.new(targetPos, 0)})
       tween:Play()
   end
   
   -- Button hover effects
   LeftScrollButton.MouseEnter:Connect(function()
       TweenService:Create(LeftScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
   end)
   
   LeftScrollButton.MouseLeave:Connect(function()
       TweenService:Create(LeftScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkBackground}):Play()
   end)
   
   RightScrollButton.MouseEnter:Connect(function()
       TweenService:Create(RightScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
   end)
   
   RightScrollButton.MouseLeave:Connect(function()
       TweenService:Create(RightScrollButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkBackground}):Play()
   end)
   
   -- Connect scroll buttons
   LeftScrollButton.MouseButton1Click:Connect(function()
       ScrollTabs("left")
   end)
   
   RightScrollButton.MouseButton1Click:Connect(function()
       ScrollTabs("right")
   end)
   
   -- Add continuous scrolling when holding the button
   local isScrollingLeft = false
   local isScrollingRight = false
   
   LeftScrollButton.MouseButton1Down:Connect(function()
       isScrollingLeft = true
       
       ScrollTabs("left")
       
       spawn(function()
           local initialDelay = 0.5
           wait(initialDelay)
           
           while isScrollingLeft do
               ScrollTabs("left")
               wait(0.2)
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
       
       ScrollTabs("right")
       
       spawn(function()
           local initialDelay = 0.5
           wait(initialDelay)
           
           while isScrollingRight do
               ScrollTabs("right")
               wait(0.2)
           end
       end)
   end)
   
   RightScrollButton.MouseButton1Up:Connect(function()
       isScrollingRight = false
   end)
   
   RightScrollButton.MouseLeave:Connect(function()
       isScrollingRight = false
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
   MinimizeButton.MouseButton1Click:Connect(function()
       isMinimized = not isMinimized
       
       if isMinimized then
           originalSize = MainFrame.Size
           
           TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
               Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 30)
           }):Play()
           
           ContentContainer.Visible = false
           TabContainer.Visible = false
           
           MinimizeButton.Text = "+"
       else
           TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
               Size = originalSize
           }):Play()
           
           task.delay(0.1, function()
               ContentContainer.Visible = true
               TabContainer.Visible = true
           end)
           
           MinimizeButton.Text = "−"
       end
   end)
   
   -- Tab Management
   local Tabs = {}
   local SelectedTab = nil
   
   -- Create Tab Function
   function Window:CreateTab(tabName)
       local Tab = {}
       tabCount = tabCount + 1
       
       -- Tab Button
       local TabButton = Instance.new("TextButton")
       TabButton.Name = tabName.."Button"
       TabButton.Size = UDim2.new(0, TextService:GetTextSize(tabName, 14, Enum.Font.GothamSemibold, Vector2.new(math.huge, 20)).X + 20, 1, -10)
       TabButton.Position = UDim2.new(0, 0, 0, 0)
       TabButton.BackgroundColor3 = Colors.DarkBackground
       TabButton.BorderSizePixel = 0
       TabButton.Text = ""
       TabButton.TextColor3 = Colors.SubText
       TabButton.TextSize = 14
       TabButton.Font = Enum.Font.GothamSemibold
       TabButton.Parent = TabButtons
       
       local TabButtonCorner = Instance.new("UICorner")
       TabButtonCorner.CornerRadius = UDim.new(0, 4)
       TabButtonCorner.Parent = TabButton
       
       -- Add UIStroke to TabButton
       local TabButtonStroke = Instance.new("UIStroke")
       TabButtonStroke.Color = Colors.Border
       TabButtonStroke.Transparency = 0.8
       TabButtonStroke.Thickness = 1
       TabButtonStroke.Parent = TabButton
       
       -- Tab Button Text
       local TabButtonText = Instance.new("TextLabel")
       TabButtonText.Name = "TabButtonText"
       TabButtonText.Size = UDim2.new(1, 0, 1, 0)
       TabButtonText.BackgroundTransparency = 1
       TabButtonText.Text = tabName
       TabButtonText.TextColor3 = Colors.SubText
       TabButtonText.TextSize = 14
       TabButtonText.Font = Enum.Font.GothamSemibold
       TabButtonText.Parent = TabButton
       
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
       TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
           TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 10)
       end)
       
       -- Tab Selection Logic
       TabButton.MouseButton1Click:Connect(function()
           if SelectedTab then
               -- Deselect current tab
               SelectedTab.Button.BackgroundColor3 = Colors.DarkBackground
               SelectedTab.ButtonText.TextColor3 = Colors.SubText
               SelectedTab.Content.Visible = false
               SelectedTab.ButtonStroke.Color = Colors.Border
           end
           
           -- Select new tab
           TabButton.BackgroundColor3 = Colors.DarkBackground
           TabButtonText.TextColor3 = Colors.NeonRed
           TabButtonStroke.Color = Colors.NeonRed
           TabContent.Visible = true
           SelectedTab = {
               Button = TabButton, 
               ButtonText = TabButtonText, 
               Content = TabContent,
               ButtonStroke = TabButtonStroke
           }
           
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
       
       -- Add to tabs table
       table.insert(Tabs, {
           Button = TabButton, 
           ButtonText = TabButtonText, 
           Content = TabContent,
           ButtonStroke = TabButtonStroke
       })
       
       -- If this is the first tab, select it
       if #Tabs == 1 then
           TabButton.BackgroundColor3 = Colors.DarkBackground
           TabButtonText.TextColor3 = Colors.NeonRed
           TabButtonStroke.Color = Colors.NeonRed
           TabContent.Visible = true
           SelectedTab = {
               Button = TabButton, 
               ButtonText = TabButtonText, 
               Content = TabContent,
               ButtonStroke = TabButtonStroke
           }
       end
       
       -- Section Creation Function
       function Tab:CreateSection(sectionName)
           local Section = {}
           
           -- Section Container
           local SectionContainer = Instance.new("Frame")
           SectionContainer.Name = sectionName.."Section"
           SectionContainer.Size = UDim2.new(1, 0, 0, 30)
           SectionContainer.BackgroundColor3 = Colors.Background
           SectionContainer.BorderSizePixel = 0
           SectionContainer.Parent = TabContent
           
           local SectionCorner = Instance.new("UICorner")
           SectionCorner.CornerRadius = UDim.new(0, 4)
           SectionCorner.Parent = SectionContainer
           
           -- Add UIStroke to Section
           local SectionStroke = Instance.new("UIStroke")
           SectionStroke.Color = Colors.Border
           SectionStroke.Transparency = 0.7
           SectionStroke.Thickness = 1
           SectionStroke.Parent = SectionContainer
           
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
           
           -- Section Content
           local SectionContent = Instance.new("Frame")
           SectionContent.Name = "SectionContent"
           SectionContent.Size = UDim2.new(1, -20, 0, 0)
           SectionContent.Position = UDim2.new(0, 10, 0, 25)
           SectionContent.BackgroundTransparency = 1
           SectionContent.Parent = SectionContainer
           
           local SectionContentLayout = Instance.new("UIListLayout")
           SectionContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
           SectionContentLayout.Padding = UDim.new(0, 8)
           SectionContentLayout.Parent = SectionContent
           
           -- Auto-size the section based on content
           SectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
               SectionContent.Size = UDim2.new(1, -20, 0, SectionContentLayout.AbsoluteContentSize.Y)
               SectionContainer.Size = UDim2.new(1, 0, 0, SectionContent.Size.Y.Offset + 35)
           end)
           
           -- Label Creation Function
           function Section:AddLabel(labelText)
               local LabelContainer = Instance.new("Frame")
               LabelContainer.Name = "LabelContainer"
               LabelContainer.Size = UDim2.new(1, 0, 0, 25)
               LabelContainer.BackgroundColor3 = Colors.DarkBackground
               LabelContainer.BackgroundTransparency = 0.7
               LabelContainer.Parent = SectionContent
               
               local LabelCorner = Instance.new("UICorner")
               LabelCorner.CornerRadius = UDim.new(0, 4)
               LabelCorner.Parent = LabelContainer
               
               local LabelStroke = Instance.new("UIStroke")
               LabelStroke.Color = Colors.Border
               LabelStroke.Transparency = 0.8
               LabelStroke.Thickness = 1
               LabelStroke.Parent = LabelContainer
               
               local Label = Instance.new("TextLabel")
               Label.Name = "Label"
               Label.Size = UDim2.new(1, -10, 1, 0)
               Label.Position = UDim2.new(0, 5, 0, 0)
               Label.BackgroundTransparency = 1
               Label.Text = labelText
               Label.TextColor3 = Colors.Text
               Label.TextSize = 14
               Label.Font = Enum.Font.Gotham
               Label.TextXAlignment = Enum.TextXAlignment.Left
               Label.Parent = LabelContainer
               
               local LabelFunctions = {}
               
               function LabelFunctions:SetText(newText)
                   Label.Text = newText
               end
               
               -- Update section size
               SectionContent.Size = UDim2.new(1, -20, 0, SectionContentLayout.AbsoluteContentSize.Y)
               SectionContainer.Size = UDim2.new(1, 0, 0, SectionContent.Size.Y.Offset + 35)
               
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
               
               local ButtonCorner = Instance.new("UICorner")
               ButtonCorner.CornerRadius = UDim.new(0, 4)
               ButtonCorner.Parent = Button
               
               -- Add UIStroke to Button
               local ButtonStroke = Instance.new("UIStroke")
               ButtonStroke.Color = Colors.Border
               ButtonStroke.Transparency = 0.7
               ButtonStroke.Thickness = 1
               ButtonStroke.Parent = Button
               
               -- Button Effects
               Button.MouseEnter:Connect(function()
                   TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Colors.NeonRed}):Play()
                   TweenService:Create(ButtonStroke, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
               end)
               
               Button.MouseLeave:Connect(function()
                   TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Colors.DarkBackground}):Play()
                   TweenService:Create(ButtonStroke, TweenInfo.new(0.3), {Transparency = 0.7}):Play()
               end)
               
               Button.MouseButton1Click:Connect(function()
                   callback()
                   TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), {BackgroundColor3 = Colors.LightNeonRed}):Play()
               end)
               
               local ButtonFunctions = {}
               
               function ButtonFunctions:SetText(newText)
                   Button.Text = newText
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
               
               local ToggleButton = Instance.new("Frame")
               ToggleButton.Name = "ToggleButton"
               ToggleButton.Size = UDim2.new(0, 40, 0, 20)
               ToggleButton.Position = UDim2.new(1, -40, 0, 2)
               ToggleButton.BackgroundColor3 = default and Colors.NeonRed or Colors.DarkBackground
               ToggleButton.BorderSizePixel = 0
               ToggleButton.Parent = ToggleContainer
               
               local ToggleButtonCorner = Instance.new("UICorner")
               ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
               ToggleButtonCorner.Parent = ToggleButton
               
               -- Add UIStroke to ToggleButton
               local ToggleButtonStroke = Instance.new("UIStroke")
               ToggleButtonStroke.Color = default and Colors.NeonRed or Colors.Border
               ToggleButtonStroke.Transparency = 0.7
               ToggleButtonStroke.Thickness = 1
               ToggleButtonStroke.Parent = ToggleButton
               
               local ToggleCircle = Instance.new("Frame")
               ToggleCircle.Name = "ToggleCircle"
               ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
               ToggleCircle.Position = UDim2.new(0, default and 22 or 2, 0, 2)
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
                   if Enabled then
                       TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.NeonRed}):Play()
                       TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 22, 0, 2)}):Play()
                       TweenService:Create(ToggleButtonStroke, TweenInfo.new(0.2), {Color = Colors.NeonRed}):Play()
                   else
                       TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Colors.DarkBackground}):Play()
                       TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0, 2)}):Play()
                       TweenService:Create(ToggleButtonStroke, TweenInfo.new(0.2), {Color = Colors.Border}):Play()
                   end
               end
               
               -- Toggle Logic
               ToggleClickArea.MouseButton1Click:Connect(function()
                   Enabled = not Enabled
                   UpdateToggle()
                   callback(Enabled)
               end)
               
               local ToggleFunctions = {}
               
               function ToggleFunctions:SetState(state)
                   Enabled = state
                   UpdateToggle()
                   callback(Enabled)
               end
               
               function ToggleFunctions:GetState()
                   return Enabled
               end
               
               return ToggleFunctions
           end
           
           -- Slider Creation Function
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
               
               local SliderBackground = Instance.new("Frame")
               SliderBackground.Name = "SliderBackground"
               SliderBackground.Size = UDim2.new(1, 0, 0, 10)
               SliderBackground.Position = UDim2.new(0, 0, 0, 25)
               SliderBackground.BackgroundColor3 = Colors.DarkBackground
               SliderBackground.BorderSizePixel = 0
               SliderBackground.Parent = SliderContainer
               
               -- Add UIStroke to SliderBackground
               local SliderBackgroundStroke = Instance.new("UIStroke")
               SliderBackgroundStroke.Color = Colors.Border
               SliderBackgroundStroke.Transparency = 0.7
               SliderBackgroundStroke.Thickness = 1
               SliderBackgroundStroke.Parent = SliderBackground
               
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
                   value = math.clamp(value, min, max)
                   value = math.floor(value + 0.5)
                   
                   SliderValue.Text = tostring(value)
                   SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                   callback(value)
               end
               
               -- Set initial value
               UpdateSlider(default)
               
               -- Slider Interaction
               local isDragging = false
               
               SliderButton.MouseButton1Down:Connect(function()
                   isDragging = true
               end)
               
               UserInputService.InputEnded:Connect(function(input)
                   if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                       isDragging = false
                   end
               end)
               
               UserInputService.InputChanged:Connect(function(input)
                   if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                       local mousePos = UserInputService:GetMouseLocation()
                       local relativePos = mousePos.X - SliderBackground.AbsolutePosition.X
                       local percent = math.clamp(relativePos / SliderBackground.AbsoluteSize.X, 0, 1)
                       local value = min + (max - min) * percent
                       
                       UpdateSlider(value)
                   end
               end)
               
               local SliderFunctions = {}
               
               function SliderFunctions:SetValue(value)
                   UpdateSlider(value)
               end
               
               function SliderFunctions:GetValue()
                   return tonumber(SliderValue.Text)
               end
               
               return SliderFunctions
           end
           
           -- Dropdown Creation Function - FIXED VERSION
           function Section:AddDropdown(dropdownText, options, default, callback)
               local ee = {}
               options = options or {}
               default = default or options[1] or ""
               callback = callback or function() end
               local dropdownOpen = false
               
               -- Main dropdown frame
               local b1 = Instance.new("Frame")
               b1.Name = "DropdownContainer"
               b1.BackgroundColor3 = Color3.fromRGB(13, 14, 16)
               b1.Size = UDim2.new(1, 0, 0, 30)
               b1.Parent = SectionContent
               b1.ClipsDescendants = true
               
               local dropdownStroke = Instance.new("UIStroke")
               dropdownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
               dropdownStroke.Color = Color3.fromRGB(24, 25, 30)
               dropdownStroke.Parent = b1
               
               local dropdownCorner = Instance.new("UICorner")
               dropdownCorner.CornerRadius = UDim.new(0, 4)
               dropdownCorner.Parent = b1
               
               local dropdownLabel = Instance.new("TextLabel")
               dropdownLabel.BackgroundTransparency = 1
               dropdownLabel.Position = UDim2.new(0, 10, 0, 8)
               dropdownLabel.Size = UDim2.new(1, -10, 0, 14)
               dropdownLabel.Font = Enum.Font.Gotham
               dropdownLabel.Text = dropdownText
               dropdownLabel.TextColor3 = Colors.Text
               dropdownLabel.TextSize = 14
               dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
               dropdownLabel.Parent = b1

               -- Display textbox
               local textbox = Instance.new("TextBox")
               textbox.BackgroundColor3 = Color3.fromRGB(13, 14, 16)
               textbox.Size = UDim2.new(0, 150, 0, 24)
               textbox.Position = UDim2.new(1, -185, 0, 3)
               textbox.Font = Enum.Font.Gotham
               textbox.Text = default
               textbox.PlaceholderText = "..."
               textbox.TextColor3 = Colors.Text
               textbox.TextSize = 14
               textbox.TextWrapped = true
               textbox.TextEditable = false
               textbox.Parent = b1
               
               local textboxStroke = Instance.new("UIStroke")
               textboxStroke.Color = Color3.fromRGB(24, 25, 30)
               textboxStroke.Parent = textbox
               
               local textboxCorner = Instance.new("UICorner")
               textboxCorner.CornerRadius = UDim.new(0, 4)
               textboxCorner.Parent = textbox
               
               -- Create a transparent button over the TextBox to handle clicks
               local textboxButton = Instance.new("TextButton")
               textboxButton.Name = "TextBoxButton"
               textboxButton.Size = UDim2.new(1, 0, 1, 0)
               textboxButton.BackgroundTransparency = 1
               textboxButton.Text = ""
               textboxButton.Parent = textbox

               -- Dropdown toggle button
               local dropdownTog = Instance.new("ImageButton")
               dropdownTog.BackgroundTransparency = 1
               dropdownTog.Image = ""
               dropdownTog.Position = UDim2.new(1, -30, 0, 3)
               dropdownTog.Size = UDim2.new(0, 24, 0, 24)
               dropdownTog.Parent = b1
               
               local dropdownTogStroke = Instance.new("UIStroke")
               dropdownTogStroke.Color = Color3.fromRGB(24, 25, 30)
               dropdownTogStroke.Parent = dropdownTog
               
               local dropdownTogCorner = Instance.new("UICorner")
               dropdownTogCorner.CornerRadius = UDim.new(0, 4)
               dropdownTogCorner.Parent = dropdownTog

               local dropdownIcon = Instance.new("ImageLabel")
               dropdownIcon.BackgroundTransparency = 1
               dropdownIcon.Image = "http://www.roblox.com/asset/?id=6031094670"
               dropdownIcon.Size = UDim2.new(1, 0, 1, 0)
               dropdownIcon.Rotation = 270
               dropdownIcon.ImageColor3 = Colors.NeonRed
               dropdownIcon.Parent = dropdownTog

               -- Dropdown options container
               local dropdownContainer = Instance.new("ScrollingFrame")
               dropdownContainer.BackgroundTransparency = 1
               dropdownContainer.BorderSizePixel = 0
               dropdownContainer.Size = UDim2.new(1, -4, 1, -32)
               dropdownContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
               dropdownContainer.ScrollBarImageColor3 = Color3.fromRGB(42, 43, 53)
               dropdownContainer.ScrollBarThickness = 6
               dropdownContainer.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
               dropdownContainer.Parent = b1
               dropdownContainer.Position = UDim2.new(0, 2, 0, 32)
               
               local dropdownListLayout = Instance.new("UIListLayout")
               dropdownListLayout.Padding = UDim.new(0, 5)
               dropdownListLayout.Parent = dropdownContainer
               
               local dropdownPadding = Instance.new("UIPadding")
               dropdownPadding.PaddingLeft = UDim.new(0, 5)
               dropdownPadding.PaddingRight = UDim.new(0, 5)
               dropdownPadding.PaddingTop = UDim.new(0, 5)
               dropdownPadding.PaddingBottom = UDim.new(0, 5)
               dropdownPadding.Parent = dropdownContainer

               -- Toggle dropdown visibility
               local function ToggleDropdown()
                   dropdownOpen = not dropdownOpen
                   TweenService:Create(dropdownIcon, TweenInfo.new(0.5), {Rotation = dropdownOpen and 90 or 270}):Play()
                   TweenService:Create(b1, TweenInfo.new(0.5), {Size = dropdownOpen and UDim2.new(1, 0, 0, 120) or UDim2.new(1, 0, 0, 30)}):Play()
               end
               
               dropdownTog.MouseButton1Click:Connect(ToggleDropdown)
               textboxButton.MouseButton1Click:Connect(ToggleDropdown)

               -- Update dropdown items
               function ee:Update(newlist)
                   -- Clear existing items
                   for i, v in pairs(dropdownContainer:GetChildren()) do
                       if v:IsA("TextButton") then
                           v:Destroy()
                       end
                   end
                   
                   options = newlist
                   textbox.Text = ""
                   dropdownContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
                   
                   -- Create new items
                   for i, v in pairs(options) do
                       local btndebounce = false
                       local optionBtn = Instance.new("TextButton")
                       optionBtn.BackgroundColor3 = Color3.fromRGB(13, 14, 16)
                       optionBtn.Size = UDim2.new(1, 0, 0, 30)
                       optionBtn.Parent = dropdownContainer
                       optionBtn.Text = ""
                       optionBtn.AutoButtonColor = false
                       
                       local optionBtnStroke = Instance.new("UIStroke")
                       optionBtnStroke.Color = Color3.fromRGB(24, 25, 30)
                       optionBtnStroke.Parent = optionBtn
                       
                       local optionBtnCorner = Instance.new("UICorner")
                       optionBtnCorner.CornerRadius = UDim.new(0, 4)
                       optionBtnCorner.Parent = optionBtn
                       
                       local optionLabel = Instance.new("TextLabel")
                       optionLabel.BackgroundTransparency = 1
                       optionLabel.Position = UDim2.new(0, 10, 0.5, -8)
                       optionLabel.Size = UDim2.new(1, -10, 0, 14)
                       optionLabel.Font = Enum.Font.Gotham
                       optionLabel.Text = i.." - "..v
                       optionLabel.TextColor3 = Colors.Text
                       optionLabel.TextSize = 14
                       optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                       optionLabel.Parent = optionBtn

                       dropdownContainer.CanvasSize = UDim2.new(0, 0, 0, dropdownContainer.CanvasSize.Y.Offset + 36)

                       optionBtn.MouseButton1Click:Connect(function()
                           textbox.Text = v
                           callback(textbox.Text)
                           if not btndebounce then
                               btndebounce = true
                               TweenService:Create(optionBtnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true), {
                                   Color = Colors.NeonRed
                               }):Play()
                               wait(0.4)
                               btndebounce = false
                           end
                           
                           -- Close dropdown after selection
                           dropdownOpen = false
                           TweenService:Create(dropdownIcon, TweenInfo.new(0.5), {Rotation = 270}):Play()
                           TweenService:Create(b1, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                       end)
                   end
               end

               -- Initial population of dropdown items
               for i, v in pairs(options) do
                   local btndebounce = false
                   local optionBtn = Instance.new("TextButton")
                   optionBtn.BackgroundColor3 = Color3.fromRGB(13, 14, 16)
                   optionBtn.Size = UDim2.new(1, 0, 0, 30)
                   optionBtn.Parent = dropdownContainer
                   optionBtn.Text = ""
                   optionBtn.AutoButtonColor = false
                   
                   local optionBtnStroke = Instance.new("UIStroke")
                   optionBtnStroke.Color = Color3.fromRGB(24, 25, 30)
                   optionBtnStroke.Parent = optionBtn
                   
                   local optionBtnCorner = Instance.new("UICorner")
                   optionBtnCorner.CornerRadius = UDim.new(0, 4)
                   optionBtnCorner.Parent = optionBtn
                   
                   local optionLabel = Instance.new("TextLabel")
                   optionLabel.BackgroundTransparency = 1
                   optionLabel.Position = UDim2.new(0, 10, 0.5, -8)
                   optionLabel.Size = UDim2.new(1, -10, 0, 14)
                   optionLabel.Font = Enum.Font.Gotham
                   optionLabel.Text = i.." - "..v
                   optionLabel.TextColor3 = Colors.Text
                   optionLabel.TextSize = 14
                   optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                   optionLabel.Parent = optionBtn

                   dropdownContainer.CanvasSize = UDim2.new(0, 0, 0, dropdownContainer.CanvasSize.Y.Offset + 36)

                   optionBtn.MouseButton1Click:Connect(function()
                       textbox.Text = v
                       callback(textbox.Text)
                       if not btndebounce then
                           btndebounce = true
                           TweenService:Create(optionBtnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true), {
                               Color = Colors.NeonRed
                           }):Play()
                           wait(0.4)
                           btndebounce = false
                       end
                       
                       -- Close dropdown after selection
                       dropdownOpen = false
                       TweenService:Create(dropdownIcon, TweenInfo.new(0.5), {Rotation = 270}):Play()
                       TweenService:Create(b1, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                   end)
               end

               -- Close dropdown when clicking elsewhere
               UserInputService.InputBegan:Connect(function(input)
                   if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                       if dropdownOpen then
                           local mousePos = UserInputService:GetMouseLocation()
                           local dropdownPos = b1.AbsolutePosition
                           local dropdownSize = b1.AbsoluteSize
                           
                           if not (mousePos.X >= dropdownPos.X and 
                                   mousePos.X <= dropdownPos.X + dropdownSize.X and
                                   mousePos.Y >= dropdownPos.Y and 
                                   mousePos.Y <= dropdownPos.Y + dropdownSize.Y) then
                               
                               dropdownOpen = false
                               TweenService:Create(dropdownIcon, TweenInfo.new(0.5), {Rotation = 270}):Play()
                               TweenService:Create(b1, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                           end
                       end
                   end
               end)
               
               -- Enable mouse wheel scrolling directly on the dropdown
               b1.InputChanged:Connect(function(input)
                   if dropdownOpen and input.UserInputType == Enum.UserInputType.MouseWheel then
                       local scrollAmount = input.Position.Z * 30
                       dropdownContainer.CanvasPosition = Vector2.new(
                           0, 
                           math.clamp(
                               dropdownContainer.CanvasPosition.Y - scrollAmount,
                               0,
                               dropdownContainer.CanvasSize.Y.Offset - dropdownContainer.AbsoluteSize.Y
                           )
                       )
                   end
               end)
               
               -- Return dropdown functions
               function ee:SetValue(value)
                   if table.find(options, value) then
                       textbox.Text = value
                       callback(value)
                   end
               end
               
               function ee:GetValue()
                   return textbox.Text
               end
               
               return ee
           end
           
           return Section
       end
       
       return Tab
   end
   
   -- Add User Profile Section
   function Window:AddUserProfile(displayName)
       displayName = displayName or Player.DisplayName
       
       -- Update username label
       UsernameLabel.Text = displayName
       
       -- Create a function to update the avatar
       local function UpdateAvatar(userId)
           AvatarImage.Image = GetPlayerAvatar(userId or Player.UserId, "100x100")
       end
       
       return {
           SetDisplayName = function(name)
               UsernameLabel.Text = name
           end,
           UpdateAvatar = UpdateAvatar
       }
   end
   
   -- Add responsive UI handling for different devices
   local function UpdateUIForDevice()
       if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
           -- Mobile optimizations
           MainFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
           MainFrame.Position = UDim2.new(0.5, -MainFrame.AbsoluteSize.X / 2, 0.5, -MainFrame.AbsoluteSize.Y / 2)
       else
           -- Desktop sizing
           MainFrame.Size = size
           MainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
       end
   end
   
   -- Update UI when device orientation changes
   UserInputService.WindowFocused:Connect(UpdateUIForDevice)
   UserInputService.WindowFocusReleased:Connect(UpdateUIForDevice)
   
   -- Initial update
   UpdateUIForDevice()
   
   return Window
end

-- Return the library
return DeltaLib

