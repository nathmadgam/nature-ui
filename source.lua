--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║                       NATURE UI FRAMEWORK  v2                          ║
    ║   A production-ready, fully object-oriented Roblox UI framework with   ║
    ║   automatic layouting, floating overlay dropdowns, an 8-point spacing  ║
    ║   system, live theming, and RGB / HSV / HEX color support.            ║
    ╠══════════════════════════════════════════════════════════════════════╣
    ║  Architecture:                                                        ║
    ║    Library → Signal, ThemeManager, LayoutManager, OverlayManager      ║
    ║            → Window → Tab → Section → Components                       ║
    ║                                                                       ║
    ║  No external assets. No drop shadows. Everything generated in code.    ║
    ║                                                                       ║
    ║  LOADING (loadstring/executor):                                       ║
    ║    local Library = loadstring(game:HttpGet(RAW_URL))()                 ║
    ║                                                                       ║
    ║  LOADING (ModuleScript):                                              ║
    ║    local Library = require(game.ReplicatedStorage.NatureUI)           ║
    ║                                                                       ║
    ║  This file works as BOTH — it returns a ready Library instance.        ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

--==========================================================================--
--                              SERVICES                                    --
--==========================================================================--

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--==========================================================================--
--                          GLOBAL CONFIG                                   --
--==========================================================================--

local CONFIG = {
    AnimationDuration = 0.22,
    AnimationStyle    = Enum.EasingStyle.Quad,
    AnimationDirection= Enum.EasingDirection.Out,
    Font              = Enum.Font.GothamMedium,
    FontBold          = Enum.Font.GothamBold,
    FontRegular       = Enum.Font.Gotham,
}

-- 8-point spacing scale. Use Spacing[n] rather than raw numbers anywhere.
local Spacing = {
    [1] = 4,  [2] = 8,  [3] = 12, [4] = 16,
    [6] = 24, [8] = 32, [10] = 40, [12] = 48, [16] = 64,
}

-- Z-index layers so overlays never clip behind window content.
local Z = {
    Window   = 1,
    Control  = 10,
    Trigger  = 20,
    Overlay  = 1000,
}

--==========================================================================--
--                          DEFAULT THEME                                   --
--==========================================================================--

local DEFAULT_THEME = {
    -- Main window surface — deep, saturated emerald with a lively top sheen.
    Primary        = Color3.fromRGB(22, 135, 70),
    PrimaryLight   = Color3.fromRGB(52, 180, 100),
    -- Panels (sidebar / content) — slightly deeper than the surface for depth.
    Secondary      = Color3.fromRGB(30, 120, 68),
    SecondaryLight = Color3.fromRGB(64, 178, 104),
    -- Accent — bright, fresh spring green for toggles, fills, indicators.
    Accent         = Color3.fromRGB(108, 230, 130),
    AccentDim      = Color3.fromRGB(78, 198, 104),
    -- Text.
    Text           = Color3.fromRGB(248, 255, 249),
    TextDim        = Color3.fromRGB(210, 235, 216),
    TextMuted      = Color3.fromRGB(168, 206, 180),
    -- Background base (darkest).
    Background     = Color3.fromRGB(16, 96, 54),
    -- Borders — luminous mint edge.
    Border         = Color3.fromRGB(120, 214, 150),
    -- Controls.
    ToggleOff      = Color3.fromRGB(46, 132, 82),
    ToggleThumb    = Color3.fromRGB(250, 255, 250),
}

--==========================================================================--
--                          COLOR UTILITIES                                 --
--==========================================================================--

local ColorUtil = {}

-- "#RRGGBB" or "RRGGBB" -> Color3
function ColorUtil.FromHex(hex)
    hex = tostring(hex):gsub("#", "")
    if #hex == 3 then
        -- expand shorthand like #0F8 -> #00FF88
        hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
    end
    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

-- Color3 -> "#RRGGBB"
function ColorUtil.ToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

function ColorUtil.FromHSV(h, s, v)
    return Color3.fromHSV(h, s, v)
end

--==========================================================================--
--                              UTILITIES                                   --
--==========================================================================--

local Util = {}

function Util.Create(className, props, children)
    local inst = Instance.new(className)
    if props then
        for key, value in pairs(props) do
            if key ~= "Parent" then
                inst[key] = value
            end
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

function Util.Corner(radius, parent)
    return Util.Create("UICorner", {
        CornerRadius = UDim.new(0, radius or Spacing[2]),
        Parent = parent,
    })
end

function Util.Padding(parent, all, opts)
    opts = opts or {}
    return Util.Create("UIPadding", {
        PaddingTop    = UDim.new(0, opts.Top    or all or 0),
        PaddingBottom = UDim.new(0, opts.Bottom or all or 0),
        PaddingLeft   = UDim.new(0, opts.Left   or all or 0),
        PaddingRight  = UDim.new(0, opts.Right  or all or 0),
        Parent = parent,
    })
end

function Util.Stroke(parent, color, thickness, transparency)
    return Util.Create("UIStroke", {
        Color = color or DEFAULT_THEME.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

function Util.Gradient(parent, colorTop, colorBottom, rotation)
    return Util.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colorTop),
            ColorSequenceKeypoint.new(1, colorBottom),
        }),
        Rotation = rotation or 90,
        Parent = parent,
    })
end

function Util.Tween(inst, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or CONFIG.AnimationDuration,
        style or CONFIG.AnimationStyle,
        direction or CONFIG.AnimationDirection
    )
    local tween = TweenService:Create(inst, info, props)
    tween:Play()
    return tween
end

function Util.GetGuiParent()
    local ok, hidden = pcall(function()
        return gethui and gethui()
    end)
    if ok and hidden then
        return hidden
    end
    if LocalPlayer then
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then return pg end
        return LocalPlayer:WaitForChild("PlayerGui")
    end
    return CoreGui
end

--==========================================================================--
--                          ICON LIBRARY                                    --
--==========================================================================--
-- ImageLabel-based icons. Every icon is a real ImageLabel. Named icons map to
-- default asset IDs below, but you can pass any "rbxassetid://..." string when
-- creating a window/tab to override. No frame-drawn glyphs are used.

local Icons = {}

-- Default asset IDs for named icons (verified Lucide → Roblox mappings).
-- Override any of these, or pass your own rbxassetid:// directly to
-- AddTab / CreateWindow. To use a different named icon, see Icons.Library
-- or supply the raw asset id.
Icons.Library = {
    wrench    = "rbxassetid://10747383470", -- lucide-wrench (tools / configuration)
    gear      = "rbxassetid://10734950309", -- lucide-settings
    settings  = "rbxassetid://10734950309", -- lucide-settings
    cog       = "rbxassetid://10709810948", -- lucide-cog
    bug       = "rbxassetid://10709782845", -- lucide-bug (debug)
    blocks    = "rbxassetid://10709782582", -- lucide-boxes (miscellaneous)
    grid      = "rbxassetid://10723404936", -- lucide-grid
    leaf      = "rbxassetid://10723425539", -- lucide-leaf (logo / nature)
    sprout    = "rbxassetid://10734965572", -- lucide-sprout
    home      = "rbxassetid://10723407389", -- lucide-home
    star      = "rbxassetid://10734966248", -- lucide-star
    chevron   = "rbxassetid://10709790948", -- lucide-chevron-down
    chevronUp = "rbxassetid://10709791523", -- lucide-chevron-up
    close     = "rbxassetid://10747384394", -- lucide-x
    minimize  = "rbxassetid://10734896206", -- lucide-minus
    copy      = "rbxassetid://10709812159", -- lucide-copy
    check     = "rbxassetid://10709790644", -- lucide-check
    rocket    = "rbxassetid://10734934585", -- lucide-rocket
    zap       = "rbxassetid://10709790202", -- lucide-charge (lightning)
    target    = "rbxassetid://10734977012", -- lucide-target
    gamepad   = "rbxassetid://10723395215", -- lucide-gamepad-2
    palette   = "rbxassetid://10734910430", -- lucide-palette
    shield    = "rbxassetid://10734951847", -- lucide-shield
}

