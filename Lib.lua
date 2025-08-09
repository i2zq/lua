-- i2zq Library v2.0
-- Modern Roblox UI Framework with Glassmorphism Effects
-- Enhanced black/purple theme with depth and animations

local i2zq = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Enhanced Theme Configuration
local Theme = {
    Primary = {
        Background = Color3.fromRGB(10, 10, 15),
        Surface = Color3.fromRGB(20, 20, 28),
        Elevated = Color3.fromRGB(28, 28, 40),
        Border = Color3.fromRGB(50, 50, 70)
    },
    Purple = {
        Main = Color3.fromRGB(138, 43, 226),
        Light = Color3.fromRGB(160, 100, 220),
        Dark = Color3.fromRGB(90, 40, 140),
        Glow = Color3.fromRGB(186, 85, 211)
    },
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(210, 210, 230),
        Muted = Color3.fromRGB(160, 160, 180)
    },
    Transparency = {
        None = 0,
        Light = 0.1,
        Medium = 0.3,
        Heavy = 0.6,
        Glass = 0.85  -- New glass effect transparency
    }
}

-- Smoother Animation Presets
local Animations = {
    Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Elastic = TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 0, false, 0)
}

-- Glassmorphism Effect
local function CreateGlassEffect(parent)
    local glass = Instance.new("Frame")
    glass.Name = "GlassEffect"
    glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glass.BackgroundTransparency = Theme.Transparency.Glass
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.ZIndex = parent.ZIndex - 1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = glass
    
    return glass
end

