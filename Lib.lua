-- i2zq Library v1.0
-- The Ultimate Roblox UI Framework
-- Created for sleek, modern interfaces with black/purple theme

local i2zq = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Theme Configuration
local Theme = {
    Primary = {
        Background = Color3.fromRGB(15, 15, 20),
        Surface = Color3.fromRGB(25, 25, 35),
        Elevated = Color3.fromRGB(35, 35, 50),
        Border = Color3.fromRGB(60, 60, 80)
    },
    Purple = {
        Main = Color3.fromRGB(138, 43, 226),
        Light = Color3.fromRGB(155, 89, 182),
        Dark = Color3.fromRGB(102, 51, 153),
        Glow = Color3.fromRGB(186, 85, 211)
    },
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(200, 200, 220),
        Muted = Color3.fromRGB(150, 150, 170)
    },
    Transparency = {
        None = 0,
        Light = 0.1,
        Medium = 0.3,
        Heavy = 0.6
    }
}

-- Animation Presets
local Animations = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

-- Utility Functions
local function CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function CreateStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Primary.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = 0.5
    return stroke
end

local function CreateGradient(colorSequence, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    gradient.Rotation = rotation or 0
    return gradient
end

local function CreateShadow(parent, intensity)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = parent
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 1 - (intensity or 0.3)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.ZIndex = parent.ZIndex - 1
    CreateCorner(12).Parent = shadow
    return shadow
end

local function CreateGlow(parent, color)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.Parent = parent
    glow.BackgroundTransparency = 1
    glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    glow.ImageColor3 = color or Theme.Purple.Glow
    glow.ImageTransparency = 0.8
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.ZIndex = parent.ZIndex - 1
    CreateCorner(16).Parent = glow
    return glow
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
    
    -- Main Frame
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
    
    CreateCorner(12).Parent = MainFrame
    CreateStroke(Theme.Purple.Main, 2).Parent = MainFrame
    CreateShadow(MainFrame, 0.5)
    CreateGlow(MainFrame, Theme.Purple.Glow)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Theme.Primary.Elevated
    TitleBar.BackgroundTransparency = Theme.Transparency.Light
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.ZIndex = 101
    
    CreateCorner(12).Parent = TitleBar
    CreateStroke(Theme.Primary.Border, 1).Parent = TitleBar
    
    -- Title gradient
    local titleGradient = CreateGradient(
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.Purple.Dark),
            ColorSequenceKeypoint.new(1, Theme.Purple.Main)
        }),
        45
    )
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
    TitleText.TextScaled = true
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.GothamBold
    TitleText.ZIndex = 102
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Theme.Primary.Surface
    CloseButton.BackgroundTransparency = Theme.Transparency.Medium
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 5)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Theme.Text.Primary
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.ZIndex = 102
    
    CreateCorner(6).Parent = CloseButton
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TitleBar
    MinimizeButton.BackgroundColor3 = Theme.Primary.Surface
    MinimizeButton.BackgroundTransparency = Theme.Transparency.Medium
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -75, 0, 5)
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = Theme.Text.Primary
    MinimizeButton.TextScaled = true
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.ZIndex = 102
    
    CreateCorner(6).Parent = MinimizeButton
    
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
    ScrollFrame.ZIndex = 101
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    
    -- Window Object
    local Window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        ContentFrame = ScrollFrame,
        IsMinimized = false,
        OriginalSize = WindowSize
    }
    
    -- Button Animations
    local function animateButton(button)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, Animations.Fast, {
                BackgroundTransparency = 0,
                BackgroundColor3 = Theme.Purple.Main
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, Animations.Fast, {
                BackgroundTransparency = Theme.Transparency.Medium,
                BackgroundColor3 = Theme.Primary.Surface
            }):Play()
        end)
    end
    
    animateButton(CloseButton)
    animateButton(MinimizeButton)
    
    -- Button Functionality
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, Animations.Medium, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if not Window.IsMinimized then
            TweenService:Create(MainFrame, Animations.Medium, {
                Size = UDim2.new(Window.OriginalSize.X.Scale, Window.OriginalSize.X.Offset, 0, 40)
            }):Play()
            MinimizeButton.Text = "+"
            Window.IsMinimized = true
        else
            TweenService:Create(MainFrame, Animations.Medium, {
                Size = Window.OriginalSize
            }):Play()
            MinimizeButton.Text = "−"
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
        Button.Size = UDim2.new(1, -10, 0, 40)
        Button.Text = ButtonName
        Button.TextColor3 = Theme.Text.Primary
        Button.TextScaled = true
        Button.Font = Enum.Font.Gotham
        Button.ZIndex = 102
        
        CreateCorner(8).Parent = Button
        CreateStroke(Theme.Purple.Main, 1).Parent = Button
        
        -- Button animations
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, Animations.Fast, {
                BackgroundColor3 = Theme.Purple.Main,
                BackgroundTransparency = Theme.Transparency.None
            }):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, Animations.Fast, {
                BackgroundColor3 = Theme.Primary.Surface,
                BackgroundTransparency = Theme.Transparency.Light
            }):Play()
        end)
        
        Button.MouseButton1Click:Connect(function()
            -- Click animation
            TweenService:Create(Button, Animations.Fast, {
                Size = UDim2.new(1, -15, 0, 35)
            }):Play()
            
            wait(0.1)
            
            TweenService:Create(Button, Animations.Fast, {
                Size = UDim2.new(1, -10, 0, 40)
            }):Play()
            
            ButtonCallback()
        end)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return Button
    end
    
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
        
        CreateCorner(8).Parent = ToggleFrame
        CreateStroke(Theme.Primary.Border, 1).Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
        ToggleLabel.Text = ToggleName
        ToggleLabel.TextColor3 = Theme.Text.Primary
        ToggleLabel.TextScaled = true
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.ZIndex = 103
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = DefaultValue and Theme.Purple.Main or Theme.Primary.Background
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
        ToggleButton.Text = ""
        ToggleButton.ZIndex = 103
        
        CreateCorner(10).Parent = ToggleButton
        
        local ToggleSlider = Instance.new("Frame")
        ToggleSlider.Parent = ToggleButton
        ToggleSlider.BackgroundColor3 = Theme.Text.Primary
        ToggleSlider.Size = UDim2.new(0, 16, 0, 16)
        ToggleSlider.Position = DefaultValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleSlider.ZIndex = 104
        
        CreateCorner(8).Parent = ToggleSlider
        
        local isToggled = DefaultValue
        
        ToggleButton.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            
            TweenService:Create(ToggleButton, Animations.Medium, {
                BackgroundColor3 = isToggled and Theme.Purple.Main or Theme.Primary.Background
            }):Play()
            
            TweenService:Create(ToggleSlider, Animations.Medium, {
                Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            ToggleCallback(isToggled)
        end)
        
        self.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        
        return {
            Toggle = ToggleButton,
            SetValue = function(value)
                isToggled = value
                TweenService:Create(ToggleButton, Animations.Medium, {
                    BackgroundColor3 = isToggled and Theme.Purple.Main or Theme.Primary.Background
                }):Play()
                TweenService:Create(ToggleSlider, Animations.Medium, {
                    Position = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
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
        
        CreateCorner(8).Parent = SliderFrame
        CreateStroke(Theme.Primary.Border, 1).Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Size = UDim2.new(1, -20, 0, 25)
        SliderLabel.Position = UDim2.new(0, 10, 0, 5)
        SliderLabel.Text = SliderName
        SliderLabel.TextColor3 = Theme.Text.Primary
        SliderLabel.TextScaled = true
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
        SliderValue.TextScaled = true
        SliderValue.TextXAlignment = Enum.TextXAlignment.Right
        SliderValue.Font = Enum.Font.GothamBold
        SliderValue.ZIndex = 103
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Parent = SliderFrame
        SliderTrack.BackgroundColor3 = Theme.Primary.Background
        SliderTrack.Size = UDim2.new(1, -20, 0, 6)
        SliderTrack.Position = UDim2.new(0, 10, 1, -16)
        SliderTrack.ZIndex = 103
        
        CreateCorner(3).Parent = SliderTrack
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderTrack
        SliderFill.BackgroundColor3 = Theme.Purple.Main
        SliderFill.Size = UDim2.new((DefaultValue - MinValue) / (MaxValue - MinValue), 0, 1, 0)
        SliderFill.Position = UDim2.new(0, 0, 0, 0)
        SliderFill.ZIndex = 104
        
        CreateCorner(3).Parent = SliderFill
        
        local SliderKnob = Instance.new("Frame")
        SliderKnob.Parent = SliderTrack
        SliderKnob.BackgroundColor3 = Theme.Text.Primary
        SliderKnob.Size = UDim2.new(0, 14, 0, 14)
        SliderKnob.Position = UDim2.new((DefaultValue - MinValue) / (MaxValue - MinValue), -7, 0.5, -7)
        SliderKnob.ZIndex = 105
        
        CreateCorner(7).Parent = SliderKnob
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
                Position = UDim2.new(pos, -7, 0.5, -7)
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
                SliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
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
        
        CreateCorner(8).Parent = TextBoxFrame
        CreateStroke(Theme.Primary.Border, 1).Parent = TextBoxFrame
        
        local TextBoxLabel = Instance.new("TextLabel")
        TextBoxLabel.Parent = TextBoxFrame
        TextBoxLabel.BackgroundTransparency = 1
        TextBoxLabel.Size = UDim2.new(1, -20, 0, 25)
        TextBoxLabel.Position = UDim2.new(0, 10, 0, 5)
        TextBoxLabel.Text = TextBoxName
        TextBoxLabel.TextColor3 = Theme.Text.Primary
        TextBoxLabel.TextScaled = true
        TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextBoxLabel.Font = Enum.Font.Gotham
        TextBoxLabel.ZIndex = 103
        
        local TextBox = Instance.new("TextBox")
        TextBox.Parent = TextBoxFrame
        TextBox.BackgroundColor3 = Theme.Primary.Background
        TextBox.BackgroundTransparency = Theme.Transparency.Light
        TextBox.Size = UDim2.new(1, -20, 0, 25)
        TextBox.Position = UDim2.new(0, 10, 1, -30)
        TextBox.PlaceholderText = PlaceholderText
        TextBox.PlaceholderColor3 = Theme.Text.Muted
        TextBox.Text = ""
        TextBox.TextColor3 = Theme.Text.Primary
        TextBox.TextScaled = true
        TextBox.TextXAlignment = Enum.TextXAlignment.Left
        TextBox.Font = Enum.Font.Gotham
        TextBox.ZIndex = 103
        
        CreateCorner(6).Parent = TextBox
        CreateStroke(Theme.Purple.Main, 1).Parent = TextBox
        
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
        
        local Label = Instance.new("TextLabel")
        Label.Parent = self.ContentFrame
        Label.BackgroundColor3 = Theme.Primary.Surface
        Label.BackgroundTransparency = Theme.Transparency.Medium
        Label.Size = UDim2.new(1, -10, 0, 30)
        Label.Text = LabelText
        Label.TextColor3 = Theme.Text.Secondary
        Label.TextScaled = true
        Label.Font = Enum.Font.Gotham
        Label.ZIndex = 102
        
        CreateCorner(8).Parent = Label
        
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
        
        CreateCorner(8).Parent = DropdownFrame
        CreateStroke(Theme.Primary.Border, 1).Parent = DropdownFrame
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Parent = DropdownFrame
        DropdownButton.BackgroundTransparency = 1
        DropdownButton.Size = UDim2.new(1, 0, 1, 0)
        DropdownButton.Text = DefaultOption
        DropdownButton.TextColor3 = Theme.Text.Primary
        DropdownButton.TextScaled = true
        DropdownButton.Font = Enum.Font.Gotham
        DropdownButton.ZIndex = 103
        
        local DropdownArrow = Instance.new("TextLabel")
        DropdownArrow.Parent = DropdownFrame
        DropdownArrow.BackgroundTransparency = 1
        DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
        DropdownArrow.Position = UDim2.new(1, -25, 0, 0)
        DropdownArrow.Text = "▼"
        DropdownArrow.TextColor3 = Theme.Purple.Main
        DropdownArrow.TextScaled = true
        DropdownArrow.Font = Enum.Font.Gotham
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
        CreateStroke(Theme.Purple.Main, 1).Parent = DropdownList
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
            OptionButton.TextScaled = true
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.ZIndex = 111
            
            if i == 1 then
                CreateCorner(8).Parent = OptionButton
            elseif i == #DropdownOptions then
                CreateCorner(8).Parent = OptionButton
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
        
        CreateCorner(8).Parent = ColorPickerFrame
        CreateStroke(Theme.Primary.Border, 1).Parent = ColorPickerFrame
        
        local ColorPickerLabel = Instance.new("TextLabel")
        ColorPickerLabel.Parent = ColorPickerFrame
        ColorPickerLabel.BackgroundTransparency = 1
        ColorPickerLabel.Size = UDim2.new(1, -60, 1, 0)
        ColorPickerLabel.Position = UDim2.new(0, 15, 0, 0)
        ColorPickerLabel.Text = ColorPickerName
        ColorPickerLabel.TextColor3 = Theme.Text.Primary
        ColorPickerLabel.TextScaled = true
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
        CreateStroke(Theme.Text.Primary, 2).Parent = ColorDisplay
        
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
        SectionFrame.BackgroundColor3 = Theme.Primary.Elevated
        SectionFrame.BackgroundTransparency = Theme.Transparency.Medium
        SectionFrame.Size = UDim2.new(1, -10, 0, 30)
        SectionFrame.ZIndex = 102
        
        CreateCorner(8).Parent = SectionFrame
        CreateStroke(Theme.Purple.Main, 1).Parent = SectionFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Parent = SectionFrame
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Size = UDim2.new(1, -20, 1, 0)
        SectionLabel.Position = UDim2.new(0, 10, 0, 0)
        SectionLabel.Text = SectionName
        SectionLabel.TextColor3 = Theme.Purple.Light
        SectionLabel.TextScaled = true
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        SectionLabel.Font = Enum.Font.GothamBold
        SectionLabel.ZIndex = 103
        
        -- Section gradient
        local sectionGradient = CreateGradient(
            ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.Purple.Dark),
                ColorSequenceKeypoint.new(1, Theme.Primary.Elevated)
            }),
            90
        )
        sectionGradient.Parent = SectionFrame
        
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
        
        CreateCorner(8).Parent = KeybindFrame
        CreateStroke(Theme.Primary.Border, 1).Parent = KeybindFrame
        
        local KeybindLabel = Instance.new("TextLabel")
        KeybindLabel.Parent = KeybindFrame
        KeybindLabel.BackgroundTransparency = 1
        KeybindLabel.Size = UDim2.new(1, -80, 1, 0)
        KeybindLabel.Position = UDim2.new(0, 15, 0, 0)
        KeybindLabel.Text = KeybindName
        KeybindLabel.TextColor3 = Theme.Text.Primary
        KeybindLabel.TextScaled = true
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
        KeybindButton.TextScaled = true
        KeybindButton.Font = Enum.Font.GothamBold
        KeybindButton.ZIndex = 103
        
        CreateCorner(6).Parent = KeybindButton
        CreateStroke(Theme.Purple.Main, 1).Parent = KeybindButton
        
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

-- Notification System
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
    NotificationFrame.BackgroundTransparency = Theme.Transparency.Light
    NotificationFrame.Size = UDim2.new(0, 300, 0, 80)
    NotificationFrame.Position = UDim2.new(1, 20, 0, 50)
    NotificationFrame.ZIndex = 200
    
    CreateCorner(10).Parent = NotificationFrame
    CreateStroke(Theme.Purple.Main, 2).Parent = NotificationFrame
    CreateShadow(NotificationFrame, 0.6)
    CreateGlow(NotificationFrame, Theme.Purple.Glow)
    
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
    TitleLabel.Size = UDim2.new(1, -50, 0, 25)
    TitleLabel.Position = UDim2.new(0, 15, 0, 10)
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Theme.Text.Primary
    TitleLabel.TextScaled = true
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.ZIndex = 201
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Parent = NotificationFrame
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Size = UDim2.new(1, -50, 0, 35)
    DescriptionLabel.Position = UDim2.new(0, 15, 0, 35)
    DescriptionLabel.Text = Description
    DescriptionLabel.TextColor3 = Theme.Text.Secondary
    DescriptionLabel.TextScaled = true
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.TextWrapped = true
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.ZIndex = 201
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Parent = NotificationFrame
    CloseButton.BackgroundTransparency = 1
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -25, 0, 5)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Theme.Text.Muted
    CloseButton.TextScaled = true
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.ZIndex = 201
    
    -- Slide in animation
    TweenService:Create(NotificationFrame, Animations.Bounce, {
        Position = UDim2.new(1, -320, 0, 50)
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
end

-- Loading Screen
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
    LoadingContent.Size = UDim2.new(0, 400, 0, 200)
    LoadingContent.Position = UDim2.new(0.5, -200, 0.5, -100)
    LoadingContent.ZIndex = 251
    
    CreateCorner(12).Parent = LoadingContent
    CreateStroke(Theme.Purple.Main, 2).Parent = LoadingContent
    CreateShadow(LoadingContent, 0.8)
    CreateGlow(LoadingContent, Theme.Purple.Glow)
    
    local LoadingTitle = Instance.new("TextLabel")
    LoadingTitle.Parent = LoadingContent
    LoadingTitle.BackgroundTransparency = 1
    LoadingTitle.Size = UDim2.new(1, -40, 0, 40)
    LoadingTitle.Position = UDim2.new(0, 20, 0, 20)
    LoadingTitle.Text = Title
    LoadingTitle.TextColor3 = Theme.Text.Primary
    LoadingTitle.TextScaled = true
    LoadingTitle.Font = Enum.Font.GothamBold
    LoadingTitle.ZIndex = 252
    
    local LoadingDescription = Instance.new("TextLabel")
    LoadingDescription.Parent = LoadingContent
    LoadingDescription.BackgroundTransparency = 1
    LoadingDescription.Size = UDim2.new(1, -40, 0, 30)
    LoadingDescription.Position = UDim2.new(0, 20, 0, 70)
    LoadingDescription.Text = Description
    LoadingDescription.TextColor3 = Theme.Text.Secondary
    LoadingDescription.TextScaled = true
    LoadingDescription.Font = Enum.Font.Gotham
    LoadingDescription.ZIndex = 252
    
    -- Loading Animation
    local LoadingBar = Instance.new("Frame")
    LoadingBar.Parent = LoadingContent
    LoadingBar.BackgroundColor3 = Theme.Primary.Background
    LoadingBar.Size = UDim2.new(1, -40, 0, 6)
    LoadingBar.Position = UDim2.new(0, 20, 0, 120)
    LoadingBar.ZIndex = 252
    
    CreateCorner(3).Parent = LoadingBar
    
    local LoadingProgress = Instance.new("Frame")
    LoadingProgress.Parent = LoadingBar
    LoadingProgress.BackgroundColor3 = Theme.Purple.Main
    LoadingProgress.Size = UDim2.new(0, 0, 1, 0)
    LoadingProgress.Position = UDim2.new(0, 0, 0, 0)
    LoadingProgress.ZIndex = 253
    
    CreateCorner(3).Parent = LoadingProgress
    
    -- Spinning loader
    local Spinner = Instance.new("Frame")
    Spinner.Parent = LoadingContent
    Spinner.BackgroundTransparency = 1
    Spinner.Size = UDim2.new(0, 30, 0, 30)
    Spinner.Position = UDim2.new(0.5, -15, 0, 150)
    Spinner.ZIndex = 252
    
    local SpinnerRing = Instance.new("Frame")
    SpinnerRing.Parent = Spinner
    SpinnerRing.BackgroundTransparency = 1
    SpinnerRing.Size = UDim2.new(1, 0, 1, 0)
    SpinnerRing.ZIndex = 253
    
    CreateStroke(Theme.Purple.Main, 3).Parent = SpinnerRing
    CreateCorner(15).Parent = SpinnerRing
    
    -- Spin animation
    local spinTween = TweenService:Create(SpinnerRing, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
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
        TweenService:Create(LoadingContent, Animations.Medium, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(LoadingFrame, Animations.Medium, {
            BackgroundTransparency = 1
        }):Play()
        
        wait(0.3)
        self.Gui:Destroy()
    end
    
    return LoadingScreen
end


-- Initialize Library
print("🚀 i2zq Library v1.0 Loaded Successfully!")

return i2zq