-- Resolve a name OR raw asset id to an asset id string.
function Icons.Resolve(nameOrId)
    if type(nameOrId) ~= "string" then
        return Icons.Library.blocks
    end
    -- Already an asset reference of some form? use as-is.
    if nameOrId:match("rbxassetid://") or nameOrId:match("rbxasset://")
    or nameOrId:match("^%d+$") then
        -- bare numeric id -> prefix it
        if nameOrId:match("^%d+$") then
            return "rbxassetid://" .. nameOrId
        end
        return nameOrId
    end
    -- Named icon lookup.
    return Icons.Library[nameOrId] or Icons.Library.blocks
end

-- Build an icon as an ImageLabel inside `parent`.
--   nameOrId : a named icon ("gear") OR a raw "rbxassetid://123" / numeric id.
--   color    : ImageColor3 tint.
-- Returns the holder Frame (the ImageLabel is named "Image" inside it).
function Icons.Build(nameOrId, parent, color)
    local holder = Util.Create("Frame", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 22, 0, 22),
        Parent = parent,
    })
    Util.Create("ImageLabel", {
        Name = "Image",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = Icons.Resolve(nameOrId),
        ImageColor3 = color or Color3.new(1, 1, 1),
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    return holder
end

-- Build a standalone chevron ImageLabel (used by dropdowns & sections).
-- Returns the ImageLabel itself so callers can tween its Rotation.
function Icons.Chevron(parent, color)
    return Util.Create("ImageLabel", {
        Name = "Chevron",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = Icons.Library.chevron,
        ImageColor3 = color or Color3.new(1, 1, 1),
        ScaleType = Enum.ScaleType.Fit,
        Parent = parent,
    })
end

--==========================================================================--
--                              SIGNAL                                      --
--==========================================================================--

local Signal = {}
Signal.__index = Signal

local Connection = {}
Connection.__index = Connection

function Connection.new(signal, fn)
    return setmetatable({ _signal = signal, _fn = fn, Connected = true }, Connection)
end

function Connection:Disconnect()
    if not self.Connected then return end
    self.Connected = false
    local conns = self._signal._connections
    for i, c in ipairs(conns) do
        if c == self then table.remove(conns, i) break end
    end
end
Connection.Destroy = Connection.Disconnect

function Signal.new()
    return setmetatable({ _connections = {}, _threads = {} }, Signal)
end

function Signal:Connect(fn)
    assert(type(fn) == "function", "Signal:Connect expects a function")
    local conn = Connection.new(self, fn)
    table.insert(self._connections, conn)
    return conn
end

function Signal:Fire(...)
    local snapshot = table.clone(self._connections)
    for _, conn in ipairs(snapshot) do
        if conn.Connected then
            task.spawn(conn._fn, ...)
        end
    end
    local waiting = self._threads
    self._threads = {}
    for _, thread in ipairs(waiting) do
        task.spawn(thread, ...)
    end
end

function Signal:Wait()
    table.insert(self._threads, coroutine.running())
    return coroutine.yield()
end

function Signal:Destroy()
    for _, conn in ipairs(self._connections) do
        conn.Connected = false
    end
    table.clear(self._connections)
    table.clear(self._threads)
end

--==========================================================================--
--                          CLEANER (MAID)                                  --
--==========================================================================--

local Cleaner = {}
Cleaner.__index = Cleaner

function Cleaner.new()
    return setmetatable({ _tasks = {} }, Cleaner)
end

function Cleaner:Add(item)
    table.insert(self._tasks, item)
    return item
end

function Cleaner:Clean()
    for _, item in ipairs(self._tasks) do
        local t = typeof(item)
        if t == "RBXScriptConnection" then
            item:Disconnect()
        elseif t == "Instance" then
            item:Destroy()
        elseif t == "table" and type(item.Destroy) == "function" then
            item:Destroy()
        elseif t == "table" and type(item.Disconnect) == "function" then
            item:Disconnect()
        elseif t == "function" then
            pcall(item)
        end
    end
    table.clear(self._tasks)
end
Cleaner.Destroy = Cleaner.Clean

--==========================================================================--
--                          THEME MANAGER                                   --
--==========================================================================--

local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new(theme)
    local self = setmetatable({}, ThemeManager)
    self.Theme = table.clone(theme or DEFAULT_THEME)
    self._registry = {}
    self.Changed = Signal.new()
    return self
end

function ThemeManager:Register(inst, applier)
    table.insert(self._registry, { inst = inst, fn = applier })
    applier(inst, self.Theme)
end

function ThemeManager:Get()
    return self.Theme
end

function ThemeManager:Set(newColors)
    for key, value in pairs(newColors) do
        self.Theme[key] = value
    end
    for i = #self._registry, 1, -1 do
        local entry = self._registry[i]
        local alive = (typeof(entry.inst) ~= "Instance") or (entry.inst.Parent ~= nil)
        if alive then
            entry.fn(entry.inst, self.Theme)
        else
            table.remove(self._registry, i)
        end
    end
    self.Changed:Fire(self.Theme)
end

--==========================================================================--
--                          LAYOUT MANAGER                                  --
--==========================================================================--

local LayoutManager = {}
LayoutManager.__index = LayoutManager

function LayoutManager.VerticalList(container, padding, alignment)
    return Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, padding or Spacing[2]),
        HorizontalAlignment = alignment or Enum.HorizontalAlignment.Center,
        Parent = container,
    })
end

function LayoutManager.HorizontalList(container, padding, valign)
    return Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, padding or Spacing[2]),
        VerticalAlignment = valign or Enum.VerticalAlignment.Center,
        Parent = container,
    })
end

function LayoutManager.AutoHeight(frame)
    frame.AutomaticSize = Enum.AutomaticSize.Y
end

function LayoutManager.BindScrollCanvas(scroll, layout)
    local function update()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + Spacing[3])
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

--==========================================================================--
--                          OVERLAY MANAGER                                 --
--==========================================================================--
-- All floating UI (dropdown menus, color pickers) is parented HERE, not inside
-- the window. This guarantees no layout reflow and no clipping: overlays float
-- above the entire interface at Z.Overlay. Only one overlay is open at a time.

local OverlayManager = {}
OverlayManager.__index = OverlayManager

function OverlayManager.new(gui)
    local self = setmetatable({}, OverlayManager)
    self.Container = Util.Create("Frame", {
        Name = "OverlayContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = Z.Overlay,
        Parent = gui,
    })
    self._active = nil       -- currently open overlay closer fn
    self._activeOwner = nil  -- the component that owns the open overlay
    return self
end

-- Open an overlay. closeFn closes it; owner identifies the component.
-- Automatically closes any previously open overlay first.
function OverlayManager:Open(owner, closeFn)
    if self._active and self._activeOwner ~= owner then
        self._active()
    end
    self._active = closeFn
    self._activeOwner = owner
end

function OverlayManager:Close(owner)
    if self._activeOwner == owner then
        self._active = nil
        self._activeOwner = nil
    end
end

function OverlayManager:CloseAll()
    if self._active then
        self._active()
        self._active = nil
        self._activeOwner = nil
    end
end

function OverlayManager:Destroy()
    self:CloseAll()
    if self.Container then self.Container:Destroy() end
end

--==========================================================================--
--                          BASE COMPONENT                                  --
--==========================================================================--

local BaseComponent = {}
BaseComponent.__index = BaseComponent

function BaseComponent.new(section)
    local self = setmetatable({}, BaseComponent)
    self._section = section
    self._theme   = section._theme
    self._overlay = section._overlay
    self._cleaner = Cleaner.new()
    self._value   = nil
    self.Changed  = Signal.new()
    self._cleaner:Add(self.Changed)
    return self
end

function BaseComponent:Get()
    return self._value
end

function BaseComponent:Set(value)
    self._value = value
    self.Changed:Fire(value)
end

function BaseComponent:Destroy()
    if self.Instance then self.Instance:Destroy() end
    self._cleaner:Clean()
end

function BaseComponent:_makeRow(height)
    local row = Util.Create("Frame", {
        Name = "Row",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 40),
        LayoutOrder = self._section:_nextOrder(),
        ZIndex = Z.Control,
        Parent = self._section.Container,
    })
    return row
end

--==========================================================================--
--                              TOGGLE                                      --
--==========================================================================--

local Toggle = setmetatable({}, { __index = BaseComponent })
Toggle.__index = Toggle

