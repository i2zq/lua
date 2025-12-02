-- // EngoUI V3 - Modern Edition
local mouse = game.Players.LocalPlayer:GetMouse()
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local rainbowvalue = 0.01

-- Modern Themes
EngoThemes = {
    Engo = {
        TextColor = Color3.fromRGB(255, 255, 255),
        DescriptionTextColor = Color3.fromRGB(200, 200, 200),
        DarkTextColor = Color3.fromRGB(150, 150, 150),
        DarkContrast = Color3.fromRGB(20, 20, 30),
        LightContrast = Color3.fromRGB(30, 30, 45),
        BackgroundGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(15, 15, 25)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 20, 35))},
        Darkness = Color3.fromRGB(10, 10, 15),
        Accent = Color3.fromRGB(0, 170, 255),
        SecondaryAccent = Color3.fromRGB(100, 70, 255),
        GlassTransparency = 0.1,
        BlurEnabled = true
    },
    ModernDark = {
        TextColor = Color3.fromRGB(255, 255, 255),
        DescriptionTextColor = Color3.fromRGB(180, 180, 180),
        DarkTextColor = Color3.fromRGB(130, 130, 130),
        DarkContrast = Color3.fromRGB(25, 25, 35),
        LightContrast = Color3.fromRGB(35, 35, 50),
        BackgroundGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 20, 30)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(25, 25, 40))},
        Darkness = Color3.fromRGB(15, 15, 20),
        Accent = Color3.fromRGB(0, 200, 255),
        SecondaryAccent = Color3.fromRGB(120, 80, 255),
        GlassTransparency = 0.15,
        BlurEnabled = true
    },
    Cyberpunk = {
        TextColor = Color3.fromRGB(255, 255, 255),
        DescriptionTextColor = Color3.fromRGB(200, 200, 255),
        DarkTextColor = Color3.fromRGB(150, 150, 200),
        DarkContrast = Color3.fromRGB(25, 15, 40),
        LightContrast = Color3.fromRGB(40, 25, 60),
        BackgroundGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 10, 35)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(30, 15, 50))},
        Darkness = Color3.fromRGB(15, 5, 25),
        Accent = Color3.fromRGB(255, 0, 255),
        SecondaryAccent = Color3.fromRGB(0, 255, 255),
        GlassTransparency = 0.2,
        BlurEnabled = true
    },
    Neon = {
        TextColor = Color3.fromRGB(255, 255, 255),
        DescriptionTextColor = Color3.fromRGB(200, 255, 200),
        DarkTextColor = Color3.fromRGB(150, 200, 150),
        DarkContrast = Color3.fromRGB(20, 35, 25),
        LightContrast = Color3.fromRGB(30, 50, 35),
        BackgroundGradient = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(15, 25, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 35, 25))},
        Darkness = Color3.fromRGB(10, 20, 15),
        Accent = Color3.fromRGB(0, 255, 0),
        SecondaryAccent = Color3.fromRGB(255, 255, 0),
        GlassTransparency = 0.1,
        BlurEnabled = true
    }
}

local theme = EngoThemes.Engo

-- Functions
local old_err = error
local function error(message)
    old_err("[EngoUILib] "..tostring(message))
end

local function getTextFromKeyCode(keycode)
    local success, result = pcall(function()
        return keycode.Name
    end)
    if success then
        return result, true
    else
        return "None", false
    end
end

local function RelativeXY(GuiObject, location)
	local x, y = location.X - GuiObject.AbsolutePosition.X, location.Y - GuiObject.AbsolutePosition.Y
	local x2 = 0
	local xm, ym = GuiObject.AbsoluteSize.X, GuiObject.AbsoluteSize.Y
	x2 = math.clamp(x, 4, xm - 6)
	x = math.clamp(x, 0, xm)
	y = math.clamp(y, 0, ym)
	return x, y, x/xm, y/ym, x2/xm
end

-- Rainbow effect for accents
spawn(function()
	while true do
		for i = 0, 1, 0.01 do
			task.wait(0.03)
			rainbowvalue = i
		end
	end
end)

-- Create blur effect
local function createBlurEffect(parent)
    if theme.BlurEnabled then
        local blur = Instance.new("BlurEffect")
        blur.Size = 24
        blur.Parent = parent
        
        -- Create glass effect
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(240, 240, 255))
        }
        gradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.7),
            NumberSequenceKeypoint.new(1, 0.9)
        }
        gradient.Rotation = 90
        gradient.Parent = parent
    end
end

-- Animation function
local function animateButton(button)
    TS:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1
    }):Play()
end

local function animateButtonOut(button)
    TS:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = theme.GlassTransparency
    }):Play()
end

-- Modern library
local library = {}
function library:SetTheme(themeSel)
    if EngoThemes[themeSel] then 
        theme = EngoThemes[themeSel]
    elseif typeof(themeSel) == "table" then
        for i,v in pairs(EngoThemes.Engo) do
            if not themeSel[i] then
                error("Custom themes needs "..tostring(i).." to work properly!")
            end
        end
        theme = themeSel
    else
        error("Invalid theme!, please use correct name or custom theme.")
    end
end