-- Utility Functions
local function CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function CreateStroke(color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Purple.Main
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

local function CreateGradient(colorSequence, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    gradient.Rotation = rotation or 0
    return gradient
end

local function CreateShadow(parent, intensity, sizeMultiplier)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = parent
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"  -- Better shadow texture
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 1 - (intensity or 0.3)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, sizeMultiplier or 20, 1, sizeMultiplier or 20)
    shadow.Position = UDim2.new(0, -(sizeMultiplier or 20)/2, 0, -(sizeMultiplier or 20)/2)
    shadow.ZIndex = parent.ZIndex - 1
    return shadow
end

local function CreateGlow(parent, color)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Parent = parent
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4996891970"  -- Soft glow texture
    glow.ImageColor3 = color or Theme.Purple.Glow
    glow.ImageTransparency = 0.7
    glow.Size = UDim2.new(1.4, 0, 1.4, 0)
    glow.Position = UDim2.new(-0.2, 0, -0.2, 0)
    glow.ZIndex = parent.ZIndex - 1
    return glow
end

-- Hover effect for interactive elements
local function ApplyHoverEffect(element)
    element.MouseEnter:Connect(function()
        TweenService:Create(element, Animations.Fast, {
            BackgroundColor3 = Theme.Purple.Main,
            BackgroundTransparency = Theme.Transparency.Medium
        }):Play()
    end)
    
    element.MouseLeave:Connect(function()
        TweenService:Create(element, Animations.Fast, {
            BackgroundColor3 = Theme.Primary.Surface,
            BackgroundTransparency = Theme.Transparency.Light
        }):Play()
    end)
end

-- Main Library Functions
function i2zq:CreateWindow(config)
    config = config or {}
    
    local WindowName = config.Name or "i2zq Window"
    local WindowSize = config.Size or UDim2.new(0, 500, 0, 400)
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "i2zqUI_" .. WindowName
    ScreenGui.Parent = PlayerGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Glass Background Effect
    local GlassFrame = Instance.new("Frame")
    GlassFrame.Name = "GlassFrame"
    GlassFrame.Parent = ScreenGui
    GlassFrame.Size = UDim2.new(1, 0, 1, 0)
    GlassFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    GlassFrame.BackgroundTransparency = 0.9
    GlassFrame.ZIndex = 90
    
    -- Main Frame with Glassmorphism
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Theme.Primary.Background
    MainFrame.BackgroundTransparency = Theme.Transparency.Light
    MainFrame.Size = WindowSize
    MainFrame.Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2)
    MainFrame.ZIndex = 100
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Add glass effect
    local glass = CreateGlassEffect(MainFrame)
    glass.Parent = MainFrame
    
    CreateCorner(14).Parent = MainFrame
    CreateStroke(Theme.Purple.Main, 1.5, 0.6).Parent = MainFrame
    CreateShadow(MainFrame, 0.4, 25)
    CreateGlow(MainFrame, Theme.Purple.Glow)
    
    -- Title Bar with Gradient
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Theme.Primary.Elevated
    TitleBar.BackgroundTransparency = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 42)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.ZIndex = 101
    
    CreateCorner(14, 14, 0, 0).Parent = TitleBar
    CreateStroke(Theme.Purple.Dark, 1, 0.7).Parent = TitleBar
    
    -- Title gradient
    local titleGradient = CreateGradient(
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Purple.Dark),
            ColorSequenceKeypoint.new(1, Theme.Purple.Main)
        }),
        90
    )
    titleGradient.Transparency = NumberSequence.new(0.3)
    titleGradient.Parent = TitleBar
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Parent = TitleBar
    TitleText.BackgroundTransparency = 1
    TitleText.Size = UDim2.new(1, -100, 1, 0)
    TitleText.Position = UDim2.new(0, 15, 0, 0)
    TitleText.Text = WindowName
    TitleText.TextColor3 = Theme.Text.Primary
    TitleText.TextSize = 18
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.GothamSemibold
    TitleText.ZIndex = 102
    
    -- Modern Icon Buttons
    local buttonConfig = {
        Size = UDim2.new(0, 32, 0, 32),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 102
    }
    
    -- Close Button
    local CloseButton = Instance.new("ImageButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.Image = "rbxassetid://3926305904"
    CloseButton.ImageRectOffset = Vector2.new(284, 4)
    CloseButton.ImageRectSize = Vector2.new(24, 24)
    CloseButton.ImageColor3 = Theme.Text.Secondary
    CloseButton.Position = UDim2.new(1, -42, 0.5, -16)
    for k,v in pairs(buttonConfig) do
        if k ~= "Text" then -- لا تحط خاصية Text على ImageButton
            CloseButton[k] = v
        end
    end

    
    -- Minimize Button
    local MinimizeButton = Instance.new("ImageButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TitleBar
    MinimizeButton.Image = "rbxassetid://3926305904"
    MinimizeButton.ImageRectOffset = Vector2.new(364, 284)
    MinimizeButton.ImageRectSize = Vector2.new(24, 24)
    MinimizeButton.ImageColor3 = Theme.Text.Secondary
    MinimizeButton.Position = UDim2.new(1, -84, 0.5, -16)
    for k,v in pairs(buttonConfig) do MinimizeButton[k] = v end
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Size = UDim2.new(1, -20, 1, -60)
    ContentFrame.Position = UDim2.new(0, 10, 0, 50)
    ContentFrame.ZIndex = 101
    
    -- Scrolling Frame for content
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Parent = ContentFrame
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = Theme.Purple.Main
    ScrollFrame.ScrollBarImageTransparency = 0.6
    ScrollFrame.ZIndex = 101
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)
    
    local UIPadding = Instance.new("UIPadding")
    UIPadding.Parent = ScrollFrame
    UIPadding.PaddingTop = UDim.new(0, 5)
    UIPadding.PaddingBottom = UDim.new(0, 5)
    
    -- Window Object
    local Window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ContentFrame = ScrollFrame,
        IsMinimized = false,
        OriginalSize = WindowSize
    }
    
    -- Button Animations
    local function animateIconButton(button)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, Animations.Fast, {
                ImageColor3 = Theme.Text.Primary,
                Rotation = 5
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, Animations.Fast, {
                ImageColor3 = Theme.Text.Secondary,
                Rotation = 0
            }):Play()
        end)
        
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, Animations.Fast, {
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(button.Position.X.Scale, button.Position.X.Offset + 2, button.Position.Y.Scale, button.Position.Y.Offset + 2)
            }):Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, Animations.Fast, {
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(button.Position.X.Scale, button.Position.X.Offset - 2, button.Position.Y.Scale, button.Position.Y.Offset - 2)
            }):Play()
        end)
    end
    
    animateIconButton(CloseButton)
    animateIconButton(MinimizeButton)
    
    -- Button Functionality
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, Animations.Elastic, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(glass, Animations.Elastic, {
            BackgroundTransparency = 1
        }):Play()
        
        wait(0.35)
        ScreenGui:Destroy()
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if not Window.IsMinimized then
            TweenService:Create(MainFrame, Animations.Bounce, {
                Size = UDim2.new(Window.OriginalSize.X.Scale, Window.OriginalSize.X.Offset, 0, 42)
            }):Play()
            Window.IsMinimized = true
        else
            TweenService:Create(MainFrame, Animations.Bounce, {
                Size = Window.OriginalSize
            }):Play()
            Window.IsMinimized = false
        end
    end)
    
    -- Window Methods
    function Window:AddButton(config)
        config = config or {}
        local ButtonName = config.Name or "Button"
        local ButtonCallback = config.Callback or function() end
        
        local Button = Instance.new("TextButton")
        Button.Name = ButtonName
        Button.Parent = self.ContentFrame
        Button.BackgroundColor3 = Theme.Primary.Surface
        Button.BackgroundTransparency = Theme.Transparency.Light
        Button.Size = UDim2.new(1, -10, 0, 42)
        Button.Text = ButtonName
        Button.TextColor3 = Theme.Text.Primary
        Button.TextSize = 16
        Button.Font = Enum.Font.Gotham
        Button.ZIndex = 102
        Button.AutoButtonColor = false
        
        CreateCorner(10).Parent = Button
        CreateStroke(Theme.Purple.Main, 1, 0.7).Parent = Button
        
        -- Hover effect
        ApplyHoverEffect(Button)
        
        -- Click animation
        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, Animations.Fast, {
                Size = UDim2.new(1, -15, 0, 38)
            }):Play()
        end)
        
        Button.MouseButton1Up:Connect(function()
            TweenService:Create(Button, Animations.Fast, {
                Size = UDim2.new(1, -10, 0, 42)
            }):Play()
        end)
        
        Button.MouseButton1Click:Connect(ButtonCallback)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return Button
    end
    
    -- Updated Toggle with modern design
    function Window:AddToggle(config)
        config = config or {}
        local ToggleName = config.Name or "Toggle"
        local DefaultValue = config.Default or false
        local ToggleCallback = config.Callback or function() end
        
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = ToggleName .. "Frame"
        ToggleFrame.Parent = self.ContentFrame
        ToggleFrame.BackgroundColor3 = Theme.Primary.Surface
        ToggleFrame.BackgroundTransparency = Theme.Transparency.Light
        ToggleFrame.Size = UDim2.new(1, -10, 0, 40)
        ToggleFrame.ZIndex = 102
        
        CreateCorner(10).Parent = ToggleFrame
        CreateStroke(Theme.Primary.Border, 1, 0.7).Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
        ToggleLabel.Text = ToggleName
        ToggleLabel.TextColor3 = Theme.Text.Primary
        ToggleLabel.TextSize = 16
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.ZIndex = 103
        
        local ToggleContainer = Instance.new("Frame")
        ToggleContainer.Parent = ToggleFrame
        ToggleContainer.BackgroundColor3 = Theme.Primary.Background
        ToggleContainer.Size = UDim2.new(0, 50, 0, 26)
        ToggleContainer.Position = UDim2.new(1, -55, 0.5, -13)
        ToggleContainer.ZIndex = 103
        CreateCorner(13).Parent = ToggleContainer
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleContainer
        ToggleButton.BackgroundColor3 = DefaultValue and Theme.Purple.Main or Theme.Primary.Elevated
        ToggleButton.Size = UDim2.new(0, 22, 0, 22)
        ToggleButton.Position = DefaultValue and UDim2.new(1, -23, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
        ToggleButton.Text = ""
        ToggleButton.ZIndex = 104
        CreateCorner(11).Parent = ToggleButton
        
        CreateGlow(ToggleButton, Theme.Purple.Glow)
        
        local isToggled = DefaultValue
        
        ToggleContainer.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            
            TweenService:Create(ToggleButton, Animations.Smooth, {
                BackgroundColor3 = isToggled and Theme.Purple.Main or Theme.Primary.Elevated,
                Position = isToggled and UDim2.new(1, -23, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
            }):Play()
            
            ToggleCallback(isToggled)
        end)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return {
            Toggle = ToggleButton,
            SetValue = function(value)
                isToggled = value
                TweenService:Create(ToggleButton, Animations.Smooth, {
                    BackgroundColor3 = isToggled and Theme.Purple.Main or Theme.Primary.Elevated,
                    Position = isToggled and UDim2.new(1, -23, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
                }):Play()
            end
        }
    end
    
    function Window:AddSlider(config)
        config = config or {}
        local SliderName = config.Name or "Slider"
        local MinValue = config.Min or 0
        local MaxValue = config.Max or 100
        local DefaultValue = config.Default or MinValue
        local SliderCallback = config.Callback or function() end
        
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = SliderName .. "Frame"
        SliderFrame.Parent = self.ContentFrame
        SliderFrame.BackgroundColor3 = Theme.Primary.Surface
        SliderFrame.BackgroundTransparency = Theme.Transparency.Light
        SliderFrame.Size = UDim2.new(1, -10, 0, 60)
        SliderFrame.ZIndex = 102
        
        CreateCorner(10).Parent = SliderFrame
        CreateStroke(Theme.Primary.Border, 1, 0.7).Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Size = UDim2.new(1, -20, 0, 25)
        SliderLabel.Position = UDim2.new(0, 15, 0, 5)
        SliderLabel.Text = SliderName
        SliderLabel.TextColor3 = Theme.Text.Primary
        SliderLabel.TextSize = 16
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.ZIndex = 103
        
        local SliderValue = Instance.new("TextLabel")
        SliderValue.Parent = SliderFrame
        SliderValue.BackgroundTransparency = 1
        SliderValue.Size = UDim2.new(0, 60, 0, 25)
        SliderValue.Position = UDim2.new(1, -70, 0, 5)
        SliderValue.Text = tostring(DefaultValue)
        SliderValue.TextColor3 = Theme.Purple.Light
        SliderValue.TextSize = 16
        SliderValue.TextXAlignment = Enum.TextXAlignment.Right
        SliderValue.Font = Enum.Font.GothamBold
        SliderValue.ZIndex = 103
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Parent = SliderFrame
        SliderTrack.BackgroundColor3 = Theme.Primary.Background
        SliderTrack.Size = UDim2.new(1, -20, 0, 8)
        SliderTrack.Position = UDim2.new(0, 10, 1, -25)
        SliderTrack.ZIndex = 103
        
        CreateCorner(4).Parent = SliderTrack
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderTrack
        SliderFill.BackgroundColor3 = Theme.Purple.Main
        SliderFill.Size = UDim2.new((DefaultValue - MinValue) / (MaxValue - MinValue), 0, 1, 0)
        SliderFill.Position = UDim2.new(0, 0, 0, 0)
        SliderFill.ZIndex = 104
        
        CreateCorner(4).Parent = SliderFill
        
        local SliderKnob = Instance.new("Frame")
        SliderKnob.Parent = SliderTrack
        SliderKnob.BackgroundColor3 = Theme.Text.Primary
        SliderKnob.Size = UDim2.new(0, 16, 0, 16)
        SliderKnob.Position = UDim2.new((DefaultValue - MinValue) / (MaxValue - MinValue), -8, 0.5, -8)
        SliderKnob.ZIndex = 105
        
        CreateCorner(8).Parent = SliderKnob
        CreateGlow(SliderKnob, Theme.Purple.Glow)
        
        local currentValue = DefaultValue
        local dragging = false
        
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
            currentValue = math.floor(MinValue + (MaxValue - MinValue) * pos)
            
            SliderValue.Text = tostring(currentValue)
            
            TweenService:Create(SliderFill, Animations.Fast, {
                Size = UDim2.new(pos, 0, 1, 0)
            }):Play()
            
            TweenService:Create(SliderKnob, Animations.Fast, {
                Position = UDim2.new(pos, -8, 0.5, -8)
            }):Play()
            
            SliderCallback(currentValue)
        end
        
        SliderTrack.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return {
            SetValue = function(value)
                currentValue = math.clamp(value, MinValue, MaxValue)
                local pos = (currentValue - MinValue) / (MaxValue - MinValue)
                SliderValue.Text = tostring(currentValue)
                SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                SliderKnob.Position = UDim2.new(pos, -8, 0.5, -8)
            end,
            GetValue = function()
                return currentValue
            end
        }
    end
    
    function Window:AddTextBox(config)
        config = config or {}
        local TextBoxName = config.Name or "TextBox"
        local PlaceholderText = config.Placeholder or "Enter text..."
        local TextBoxCallback = config.Callback or function() end
        
        local TextBoxFrame = Instance.new("Frame")
        TextBoxFrame.Name = TextBoxName .. "Frame"
        TextBoxFrame.Parent = self.ContentFrame
        TextBoxFrame.BackgroundColor3 = Theme.Primary.Surface
        TextBoxFrame.BackgroundTransparency = Theme.Transparency.Light
        TextBoxFrame.Size = UDim2.new(1, -10, 0, 60)
        TextBoxFrame.ZIndex = 102
        
        CreateCorner(10).Parent = TextBoxFrame
        CreateStroke(Theme.Primary.Border, 1, 0.7).Parent = TextBoxFrame
        
        local TextBoxLabel = Instance.new("TextLabel")
        TextBoxLabel.Parent = TextBoxFrame
        TextBoxLabel.BackgroundTransparency = 1
        TextBoxLabel.Size = UDim2.new(1, -20, 0, 25)
        TextBoxLabel.Position = UDim2.new(0, 15, 0, 5)
        TextBoxLabel.Text = TextBoxName
        TextBoxLabel.TextColor3 = Theme.Text.Primary
        TextBoxLabel.TextSize = 16
        TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextBoxLabel.Font = Enum.Font.Gotham
        TextBoxLabel.ZIndex = 103
        
        local TextBox = Instance.new("TextBox")
        TextBox.Parent = TextBoxFrame
        TextBox.BackgroundColor3 = Theme.Primary.Background
        TextBox.BackgroundTransparency = Theme.Transparency.Light
        TextBox.Size = UDim2.new(1, -20, 0, 30)
        TextBox.Position = UDim2.new(0, 10, 1, -35)
        TextBox.PlaceholderText = PlaceholderText
        TextBox.PlaceholderColor3 = Theme.Text.Muted
        TextBox.Text = ""
        TextBox.TextColor3 = Theme.Text.Primary
        TextBox.TextSize = 14
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.Font = Enum.Font.Gotham
        TextBox.ZIndex = 103
        
        CreateCorner(6).Parent = TextBox
        CreateStroke(Theme.Purple.Main, 1, 0.7).Parent = TextBox
        
        TextBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                TextBoxCallback(TextBox.Text)
            end
        end)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return TextBox
    end
    
    function Window:AddLabel(config)
        config = config or {}
        local LabelText = config.Text or "Label"
        local IsTitle = config.IsTitle or false
        
        local Label = Instance.new("TextLabel")
        Label.Parent = self.ContentFrame
        Label.BackgroundTransparency = 1
        Label.Size = UDim2.new(1, -10, 0, 30)
        Label.Text = LabelText
        Label.TextColor3 = IsTitle and Theme.Purple.Light or Theme.Text.Secondary
        Label.TextSize = IsTitle and 18 or 14
        Label.Font = IsTitle and Enum.Font.GothamBold or Enum.Font.Gotham
        Label.ZIndex = 102
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return Label
    end
    
    function Window:AddDropdown(config)
        config = config or {}
        local DropdownName = config.Name or "Dropdown"
        local DropdownOptions = config.Options or {"Option 1", "Option 2"}
        local DefaultOption = config.Default or DropdownOptions[1]
        local DropdownCallback = config.Callback or function() end
        
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Name = DropdownName .. "Frame"
        DropdownFrame.Parent = self.ContentFrame
        DropdownFrame.BackgroundColor3 = Theme.Primary.Surface
        DropdownFrame.BackgroundTransparency = Theme.Transparency.Light
        DropdownFrame.Size = UDim2.new(1, -10, 0, 40)
        DropdownFrame.ZIndex = 102
        
        CreateCorner(10).Parent = DropdownFrame
        CreateStroke(Theme.Primary.Border, 1, 0.7).Parent = DropdownFrame
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Parent = DropdownFrame
        DropdownButton.BackgroundTransparency = 1
        DropdownButton.Size = UDim2.new(1, 0, 1, 0)
        DropdownButton.Text = DefaultOption
        DropdownButton.TextColor3 = Theme.Text.Primary
        DropdownButton.TextSize = 16
        DropdownButton.Font = Enum.Font.Gotham
        DropdownButton.ZIndex = 103
        DropdownButton.AutoButtonColor = false
        
        local DropdownArrow = Instance.new("ImageLabel")
        DropdownArrow.Parent = DropdownFrame
        DropdownArrow.BackgroundTransparency = 1
        DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
        DropdownArrow.Position = UDim2.new(1, -30, 0.5, -10)
        DropdownArrow.Image = "rbxassetid://3926305904"
        DropdownArrow.ImageRectOffset = Vector2.new(324, 364)
        DropdownArrow.ImageRectSize = Vector2.new(24, 24)
        DropdownArrow.ImageColor3 = Theme.Purple.Main
        DropdownArrow.ZIndex = 103
        
        local DropdownList = Instance.new("Frame")
        DropdownList.Name = "DropdownList"
        DropdownList.Parent = DropdownFrame
        DropdownList.BackgroundColor3 = Theme.Primary.Elevated
        DropdownList.BackgroundTransparency = Theme.Transparency.Light
        DropdownList.Size = UDim2.new(1, 0, 0, 0)
        DropdownList.Position = UDim2.new(0, 0, 1, 5)
        DropdownList.ZIndex = 110
        DropdownList.Visible = false
        
        CreateCorner(8).Parent = DropdownList
        CreateStroke(Theme.Purple.Main, 1, 0.7).Parent = DropdownList
        CreateShadow(DropdownList, 0.4)
        
        local DropdownListLayout = Instance.new("UIListLayout")
        DropdownListLayout.Parent = DropdownList
        DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local isOpen = false
        local currentSelection = DefaultOption
        
        for i, option in ipairs(DropdownOptions) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Parent = DropdownList
            OptionButton.BackgroundColor3 = Theme.Primary.Surface
            OptionButton.BackgroundTransparency = Theme.Transparency.Light
            OptionButton.Size = UDim2.new(1, 0, 0, 30)
            OptionButton.Text = option
            OptionButton.TextColor3 = Theme.Text.Primary
            OptionButton.TextSize = 14
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.ZIndex = 111
            OptionButton.AutoButtonColor = false
            
            if i == 1 then
                CreateCorner(8, 8, 0, 0).Parent = OptionButton
            elseif i == #DropdownOptions then
                CreateCorner(0, 0, 8, 8).Parent = OptionButton
            end
            
            OptionButton.MouseEnter:Connect(function()
                TweenService:Create(OptionButton, Animations.Fast, {
                    BackgroundColor3 = Theme.Purple.Main,
                    BackgroundTransparency = Theme.Transparency.None
                }):Play()
            end)
            
            OptionButton.MouseLeave:Connect(function()
                TweenService:Create(OptionButton, Animations.Fast, {
                    BackgroundColor3 = Theme.Primary.Surface,
                    BackgroundTransparency = Theme.Transparency.Light
                }):Play()
            end)
            
            OptionButton.MouseButton1Click:Connect(function()
                currentSelection = option
                DropdownButton.Text = option
                
                -- Close dropdown
                isOpen = false
                TweenService:Create(DropdownList, Animations.Medium, {
                    Size = UDim2.new(1, 0, 0, 0)
                }):Play()
                TweenService:Create(DropdownArrow, Animations.Medium, {
                    Rotation = 0
                }):Play()
                
                wait(0.3)
                DropdownList.Visible = false
                
                DropdownCallback(option)
            end)
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            
            if isOpen then
                DropdownList.Visible = true
                TweenService:Create(DropdownList, Animations.Medium, {
                    Size = UDim2.new(1, 0, 0, #DropdownOptions * 30)
                }):Play()
                TweenService:Create(DropdownArrow, Animations.Medium, {
                    Rotation = 180
                }):Play()
            else
                TweenService:Create(DropdownList, Animations.Medium, {
                    Size = UDim2.new(1, 0, 0, 0)
                }):Play()
                TweenService:Create(DropdownArrow, Animations.Medium, {
                    Rotation = 0
                }):Play()
                
                wait(0.3)
                DropdownList.Visible = false
            end
        end)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return {
            SetValue = function(value)
                if table.find(DropdownOptions, value) then
                    currentSelection = value
                    DropdownButton.Text = value
                end
            end,
            GetValue = function()
                return currentSelection
            end
        }
    end
    
    function Window:AddColorPicker(config)
        config = config or {}
        local ColorPickerName = config.Name or "Color Picker"
        local DefaultColor = config.Default or Theme.Purple.Main
        local ColorPickerCallback = config.Callback or function() end
        
        local ColorPickerFrame = Instance.new("Frame")
        ColorPickerFrame.Name = ColorPickerName .. "Frame"
        ColorPickerFrame.Parent = self.ContentFrame
        ColorPickerFrame.BackgroundColor3 = Theme.Primary.Surface
        ColorPickerFrame.BackgroundTransparency = Theme.Transparency.Light
        ColorPickerFrame.Size = UDim2.new(1, -10, 0, 40)
        ColorPickerFrame.ZIndex = 102
        
        CreateCorner(10).Parent = ColorPickerFrame
        CreateStroke(Theme.Primary.Border, 1, 0.7).Parent = ColorPickerFrame
        
        local ColorPickerLabel = Instance.new("TextLabel")
        ColorPickerLabel.Parent = ColorPickerFrame
        ColorPickerLabel.BackgroundTransparency = 1
        ColorPickerLabel.Size = UDim2.new(1, -60, 1, 0)
        ColorPickerLabel.Position = UDim2.new(0, 15, 0, 0)
        ColorPickerLabel.Text = ColorPickerName
        ColorPickerLabel.TextColor3 = Theme.Text.Primary
        ColorPickerLabel.TextSize = 16
        ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
        ColorPickerLabel.Font = Enum.Font.Gotham
        ColorPickerLabel.ZIndex = 103
        
        local ColorDisplay = Instance.new("Frame")
        ColorDisplay.Parent = ColorPickerFrame
        ColorDisplay.BackgroundColor3 = DefaultColor
        ColorDisplay.Size = UDim2.new(0, 30, 0, 30)
        ColorDisplay.Position = UDim2.new(1, -40, 0.5, -15)
        ColorDisplay.ZIndex = 103
        
        CreateCorner(6).Parent = ColorDisplay
        CreateStroke(Theme.Text.Primary, 2, 0.5).Parent = ColorDisplay
        
        local ColorButton = Instance.new("TextButton")
        ColorButton.Parent = ColorDisplay
        ColorButton.BackgroundTransparency = 1
        ColorButton.Size = UDim2.new(1, 0, 1, 0)
        ColorButton.Text = ""
        ColorButton.ZIndex = 104
        
        local currentColor = DefaultColor
        
        ColorButton.MouseButton1Click:Connect(function()
            -- Simple color cycle for demonstration
            local colors = {
                Theme.Purple.Main,
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 0, 255),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(255, 0, 255),
                Color3.fromRGB(0, 255, 255)
            }
            
            local currentIndex = 1
            for i, color in ipairs(colors) do
                if color == currentColor then
                    currentIndex = i
                    break
                end
            end
            
            currentIndex = currentIndex % #colors + 1
            currentColor = colors[currentIndex]
            
            TweenService:Create(ColorDisplay, Animations.Medium, {
                BackgroundColor3 = currentColor
            }):Play()
            
            ColorPickerCallback(currentColor)
        end)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return {
            SetColor = function(color)
                currentColor = color
                ColorDisplay.BackgroundColor3 = color
            end,
            GetColor = function()
                return currentColor
            end
        }
    end
    
    function Window:AddSection(config)
        config = config or {}
        local SectionName = config.Name or "Section"
        
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Name = SectionName .. "Section"
        SectionFrame.Parent = self.ContentFrame
        SectionFrame.BackgroundTransparency = 1
        SectionFrame.Size = UDim2.new(1, -10, 0, 40)
        SectionFrame.ZIndex = 102
        
        local SectionDivider = Instance.new("Frame")
        SectionDivider.Parent = SectionFrame
        SectionDivider.BackgroundColor3 = Theme.Purple.Main
        SectionDivider.BackgroundTransparency = 0.7
        SectionDivider.Size = UDim2.new(1, 0, 0, 1)
        SectionDivider.Position = UDim2.new(0, 0, 0.5, 0)
        SectionDivider.ZIndex = 103
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Parent = SectionFrame
        SectionLabel.BackgroundColor3 = Theme.Primary.Elevated
        SectionLabel.BackgroundTransparency = 0.2
        SectionLabel.Size = UDim2.new(0, 0, 0, 24)
        SectionLabel.Position = UDim2.new(0.5, -50, 0.5, -12)
        SectionLabel.Text = " " .. SectionName .. " "
        SectionLabel.TextColor3 = Theme.Purple.Light
        SectionLabel.TextSize = 14
        SectionLabel.Font = Enum.Font.GothamBold
        SectionLabel.ZIndex = 104
        CreateCorner(4).Parent = SectionLabel
        
        -- Auto-size label
        local textSize = TextService:GetTextSize(SectionLabel.Text, SectionLabel.TextSize, SectionLabel.Font, Vector2.new(1000, 24))
        SectionLabel.Size = UDim2.new(0, textSize.X + 20, 0, 24)
        SectionLabel.Position = UDim2.new(0.5, -textSize.X/2 - 10, 0.5, -12)
        
        CreateStroke(Theme.Purple.Main, 1, 0.6).Parent = SectionLabel
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return SectionFrame
    end
    
    function Window:AddKeybind(config)
        config = config or {}
        local KeybindName = config.Name or "Keybind"
        local DefaultKey = config.Default or Enum.KeyCode.F
        local KeybindCallback = config.Callback or function() end
        
        local KeybindFrame = Instance.new("Frame")
        KeybindFrame.Name = KeybindName .. "Frame"
        KeybindFrame.Parent = self.ContentFrame
        KeybindFrame.BackgroundColor3 = Theme.Primary.Surface
        KeybindFrame.BackgroundTransparency = Theme.Transparency.Light
        KeybindFrame.Size = UDim2.new(1, -10, 0, 40)
        KeybindFrame.ZIndex = 102
        
        CreateCorner(10).Parent = KeybindFrame
        CreateStroke(Theme.Primary.Border, 1, 0.7).Parent = KeybindFrame
        
        local KeybindLabel = Instance.new("TextLabel")
        KeybindLabel.Parent = KeybindFrame
        KeybindLabel.BackgroundTransparency = 1
        KeybindLabel.Size = UDim2.new(1, -80, 1, 0)
        KeybindLabel.Position = UDim2.new(0, 15, 0, 0)
        KeybindLabel.Text = KeybindName
        KeybindLabel.TextColor3 = Theme.Text.Primary
        KeybindLabel.TextSize = 16
        KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
        KeybindLabel.Font = Enum.Font.Gotham
        KeybindLabel.ZIndex = 103
        
        local KeybindButton = Instance.new("TextButton")
        KeybindButton.Parent = KeybindFrame
        KeybindButton.BackgroundColor3 = Theme.Primary.Background
        KeybindButton.BackgroundTransparency = Theme.Transparency.Light
        KeybindButton.Size = UDim2.new(0, 60, 0, 25)
        KeybindButton.Position = UDim2.new(1, -70, 0.5, -12.5)
        KeybindButton.Text = DefaultKey.Name
        KeybindButton.TextColor3 = Theme.Purple.Light
        KeybindButton.TextSize = 14
        KeybindButton.Font = Enum.Font.GothamBold
        KeybindButton.ZIndex = 103
        
        CreateCorner(6).Parent = KeybindButton
        CreateStroke(Theme.Purple.Main, 1, 0.7).Parent = KeybindButton
        
        local currentKey = DefaultKey
        local isBinding = false
        
        KeybindButton.MouseButton1Click:Connect(function()
            if not isBinding then
                isBinding = true
                KeybindButton.Text = "..."
                KeybindButton.BackgroundColor3 = Theme.Purple.Main
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        KeybindButton.Text = currentKey.Name
                        KeybindButton.BackgroundColor3 = Theme.Primary.Background
                        isBinding = false
                        connection:Disconnect()
                    end
                end)
            end
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == currentKey and not isBinding then
                KeybindCallback()
            end
        end)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return {
            SetKey = function(key)
                currentKey = key
                KeybindButton.Text = key.Name
            end,
            GetKey = function()
                return currentKey
            end
        }
    end
    
    function Window:Destroy()
        self.ScreenGui:Destroy()
    end
    
    function Window:SetVisible(visible)
        self.ScreenGui.Enabled = visible
    end
    
    function Window:SetTitle(title)
        self.MainFrame.TitleBar.TitleText.Text = title
    end
    
    return Window