function Toggle.new(section, text, onFn, offFn, default)
    local self = BaseComponent.new(section)
    setmetatable(self, Toggle)
    self._onFn, self._offFn = onFn, offFn
    self._value = default or false

    local theme = self._theme:Get()
    local row = self:_makeRow(42)
    self.Instance = row

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 2, 0, 0),
        Font = CONFIG.Font, Text = text, TextSize = 18,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local track = Util.Create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 52, 0, 26),
        BackgroundColor3 = self._value and theme.Accent or theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = row,
    })
    Util.Corner(13, track)

    local thumb = Util.Create("Frame", {
        Name = "Thumb",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 20, 0, 20),
        Position = self._value and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 13, 0.5, 0),
        BackgroundColor3 = theme.ToggleThumb,
        BorderSizePixel = 0,
        Parent = track,
    })
    Util.Corner(10, thumb)

    local btn = Util.Create("TextButton", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = track,
    })
    self._track, self._thumb = track, thumb

    self._cleaner:Add(btn.MouseButton1Click:Connect(function() self:Set(not self._value) end))
    self._cleaner:Add(btn.MouseEnter:Connect(function()
        Util.Tween(thumb, { Size = UDim2.new(0, 22, 0, 22) }, 0.12)
    end))
    self._cleaner:Add(btn.MouseLeave:Connect(function()
        Util.Tween(thumb, { Size = UDim2.new(0, 20, 0, 20) }, 0.12)
    end))

    self:_render(false)
    return self
end

function Toggle:_render(animate)
    local theme = self._theme:Get()
    local trackColor = self._value and theme.Accent or theme.ToggleOff
    local thumbPos   = self._value and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 13, 0.5, 0)
    if animate then
        Util.Tween(self._track, { BackgroundColor3 = trackColor })
        Util.Tween(self._thumb, { Position = thumbPos })
    else
        self._track.BackgroundColor3 = trackColor
        self._thumb.Position = thumbPos
    end
end

function Toggle:Set(value)
    value = value and true or false
    if value == self._value then self:_render(true) return end
    self._value = value
    self:_render(true)
    if value then
        if self._onFn then task.spawn(self._onFn) end
    else
        if self._offFn then task.spawn(self._offFn) end
    end
    self.Changed:Fire(value)
end

--==========================================================================--
--                              BUTTON                                      --
--==========================================================================--

local Button = setmetatable({}, { __index = BaseComponent })
Button.__index = Button

function Button.new(section, text, callback)
    local self = BaseComponent.new(section)
    setmetatable(self, Button)
    local theme = self._theme:Get()
    local row = self:_makeRow(42)
    self.Instance = row

    local btn = Util.Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.SecondaryLight,
        AutoButtonColor = false, BorderSizePixel = 0,
        Font = CONFIG.Font, Text = text, TextSize = 17,
        TextColor3 = theme.Text, Parent = row,
    })
    Util.Corner(Spacing[2], btn)
    Util.Gradient(btn, theme.SecondaryLight, theme.Secondary, 90)
    self._theme:Register(btn, function(b, t)
        b.TextColor3 = t.Text; b.BackgroundColor3 = t.SecondaryLight
    end)

    local rippleHolder = Util.Create("Frame", {
        BackgroundTransparency = 1, ClipsDescendants = true,
        Size = UDim2.new(1, 0, 1, 0), Parent = btn,
    })
    Util.Corner(Spacing[2], rippleHolder)

    self._cleaner:Add(btn.MouseEnter:Connect(function()
        Util.Tween(btn, { BackgroundColor3 = self._theme:Get().Accent })
    end))
    self._cleaner:Add(btn.MouseLeave:Connect(function()
        Util.Tween(btn, { BackgroundColor3 = self._theme:Get().SecondaryLight })
    end))
    self._cleaner:Add(btn.MouseButton1Down:Connect(function(x, y)
        self:_ripple(rippleHolder, x, y)
        Util.Tween(btn, { Size = UDim2.new(1, -4, 1, -4) }, 0.08)
    end))
    self._cleaner:Add(btn.MouseButton1Up:Connect(function()
        Util.Tween(btn, { Size = UDim2.new(1, 0, 1, 0) }, 0.12)
    end))
    self._cleaner:Add(btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
        self.Changed:Fire()
    end))
    return self
end

function Button:_ripple(holder, x, y)
    local abs = holder.AbsolutePosition
    local ripple = Util.Create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, x - abs.X, 0, y - abs.Y),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 0, 0, 0), Parent = holder,
    })
    Util.Corner(999, ripple)
    Util.Tween(ripple, { Size = UDim2.new(0, 200, 0, 200), BackgroundTransparency = 1 }, 0.5)
    task.delay(0.5, function() ripple:Destroy() end)
end

--==========================================================================--
--                              DROPDOWN                                    --
--==========================================================================--
-- Floating overlay implementation. The menu is parented to the OverlayManager
-- container, positioned at the trigger's absolute screen coordinates. It never
-- changes section height, canvas size, or pushes sibling controls.

local Dropdown = setmetatable({}, { __index = BaseComponent })
Dropdown.__index = Dropdown

function Dropdown.new(section, text, options, callback, default)
    local self = BaseComponent.new(section)
    setmetatable(self, Dropdown)
    self._options  = table.clone(options or {})
    self._callback = callback
    self._open     = false
    self._value    = default or self._options[1]

    local theme = self._theme:Get()
    local row = self:_makeRow(40)
    self.Instance = row

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -Spacing[3], 1, 0),
        Font = CONFIG.Font, Text = text, TextSize = 18,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    -- Trigger (always visible, lives in the row).
    local trigger = Util.Create("TextButton", {
        Name = "Trigger",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.46, 0, 0, 38),
        BackgroundColor3 = theme.SecondaryLight,
        AutoButtonColor = false, BorderSizePixel = 0,
        Text = "", ZIndex = Z.Trigger, Parent = row,
    })
    Util.Corner(Spacing[2], trigger)
    Util.Gradient(trigger, theme.SecondaryLight, theme.Secondary, 90)
    self._theme:Register(trigger, function(b, t) b.BackgroundColor3 = t.SecondaryLight end)
    self._trigger = trigger

    local selected = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Font = CONFIG.Font, Text = tostring(self._value or "Select..."), TextSize = 17,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = Z.Trigger, Parent = trigger,
    })
    self._selectedLabel = selected
    self._theme:Register(selected, function(l, t) l.TextColor3 = t.Text end)

    local arrowHolder = Util.Create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        ZIndex = Z.Trigger, Parent = trigger,
    })
    self._arrow = Icons.Chevron(arrowHolder, theme.Text)
    self._arrow.ZIndex = Z.Trigger

    self._cleaner:Add(trigger.MouseButton1Click:Connect(function() self:_toggleOpen() end))
    -- Close the menu if the trigger scrolls off / window moves while open.
    self._cleaner:Add(trigger:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if self._open then self:_positionMenu() end
    end))
    return self
end

-- Build (or rebuild) the floating menu inside the overlay container.
function Dropdown:_buildMenu()
    if self._menu then self._menu:Destroy() end
    local theme = self._theme:Get()

    local menu = Util.Create("Frame", {
        Name = "DropdownMenu",
        BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, self._trigger.AbsoluteSize.X, 0, 0),
        ClipsDescendants = true,
        ZIndex = Z.Overlay + 1,
        Parent = self._overlay.Container,
    })
    Util.Corner(Spacing[2], menu)
    Util.Stroke(menu, theme.Border, 1, 0.35)

    local scroll = Util.Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = Z.Overlay + 2, Parent = menu,
    })
    local layout = LayoutManager.VerticalList(scroll, Spacing[1] / 2, Enum.HorizontalAlignment.Center)
    Util.Padding(scroll, Spacing[1])
    LayoutManager.BindScrollCanvas(scroll, layout)

    for i, opt in ipairs(self._options) do
        local isSel = (opt == self._value)
        local optBtn = Util.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = isSel and theme.Accent or theme.SecondaryLight,
            BackgroundTransparency = isSel and 0 or 0.4,
            AutoButtonColor = false, BorderSizePixel = 0,
            Font = CONFIG.Font, Text = tostring(opt), TextSize = 16,
            TextColor3 = theme.Text, LayoutOrder = i,
            ZIndex = Z.Overlay + 3, Parent = scroll,
        })
        Util.Corner(Spacing[1] + 2, optBtn)
        optBtn.MouseEnter:Connect(function()
            if opt ~= self._value then Util.Tween(optBtn, { BackgroundTransparency = 0.1 }, 0.1) end
        end)
        optBtn.MouseLeave:Connect(function()
            if opt ~= self._value then Util.Tween(optBtn, { BackgroundTransparency = 0.4 }, 0.1) end
        end)
        optBtn.MouseButton1Click:Connect(function()
            self:Set(opt)
            self:_toggleOpen(false)
        end)
    end
    self._menu = menu
    self._menuScroll = scroll