function library:CreateMain(title, description, keycode)
    library["OriginalBind"] = keycode
    library["Bind"] = keycode
    local closeconnection 
    
    function onSelfDestroy()
        if getgenv().userInputConnection then
            getgenv().userInputConnection:Disconnect()
            getgenv().userInputConnection = nil
        end
        if closeconnection then
            closeconnection:Disconnect()
        end
    end
    
    if getgenv().EngoUILib then 
        getgenv().EngoUILib:Destroy() 
        onSelfDestroy()
    end
    
    local firstTab
    local EngoUI = Instance.new("ScreenGui")
    if syn then 
        syn.protect_gui(EngoUI)
    end
    EngoUI.Parent = gethui and gethui() or game.CoreGui
    getgenv().EngoUILib = EngoUI
    
    -- Create background blur
    createBlurEffect(game:GetService("Lighting"))
    
    closeconnection = UIS.InputEnded:Connect(function(input,yes)
        local TextBoxFocused = UIS:GetFocusedTextBox()
        if TextBoxFocused then return end
        if input.KeyCode == library["Bind"] and not yes and not library["IsBinding"] then
            EngoUI.Enabled = not EngoUI.Enabled
        end
    end)

    -- Main Container with glass effect
    local Main = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local UIGradient = Instance.new("UIGradient")
    local BackgroundBlur = Instance.new("Frame")
    local BackgroundBlurCorner = Instance.new("UICorner")
    local Sidebar = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local Topbar = Instance.new("Frame")
    local Info = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Description = Instance.new("TextLabel")
    local TabContainer = Instance.new("Frame")
    local GlowEffect = Instance.new("ImageLabel")

    EngoUI.Name = "EngoUI"
    EngoUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    EngoUI.IgnoreGuiInset = true

    -- Glow effect for main window
    GlowEffect.Name = "GlowEffect"
    GlowEffect.Parent = EngoUI
    GlowEffect.BackgroundTransparency = 1
    GlowEffect.Size = UDim2.new(0, 600, 0, 450)
    GlowEffect.Position = UDim2.new(0.5, -300, 0.5, -225)
    GlowEffect.Image = "rbxassetid://4996891970"
    GlowEffect.ImageColor3 = theme.Accent
    GlowEffect.ImageTransparency = 0.8
    GlowEffect.ScaleType = Enum.ScaleType.Slice
    GlowEffect.SliceCenter = Rect.new(49, 49, 450, 450)
    GlowEffect.ZIndex = 0

    -- Blurred background
    BackgroundBlur.Name = "BackgroundBlur"
    BackgroundBlur.Parent = EngoUI
    BackgroundBlur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundBlur.BackgroundTransparency = 0.5
    BackgroundBlur.Size = UDim2.new(0, 600, 0, 450)
    BackgroundBlur.Position = UDim2.new(0.5, -300, 0.5, -225)

    BackgroundBlurCorner.CornerRadius = UDim.new(0, 12)
    BackgroundBlurCorner.Parent = BackgroundBlur

    -- Main glass window
    Main.Name = "Main"
    Main.Parent = EngoUI
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Main.BackgroundTransparency = theme.GlassTransparency
    Main.Position = UDim2.new(0.5, -275, 0.5, -175)
    Main.Size = UDim2.new(0, 550, 0, 400)
    Main.Active = true
    Main.Draggable = true
    Main.ZIndex = 2
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = theme.Accent
    stroke.Transparency = 0.7
    stroke.Parent = Main

    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Main

    -- Glass gradient effect
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.LightContrast),
        ColorSequenceKeypoint.new(1, theme.DarkContrast)
    }
    UIGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0.5)
    }
    UIGradient.Rotation = 90
    UIGradient.Parent = Main

    -- Sidebar with glass effect
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.Active = true
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.Position = UDim2.new(0.02, 0, 0.15, 0)
    Sidebar.Size = UDim2.new(0, 100, 0, 300)
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = theme.Accent
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.ZIndex = 3
    
    local sidebarStroke = Instance.new("UIStroke")
    sidebarStroke.Thickness = 1
    sidebarStroke.Color = theme.Accent
    sidebarStroke.Transparency = 0.5
    sidebarStroke.Parent = Sidebar

    UIListLayout.Parent = Sidebar
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)

    -- Topbar with accent color
    Topbar.Name = "Topbar"
    Topbar.Parent = Main
    Topbar.BackgroundColor3 = theme.Accent
    Topbar.BackgroundTransparency = 0.1
    Topbar.Size = UDim2.new(0, 550, 0, 40)
    Topbar.ZIndex = 3

    Info.Name = "Info"
    Info.Parent = Topbar
    Info.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Info.BackgroundTransparency = 1.000
    Info.Position = UDim2.new(0, 10, 0, 0)
    Info.Size = UDim2.new(0, 151, 0, 40)

    Title.Name = "Title"
    Title.Parent = Info
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.Position = UDim2.new(0, 0, 0.1, 0)
    Title.Size = UDim2.new(0, 200, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 =  Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18.000
    Title.TextXAlignment = Enum.TextXAlignment.Left

    Description.Name = "Description"
    Description.Parent = Info
    Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Description.BackgroundTransparency = 1.000
    Description.Position = UDim2.new(0, 0, 0.6, 0)
    Description.Size = UDim2.new(0, 200, 0, 15)
    Description.Font = Enum.Font.Gotham
    Description.Text = description
    Description.TextColor3 = Color3.fromRGB(220, 220, 220)
    Description.TextSize = 11.000
    Description.TextXAlignment = Enum.TextXAlignment.Left

    -- Tab container
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Main
    TabContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabContainer.BackgroundTransparency = 1.000
    TabContainer.Position = UDim2.new(0.22, 0, 0.15, 0)
    TabContainer.Size = UDim2.new(0, 420, 0, 300)
    TabContainer.ZIndex = 2

    local library2 = {}
    library2["Tabs"] = {}
    library2["CurrentTab"] = nil
    library2["Dropdowns"] = {} -- Track active dropdowns

    -- Function to close all dropdowns
    function library2:CloseAllDropdowns(except)
        for name, dropdownData in pairs(self.Dropdowns) do
            if name ~= except and dropdownData and dropdownData.ListFrame then
                dropdownData.Expanded = false
                TS:Create(dropdownData.ListFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 375, 0, 0),
                    BackgroundTransparency = 1
                }):Play()
                task.wait(0.3)
                dropdownData.ListFrame.Visible = false
            end
        end
    end

    function library2:CreateTab(name)
        local library3 = {}
        local UIListLayout_2 = Instance.new("UIListLayout") 
        local TabButton = Instance.new("TextButton")
        local Tab = Instance.new("ScrollingFrame")
        local TabButtonCorner = Instance.new("UICorner")
        local TabButtonStroke = Instance.new("UIStroke")

        TabButton.Parent = Sidebar
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        TabButton.BackgroundTransparency = 0.3
        TabButton.Size = UDim2.new(0.9, 0, 0, 35)
        TabButton.Position = UDim2.new(0.05, 0, 0, 0)
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.Text = name
        TabButton.TextColor3 =  theme.DescriptionTextColor
        TabButton.TextSize = 14.000
        TabButton.TextWrapped = true
        TabButton.Name = name.."TabButton"
        TabButton.ZIndex = 4
        
        TabButtonCorner.CornerRadius = UDim.new(0, 8)
        TabButtonCorner.Parent = TabButton
        
        TabButtonStroke.Thickness = 1
        TabButtonStroke.Color = theme.Accent
        TabButtonStroke.Transparency = 0.7
        TabButtonStroke.Parent = TabButton

        TabButton.MouseEnter:Connect(function()
            TS:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1,
                TextColor3 = theme.TextColor
            }):Play()
        end)
        
        TabButton.MouseLeave:Connect(function()
            if library2.CurrentTab ~= name then
                TS:Create(TabButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.3,
                    TextColor3 = theme.DescriptionTextColor
                }):Play()
            end
        end)

        Tab.Name = name.."Tab"
        Tab.Parent = TabContainer
        Tab.Active = true
        Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Tab.BackgroundTransparency = 1.000
        Tab.BorderSizePixel = 0
        Tab.Position = UDim2.new(0, 0, 0, 0)
        Tab.Size = UDim2.new(1, 0, 1, 0)
        Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.ScrollBarThickness = 3
        Tab.ScrollBarImageColor3 = theme.Accent
        Tab.TopImage = ""
        Tab.BottomImage = ""
        Tab.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Tab.ZIndex = 2

        UIListLayout_2.Parent = Tab
        UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
        UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
        UIListLayout_2.Padding = UDim.new(0, 8)

        library2["Tabs"][name] = {
            Instance = Tab,
            Button = TabButton,
            Elements = {}
        }

        if not firstTab then 
            firstTab = library2["Tabs"][name]
            library2:OpenTab(name)
        else
            Tab.Visible = false
        end

        function library2:OpenTab(tabName)
            for name, tabData in pairs(self.Tabs) do 
                if name ~= tabName then
                    tabData.Instance.Visible = false
                    TS:Create(tabData.Button, TweenInfo.new(0.3), {
                        BackgroundTransparency = 0.3,
                        TextColor3 = theme.DescriptionTextColor
                    }):Play()
                else
                    tabData.Instance.Visible = true
                    TS:Create(tabData.Button, TweenInfo.new(0.3), {
                        BackgroundTransparency = 0.1,
                        TextColor3 = theme.TextColor
                    }):Play()
                    self.CurrentTab = name
                end
            end
        end

        TabButton.MouseButton1Click:Connect(function()
            library2:OpenTab(name)
        end)

        function library3:CreateSection(text)
            local Section = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Line = Instance.new("Frame")
            local Stroke = Instance.new("UIStroke")

            Section.Name = text.."Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = theme.LightContrast
            Section.BackgroundTransparency = 0.2
            Section.Size = UDim2.new(0.95, 0, 0, 50)
            Section.ZIndex = 2

            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = Section
            
            Stroke.Thickness = 1
            Stroke.Color = theme.Accent
            Stroke.Transparency = 0.5
            Stroke.Parent = Section

            Title.Name = "Title"
            Title.Parent = Section
            Title.AnchorPoint = Vector2.new(0, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.05, 0, 0.5, 0)
            Title.Size = UDim2.new(0.9, 0, 0, 25)
            Title.Font = Enum.Font.GothamSemibold
            Title.Text = text
            Title.TextColor3 = theme.TextColor
            Title.TextSize = 16.000
            Title.TextXAlignment = Enum.TextXAlignment.Left

            Line.Name = "Line"
            Line.Parent = Section
            Line.AnchorPoint = Vector2.new(0, 0.5)
            Line.BackgroundColor3 = theme.Accent
            Line.BackgroundTransparency = 0.3
            Line.BorderSizePixel = 0
            Line.Position = UDim2.new(0.05, 0, 0.9, 0)
            Line.Size = UDim2.new(0.9, 0, 0, 2)

            local obj = {
                ["Type"] = "Section",
                ["Instance"] = Section,
                ["Api"] = nil
            }
            table.insert(library2["Tabs"][name].Elements, obj)
            return obj
        end

        function library3:CreateButton(text, callback)
            callback = callback or function() end
            local Button = Instance.new("TextButton")
            local UICorner_2 = Instance.new("UICorner")
            local Title_2 = Instance.new("TextLabel")
            local Icon = Instance.new("ImageLabel")
            local Stroke = Instance.new("UIStroke")
            local HoverEffect = Instance.new("Frame")
            local HoverCorner = Instance.new("UICorner")

            Button.Name = text.."Button"
            Button.Parent = Tab
            Button.BackgroundColor3 = theme.LightContrast
            Button.BackgroundTransparency = 0.2
            Button.Size = UDim2.new(0.95, 0, 0, 50)
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000
            Button.ZIndex = 2
            
            -- Hover effect
            HoverEffect.Name = "HoverEffect"
            HoverEffect.Parent = Button
            HoverEffect.BackgroundColor3 = theme.Accent
            HoverEffect.BackgroundTransparency = 0.9
            HoverEffect.Size = UDim2.new(1, 0, 1, 0)
            HoverEffect.ZIndex = 1
            
            HoverCorner.CornerRadius = UDim.new(0, 10)
            HoverCorner.Parent = HoverEffect

            UICorner_2.CornerRadius = UDim.new(0, 10)
            UICorner_2.Parent = Button
            
            Stroke.Thickness = 1
            Stroke.Color = theme.Accent
            Stroke.Transparency = 0.5
            Stroke.Parent = Button

            Title_2.Name = "Title"
            Title_2.Parent = Button
            Title_2.AnchorPoint = Vector2.new(0, 0.5)
            Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_2.BackgroundTransparency = 1.000
            Title_2.Position = UDim2.new(0.15, 0, 0.5, 0)
            Title_2.Size = UDim2.new(0.7, 0, 0, 25)
            Title_2.Font = Enum.Font.GothamSemibold
            Title_2.Text = text
            Title_2.TextColor3 =  theme.TextColor
            Title_2.TextSize = 14.000
            Title_2.TextXAlignment = Enum.TextXAlignment.Left
            Title_2.ZIndex = 3

            Icon.Name = "Icon"
            Icon.Parent = Button
            Icon.AnchorPoint = Vector2.new(0, 0.5)
            Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Icon.BackgroundTransparency = 1.000
            Icon.ClipsDescendants = true
            Icon.Position = UDim2.new(0.05, 0, 0.5, 0)
            Icon.Size = UDim2.new(0, 24, 0, 24)
            Icon.Image = "rbxassetid://8284791761"
            Icon.ScaleType = Enum.ScaleType.Stretch
            Icon.ImageColor3 = theme.Accent
            Icon.ZIndex = 3
            
            -- Animation effects
            Button.MouseEnter:Connect(function()
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.7
                }):Play()
                TS:Create(Stroke, TweenInfo.new(0.2), {
                    Transparency = 0.3
                }):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.9
                }):Play()
                TS:Create(Stroke, TweenInfo.new(0.2), {
                    Transparency = 0.5
                }):Play()
            end)
            
            Button.MouseButton1Down:Connect(function()
                TS:Create(Button, TweenInfo.new(0.1), {
                    Position = Button.Position + UDim2.new(0, 0, 0, 2)
                }):Play()
            end)
            
            Button.MouseButton1Up:Connect(function()
                TS:Create(Button, TweenInfo.new(0.1), {
                    Position = Button.Position - UDim2.new(0, 0, 0, 2)
                }):Play()
            end)

            Button.MouseButton1Click:Connect(function() 
                spawn(function() pcall(callback) end)
                
                -- Click animation
                TS:Create(HoverEffect, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.5
                }):Play()
                task.wait(0.1)
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.7
                }):Play()
            end)
            
            local obj = {
                ["Type"] = "Button",
                ["Instance"] = Button,
                ["Api"] = nil
            }
            table.insert(library2["Tabs"][name].Elements, obj)
        end

        function library3:CreateToggle(text, default, callback)
            local library4 = {}
            library4["Enabled"] = default or false
            callback = callback or function() end
            
            local Toggle = Instance.new("TextButton")
            local UICorner_3 = Instance.new("UICorner")
            local Title_3 = Instance.new("TextLabel")
            local ToggleFrame = Instance.new("Frame")
            local ToggleCorner = Instance.new("UICorner")
            local ToggleDot = Instance.new("Frame")
            local DotCorner = Instance.new("UICorner")
            local Stroke = Instance.new("UIStroke")
            local HoverEffect = Instance.new("Frame")
            local HoverCorner = Instance.new("UICorner")

            Toggle.Name = text.."Toggle"
            Toggle.Parent = Tab
            Toggle.BackgroundColor3 = theme.LightContrast
            Toggle.BackgroundTransparency = 0.2
            Toggle.Size = UDim2.new(0.95, 0, 0, 50)
            Toggle.Font = Enum.Font.SourceSans
            Toggle.Text = ""
            Toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
            Toggle.TextSize = 14.000
            Toggle.ZIndex = 2
            
            -- Hover effect
            HoverEffect.Name = "HoverEffect"
            HoverEffect.Parent = Toggle
            HoverEffect.BackgroundColor3 = theme.Accent
            HoverEffect.BackgroundTransparency = 0.9
            HoverEffect.Size = UDim2.new(1, 0, 1, 0)
            HoverEffect.ZIndex = 1
            
            HoverCorner.CornerRadius = UDim.new(0, 10)
            HoverCorner.Parent = HoverEffect

            UICorner_3.CornerRadius = UDim.new(0, 10)
            UICorner_3.Parent = Toggle
            
            Stroke.Thickness = 1
            Stroke.Color = theme.Accent
            Stroke.Transparency = 0.5
            Stroke.Parent = Toggle

            Title_3.Name = "Title"
            Title_3.Parent = Toggle
            Title_3.AnchorPoint = Vector2.new(0, 0.5)
            Title_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_3.BackgroundTransparency = 1.000
            Title_3.Position = UDim2.new(0.15, 0, 0.5, 0)
            Title_3.Size = UDim2.new(0.6, 0, 0, 25)
            Title_3.Font = Enum.Font.GothamSemibold
            Title_3.Text = text
            Title_3.TextColor3 =  theme.TextColor
            Title_3.TextSize = 14.000
            Title_3.TextXAlignment = Enum.TextXAlignment.Left
            Title_3.ZIndex = 3

            -- Modern toggle switch
            ToggleFrame.Name = "ToggleFrame"
            ToggleFrame.Parent = Toggle
            ToggleFrame.AnchorPoint = Vector2.new(1, 0.5)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            ToggleFrame.BackgroundTransparency = 0.3
            ToggleFrame.Position = UDim2.new(0.95, 0, 0.5, 0)
            ToggleFrame.Size = UDim2.new(0, 50, 0, 25)
            ToggleFrame.ZIndex = 3
            
            ToggleCorner.CornerRadius = UDim.new(1, 0)
            ToggleCorner.Parent = ToggleFrame
            
            ToggleDot.Name = "ToggleDot"
            ToggleDot.Parent = ToggleFrame
            ToggleDot.AnchorPoint = Vector2.new(0.5, 0.5)
            ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleDot.BackgroundTransparency = 0.1
            ToggleDot.Position = UDim2.new(0.25, 0, 0.5, 0)
            ToggleDot.Size = UDim2.new(0, 20, 0, 20)
            ToggleDot.ZIndex = 4
            
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = ToggleDot

            -- Set initial state
            function library4:UpdateToggle()
                if self.Enabled then
                    TS:Create(ToggleFrame, TweenInfo.new(0.2), {
                        BackgroundColor3 = theme.Accent
                    }):Play()
                    TS:Create(ToggleDot, TweenInfo.new(0.2), {
                        Position = UDim2.new(0.75, 0, 0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                else
                    TS:Create(ToggleFrame, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                    }):Play()
                    TS:Create(ToggleDot, TweenInfo.new(0.2), {
                        Position = UDim2.new(0.25, 0, 0.5, 0),
                        BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                    }):Play()
                end
            end
            
            function library4:SetState(state)
                self.Enabled = state
                self:UpdateToggle()
                spawn(function() callback(state) end)
            end
            
            function library4:Toggle()
                self.Enabled = not self.Enabled
                self:UpdateToggle()
                spawn(function() callback(self.Enabled) end)
            end
            
            -- Set initial state
            library4:UpdateToggle()

            -- Animation effects
            Toggle.MouseEnter:Connect(function()
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.7
                }):Play()
                TS:Create(Stroke, TweenInfo.new(0.2), {
                    Transparency = 0.3
                }):Play()
            end)
            
            Toggle.MouseLeave:Connect(function()
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.9
                }):Play()
                TS:Create(Stroke, TweenInfo.new(0.2), {
                    Transparency = 0.5
                }):Play()
            end)

            Toggle.MouseButton1Click:Connect(function()
                library4:Toggle()
            end)

            local obj = {
                ["Type"] = "Toggle",
                ["Instance"] = Toggle,
                ["Api"] = library4
            }
            table.insert(library2["Tabs"][name].Elements, obj)
            library4["Object"] = obj
            return library4
        end

        function library3:CreateTextbox(text, callback)
            local library4 = {}
            library4["Text"] = ""

            local Textbox = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Textbox_2 = Instance.new("TextBox")
            local UICorner_2 = Instance.new("UICorner")
            local Stroke = Instance.new("UIStroke")
            local InputStroke = Instance.new("UIStroke")

            Textbox.Name = text.."Textbox"
            Textbox.Parent = Tab
            Textbox.BackgroundColor3 = theme.LightContrast
            Textbox.BackgroundTransparency = 0.2
            Textbox.Size = UDim2.new(0.95, 0, 0, 50)
            Textbox.ZIndex = 2

            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = Textbox
            
            Stroke.Thickness = 1
            Stroke.Color = theme.Accent
            Stroke.Transparency = 0.5
            Stroke.Parent = Textbox

            Title.Name = "Title"
            Title.Parent = Textbox
            Title.AnchorPoint = Vector2.new(0, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.05, 0, 0.5, 0)
            Title.Size = UDim2.new(0.4, 0, 0, 21)
            Title.Font = Enum.Font.GothamSemibold
            Title.Text = text
            Title.TextColor3 =  theme.TextColor
            Title.TextSize = 14.000
            Title.TextXAlignment = Enum.TextXAlignment.Left

            Textbox_2.Name = "Textbox"
            Textbox_2.Parent = Textbox
            Textbox_2.AnchorPoint = Vector2.new(0, 0.5)
            Textbox_2.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            Textbox_2.BackgroundTransparency = 0.1
            Textbox_2.Position = UDim2.new(0.45, 0, 0.5, 0)
            Textbox_2.Size = UDim2.new(0.5, 0, 0.6, 0)
            Textbox_2.Font = Enum.Font.Gotham
            Textbox_2.PlaceholderColor3 = theme.DarkTextColor
            Textbox_2.PlaceholderText = "Enter value..."
            Textbox_2.Text = ""
            Textbox_2.TextColor3 = theme.DescriptionTextColor
            Textbox_2.TextSize = 14.000
            Textbox_2.ClearTextOnFocus = false
            
            InputStroke.Thickness = 1
            InputStroke.Color = theme.Accent
            InputStroke.Transparency = 0.5
            InputStroke.Parent = Textbox_2

            UICorner_2.CornerRadius = UDim.new(0, 6)
            UICorner_2.Parent = Textbox_2
            
            Textbox_2.Focused:Connect(function()
                TS:Create(InputStroke, TweenInfo.new(0.2), {
                    Transparency = 0.2
                }):Play()
                TS:Create(Textbox_2, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0
                }):Play()
            end)
            
            Textbox_2.FocusLost:Connect(function()
                TS:Create(InputStroke, TweenInfo.new(0.2), {
                    Transparency = 0.5
                }):Play()
                TS:Create(Textbox_2, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.1
                }):Play()
                
                spawn(function() callback(Textbox_2.Text) end)
                library4["Text"] = Textbox_2.Text
            end)
            
            local obj = {
                ["Type"] = "Textbox",
                ["Instance"] = Textbox,
                ["Api"] = library4
            }
            table.insert(library2["Tabs"][name].Elements, obj)
            library4["Object"] = obj
            return library4
        end

        function library3:CreateSlider(text, min, max, callback)
            local library4 = {}
            library4["Value"] = min
            callback = callback or function() end

            local Slider = Instance.new("Frame")
            local UICorner_4 = Instance.new("UICorner")
            local Title_4 = Instance.new("TextLabel")
            local SliderBar = Instance.new("Frame")
            local UICorner_5 = Instance.new("UICorner")
            local Value = Instance.new("TextLabel")
            local Slider_2 = Instance.new("Frame")
            local UICorner_6 = Instance.new("UICorner")
            local Fill = Instance.new("Frame")
            local FillCorner = Instance.new("UICorner")
            local Stroke = Instance.new("UIStroke")

            Slider.Name = text.."Slider"
            Slider.Parent = Tab
            Slider.BackgroundColor3 = theme.LightContrast
            Slider.BackgroundTransparency = 0.2
            Slider.Size = UDim2.new(0.95, 0, 0, 60)
            Slider.ZIndex = 2

            UICorner_4.CornerRadius = UDim.new(0, 10)
            UICorner_4.Parent = Slider
            
            Stroke.Thickness = 1
            Stroke.Color = theme.Accent
            Stroke.Transparency = 0.5
            Stroke.Parent = Slider

            Title_4.Name = "Title"
            Title_4.Parent = Slider
            Title_4.AnchorPoint = Vector2.new(0, 0)
            Title_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_4.BackgroundTransparency = 1.000
            Title_4.Position = UDim2.new(0.05, 0, 0.1, 0)
            Title_4.Size = UDim2.new(0.7, 0, 0, 20)
            Title_4.Font = Enum.Font.GothamSemibold
            Title_4.Text = text
            Title_4.TextColor3 =  theme.TextColor
            Title_4.TextSize = 14.000
            Title_4.TextXAlignment = Enum.TextXAlignment.Left

            SliderBar.Name = "SliderBar"
            SliderBar.Parent = Slider
            SliderBar.AnchorPoint = Vector2.new(0, 0)
            SliderBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            SliderBar.BackgroundTransparency = 0.1
            SliderBar.Position = UDim2.new(0.05, 0, 0.6, 0)
            SliderBar.Size = UDim2.new(0.9, 0, 0, 8)

            UICorner_5.CornerRadius = UDim.new(1, 0)
            UICorner_5.Parent = SliderBar

            Value.Name = "Value"
            Value.Parent = Slider
            Value.AnchorPoint = Vector2.new(1, 0)
            Value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Value.BackgroundTransparency = 1.000
            Value.Position = UDim2.new(0.95, 0, 0.1, 0)
            Value.Size = UDim2.new(0.2, 0, 0, 20)
            Value.ZIndex = 2
            Value.Font = Enum.Font.GothamSemibold
            Value.Text = tostring(min)
            Value.TextColor3 =  theme.Accent
            Value.TextSize = 14.000
            Value.TextXAlignment = Enum.TextXAlignment.Right

            -- Fill for slider background
            Fill.Name = "Fill"
            Fill.Parent = SliderBar
            Fill.BackgroundColor3 = theme.Accent
            Fill.BackgroundTransparency = 0.3
            Fill.Size = UDim2.new(0, 0, 1, 0)
            
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill

            Slider_2.Name = "Slider"
            Slider_2.Parent = SliderBar
            Slider_2.AnchorPoint = Vector2.new(0.5, 0.5)
            Slider_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Slider_2.BackgroundTransparency = 0.1
            Slider_2.Position = UDim2.new(0, 0, 0.5, 0)
            Slider_2.Size = UDim2.new(0, 18, 0, 18)
            Slider_2.ZIndex = 3

            UICorner_6.CornerRadius = UDim.new(1, 0)
            UICorner_6.Parent = Slider_2
            
            -- Add glow to slider dot
            local SliderGlow = Instance.new("ImageLabel")
            SliderGlow.Name = "SliderGlow"
            SliderGlow.Parent = Slider_2
            SliderGlow.BackgroundTransparency = 1
            SliderGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
            SliderGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
            SliderGlow.Image = "rbxassetid://4996891970"
            SliderGlow.ImageColor3 = theme.Accent
            SliderGlow.ImageTransparency = 0.8
            SliderGlow.ScaleType = Enum.ScaleType.Slice
            SliderGlow.SliceCenter = Rect.new(49, 49, 450, 450)
            SliderGlow.ZIndex = 2
			
            local value
			local dragging
			function library4:SetValue(input)
				local pos = UDim2.new(math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1), 0, 0, (SliderBar.AbsoluteSize.Y))
				TS:Create(Slider_2, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(pos.X.Scale, 0, 0.5, 0)
                }):Play()
                
                TS:Create(Fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(pos.X.Scale, 0, 1, 0)
                }):Play()
                
				local value = math.floor(( ((pos.X.Scale * max) / max) * (max - min) + min ))
				Value.Text = tostring(value)
                library4["Value"] = value
				spawn(function() callback(value) end)
			end
			
			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
                    TS:Create(SliderGlow, TweenInfo.new(0.2), {
                        ImageTransparency = 0.6
                    }):Play()
				end
			end)

			SliderBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
                    TS:Create(SliderGlow, TweenInfo.new(0.2), {
                        ImageTransparency = 0.8
                    }):Play()
				end
			end)

			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					library4:SetValue(input)
				end
			end)

			UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					library4:SetValue(input)
				end
			end)
            
            -- Set initial value
            library4:SetValue({Position = Vector2.new(SliderBar.AbsolutePosition.X, SliderBar.AbsolutePosition.Y)})

            local obj = {
                ["Type"] = "Slider",
                ["Instance"] = Slider,
                ["Api"] = library4
            }
            table.insert(library2["Tabs"][name].Elements, obj)
            library4["Object"] = obj
            return library4
        end

        function library3:CreateLabel(text)
            local library4 = {}
            local Label = Instance.new("Frame")
            local UICorner_7 = Instance.new("UICorner")
            local Title_5 = Instance.new("TextLabel")
            local Stroke = Instance.new("UIStroke")
        
            Label.Name = text.."Label"
            Label.Parent = Tab
            Label.BackgroundColor3 = theme.LightContrast
            Label.BackgroundTransparency = 0.2
            Label.Size = UDim2.new(0.95, 0, 0, 40)
            Label.ZIndex = 2

            UICorner_7.CornerRadius = UDim.new(0, 10)
            UICorner_7.Parent = Label
            
            Stroke.Thickness = 1
            Stroke.Color = theme.Accent
            Stroke.Transparency = 0.5
            Stroke.Parent = Label

            Title_5.Name = "Title"
            Title_5.Parent = Label
            Title_5.AnchorPoint = Vector2.new(0.5, 0.5)
            Title_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_5.BackgroundTransparency = 1.000
            Title_5.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title_5.Size = UDim2.new(0.9, 0, 0, 30)
            Title_5.Font = Enum.Font.GothamSemibold
            Title_5.TextColor3 =  theme.TextColor
            Title_5.TextSize = 14.000
            Title_5.Text = text

            function library4:Update(textnew) 
                Title_5.Text = textnew
            end

            local obj = {
                ["Type"] = "Label",
                ["Instance"] = Label,
                ["Api"] = library4
            }
            table.insert(library2["Tabs"][name].Elements, obj)
            library4["Object"] = obj
            return library4
        end

        function library3:CreateBind(text, originalBind, callback)
            local library4 = {}
            local o, a = getTextFromKeyCode(originalBind)
            library["IsBinding"] = false
            library4["IsBinding"] = false
            library4["Bind"] = originalBind
            callback = callback or function() end

            local Keybind = Instance.new("Frame")
            local UICorner_8 = Instance.new("UICorner")
            local Title_6 = Instance.new("TextLabel")
            local BindButton = Instance.new("TextButton")
            local BindCorner = Instance.new("UICorner")
            local BindStroke = Instance.new("UIStroke")
            local Stroke = Instance.new("UIStroke")

            Keybind.Name = text.."Bind"
            Keybind.Parent = Tab
            Keybind.BackgroundColor3 = theme.LightContrast
            Keybind.BackgroundTransparency = 0.2
            Keybind.Size = UDim2.new(0.95, 0, 0, 50)
            Keybind.ZIndex = 2

            UICorner_8.CornerRadius = UDim.new(0, 10)
            UICorner_8.Parent = Keybind
            
            Stroke.Thickness = 1
            Stroke.Color = theme.Accent
            Stroke.Transparency = 0.5
            Stroke.Parent = Keybind

            Title_6.Name = "Title"
            Title_6.Parent = Keybind
            Title_6.AnchorPoint = Vector2.new(0, 0.5)
            Title_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_6.BackgroundTransparency = 1.000
            Title_6.Position = UDim2.new(0.05, 0, 0.5, 0)
            Title_6.Size = UDim2.new(0.5, 0, 0, 25)
            Title_6.Font = Enum.Font.GothamSemibold
            Title_6.Text = text
            Title_6.TextColor3 =  theme.TextColor
            Title_6.TextSize = 14.000
            Title_6.TextXAlignment = Enum.TextXAlignment.Left

            BindButton.Name = "BindButton"
            BindButton.Parent = Keybind
            BindButton.AnchorPoint = Vector2.new(1, 0.5)
            BindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            BindButton.BackgroundTransparency = 0.1
            BindButton.Position = UDim2.new(0.95, 0, 0.5, 0)
            BindButton.Size = UDim2.new(0.3, 0, 0.6, 0)
            BindButton.Font = Enum.Font.GothamSemibold
            BindButton.Text = o
            BindButton.TextColor3 = theme.TextColor
            BindButton.TextSize = 14.000
            
            BindCorner.CornerRadius = UDim.new(0, 6)
            BindCorner.Parent = BindButton
            
            BindStroke.Thickness = 1
            BindStroke.Color = theme.Accent
            BindStroke.Transparency = 0.5
            BindStroke.Parent = BindButton
            
            BindButton.MouseButton1Click:Connect(function()
                library4["IsBinding"] = true
                library["IsBinding"] = true
                BindButton.Text = "Press a key..."
                TS:Create(BindButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = theme.Accent,
                    BackgroundTransparency = 0.3
                }):Play()
            end)

            getgenv().userInputConnection = UIS.InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Unknown then return end
                local TextBoxFocused = UIS:GetFocusedTextBox()
                if TextBoxFocused then return end
                
                if library4["IsBinding"] then 
                    if input.KeyCode == Enum.KeyCode.Backspace then 
                        library4["Bind"] = originalBind
                        local t, b = getTextFromKeyCode(originalBind)
                        BindButton.Text = t
                    else
                        library4["Bind"] = input.KeyCode
                        local t, b = getTextFromKeyCode(library4["Bind"])
                        BindButton.Text = t
                    end
                    
                    library4["IsBinding"] = false
                    library["IsBinding"] = false
                    
                    TS:Create(BindButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
                        BackgroundTransparency = 0.1
                    }):Play()
                    
                    spawn(function() callback(library4["Bind"]) end)
                else
                    if input.KeyCode == library4["Bind"] then 
                        spawn(function() callback(library4["Bind"]) end)
                    end
                end
            end)
            
            -- Button animation
            BindButton.MouseEnter:Connect(function()
                if not library4["IsBinding"] then
                    TS:Create(BindButton, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0
                    }):Play()
                    TS:Create(BindStroke, TweenInfo.new(0.2), {
                        Transparency = 0.3
                    }):Play()
                end
            end)
            
            BindButton.MouseLeave:Connect(function()
                if not library4["IsBinding"] then
                    TS:Create(BindButton, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.1
                    }):Play()
                    TS:Create(BindStroke, TweenInfo.new(0.2), {
                        Transparency = 0.5
                    }):Play()
                end
            end)

            local obj = {
                ["Type"] = "Bind",
                ["Instance"] = Keybind,
                ["Api"] = library4
            }
            table.insert(library2["Tabs"][name].Elements, obj)
            library4["Object"] = obj
            return library4
        end

        function library3:CreateDropdown(text, list, callback)
            local library4 = {}
            library4["Options"] = {}
            library4["Expanded"] = false
            library4["Connections"] = {}
            library4["CurrentValue"] = nil
            library4["ListFrame"] = nil

            local Dropdown = Instance.new("Frame")
            local UICorner_10 = Instance.new("UICorner")
            local Title_7 = Instance.new("TextLabel")
            local DropdownButton = Instance.new("TextButton")
            local DropdownCorner = Instance.new("UICorner")
            local DropdownStroke = Instance.new("UIStroke")
            local Arrow = Instance.new("ImageLabel")
            local Stroke = Instance.new("UIStroke")
            local HoverEffect = Instance.new("Frame")
            local HoverCorner = Instance.new("UICorner")

            Dropdown.Name = text.."Dropdown"
            Dropdown.Parent = Tab
            Dropdown.BackgroundColor3 = theme.LightContrast
            Dropdown.BackgroundTransparency = 0.2
            Dropdown.Size = UDim2.new(0.95, 0, 0, 50)
            Dropdown.ZIndex = 2
            Dropdown.ClipsDescendants = true
            
            -- Hover effect
            HoverEffect.Name = "HoverEffect"
            HoverEffect.Parent = Dropdown
            HoverEffect.BackgroundColor3 = theme.Accent
            HoverEffect.BackgroundTransparency = 0.9
            HoverEffect.Size = UDim2.new(1, 0, 1, 0)
            HoverEffect.ZIndex = 1
            
            HoverCorner.CornerRadius = UDim.new(0, 10)
            HoverCorner.Parent = HoverEffect

            UICorner_10.CornerRadius = UDim.new(0, 10)
            UICorner_10.Parent = Dropdown
            
            Stroke.Thickness = 1
            Stroke.Color = theme.Accent
            Stroke.Transparency = 0.5
            Stroke.Parent = Dropdown

            Title_7.Name = "Title"
            Title_7.Parent = Dropdown
            Title_7.AnchorPoint = Vector2.new(0, 0.5)
            Title_7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_7.BackgroundTransparency = 1.000
            Title_7.Position = UDim2.new(0.05, 0, 0.5, 0)
            Title_7.Size = UDim2.new(0.5, 0, 0, 25)
            Title_7.Font = Enum.Font.GothamSemibold
            Title_7.Text = text
            Title_7.TextColor3 =  theme.TextColor
            Title_7.TextSize = 14.000
            Title_7.TextXAlignment = Enum.TextXAlignment.Left
            Title_7.ZIndex = 3

            DropdownButton.Name = "DropdownButton"
            DropdownButton.Parent = Dropdown
            DropdownButton.AnchorPoint = Vector2.new(1, 0.5)
            DropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            DropdownButton.BackgroundTransparency = 0.1
            DropdownButton.Position = UDim2.new(0.95, 0, 0.5, 0)
            DropdownButton.Size = UDim2.new(0.4, 0, 0.6, 0)
            DropdownButton.Font = Enum.Font.GothamSemibold
            DropdownButton.Text = "Select..."
            DropdownButton.TextColor3 = theme.TextColor
            DropdownButton.TextSize = 14.000
            DropdownButton.ZIndex = 3
            
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownButton
            
            DropdownStroke.Thickness = 1
            DropdownStroke.Color = theme.Accent
            DropdownStroke.Transparency = 0.5
            DropdownStroke.Parent = DropdownButton

            Arrow.Name = "Arrow"
            Arrow.Parent = DropdownButton
            Arrow.AnchorPoint = Vector2.new(1, 0.5)
            Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Arrow.BackgroundTransparency = 1.000
            Arrow.Position = UDim2.new(0.9, 0, 0.5, 0)
            Arrow.Size = UDim2.new(0, 15, 0, 15)
            Arrow.Image = "rbxassetid://6034818378"
            Arrow.ImageColor3 = theme.TextColor
            Arrow.ZIndex = 4
            
            -- Create dropdown list frame (will be parented to Main for proper positioning)
            local DropdownList = Instance.new("Frame")
            local ListCorner = Instance.new("UICorner")
            local ListLayout = Instance.new("UIListLayout")
            local ListStroke = Instance.new("UIStroke")
            local ListBackground = Instance.new("Frame")
            local ListBackgroundCorner = Instance.new("UICorner")
            
            DropdownList.Name = text.."DropdownList"
            DropdownList.Parent = Main
            DropdownList.BackgroundColor3 = theme.LightContrast
            DropdownList.BackgroundTransparency = 0.1
            DropdownList.Size = UDim2.new(0, 375, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 0, 0)
            DropdownList.Visible = false
            DropdownList.ZIndex = 10
            DropdownList.ClipsDescendants = true
            
            ListCorner.CornerRadius = UDim.new(0, 8)
            ListCorner.Parent = DropdownList
            
            ListStroke.Thickness = 1
            ListStroke.Color = theme.Accent
            ListStroke.Transparency = 0.3
            ListStroke.Parent = DropdownList
            
            -- Glass background
            ListBackground.Name = "ListBackground"
            ListBackground.Parent = DropdownList
            ListBackground.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
            ListBackground.BackgroundTransparency = 0.1
            ListBackground.Size = UDim2.new(1, 0, 1, 0)
            ListBackground.ZIndex = 9
            
            ListBackgroundCorner.CornerRadius = UDim.new(0, 8)
            ListBackgroundCorner.Parent = ListBackground
            
            ListLayout.Parent = DropdownList
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Padding = UDim.new(0, 2)
            
            library4["ListFrame"] = DropdownList
            
            -- Store dropdown reference
            library2.Dropdowns[text] = library4

            function library4:CreateOption(optionText)
                local Option = Instance.new("TextButton")
                local OptionCorner = Instance.new("UICorner")
                local OptionTitle = Instance.new("TextLabel")
                local OptionStroke = Instance.new("UIStroke")
                local OptionHover = Instance.new("Frame")
                local OptionHoverCorner = Instance.new("UICorner")
                
                Option.Name = optionText.."Option"
                Option.Parent = DropdownList
                Option.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                Option.BackgroundTransparency = 0.3
                Option.Size = UDim2.new(0.95, 0, 0, 40)
                Option.Position = UDim2.new(0.025, 0, 0, 0)
                Option.Font = Enum.Font.SourceSans
                Option.Text = ""
                Option.TextColor3 = Color3.fromRGB(0, 0, 0)
                Option.TextSize = 14.000
                Option.ZIndex = 11
                
                -- Hover effect
                OptionHover.Name = "OptionHover"
                OptionHover.Parent = Option
                OptionHover.BackgroundColor3 = theme.Accent
                OptionHover.BackgroundTransparency = 0.9
                OptionHover.Size = UDim2.new(1, 0, 1, 0)
                OptionHover.ZIndex = 10
                
                OptionHoverCorner.CornerRadius = UDim.new(0, 6)
                OptionHoverCorner.Parent = OptionHover

                OptionCorner.CornerRadius = UDim.new(0, 6)
                OptionCorner.Parent = Option
                
                OptionStroke.Thickness = 1
                OptionStroke.Color = theme.Accent
                OptionStroke.Transparency = 0.5
                OptionStroke.Parent = Option

                OptionTitle.Name = "Title"
                OptionTitle.Parent = Option
                OptionTitle.AnchorPoint = Vector2.new(0, 0.5)
                OptionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                OptionTitle.BackgroundTransparency = 1.000
                OptionTitle.Position = UDim2.new(0.1, 0, 0.5, 0)
                OptionTitle.Size = UDim2.new(0.8, 0, 0, 25)
                OptionTitle.Font = Enum.Font.GothamSemibold
                OptionTitle.Text = optionText
                OptionTitle.TextColor3 = theme.TextColor
                OptionTitle.TextSize = 14.000
                OptionTitle.TextXAlignment = Enum.TextXAlignment.Left
                OptionTitle.ZIndex = 12
                
                -- Hover animations
                Option.MouseEnter:Connect(function()
                    TS:Create(OptionHover, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.7
                    }):Play()
                    TS:Create(OptionStroke, TweenInfo.new(0.2), {
                        Transparency = 0.3
                    }):Play()
                end)
                
                Option.MouseLeave:Connect(function()
                    TS:Create(OptionHover, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.9
                    }):Play()
                    TS:Create(OptionStroke, TweenInfo.new(0.2), {
                        Transparency = 0.5
                    }):Play()
                end)
                
                Option.MouseButton1Click:Connect(function()
                    library4["CurrentValue"] = optionText
                    DropdownButton.Text = optionText
                    spawn(function() callback(optionText) end)
                    library4:Toggle()
                end)
                
                return Option
            end

            function library4:CreateOptions(options)
                for _, optionText in pairs(options) do
                    self:CreateOption(optionText)
                end
            end

            function library4:Refresh(newList)
                -- Clear existing options
                for _, child in pairs(DropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Create new options
                self:CreateOptions(newList)
                
                -- Update list size
                local optionCount = #newList
                local newHeight = math.min(optionCount * 42 + 10, 200) -- Max height 200
                DropdownList.Size = UDim2.new(0, 375, 0, newHeight)
            end
            
            -- Initial create
            library4:CreateOptions(list)

            function library4:Toggle()
                if self.Expanded then
                    self.Expanded = false
                    TS:Create(Arrow, TweenInfo.new(0.3), {
                        Rotation = 0
                    }):Play()
                    
                    TS:Create(DropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 375, 0, 0),
                        BackgroundTransparency = 1
                    }):Play()
                    
                    TS:Create(ListStroke, TweenInfo.new(0.3), {
                        Transparency = 1
                    }):Play()
                    
                    task.wait(0.3)
                    DropdownList.Visible = false
                else
                    -- Close all other dropdowns first
                    library2:CloseAllDropdowns(text)
                    
                    self.Expanded = true
                    
                    -- Calculate position relative to Main
                    local dropdownAbsPos = Dropdown.AbsolutePosition
                    local mainAbsPos = Main.AbsolutePosition
                    
                    local relativeX = dropdownAbsPos.X - mainAbsPos.X + 120
                    local relativeY = dropdownAbsPos.Y - mainAbsPos.Y + Dropdown.AbsoluteSize.Y + 5
                    
                    DropdownList.Position = UDim2.new(0, relativeX, 0, relativeY)
                    
                    -- Calculate height based on options
                    local optionCount = #list
                    local maxHeight = math.min(optionCount * 42 + 10, 200)
                    
                    DropdownList.Size = UDim2.new(0, 375, 0, 0)
                    DropdownList.BackgroundTransparency = 1
                    DropdownList.Visible = true
                    
                    TS:Create(Arrow, TweenInfo.new(0.3), {
                        Rotation = 180
                    }):Play()
                    
                    TS:Create(DropdownList, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 375, 0, maxHeight),
                        BackgroundTransparency = 0.1
                    }):Play()
                    
                    TS:Create(ListStroke, TweenInfo.new(0.3), {
                        Transparency = 0.3
                    }):Play()
                end
            end

            -- Button animations
            DropdownButton.MouseEnter:Connect(function()
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.7
                }):Play()
                TS:Create(Stroke, TweenInfo.new(0.2), {
                    Transparency = 0.3
                }):Play()
                TS:Create(DropdownStroke, TweenInfo.new(0.2), {
                    Transparency = 0.3
                }):Play()
            end)
            
            DropdownButton.MouseLeave:Connect(function()
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.9
                }):Play()
                TS:Create(Stroke, TweenInfo.new(0.2), {
                    Transparency = 0.5
                }):Play()
                TS:Create(DropdownStroke, TweenInfo.new(0.2), {
                    Transparency = 0.5
                }):Play()
            end)

            DropdownButton.MouseButton1Click:Connect(function()
                library4:Toggle()
            end)
            
            -- Also allow clicking the main dropdown area
            Dropdown.MouseEnter:Connect(function()
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.7
                }):Play()
                TS:Create(Stroke, TweenInfo.new(0.2), {
                    Transparency = 0.3
                }):Play()
            end)
            
            Dropdown.MouseLeave:Connect(function()
                TS:Create(HoverEffect, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.9
                }):Play()
                TS:Create(Stroke, TweenInfo.new(0.2), {
                    Transparency = 0.5
                }):Play()
            end)

            local obj = {
                ["Type"] = "Dropdown",
                ["Instance"] = Dropdown,
                ["Api"] = library4
            }
            table.insert(library2["Tabs"][name].Elements, obj)
            library4["Object"] = obj
            return library4
        end

		function library3:CreateInput(text, placeholder, callback)
		    local library4 = {}
		    library4["Text"] = ""
		
		    local Input = Instance.new("Frame")
		    local UICorner = Instance.new("UICorner")
		    local Title = Instance.new("TextLabel")
		    local InputField = Instance.new("TextBox")
		    local UICorner_2 = Instance.new("UICorner")
		    local Stroke = Instance.new("UIStroke")
		    local InputStroke = Instance.new("UIStroke")
		
		    Input.Name = text.."Input"
		    Input.Parent = Tab
		    Input.BackgroundColor3 = theme.LightContrast
		    Input.BackgroundTransparency = 0.2
		    Input.Size = UDim2.new(0.95, 0, 0, 50)
		    Input.ZIndex = 2

		    UICorner.CornerRadius = UDim.new(0, 10)
		    UICorner.Parent = Input
		    
		    Stroke.Thickness = 1
		    Stroke.Color = theme.Accent
		    Stroke.Transparency = 0.5
		    Stroke.Parent = Input

		    Title.Name = "Title"
		    Title.Parent = Input
		    Title.AnchorPoint = Vector2.new(0, 0.5)
		    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		    Title.BackgroundTransparency = 1.000
		    Title.Position = UDim2.new(0.05, 0, 0.5, 0)
		    Title.Size = UDim2.new(0.4, 0, 0, 21)
		    Title.Font = Enum.Font.GothamSemibold
		    Title.Text = text
		    Title.TextColor3 = theme.TextColor
		    Title.TextSize = 14.000
		    Title.TextXAlignment = Enum.TextXAlignment.Left

		    InputField.Name = "InputField"
		    InputField.Parent = Input
		    InputField.AnchorPoint = Vector2.new(0, 0.5)
		    InputField.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
		    InputField.BackgroundTransparency = 0.1
		    InputField.Position = UDim2.new(0.45, 0, 0.5, 0)
		    InputField.Size = UDim2.new(0.5, 0, 0.6, 0)
		    InputField.Font = Enum.Font.Gotham
		    InputField.PlaceholderColor3 = theme.DarkTextColor
		    InputField.PlaceholderText = placeholder or "Enter value..."
		    InputField.Text = ""
		    InputField.TextColor3 = theme.DescriptionTextColor
		    InputField.TextSize = 14.000
		    InputField.ClearTextOnFocus = false
		    
		    InputStroke.Thickness = 1
		    InputStroke.Color = theme.Accent
		    InputStroke.Transparency = 0.5
		    InputStroke.Parent = InputField

		    UICorner_2.CornerRadius = UDim.new(0, 6)
		    UICorner_2.Parent = InputField
		    
		    InputField.Focused:Connect(function()
		        TS:Create(InputStroke, TweenInfo.new(0.2), {
		            Transparency = 0.2
		        }):Play()
		        TS:Create(InputField, TweenInfo.new(0.2), {
		            BackgroundTransparency = 0
		        }):Play()
		    end)
		    
		    InputField.FocusLost:Connect(function(enterPressed)
		        TS:Create(InputStroke, TweenInfo.new(0.2), {
		            Transparency = 0.5
		        }):Play()
		        TS:Create(InputField, TweenInfo.new(0.2), {
		            BackgroundTransparency = 0.1
		        }):Play()
		        
		        if enterPressed then
		            spawn(function() 
		                pcall(callback, InputField.Text) 
		            end)
		            library4["Text"] = InputField.Text
		        end
		    end)

		    function library4:SetValue(value)
		        InputField.Text = tostring(value)
		        library4["Text"] = tostring(value)
		    end

		    function library4:GetValue()
		        return library4["Text"]
		    end

		    local obj = {
		        ["Type"] = "Input",
		        ["Instance"] = Input,
		        ["Api"] = library4
		    }
		    table.insert(library2["Tabs"][name].Elements, obj)
		    library4["Object"] = obj
		    return library4
		end

        return library3
    end
    
    function library2:CreateSettings()
        local settings = library2:CreateTab("Settings")
        local hidegui = settings:CreateBind("Hide GUI", Enum.KeyCode.RightControl, function(value)
            library["Bind"] = value
        end)

        local uninject = settings:CreateButton("Remove GUI", function() 
            if getgenv().EngoUILib then 
                onSelfDestroy()
                getgenv().EngoUILib:Destroy()
            end
        end)
        
        -- Theme selector
        local themeDropdown = settings:CreateDropdown("Theme", {"Engo", "ModernDark", "Cyberpunk", "Neon"}, function(selected)
            library:SetTheme(selected)
        end)
        
        return settings
    end

    function library2:CreateNotification(title, description, callback)
        callback = callback or function() end
        if EngoUI:FindFirstChild("Notification") then 
            EngoUI:FindFirstChild("Notification"):Destroy()
        end

        local Notification = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        local Title = Instance.new("TextLabel")
        local Description = Instance.new("TextLabel")
        local TextButton = Instance.new("TextButton")
        local UICorner_2 = Instance.new("UICorner")
        local Cancel = Instance.new("TextButton")
        local UICorner_3 = Instance.new("UICorner")
        local Stroke = Instance.new("UIStroke")
        local Glow = Instance.new("ImageLabel")

        Notification.Name = "Notification"
        Notification.Parent = EngoUI
        Notification.BackgroundColor3 = theme.DarkContrast
        Notification.BackgroundTransparency = 0.2
        Notification.Position = UDim2.new(0.5, -106, 1.5, 0)
        Notification.Size = UDim2.new(0, 212, 0, 130)
        Notification.ZIndex = 20
        
        -- Glow effect
        Glow.Name = "Glow"
        Glow.Parent = Notification
        Glow.BackgroundTransparency = 1
        Glow.Size = UDim2.new(1.1, 0, 1.1, 0)
        Glow.Position = UDim2.new(-0.05, 0, -0.05, 0)
        Glow.Image = "rbxassetid://4996891970"
        Glow.ImageColor3 = theme.Accent
        Glow.ImageTransparency = 0.8
        Glow.ScaleType = Enum.ScaleType.Slice
        Glow.SliceCenter = Rect.new(49, 49, 450, 450)
        Glow.ZIndex = 19

        UICorner.CornerRadius = UDim.new(0, 12)
        UICorner.Parent = Notification
        
        Stroke.Thickness = 2
        Stroke.Color = theme.Accent
        Stroke.Transparency = 0.3
        Stroke.Parent = Notification

        Title.Name = "Title"
        Title.Parent = Notification
        Title.AnchorPoint = Vector2.new(0, 0.5)
        Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Title.BackgroundTransparency = 1.000
        Title.Position = UDim2.new(0.1, 0, 0.2, 0)
        Title.Size = UDim2.new(0.8, 0, 0, 25)
        Title.Font = Enum.Font.GothamBold
        Title.Text = title
        Title.TextColor3 =  theme.TextColor
        Title.TextSize = 16.000

        Description.Name = "Description"
        Description.Parent = Notification
        Description.AnchorPoint = Vector2.new(0.5, 0.5)
        Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Description.BackgroundTransparency = 1.000
        Description.Position = UDim2.new(0.5, 0, 0.5, 0)
        Description.Size = UDim2.new(0.9, 0, 0, 40)
        Description.Font = Enum.Font.Gotham
        Description.Text = description
        Description.TextColor3 = theme.DescriptionTextColor
        Description.TextSize = 14.000
        Description.TextWrapped = true
        Description.TextYAlignment = Enum.TextYAlignment.Top

        TextButton.Parent = Notification
        TextButton.BackgroundColor3 = theme.Accent
        TextButton.BackgroundTransparency = 0.2
        TextButton.BorderSizePixel = 0
        TextButton.Position = UDim2.new(0.05, 0, 0.8, 0)
        TextButton.Size = UDim2.new(0.4, 0, 0, 25)
        TextButton.Font = Enum.Font.GothamSemibold
        TextButton.Text = "OK"
        TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextButton.TextSize = 14.000
        TextButton.ZIndex = 21
        
        TextButton.MouseEnter:Connect(function()
            TS:Create(TextButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        TextButton.MouseLeave:Connect(function()
            TS:Create(TextButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        TextButton.MouseButton1Click:Connect(function()
            spawn(function() callback(true) end)
            TS:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -106, 1.5, 0)
            }):Play()
            task.wait(0.5)
            Notification:Destroy()
        end)

        UICorner_2.CornerRadius = UDim.new(0, 6)
        UICorner_2.Parent = TextButton

        Cancel.Name = "Cancel"
        Cancel.Parent = Notification
        Cancel.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        Cancel.BackgroundTransparency = 0.2
        Cancel.BorderSizePixel = 0
        Cancel.Position = UDim2.new(0.55, 0, 0.8, 0)
        Cancel.Size = UDim2.new(0.4, 0, 0, 25)
        Cancel.Font = Enum.Font.GothamSemibold
        Cancel.Text = "CANCEL"
        Cancel.TextColor3 = theme.TextColor
        Cancel.TextSize = 14.000
        Cancel.ZIndex = 21
        
        Cancel.MouseEnter:Connect(function()
            TS:Create(Cancel, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1
            }):Play()
        end)
        
        Cancel.MouseLeave:Connect(function()
            TS:Create(Cancel, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
        end)
        
        Cancel.MouseButton1Click:Connect(function()
            spawn(function() callback(false) end)
            TS:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -106, 1.5, 0)
            }):Play()
            task.wait(0.5)
            Notification:Destroy()
        end)

        UICorner_3.CornerRadius = UDim.new(0, 6)
        UICorner_3.Parent = Cancel
        
        -- Animation
        TS:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -106, 0.5, -65)
        }):Play()
    end

    return library2
end

return library