end

-- Enhanced Notification System
function i2zq:CreateNotification(config)
    config = config or {}
    local Title = config.Title or "Notification"
    local Description = config.Description or "This is a notification"
    local Duration = config.Duration or 5
    local Type = config.Type or "info" -- info, success, warning, error
    
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "i2zqNotification"
    NotificationGui.Parent = PlayerGui
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Parent = NotificationGui
    NotificationFrame.BackgroundColor3 = Theme.Primary.Elevated
    NotificationFrame.BackgroundTransparency = 0.2
    NotificationFrame.Size = UDim2.new(0, 320, 0, 90)
    NotificationFrame.Position = UDim2.new(1, 20, 0, 50)
    NotificationFrame.ZIndex = 200
    
    CreateCorner(12).Parent = NotificationFrame
    CreateStroke(Theme.Purple.Main, 1.5, 0.6).Parent = NotificationFrame
    CreateShadow(NotificationFrame, 0.5, 20)
    
    -- Glass effect
    local glass = CreateGlassEffect(NotificationFrame)
    glass.Parent = NotificationFrame
    
    local TypeColors = {
        info = Theme.Purple.Main,
        success = Color3.fromRGB(46, 204, 113),
        warning = Color3.fromRGB(241, 196, 15),
        error = Color3.fromRGB(231, 76, 60)
    }
    
    local TypeIndicator = Instance.new("Frame")
    TypeIndicator.Parent = NotificationFrame
    TypeIndicator.BackgroundColor3 = TypeColors[Type] or Theme.Purple.Main
    TypeIndicator.Size = UDim2.new(0, 4, 1, 0)
    TypeIndicator.Position = UDim2.new(0, 0, 0, 0)
    TypeIndicator.ZIndex = 201
    
    CreateCorner(2).Parent = TypeIndicator
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = NotificationFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -40, 0, 25)
    TitleLabel.Position = UDim2.new(0, 15, 0, 10)
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.Text.Primary
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.ZIndex = 201
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Parent = NotificationFrame
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Size = UDim2.new(1, -40, 0, 40)
    DescriptionLabel.Position = UDim2.new(0, 15, 0, 35)
    DescriptionLabel.Text = Description
    DescriptionLabel.TextColor3 = Theme.Text.Secondary
    DescriptionLabel.TextSize = 14
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.TextWrapped = true
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.ZIndex = 201
    
    local CloseButton = Instance.new("ImageButton")
    CloseButton.Parent = NotificationFrame
    CloseButton.BackgroundTransparency = 1
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -30, 0, 10)
    CloseButton.Image = "rbxassetid://3926305904"
    CloseButton.ImageRectOffset = Vector2.new(284, 4)
    CloseButton.ImageRectSize = Vector2.new(24, 24)
    CloseButton.ImageColor3 = Theme.Text.Muted
    CloseButton.ZIndex = 201
    
    -- Slide in animation
    TweenService:Create(NotificationFrame, Animations.Bounce, {
        Position = UDim2.new(1, -340, 0, 50)
    }):Play()
    
    -- Auto close
    local function closeNotification()
        TweenService:Create(NotificationFrame, Animations.Medium, {
            Position = UDim2.new(1, 20, 0, 50),
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(TitleLabel, Animations.Medium, {
            TextTransparency = 1
        }):Play()
        
        TweenService:Create(DescriptionLabel, Animations.Medium, {
            TextTransparency = 1
        }):Play()
        
        wait(0.3)
        NotificationGui:Destroy()
    end
    
    CloseButton.MouseButton1Click:Connect(closeNotification)
    
    -- Auto close timer
    if Duration > 0 then
        spawn(function()
            wait(Duration)
            if NotificationGui.Parent then
                closeNotification()
            end
        end)
    end
    
    return {
        Close = closeNotification
    }
end

-- Modern Loading Screen
function i2zq:CreateLoadingScreen(config)
    config = config or {}
    local Title = config.Title or "Loading..."
    local Description = config.Description or "Please wait while we load your content"
    
    local LoadingGui = Instance.new("ScreenGui")
    LoadingGui.Name = "i2zqLoading"
    LoadingGui.Parent = PlayerGui
    LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Parent = LoadingGui
    LoadingFrame.BackgroundColor3 = Theme.Primary.Background
    LoadingFrame.BackgroundTransparency = 0.2
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.Position = UDim2.new(0, 0, 0, 0)
    LoadingFrame.ZIndex = 250
    
    local LoadingContent = Instance.new("Frame")
    LoadingContent.Parent = LoadingFrame
    LoadingContent.BackgroundColor3 = Theme.Primary.Elevated
    LoadingContent.BackgroundTransparency = Theme.Transparency.Light
    LoadingContent.Size = UDim2.new(0, 400, 0, 220)
    LoadingContent.Position = UDim2.new(0.5, -200, 0.5, -110)
    LoadingContent.ZIndex = 251
    
    CreateCorner(14).Parent = LoadingContent
    CreateStroke(Theme.Purple.Main, 2, 0.6).Parent = LoadingContent
    CreateShadow(LoadingContent, 0.8, 30)
    
    -- Glass effect
    local glass = CreateGlassEffect(LoadingContent)
    glass.Parent = LoadingContent
    
    local LoadingTitle = Instance.new("TextLabel")
    LoadingTitle.Parent = LoadingContent
    LoadingTitle.BackgroundTransparency = 1
    LoadingTitle.Size = UDim2.new(1, -40, 0, 40)
    LoadingTitle.Position = UDim2.new(0, 20, 0, 20)
    LoadingTitle.Text = Title
    LoadingTitle.TextColor3 = Theme.Text.Primary
    LoadingTitle.TextSize = 22
    LoadingTitle.Font = Enum.Font.GothamBold
    LoadingTitle.ZIndex = 252
    
    local LoadingDescription = Instance.new("TextLabel")
    LoadingDescription.Parent = LoadingContent
    LoadingDescription.BackgroundTransparency = 1
    LoadingDescription.Size = UDim2.new(1, -40, 0, 30)
    LoadingDescription.Position = UDim2.new(0, 20, 0, 70)
    LoadingDescription.Text = Description
    LoadingDescription.TextColor3 = Theme.Text.Secondary
    LoadingDescription.TextSize = 16
    LoadingDescription.Font = Enum.Font.Gotham
    LoadingDescription.ZIndex = 252
    
    -- Loading Animation
    local LoadingBar = Instance.new("Frame")
    LoadingBar.Parent = LoadingContent
    LoadingBar.BackgroundColor3 = Theme.Primary.Background
    LoadingBar.Size = UDim2.new(1, -40, 0, 8)
    LoadingBar.Position = UDim2.new(0, 20, 0, 120)
    LoadingBar.ZIndex = 252
    
    CreateCorner(4).Parent = LoadingBar
    
    local LoadingProgress = Instance.new("Frame")
    LoadingProgress.Parent = LoadingBar
    LoadingProgress.BackgroundColor3 = Theme.Purple.Main
    LoadingProgress.Size = UDim2.new(0, 0, 1, 0)
    LoadingProgress.Position = UDim2.new(0, 0, 0, 0)
    LoadingProgress.ZIndex = 253
    
    CreateCorner(4).Parent = LoadingProgress
    
    -- Spinning loader
    local Spinner = Instance.new("Frame")
    Spinner.Parent = LoadingContent
    Spinner.BackgroundTransparency = 1
    Spinner.Size = UDim2.new(0, 40, 0, 40)
    Spinner.Position = UDim2.new(0.5, -20, 0, 150)
    Spinner.ZIndex = 252
    
    local SpinnerRing = Instance.new("Frame")
    SpinnerRing.Parent = Spinner
    SpinnerRing.BackgroundTransparency = 1
    SpinnerRing.Size = UDim2.new(1, 0, 1, 0)
    SpinnerRing.ZIndex = 253
    
    CreateStroke(Theme.Purple.Main, 4, 0.5).Parent = SpinnerRing
    CreateCorner(20).Parent = SpinnerRing
    
    -- Spin animation
    local spinTween = TweenService:Create(SpinnerRing, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
        Rotation = 360
    })
    spinTween:Play()
    
    local LoadingScreen = {
        Gui = LoadingGui,
        Progress = LoadingProgress,
        Title = LoadingTitle,
        Description = LoadingDescription
    }
    
    function LoadingScreen:SetProgress(progress)
        progress = math.clamp(progress, 0, 1)
        TweenService:Create(self.Progress, Animations.Medium, {
            Size = UDim2.new(progress, 0, 1, 0)
        }):Play()
    end
    
    function LoadingScreen:SetTitle(title)
        self.Title.Text = title
    end
    
    function LoadingScreen:SetDescription(description)
        self.Description.Text = description
    end
    
    function LoadingScreen:Close()
        spinTween:Cancel()
        TweenService:Create(LoadingContent, Animations.Elastic, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(LoadingFrame, Animations.Elastic, {
            BackgroundTransparency = 1
        }):Play()
        
        wait(0.4)
        self.Gui:Destroy()
    end
    
    return LoadingScreen
end

-- Initialize Library
print("🚀 i2zq Library v2.0 Loaded Successfully!")

return i2zq