end

-- Position the menu directly under the trigger using absolute coords.
function Dropdown:_positionMenu()
    if not self._menu then return end
    local pos  = self._trigger.AbsolutePosition
    local size = self._trigger.AbsoluteSize
    self._menu.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y + Spacing[1])
    self._menu.Size = UDim2.new(0, size.X, 0, self._menu.Size.Y.Offset) -- width tracks trigger
end

function Dropdown:_toggleOpen(force)
    if force ~= nil then self._open = force else self._open = not self._open end

    if self._open then
        self:_buildMenu()
        self:_positionMenu()
        local count = #self._options
        local targetH = math.min(count * 32 + Spacing[2], 200)
        Util.Tween(self._menu, { Size = UDim2.new(0, self._trigger.AbsoluteSize.X, 0, targetH) })
        Util.Tween(self._arrow, { Rotation = 180 })
        -- Register with overlay manager so opening another closes this.
        self._overlay:Open(self, function() self:_toggleOpen(false) end)
    else
        Util.Tween(self._arrow, { Rotation = 0 })
        if self._menu then
            local menu = self._menu
            self._menu = nil
            Util.Tween(menu, { Size = UDim2.new(0, menu.Size.X.Offset, 0, 0) })
            task.delay(CONFIG.AnimationDuration, function()
                if menu then menu:Destroy() end
            end)
        end
        self._overlay:Close(self)
    end
end

function Dropdown:Set(value)
    self._value = value
    self._selectedLabel.Text = tostring(value)
    if self._open then self:_buildMenu(); self:_positionMenu() end
    if self._callback then task.spawn(self._callback, value) end
    self.Changed:Fire(value)
end

function Dropdown:Refresh(newValues)
    self._options = table.clone(newValues or {})
    if not table.find(self._options, self._value) then
        self._value = self._options[1]
        self._selectedLabel.Text = tostring(self._value or "Select...")
    end
    if self._open then self:_buildMenu(); self:_positionMenu() end
end

function Dropdown:Destroy()
    if self._menu then self._menu:Destroy() end
    self._overlay:Close(self)
    BaseComponent.Destroy(self)
end

--==========================================================================--
--                              SLIDER                                      --
--==========================================================================--

local Slider = setmetatable({}, { __index = BaseComponent })
Slider.__index = Slider

function Slider.new(section, text, min, max, default, callback)
    local self = BaseComponent.new(section)
    setmetatable(self, Slider)
    self._min, self._max = min or 0, max or 100
    self._callback = callback
    self._value = math.clamp(default or self._min, self._min, self._max)

    local theme = self._theme:Get()
    local row = self:_makeRow(54)
    self.Instance = row

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 22),
        Font = CONFIG.Font, Text = text, TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local valueLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 60, 0, 22),
        Font = CONFIG.FontBold, Text = tostring(self._value), TextSize = 18,
        TextColor3 = theme.Accent, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
    })
    self._valueLabel = valueLabel
    self._theme:Register(valueLabel, function(l, t) l.TextColor3 = t.Accent end)

    local track = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 8), BackgroundColor3 = theme.ToggleOff,
        BorderSizePixel = 0, Parent = row,
    })
    Util.Corner(4, track)
    self._theme:Register(track, function(o, t) o.BackgroundColor3 = t.ToggleOff end)

    local fill = Util.Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = theme.Accent,
        BorderSizePixel = 0, Parent = track,
    })
    Util.Corner(4, fill)
    self._fill = fill
    self._theme:Register(fill, function(f, t) f.BackgroundColor3 = t.Accent end)

    local knob = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = theme.ToggleThumb,
        BorderSizePixel = 0, ZIndex = 3, Parent = track,
    })
    Util.Corner(8, knob)
    self._knob = knob

    local btn = Util.Create("TextButton", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10), Text = "", ZIndex = 4, Parent = track,
    })
    self._track = track

    local dragging = false
    local function updateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        self:Set(math.floor(self._min + (self._max - self._min) * rel + 0.5))
    end
    self._cleaner:Add(btn.MouseButton1Down:Connect(function(x) dragging = true; updateFromX(x) end))
    self._cleaner:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    self._cleaner:Add(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end))
    self:_render()
    return self
end

function Slider:_render()
    local rel = (self._value - self._min) / (self._max - self._min)
    Util.Tween(self._fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.08)
    Util.Tween(self._knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.08)
    self._valueLabel.Text = tostring(self._value)
end

function Slider:Set(value)
    value = math.clamp(value, self._min, self._max)
    if value == self._value then return end
    self._value = value
    self:_render()
    if self._callback then task.spawn(self._callback, value) end
    self.Changed:Fire(value)
end

--==========================================================================--
--                              TEXTBOX                                     --
--==========================================================================--

local Textbox = setmetatable({}, { __index = BaseComponent })
Textbox.__index = Textbox

function Textbox.new(section, text, placeholder, callback)
    local self = BaseComponent.new(section)
    setmetatable(self, Textbox)
    self._callback = callback
    self._value = ""

    local theme = self._theme:Get()
    local row = self:_makeRow(40)
    self.Instance = row

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(0.5, -Spacing[3], 1, 0),
        Font = CONFIG.Font, Text = text, TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local boxFrame = Util.Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0.46, 0, 0, 36), BackgroundColor3 = theme.SecondaryLight,
        BorderSizePixel = 0, Parent = row,
    })
    Util.Corner(Spacing[2], boxFrame)
    local stroke = Util.Stroke(boxFrame, theme.Border, 1, 0.6)
    self._theme:Register(boxFrame, function(b, t) b.BackgroundColor3 = t.SecondaryLight end)

    local input = Util.Create("TextBox", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0), Font = CONFIG.Font, Text = "",
        PlaceholderText = placeholder or "Enter text...",
        PlaceholderColor3 = theme.TextMuted, TextSize = 16, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = boxFrame,
    })
    self._input = input
    self._theme:Register(input, function(b, t) b.TextColor3 = t.Text; b.PlaceholderColor3 = t.TextMuted end)

    self._cleaner:Add(input.Focused:Connect(function()
        Util.Tween(stroke, { Transparency = 0, Color = self._theme:Get().Accent }, 0.15)
    end))
    self._cleaner:Add(input.FocusLost:Connect(function()
        Util.Tween(stroke, { Transparency = 0.6, Color = self._theme:Get().Border }, 0.15)
        self._value = input.Text
        if self._callback then task.spawn(self._callback, input.Text) end
        self.Changed:Fire(input.Text)
    end))
    return self
end

function Textbox:Set(value)
    self._value = tostring(value)
    self._input.Text = self._value
    self.Changed:Fire(self._value)
end

--==========================================================================--
--                              LABEL                                       --
--==========================================================================--

local Label = setmetatable({}, { __index = BaseComponent })
Label.__index = Label

function Label.new(section, text)
    local self = BaseComponent.new(section)
    setmetatable(self, Label)
    self._value = text
    local theme = self._theme:Get()
    local row = self:_makeRow(28)
    self.Instance = row
    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        Font = CONFIG.Font, Text = text, TextSize = 17, TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._label = label
    self._theme:Register(label, function(l, t) l.TextColor3 = t.TextDim end)
    return self
end

function Label:Set(value)
    self._value = value
    self._label.Text = value
    self.Changed:Fire(value)
end

--==========================================================================--
--                              PARAGRAPH                                   --
--==========================================================================--

local Paragraph = setmetatable({}, { __index = BaseComponent })
Paragraph.__index = Paragraph

function Paragraph.new(section, title, body)
    local self = BaseComponent.new(section)
    setmetatable(self, Paragraph)
    local theme = self._theme:Get()
    local row = self:_makeRow(0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    self.Instance = row

    local container = Util.Create("Frame", {
        BackgroundColor3 = theme.Secondary, BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0, Parent = row,
    })
    Util.Corner(Spacing[2], container)
    Util.Padding(container, Spacing[3])
    LayoutManager.VerticalList(container, Spacing[1] + 2, Enum.HorizontalAlignment.Left)
    self._theme:Register(container, function(c, t) c.BackgroundColor3 = t.Secondary end)

    local titleLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
        Font = CONFIG.FontBold, Text = title, TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = container,
    })
    self._theme:Register(titleLabel, function(l, t) l.TextColor3 = t.Text end)

    local bodyLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, Font = CONFIG.FontRegular,
        Text = body, TextSize = 15, TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, Parent = container,
    })
    self._title, self._body = titleLabel, bodyLabel
    self._theme:Register(bodyLabel, function(l, t) l.TextColor3 = t.TextDim end)
    return self
end

function Paragraph:Set(body)
    self._body.Text = body
    self.Changed:Fire(body)
end

--==========================================================================--
--                              KEYBIND                                     --
--==========================================================================--

local Keybind = setmetatable({}, { __index = BaseComponent })
Keybind.__index = Keybind

function Keybind.new(section, text, defaultKey, callback)
    local self = BaseComponent.new(section)
    setmetatable(self, Keybind)
    self._callback = callback
    self._value = defaultKey or Enum.KeyCode.Unknown
    self._listening = false

    local theme = self._theme:Get()
    local row = self:_makeRow(40)
    self.Instance = row

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0),
        Font = CONFIG.Font, Text = text, TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local keyBtn = Util.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 110, 0, 34), BackgroundColor3 = theme.SecondaryLight,
        AutoButtonColor = false, BorderSizePixel = 0, Font = CONFIG.Font,
        Text = self._value.Name, TextSize = 15, TextColor3 = theme.Text, Parent = row,
    })
    Util.Corner(Spacing[2], keyBtn)
    self._keyBtn = keyBtn
    self._theme:Register(keyBtn, function(b, t) b.BackgroundColor3 = t.SecondaryLight; b.TextColor3 = t.Text end)

    self._cleaner:Add(keyBtn.MouseButton1Click:Connect(function()
        self._listening = true
        keyBtn.Text = "..."
        Util.Tween(keyBtn, { BackgroundColor3 = self._theme:Get().Accent }, 0.12)
    end))
    self._cleaner:Add(UserInputService.InputBegan:Connect(function(input, processed)
        if self._listening and input.UserInputType == Enum.UserInputType.Keyboard then
            self._listening = false
            self:Set(input.KeyCode)
            Util.Tween(keyBtn, { BackgroundColor3 = self._theme:Get().SecondaryLight }, 0.12)
        elseif not self._listening and not processed
        and input.KeyCode == self._value and self._value ~= Enum.KeyCode.Unknown then
            if self._callback then task.spawn(self._callback) end
        end
    end))
    return self
end

function Keybind:Set(keyCode)
    self._value = keyCode
    self._keyBtn.Text = keyCode.Name
    self.Changed:Fire(keyCode)
end

--==========================================================================--
--                          COLOR PICKER                                    --
--==========================================================================--
-- Floating overlay color picker with SV box, hue bar, HEX input (copy/paste),
-- and live preview. Renders in the OverlayManager container like dropdowns.

local ColorPicker = setmetatable({}, { __index = BaseComponent })
ColorPicker.__index = ColorPicker

function ColorPicker.new(section, text, defaultColor, callback)
    local self = BaseComponent.new(section)
    setmetatable(self, ColorPicker)
    self._callback = callback
    self._value = defaultColor or Color3.fromRGB(0, 255, 0)
    self._open = false
    self._h, self._s, self._v = self._value:ToHSV()

    local theme = self._theme:Get()
    local row = self:_makeRow(40)
    self.Instance = row

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(0.7, 0, 1, 0),
        Font = CONFIG.Font, Text = text, TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local swatch = Util.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 50, 0, 28), BackgroundColor3 = self._value,
        AutoButtonColor = false, BorderSizePixel = 0, Text = "",
        ZIndex = Z.Trigger, Parent = row,
    })
    Util.Corner(Spacing[1] + 2, swatch)
    Util.Stroke(swatch, theme.Border, 1, 0.4)
    self._swatch = swatch

    self._cleaner:Add(swatch.MouseButton1Click:Connect(function() self:_togglePopup() end))
    self._cleaner:Add(swatch:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if self._open then self:_positionPopup() end
    end))
    return self
end

function ColorPicker:_buildPopup()
    if self._popup then self._popup:Destroy() end
    local theme = self._theme:Get()

    local popup = Util.Create("Frame", {
        Name = "ColorPicker",
        Size = UDim2.new(0, 220, 0, 0), BackgroundColor3 = theme.Secondary,
        BorderSizePixel = 0, ClipsDescendants = true,
        ZIndex = Z.Overlay + 1, Parent = self._overlay.Container,
    })
    Util.Corner(Spacing[2], popup)
    Util.Stroke(popup, theme.Border, 1, 0.4)
    self._popup = popup

    local inner = Util.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        ZIndex = Z.Overlay + 2, Parent = popup,
    })
    Util.Padding(inner, Spacing[3])
    LayoutManager.VerticalList(inner, Spacing[2], Enum.HorizontalAlignment.Center)

    -- SV box.
    local svBox = Util.Create("ImageButton", {
        Size = UDim2.new(1, 0, 0, 120), BackgroundColor3 = Color3.fromHSV(self._h, 1, 1),
        BorderSizePixel = 0, AutoButtonColor = false,
        ZIndex = Z.Overlay + 2, Parent = inner,
    })
    Util.Corner(Spacing[1] + 2, svBox)
    Util.Create("UIGradient", {
        Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
        }), Parent = svBox,
    })
    local valOverlay = Util.Create("Frame", {
        Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0),
        BorderSizePixel = 0, ZIndex = Z.Overlay + 2, Parent = svBox,
    })
    Util.Corner(Spacing[1] + 2, valOverlay)
    Util.Create("UIGradient", {
        Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
        }), Rotation = 90, Parent = valOverlay,
    })
    self._svBox = svBox

    local svCursor = Util.Create("Frame", {
        Size = UDim2.new(0, 8, 0, 8), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0,
        Position = UDim2.new(self._s, 0, 1 - self._v, 0),
        ZIndex = Z.Overlay + 3, Parent = svBox,
    })
    Util.Corner(4, svCursor)
    Util.Stroke(svCursor, Color3.new(0,0,0), 1, 0)
    self._svCursor = svCursor

    -- Hue bar.
    local hueBar = Util.Create("ImageButton", {
        Size = UDim2.new(1, 0, 0, 16), BorderSizePixel = 0,
        AutoButtonColor = false, ZIndex = Z.Overlay + 2, Parent = inner,
    })
    Util.Corner(Spacing[1] + 2, hueBar)
    Util.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
        }), Parent = hueBar,
    })
    self._hueBar = hueBar
    local hueCursor = Util.Create("Frame", {
        Size = UDim2.new(0, 4, 1, 4), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(self._h, 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0, ZIndex = Z.Overlay + 3, Parent = hueBar,
    })
    Util.Corner(2, hueCursor)
    Util.Stroke(hueCursor, Color3.new(0,0,0), 1, 0)
    self._hueCursor = hueCursor

    -- HEX input row (copy/paste).
    local hexRow = Util.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30),
        ZIndex = Z.Overlay + 2, Parent = inner,
    })
    local hexBox = Util.Create("Frame", {
        Size = UDim2.new(1, -36, 1, 0), BackgroundColor3 = theme.SecondaryLight,
        BorderSizePixel = 0, ZIndex = Z.Overlay + 2, Parent = hexRow,
    })
    Util.Corner(Spacing[1] + 2, hexBox)
    local hexInput = Util.Create("TextBox", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 10, 0, 0), Font = CONFIG.Font,
        Text = ColorUtil.ToHex(self._value), TextSize = 15, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
        ZIndex = Z.Overlay + 3, Parent = hexBox,
    })
    self._hexInput = hexInput

    -- Copy button.
    local copyBtn = Util.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 30, 1, 0), BackgroundColor3 = theme.SecondaryLight,
        AutoButtonColor = false, BorderSizePixel = 0, Font = CONFIG.FontBold,
        Text = "⧉", TextSize = 16, TextColor3 = theme.Text,
        ZIndex = Z.Overlay + 3, Parent = hexRow,
    })
    Util.Corner(Spacing[1] + 2, copyBtn)

    -- Interactions ----------------------------------------------------------
    local svDragging, hueDragging = false, false
    local function updateSV(x, y)
        local rx = math.clamp((x - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
        local ry = math.clamp((y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
        self._s, self._v = rx, 1 - ry
        svCursor.Position = UDim2.new(rx, 0, ry, 0)
        self:_apply(true)
    end
    local function updateHue(x)
        local rx = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
        self._h = rx
        hueCursor.Position = UDim2.new(rx, 0, 0.5, 0)
        svBox.BackgroundColor3 = Color3.fromHSV(self._h, 1, 1)
        self:_apply(true)
    end

    svBox.MouseButton1Down:Connect(function(x, y) svDragging = true; updateSV(x, y) end)
    hueBar.MouseButton1Down:Connect(function(x) hueDragging = true; updateHue(x) end)
    self._popupConns = {
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                svDragging, hueDragging = false, false
            end
        end),
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                if svDragging then updateSV(input.Position.X, input.Position.Y) end
                if hueDragging then updateHue(input.Position.X) end
            end
        end),
    }

    -- HEX paste: apply typed hex on focus lost.
    hexInput.FocusLost:Connect(function()
        local ok, color = pcall(ColorUtil.FromHex, hexInput.Text)
        if ok and color then
            self:Set(color)
        else
            hexInput.Text = ColorUtil.ToHex(self._value)
        end
    end)
    -- HEX copy.
    copyBtn.MouseButton1Click:Connect(function()
        local hex = ColorUtil.ToHex(self._value)
        if setclipboard then pcall(setclipboard, hex) end
        local old = copyBtn.Text
        copyBtn.Text = "✓"
        task.delay(0.8, function() if copyBtn then copyBtn.Text = old end end)
    end)
end

function ColorPicker:_positionPopup()
    if not self._popup then return end
    local pos  = self._swatch.AbsolutePosition
    local size = self._swatch.AbsoluteSize
    -- Right-align popup to the swatch's right edge.
    local px = pos.X + size.X - 220
    self._popup.Position = UDim2.new(0, px, 0, pos.Y + size.Y + Spacing[1])
end

function ColorPicker:_apply(skipSet)
    local color = Color3.fromHSV(self._h, self._s, self._v)
    self._value = color
    self._swatch.BackgroundColor3 = color
    if self._hexInput then self._hexInput.Text = ColorUtil.ToHex(color) end
    if self._callback then task.spawn(self._callback, color) end
    self.Changed:Fire(color)
end

function ColorPicker:_togglePopup()
    self._open = not self._open
    if self._open then
        self:_buildPopup()
        self:_positionPopup()
        Util.Tween(self._popup, { Size = UDim2.new(0, 220, 0, 230) })
        self._overlay:Open(self, function() self:_togglePopup() end)
    else
        self:_closePopup()
        self._overlay:Close(self)
    end
end

function ColorPicker:_closePopup()
    self._open = false
    if self._popupConns then
        for _, c in ipairs(self._popupConns) do c:Disconnect() end
        self._popupConns = nil
    end
    if self._popup then
        local popup = self._popup
        self._popup = nil
        Util.Tween(popup, { Size = UDim2.new(0, 220, 0, 0) })
        task.delay(CONFIG.AnimationDuration, function() if popup then popup:Destroy() end end)
    end
end

function ColorPicker:Set(color)
    self._value = color
    self._h, self._s, self._v = color:ToHSV()
    self._swatch.BackgroundColor3 = color
    if self._svBox then
        self._svBox.BackgroundColor3 = Color3.fromHSV(self._h, 1, 1)
        self._svCursor.Position = UDim2.new(self._s, 0, 1 - self._v, 0)
        self._hueCursor.Position = UDim2.new(self._h, 0, 0.5, 0)
        self._hexInput.Text = ColorUtil.ToHex(color)
    end
    if self._callback then task.spawn(self._callback, color) end
    self.Changed:Fire(color)
end

function ColorPicker:Destroy()
    self:_closePopup()
    self._overlay:Close(self)
    BaseComponent.Destroy(self)
end

--==========================================================================--
--                              SECTION                                     --
--==========================================================================--

local Section = {}
Section.__index = Section

function Section.new(tab, title)
    local self = setmetatable({}, Section)
    self._tab = tab
    self._theme = tab._theme
    self._overlay = tab._overlay
    self._cleaner = Cleaner.new()
    self._components = {}
    self._order = 0
    self._expanded = true

    local theme = self._theme:Get()

    self.Wrapper = Util.Create("Frame", {
        Name = "Section_" .. title,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = tab:_nextSectionOrder(), Parent = tab.Content,
    })
    LayoutManager.VerticalList(self.Wrapper, Spacing[1] + 2, Enum.HorizontalAlignment.Center)

    local header = Util.Create("TextButton", {
        Name = "Header", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36), AutoButtonColor = false, Text = "",
        LayoutOrder = 0, Parent = self.Wrapper,
    })

    local chevHolder = Util.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), Parent = header,
    })
    local chev = Icons.Chevron(chevHolder, theme.Text)
    chev.Rotation = 180  -- points up when expanded
    self._chev = chev

    local titleLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -40, 1, 0), Font = CONFIG.FontBold, Text = title,
        TextSize = 22, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = header,
    })
    self._theme:Register(titleLabel, function(l, t) l.TextColor3 = t.Text end)

    self.Container = Util.Create("Frame", {
        Name = "Container", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true, LayoutOrder = 1, Parent = self.Wrapper,
    })
    LayoutManager.VerticalList(self.Container, Spacing[4], Enum.HorizontalAlignment.Center)
    Util.Padding(self.Container, nil, { Top = Spacing[1] + 2, Bottom = Spacing[1] + 2 })

    self._cleaner:Add(header.MouseButton1Click:Connect(function() self:_toggleExpand() end))
    return self
end

function Section:_nextOrder()
    self._order += 1
    return self._order
end

function Section:_toggleExpand()
    self._expanded = not self._expanded
    if self._expanded then
        self.Container.Visible = true
        self.Container.AutomaticSize = Enum.AutomaticSize.Y
        Util.Tween(self._chev, { Rotation = 180 })
    else
        self.Container.AutomaticSize = Enum.AutomaticSize.None
        Util.Tween(self._chev, { Rotation = 0 })
        Util.Tween(self.Container, { Size = UDim2.new(1, 0, 0, 0) })
        task.delay(CONFIG.AnimationDuration, function()
            if not self._expanded then self.Container.Visible = false end
        end)
    end
end

local function registerComponent(self, component)
    table.insert(self._components, component)
    self._cleaner:Add(component)
    return component
end

function Section:AddToggle(text, onFn, offFn, default)
    return registerComponent(self, Toggle.new(self, text, onFn, offFn, default))
end
function Section:AddButton(text, callback)
    return registerComponent(self, Button.new(self, text, callback))
end
function Section:AddDropdown(text, options, callback, default)
    return registerComponent(self, Dropdown.new(self, text, options, callback, default))
end
function Section:AddSlider(text, min, max, default, callback)
    return registerComponent(self, Slider.new(self, text, min, max, default, callback))
end
function Section:AddTextbox(text, placeholder, callback)
    return registerComponent(self, Textbox.new(self, text, placeholder, callback))
end
function Section:AddLabel(text)
    return registerComponent(self, Label.new(self, text))
end
function Section:AddParagraph(title, body)
    return registerComponent(self, Paragraph.new(self, title, body))
end
function Section:AddKeybind(text, defaultKey, callback)
    return registerComponent(self, Keybind.new(self, text, defaultKey, callback))
end
function Section:AddColorPicker(text, defaultColor, callback)
    return registerComponent(self, ColorPicker.new(self, text, defaultColor, callback))
end

function Section:Destroy()
    for _, comp in ipairs(self._components) do comp:Destroy() end
    table.clear(self._components)
    self._cleaner:Clean()
    if self.Wrapper then self.Wrapper:Destroy() end
end

--==========================================================================--
--                              TAB                                         --
--==========================================================================--

local Tab = {}
Tab.__index = Tab

function Tab.new(window, name, iconName)
    local self = setmetatable({}, Tab)
    self._window = window
    self._theme = window._theme
    self._overlay = window._overlay
    self._cleaner = Cleaner.new()
    self._sections = {}
    self._sectionOrder = 0
    self._active = false

    local theme = self._theme:Get()

    local button = Util.Create("TextButton", {
        Name = "Tab_" .. name, Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = theme.SecondaryLight, BackgroundTransparency = 1,
        AutoButtonColor = false, BorderSizePixel = 0, Text = "",
        LayoutOrder = window:_nextTabOrder(), Parent = window.TabList,
    })
    Util.Corner(Spacing[2] + 2, button)
    self._button = button

    local highlight = Util.Create("Frame", {
        Name = "Highlight", Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = theme.SecondaryLight, BackgroundTransparency = 1,
        BorderSizePixel = 0, Parent = button,
    })
    Util.Corner(Spacing[2] + 2, highlight)
    Util.Gradient(highlight, theme.SecondaryLight, theme.Secondary, 0)
    self._highlight = highlight

    local iconHolder = Util.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0, Spacing[4], 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 2, Parent = button,
    })
    Icons.Build(iconName or "blocks", iconHolder, theme.Text)

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 54, 0, 0),
        Size = UDim2.new(1, -60, 1, 0), Font = CONFIG.Font, Text = name,
        TextSize = 19, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = button,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local page = Util.Create("ScrollingFrame", {
        Name = "Page_" .. name, Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Accent, ScrollBarImageTransparency = 0.3,
        CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, Parent = window.ContentContainer,
    })
    Util.Padding(page, nil, { Top = Spacing[1], Bottom = Spacing[2], Left = Spacing[1], Right = Spacing[2] })
    self.Content = page
    local contentLayout = LayoutManager.VerticalList(page, Spacing[3] + 2, Enum.HorizontalAlignment.Center)
    LayoutManager.BindScrollCanvas(page, contentLayout)

    self._cleaner:Add(button.MouseButton1Click:Connect(function() window:_selectTab(self) end))
    self._cleaner:Add(button.MouseEnter:Connect(function()
        if not self._active then Util.Tween(button, { BackgroundTransparency = 0.85 }, 0.12) end
    end))
    self._cleaner:Add(button.MouseLeave:Connect(function()
        if not self._active then Util.Tween(button, { BackgroundTransparency = 1 }, 0.12) end
    end))
    return self
end

function Tab:_nextSectionOrder()
    self._sectionOrder += 1
    return self._sectionOrder
end

function Tab:_setActive(active)
    self._active = active
    self.Content.Visible = active
    if active then
        Util.Tween(self._button, { BackgroundTransparency = 1 }, 0.15)
        Util.Tween(self._highlight, { BackgroundTransparency = 0.15 }, 0.2)
    else
        Util.Tween(self._highlight, { BackgroundTransparency = 1 }, 0.2)
        Util.Tween(self._button, { BackgroundTransparency = 1 }, 0.15)
    end
end

function Tab:AddSection(title)
    local section = Section.new(self, title)
    table.insert(self._sections, section)
    return section
end

function Tab:Destroy()
    for _, section in ipairs(self._sections) do section:Destroy() end
    table.clear(self._sections)
    self._cleaner:Clean()
    if self._button then self._button:Destroy() end
    if self.Content then self.Content:Destroy() end
end

--==========================================================================--
--                              WINDOW                                      --
--==========================================================================--

local Window = {}
Window.__index = Window

local MIN_W, MIN_H = 540, 360  -- resize lower bounds

function Window.new(library, opts)
    local self = setmetatable({}, Window)
    opts = opts or {}
    self._library = library
    self._theme = library._theme
    self._cleaner = Cleaner.new()
    self._tabs = {}
    self._tabOrder = 0
    self._activeTab = nil
    self._minimized = false

    local theme = self._theme:Get()

    -- ScreenGui -------------------------------------------------------------
    local gui = Util.Create("ScreenGui", {
        Name = "NatureUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 999,
    })
    pcall(function() gui.Parent = Util.GetGuiParent() end)
    self.Gui = gui
    self._cleaner:Add(gui)

    local scale = Util.Create("UIScale", { Scale = 1, Parent = gui })
    self._scale = scale

    -- Overlay manager (must be a sibling above the window). -----------------
    self._overlay = OverlayManager.new(gui)
    self._cleaner:Add(self._overlay)

    -- Main window (NO drop shadow — borders + gradient for hierarchy). ------
    local main = Util.Create("Frame", {
        Name = "MainWindow", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 720, 0, 470),
        BackgroundColor3 = theme.Primary, BorderSizePixel = 0,
        ClipsDescendants = true,  -- prevents minimize content leak
        ZIndex = Z.Window, Parent = gui,
    })
    Util.Corner(Spacing[3] + 2, main)
    Util.Gradient(main, theme.PrimaryLight, theme.Primary, 135)
    Util.Stroke(main, theme.Border, 1.5, 0.3)
    self.Main = main
    self._theme:Register(main, function(m, t) m.BackgroundColor3 = t.Primary end)

    -- Header ----------------------------------------------------------------
    local header = Util.Create("Frame", {
        Name = "Header", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 64), Parent = main,
    })
    self.Header = header

    -- Logo (icon placeholder slot — never collapses spacing). ---------------
    local logoHolder = Util.Create("Frame", {
        Name = "LogoSlot", BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, Spacing[6] - 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), Parent = header,
    })
    Icons.Build(opts.Icon or "leaf", logoHolder, theme.Text)

    -- Title + subtitle. Using one container with horizontal list keeps them
    -- perfectly centered and correctly spaced regardless of title length.
    local titleHolder = Util.Create("Frame", {
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 60, 0, 0), Parent = header,
    })
    LayoutManager.HorizontalList(titleHolder, Spacing[2], Enum.VerticalAlignment.Center)

    local titleLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0), Font = CONFIG.FontBold,
        Text = opts.Title or "Nature", TextSize = 24, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = titleHolder,
    })
    self._titleLabel = titleLabel
    self._theme:Register(titleLabel, function(l, t) l.TextColor3 = t.Text end)

    local subtitleLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0), Font = CONFIG.FontRegular,
        Text = opts.Subtitle or "Basic", TextSize = 24, TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = titleHolder,
    })
    self._subtitleLabel = subtitleLabel
    self._theme:Register(subtitleLabel, function(l, t) l.TextColor3 = t.TextDim end)

    -- Window controls -------------------------------------------------------
    local function makeControl(symbol, xOffset, hoverColor)
        local btn = Util.Create("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOffset, 0.5, 0),
            Size = UDim2.new(0, 34, 0, 34), BackgroundTransparency = 1,
            Font = CONFIG.FontBold, Text = symbol, TextSize = 26,
            TextColor3 = theme.Text, Parent = header,
        })
        Util.Corner(Spacing[2], btn)
        btn.MouseEnter:Connect(function()
            Util.Tween(btn, { BackgroundColor3 = hoverColor, BackgroundTransparency = 0.7 }, 0.12)
        end)
        btn.MouseLeave:Connect(function()
            Util.Tween(btn, { BackgroundTransparency = 1 }, 0.12)
        end)
        return btn
    end
    local closeBtn = makeControl("×", -Spacing[4], Color3.fromRGB(200, 70, 70))
    local minBtn   = makeControl("–", -Spacing[12] + 2, theme.SecondaryLight)
    self._cleaner:Add(closeBtn.MouseButton1Click:Connect(function() self:Close() end))
    self._cleaner:Add(minBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end))

    -- Divider.
    local divider = Util.Create("Frame", {
        BackgroundColor3 = theme.Border, BackgroundTransparency = 0.5, BorderSizePixel = 0,
        Size = UDim2.new(1, -Spacing[12] + 4, 0, 1), Position = UDim2.new(0, Spacing[6] - 2, 0, 64), Parent = main,
    })
    self._theme:Register(divider, function(d, t) d.BackgroundColor3 = t.Border end)

    -- Body ------------------------------------------------------------------
    local body = Util.Create("Frame", {
        Name = "Body", BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 72), Size = UDim2.new(1, 0, 1, -84), Parent = main,
    })
    self.Body = body

    -- Sidebar.
    local sidebar = Util.Create("Frame", {
        Name = "Sidebar", Position = UDim2.new(0, Spacing[4] + 2, 0, 0),
        Size = UDim2.new(0, 270, 1, 0), BackgroundColor3 = theme.Secondary,
        BackgroundTransparency = 0.25, BorderSizePixel = 0, Parent = body,
    })
    Util.Corner(Spacing[3], sidebar)
    Util.Gradient(sidebar, theme.PrimaryLight, theme.Secondary, 160)
    Util.Stroke(sidebar, theme.Border, 1, 0.6)
    self.Sidebar = sidebar
    self._theme:Register(sidebar, function(s, t) s.BackgroundColor3 = t.Secondary end)

    local tabList = Util.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -Spacing[6], 1, -Spacing[6]),
        Position = UDim2.new(0, Spacing[3], 0, Spacing[3] + 2), Parent = sidebar,
    })
    LayoutManager.VerticalList(tabList, Spacing[3] - 2, Enum.HorizontalAlignment.Center)
    self.TabList = tabList

    -- Content panel.
    local contentPanel = Util.Create("Frame", {
        Name = "ContentPanel", Position = UDim2.new(0, 306, 0, 0),
        Size = UDim2.new(1, -324, 1, 0), BackgroundColor3 = theme.Secondary,
        BackgroundTransparency = 0.25, BorderSizePixel = 0, Parent = body,
    })
    Util.Corner(Spacing[3], contentPanel)
    Util.Gradient(contentPanel, theme.PrimaryLight, theme.Secondary, 200)
    Util.Stroke(contentPanel, theme.Border, 1, 0.6)
    self._contentPanel = contentPanel
    self._theme:Register(contentPanel, function(c, t) c.BackgroundColor3 = t.Secondary end)

    local contentContainer = Util.Create("Frame", {
        Name = "ContentContainer", BackgroundTransparency = 1,
        Size = UDim2.new(1, -Spacing[8] + 4, 1, -Spacing[6] + 4),
        Position = UDim2.new(0, Spacing[4] + 2, 0, Spacing[4]), Parent = contentPanel,
    })
    self.ContentContainer = contentContainer

    -- Resize handle (bottom-right corner). ----------------------------------
    self:_setupResize(main)

    -- Dragging & responsive scaling. ----------------------------------------
    self:_setupDragging(header, main)
    self:_setupViewportScaling()

    -- Close any open overlay when the window itself is clicked elsewhere.
    self._cleaner:Add(UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            task.defer(function()
                -- if the click wasn't on a trigger/menu, close overlays
                self._overlay:CloseAll()
            end)
        end
    end))
    return self
end

function Window:_nextTabOrder()
    self._tabOrder += 1
    return self._tabOrder
end

function Window:_setupDragging(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    self._cleaner:Add(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, target.Position
        end
    end))
    self._cleaner:Add(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    self._cleaner:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

function Window:_setupResize(main)
    local theme = self._theme:Get()
    local handle = Util.Create("TextButton", {
        Name = "ResizeHandle", AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -4, 1, -4), Size = UDim2.new(0, 16, 0, 16),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        ZIndex = Z.Control, Parent = main,
    })
    -- visual grip (two diagonal lines) — plain frames, not the old glyph helper
    local function gripLine(width, posX, posY)
        Util.Create("Frame", {
            BackgroundColor3 = theme.Border, BackgroundTransparency = 0.4,
            BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.new(0, width, 0, 2), Position = UDim2.new(0.5, posX, 0.5, posY),
            Rotation = -45, ZIndex = Z.Control, Parent = handle,
        })
    end
    gripLine(10, 0, 2)
    gripLine(5, 3, 5)

    local resizing, startPos, startSize = false, nil, nil
    self._cleaner:Add(handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing, startPos, startSize = true, input.Position, main.AbsoluteSize
        end
    end))
    self._cleaner:Add(UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            local newW = math.max(MIN_W, startSize.X + delta.X)
            local newH = math.max(MIN_H, startSize.Y + delta.Y)
            main.Size = UDim2.new(0, newW, 0, newH)
        end
    end))
    self._cleaner:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end))
end

function Window:_setupViewportScaling()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local function update()
        local vp = camera.ViewportSize
        local s = math.clamp(math.min(vp.X / 760, vp.Y / 520), 0.45, 1)
        self._scale.Scale = s
    end
    self._cleaner:Add(camera:GetPropertyChangedSignal("ViewportSize"):Connect(update))
    update()
end

function Window:_selectTab(tab)
    if self._activeTab == tab then return end
    self._overlay:CloseAll()
    for _, t in ipairs(self._tabs) do t:_setActive(t == tab) end
    self._activeTab = tab
end

function Window:AddTab(name, iconName)
    local tab = Tab.new(self, name, iconName)
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self:_selectTab(tab) end
    return tab
end

function Window:SetTitle(text) self._titleLabel.Text = text end
function Window:SetSubtitle(text) self._subtitleLabel.Text = text end

-- Minimize: 1) clipping already on, 2) tween size, 3) tween transparency.
function Window:ToggleMinimize()
    self._overlay:CloseAll()
    self._minimized = not self._minimized
    if self._minimized then
        self._savedSize = self.Main.Size
        Util.Tween(self.Body, { Position = UDim2.new(0, 0, 0, 72) }, 0.1)
        for _, d in ipairs(self.Body:GetDescendants()) do
            if d:IsA("GuiObject") then
                pcall(function() Util.Tween(d, { BackgroundTransparency = math.min(1, d.BackgroundTransparency + 0.3) }, 0.12) end)
            end
        end
        self.Body.Visible = false
        Util.Tween(self.Main, { Size = UDim2.new(self.Main.Size.X.Scale, self.Main.Size.X.Offset, 0, 64) })
    else
        Util.Tween(self.Main, { Size = self._savedSize or UDim2.new(0, 720, 0, 470) })
        task.delay(0.1, function() if not self._minimized then self.Body.Visible = true end end)
    end
end

function Window:Close()
    self._overlay:CloseAll()
    Util.Tween(self.Main, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.25)
    task.delay(0.28, function() self:Destroy() end)
end

function Window:Destroy()
    for _, tab in ipairs(self._tabs) do tab:Destroy() end
    table.clear(self._tabs)
    self._cleaner:Clean()
end

--==========================================================================--
--                              LIBRARY                                     --
--==========================================================================--

local Library = {}
Library.__index = Library

function Library.new()
    local self = setmetatable({}, Library)
    self._theme = ThemeManager.new(DEFAULT_THEME)
    self._windows = {}
    return self
end

function Library:CreateWindow(opts)
    local window = Window.new(self, opts)
    table.insert(self._windows, window)
    return window
end

function Library:SetTheme(colors)
    self._theme:Set(colors)
end

function Library:GetTheme()
    return self._theme:Get()
end

-- Accent color helpers (RGB / HSV / HEX). -----------------------------------
function Library:SetAccentColor(color3)
    self._theme:Set({ Accent = color3 })
end
function Library:SetAccentColorHSV(h, s, v)
    self._theme:Set({ Accent = Color3.fromHSV(h, s, v) })
end
function Library:SetAccentColorHex(hex)
    self._theme:Set({ Accent = ColorUtil.FromHex(hex) })
end

function Library:SetAnimationDuration(duration)
    CONFIG.AnimationDuration = duration
end

function Library:Destroy()
    for _, window in ipairs(self._windows) do window:Destroy() end
    table.clear(self._windows)
end

-- Expose submodules & helpers for advanced users.
Library.Signal = Signal
Library.Cleaner = Cleaner
Library.Color = ColorUtil
Library.Spacing = Spacing

--==========================================================================--
--                          MODULE RETURN                                   --
--==========================================================================--
-- Returns a ready Library instance. Works as a ModuleScript (require) and via
-- loadstring: local Library = loadstring(game:HttpGet(RAW_URL))()

return Library.new()
