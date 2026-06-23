
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    AnimationDuration = 0.22,
    AnimationStyle    = Enum.EasingStyle.Quint,
    AnimationDirection= Enum.EasingDirection.Out,
    Font              = Enum.Font.GothamMedium,
    FontBold          = Enum.Font.GothamBold,
    FontRegular       = Enum.Font.Gotham,
    Debug             = false,
}

local Spacing = {
    [1] = 4,  [2] = 8,  [3] = 12, [4] = 16,
    [6] = 24, [8] = 32, [10] = 40, [12] = 48, [16] = 64,
}

local Z = {
    Window   = 1,
    Control  = 10,
    Trigger  = 20,
    Overlay  = 1000,
}

local Logger = {}

local function _stamp()
    return string.format("%.2f", os.clock())
end

function Logger.Log(category, ...)
    if not CONFIG.Debug then return end
    local parts = {}
    for _, v in ipairs({ ... }) do
        parts[#parts + 1] = tostring(v)
    end
    print(string.format("[Nature %s] [%s] %s", _stamp(), category, table.concat(parts, " ")))
end

function Logger.Init(...)    Logger.Log("INIT", ...)    end
function Logger.Theme(...)   Logger.Log("THEME", ...)   end
function Logger.Toggle(...)  Logger.Log("TOGGLE", ...)  end
function Logger.Exec(...)    Logger.Log("EXEC", ...)    end
function Logger.UI(...)      Logger.Log("UI", ...)      end

local THEMES = {}

THEMES.Nature = {
    Name           = "Nature",
    BackdropTop    = Color3.fromRGB(126, 206, 146),
    BackdropBottom = Color3.fromRGB(220, 244, 228),
    BackdropT      = 0.0,
    Primary        = Color3.fromRGB(249, 253, 250),
    PrimaryLight   = Color3.fromRGB(255, 255, 255),
    Secondary      = Color3.fromRGB(244, 250, 246),
    SecondaryLight = Color3.fromRGB(236, 246, 240),
    ControlHover   = Color3.fromRGB(228, 241, 233),
    ControlPressed = Color3.fromRGB(218, 234, 225),
    PanelTop       = Color3.fromRGB(248, 253, 249),
    PanelBottom    = Color3.fromRGB(240, 248, 243),
    PanelT         = 0.03,
    PanelTopT      = 0.00,
    PanelBottomT   = 0.02,
    ControlT       = 0.00,
    ControlTopT    = 0.00,
    ControlBottomT = 0.04,
    Accent         = Color3.fromRGB(74, 176, 98),
    AccentTop      = Color3.fromRGB(74, 176, 98),
    AccentBottom   = Color3.fromRGB(74, 176, 98),
    AccentDim      = Color3.fromRGB(134, 206, 151),
    AccentText     = Color3.fromRGB(255, 255, 255),
    Text           = Color3.fromRGB(31, 49, 39),
    TextDim        = Color3.fromRGB(78, 102, 88),
    TextMuted      = Color3.fromRGB(128, 154, 140),
    Border         = Color3.fromRGB(197, 219, 206),
    BorderGlow     = Color3.fromRGB(255, 255, 255),
    ToggleOff      = Color3.fromRGB(208, 222, 214),
    ToggleThumb    = Color3.fromRGB(255, 255, 255),
}

THEMES.Apple = {
    Name           = "Apple",
    BackdropTop    = Color3.fromRGB(228, 230, 236),
    BackdropBottom = Color3.fromRGB(244, 245, 248),
    BackdropT      = 0.02,
    Primary        = Color3.fromRGB(250, 251, 253),
    PrimaryLight   = Color3.fromRGB(255, 255, 255),
    Secondary      = Color3.fromRGB(246, 247, 250),
    SecondaryLight = Color3.fromRGB(236, 238, 243),
    ControlHover   = Color3.fromRGB(228, 230, 236),
    ControlPressed = Color3.fromRGB(218, 221, 229),
    PanelTop       = Color3.fromRGB(251, 252, 254),
    PanelBottom    = Color3.fromRGB(244, 246, 249),
    PanelT         = 0.03,
    PanelTopT      = 0.00,
    PanelBottomT   = 0.02,
    ControlT       = 0.00,
    ControlTopT    = 0.00,
    ControlBottomT = 0.04,
    Accent         = Color3.fromRGB(10, 132, 255),
    AccentTop      = Color3.fromRGB(10, 132, 255),
    AccentBottom   = Color3.fromRGB(10, 132, 255),
    AccentDim      = Color3.fromRGB(94, 174, 255),
    AccentText     = Color3.fromRGB(255, 255, 255),
    Text           = Color3.fromRGB(28, 28, 30),
    TextDim        = Color3.fromRGB(86, 88, 92),
    TextMuted      = Color3.fromRGB(140, 142, 148),
    Border         = Color3.fromRGB(209, 212, 219),
    BorderGlow     = Color3.fromRGB(255, 255, 255),
    ToggleOff      = Color3.fromRGB(214, 217, 224),
    ToggleThumb    = Color3.fromRGB(255, 255, 255),
}

local THEME_ORDER = { "Nature", "Apple" }

local DEFAULT_THEME = THEMES.Nature

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

function Util.PointInGui(point, gui)
    if not point or not gui or typeof(gui) ~= "Instance" or not gui.Parent then
        return false
    end
    if not gui:IsA("GuiObject") then
        return false
    end
    local pos = gui.AbsolutePosition
    local size = gui.AbsoluteSize
    return point.X >= pos.X and point.X <= pos.X + size.X
       and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
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

function Util.GlassGradient(parent, colorTop, colorBottom, transpTop, transpBottom, rotation)
    return Util.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, colorTop),
            ColorSequenceKeypoint.new(1, colorBottom),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, transpTop or 0),
            NumberSequenceKeypoint.new(1, transpBottom or 0),
        }),
        Rotation = rotation or 90,
        Parent = parent,
    })
end

function Util.GlassStroke(parent, borderColor, glowColor, thickness)
    local stroke = Util.Create("UIStroke", {
        Color = borderColor or DEFAULT_THEME.Border,
        Thickness = thickness or 1,
        Transparency = 0.22,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
    return stroke
end
function Util.InnerHighlight(parent)
    local hl = Util.Create("Frame", {
        Name = "InnerHighlight",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.86,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1.5),
        ZIndex = (parent.ZIndex or 1) + 1,
        Parent = parent,
    })
    Util.Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.25),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = hl,
    })
    return hl
end

function Util.ChipGlass(frame, themeMgr)
    local t = themeMgr:Get()
    local grad = Util.GlassGradient(frame, t.SecondaryLight, t.Secondary,
        t.ControlTopT or 0, t.ControlBottomT or 0.04, 90)
    local stroke = Util.GlassStroke(frame, t.Border, t.BorderGlow, 1)
    themeMgr:Register(grad, function(g, th)
        g.Color = ColorSequence.new(th.SecondaryLight, th.Secondary)
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, th.ControlTopT or 0),
            NumberSequenceKeypoint.new(1, th.ControlBottomT or 0.04),
        })
    end)
    themeMgr:Register(stroke, function(st, th)
        st.Color = th.Border
        st.Transparency = 0.22
    end)
    return grad, stroke
end

function Util.ChipSheen(frame, themeMgr)
    local t = themeMgr:Get()
    local grad = Util.Create("UIGradient", {
        Color = ColorSequence.new(t.SecondaryLight, t.Secondary),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.08),
            NumberSequenceKeypoint.new(1, 0.12),
        }),
        Rotation = 90, Parent = frame,
    })
    local stroke = Util.GlassStroke(frame, t.Border, t.BorderGlow, 1)
    themeMgr:Register(grad, function(g, th)
        g.Color = ColorSequence.new(th.SecondaryLight, th.Secondary)
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, th.ControlTopT or 0.02),
            NumberSequenceKeypoint.new(1, th.ControlBottomT or 0.06),
        })
    end)
    themeMgr:Register(stroke, function(st, th)
        st.Color = th.Border
        st.Transparency = 0.22
    end)
    return grad, stroke
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

local Icons = {}

Icons.Library = {
    wrench    = "rbxassetid://10747383470",
    gear      = "rbxassetid://10734950309",
    settings  = "rbxassetid://10734950309",
    cog       = "rbxassetid://10709810948",
    bug       = "rbxassetid://10709782845",
    blocks    = "rbxassetid://10709782582",
    grid      = "rbxassetid://10723404936",
    leaf      = "rbxassetid://10723425539",
    sprout    = "rbxassetid://10734965572",
    home      = "rbxassetid://10723407389",
    star      = "rbxassetid://10734966248",
    chevron   = "rbxassetid://10709790948",
    chevronUp = "rbxassetid://10709791523",
    close     = "rbxassetid://10747384394",
    minimize  = "rbxassetid://10734896206",
    copy      = "rbxassetid://10709812159",
    check     = "rbxassetid://10709790644",
    rocket    = "rbxassetid://10734934585",
    zap       = "rbxassetid://10709790202",
    target    = "rbxassetid://10734977012",
    gamepad   = "rbxassetid://10723395215",
    palette   = "rbxassetid://10734910430",
    shield    = "rbxassetid://10734951847",
}

function Icons.Resolve(nameOrId)
    if type(nameOrId) ~= "string" then
        return Icons.Library.blocks
    end

    if nameOrId:match("rbxassetid://") or nameOrId:match("rbxasset://")
    or nameOrId:match("^%d+$") then

        if nameOrId:match("^%d+$") then
            return "rbxassetid://" .. nameOrId
        end
        return nameOrId
    end

    return Icons.Library[nameOrId] or Icons.Library.blocks
end

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

local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new(theme)
    local self = setmetatable({}, ThemeManager)
    self.Theme = table.clone(theme or DEFAULT_THEME)
    self.Current = self.Theme.Name or "Nature"
    self._registry = {}
    self.Changed = Signal.new()
    return self
end

function ThemeManager:Register(inst, applier)
    table.insert(self._registry, { inst = inst, fn = applier })

    local ok, err = pcall(applier, inst, self.Theme)
    if not ok then
        Logger.Theme("applier error on register:", tostring(err))
    end
end

function ThemeManager:Get()
    return self.Theme
end

function ThemeManager:GetCurrentName()
    return self.Current
end

function ThemeManager:_reapply()
    for i = #self._registry, 1, -1 do
        local entry = self._registry[i]
        local inst = entry.inst
        local alive
        if typeof(inst) == "Instance" then

            alive = inst.Parent ~= nil
        else
            alive = true
        end
        if alive then
            local ok, err = pcall(entry.fn, inst, self.Theme)
            if not ok then
                Logger.Theme("applier error during re-skin:", tostring(err))
            end
        else
            table.remove(self._registry, i)
        end
    end
    self.Changed:Fire(self.Theme)
end

function ThemeManager:SetTheme(name)
    local theme = THEMES[name]
    if not theme then
        Logger.Theme("Unknown theme:", tostring(name), "- keeping", self.Current)
        return false
    end
    self.Theme = table.clone(theme)
    self.Current = name
    Logger.Theme("Switched to", name)
    self:_reapply()
    return true
end

function ThemeManager:NextTheme()
    local idx = 1
    for i, n in ipairs(THEME_ORDER) do
        if n == self.Current then idx = i break end
    end
    local nextName = THEME_ORDER[(idx % #THEME_ORDER) + 1]
    return self:SetTheme(nextName)
end

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

local OverlayManager = {}
OverlayManager.__index = OverlayManager

function OverlayManager.new(gui)
    local self = setmetatable({}, OverlayManager)
    self.Container = Util.Create("Frame", {
        Name = "OverlayContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
        ZIndex = Z.Overlay,
        Parent = gui,
    })
    self._active = nil
    self._activeOwner = nil
    return self
end

function OverlayManager:BindTo(root)
    if not root or typeof(root) ~= "Instance" or not root:IsA("GuiObject") then
        return
    end
    self.Root = root
    self.Container.Parent = root
    self.Container.Position = UDim2.new(0, 0, 0, 0)
    self.Container.Size = UDim2.new(1, 0, 1, 0)
    self.Container.ClipsDescendants = true
    self.Container.ZIndex = Z.Overlay
end

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

function OverlayManager:IsPointInsideActive(point)
    local owner = self._activeOwner
    if not owner then return false end

    if type(owner._isPointInsideOverlay) == "function" then
        local ok, inside = pcall(function()
            return owner:_isPointInsideOverlay(point)
        end)
        if ok and inside then return true end
    end

    if owner.Instance and Util.PointInGui(point, owner.Instance) then
        return true
    end

    return false
end

function OverlayManager:HandleOutsideInput(input)
    if not self._active then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
    and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    local point = input.Position
    if not self:IsPointInsideActive(point) then
        self:CloseAll()
    end
end

function OverlayManager:Destroy()
    self:CloseAll()
    if self.Container then self.Container:Destroy() end
end

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

local Toggle = setmetatable({}, { __index = BaseComponent })
Toggle.__index = Toggle

function Toggle.new(section, text, onFn, offFn, default)
    local self = BaseComponent.new(section)
    setmetatable(self, Toggle)
    self._onFn, self._offFn = onFn, offFn
    self._value = default or false
    self._text = text

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
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, 52, 0, 26),
        BackgroundColor3 = self._value and theme.Accent or theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = row,
    })
    Util.Corner(13, track)
    local trackStroke = Util.Stroke(track, theme.Border, 1, 0.25)

    self._theme:Register(track, function(tr, t)
        tr.BackgroundColor3 = self._value and t.Accent or t.ToggleOff
    end)
    self._theme:Register(trackStroke, function(st, t)
        st.Color = self._value and t.Accent or t.Border
        st.Transparency = self._value and 0.55 or 0.25
    end)

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
    Util.Stroke(thumb, Color3.fromRGB(0, 0, 0), 1, 0.92)

    local btn = Util.Create("TextButton", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", Parent = track,
    })
    self._track, self._thumb, self._trackStroke = track, thumb, trackStroke

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
    local strokeColor = self._value and theme.Accent or theme.Border
    local strokeTransparency = self._value and 0.55 or 0.25
    if animate then
        Util.Tween(self._track, { BackgroundColor3 = trackColor })
        Util.Tween(self._thumb, { Position = thumbPos })
        if self._trackStroke then Util.Tween(self._trackStroke, { Color = strokeColor, Transparency = strokeTransparency }) end
    else
        self._track.BackgroundColor3 = trackColor
        self._thumb.Position = thumbPos
        if self._trackStroke then
            self._trackStroke.Color = strokeColor
            self._trackStroke.Transparency = strokeTransparency
        end
    end
end

function Toggle:Set(value)
    value = value and true or false
    if value == self._value then self:_render(true) return end
    self._value = value
    self:_render(true)
    Logger.Toggle(self._text or "Toggle", "->", value and "ON" or "OFF")
    if value then
        if self._onFn then task.spawn(self._onFn) end
    else
        if self._offFn then task.spawn(self._offFn) end
    end
    self.Changed:Fire(value)
end

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
        BackgroundTransparency = theme.ControlT,
        AutoButtonColor = false, BorderSizePixel = 0,
        Font = CONFIG.Font, Text = text, TextSize = 17,
        TextColor3 = theme.Text, Parent = row,
    })
    self._button = btn
    self._text = text
    Util.Corner(Spacing[3], btn)
    Util.ChipSheen(btn, self._theme)
    self._theme:Register(btn, function(b, t)
        b.TextColor3 = t.Text
        b.BackgroundColor3 = t.SecondaryLight
        b.BackgroundTransparency = t.ControlT
    end)

    local rippleHolder = Util.Create("Frame", {
        BackgroundTransparency = 1, ClipsDescendants = true,
        Size = UDim2.new(1, 0, 1, 0), Parent = btn,
    })
    Util.Corner(Spacing[3], rippleHolder)

    self._cleaner:Add(btn.MouseEnter:Connect(function()
        local t = self._theme:Get()
        Util.Tween(btn, { BackgroundColor3 = t.ControlHover or t.SecondaryLight, BackgroundTransparency = 0, TextColor3 = t.Text }, 0.15)
    end))
    self._cleaner:Add(btn.MouseLeave:Connect(function()
        local t = self._theme:Get()
        Util.Tween(btn, { BackgroundColor3 = t.SecondaryLight, BackgroundTransparency = t.ControlT, TextColor3 = t.Text }, 0.15)
    end))
    self._cleaner:Add(btn.MouseButton1Down:Connect(function(x, y)
        self:_ripple(rippleHolder, x, y)
        local t = self._theme:Get()
        Util.Tween(btn, { Size = UDim2.new(1, -4, 1, -4), BackgroundColor3 = t.ControlPressed or t.ControlHover or t.SecondaryLight }, 0.08)
    end))
    self._cleaner:Add(btn.MouseButton1Up:Connect(function()
        local t = self._theme:Get()
        Util.Tween(btn, { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = t.ControlHover or t.SecondaryLight }, 0.12)
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

local Dropdown = setmetatable({}, { __index = BaseComponent })
Dropdown.__index = Dropdown

function Dropdown.new(section, text, options, callback, default)
    local self = BaseComponent.new(section)
    setmetatable(self, Dropdown)
    self._options  = table.clone(options or {})
    self._callback = callback
    self._open     = false
    self._multiple = false
    self._value    = default or self._options[1]

    local theme = self._theme:Get()
    local row = self:_makeRow(40)
    self.Instance = row
    self._baseHeight = 40
    self._menuGap = 12

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -Spacing[3], 1, 0),
        Font = CONFIG.Font, Text = text, TextSize = 18,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local trigger = Util.Create("TextButton", {
        Name = "Trigger",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0.46, -2, 0, 38),
        BackgroundColor3 = theme.SecondaryLight,
        BackgroundTransparency = theme.ControlT,
        AutoButtonColor = false, BorderSizePixel = 0,
        Text = "", ZIndex = Z.Trigger, Parent = row,
    })
    Util.Corner(Spacing[3], trigger)
    Util.ChipGlass(trigger, self._theme)
    self._theme:Register(trigger, function(b, t)
        b.BackgroundColor3 = t.SecondaryLight
        b.BackgroundTransparency = t.ControlT
    end)
    self._trigger = trigger

    local selected = Util.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Font = CONFIG.Font, Text = self:_formatValue(self._value), TextSize = 17,
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
    self._theme:Register(self._arrow, function(a, t) a.ImageColor3 = t.Text end)

    self._cleaner:Add(trigger.MouseEnter:Connect(function()
        local t = self._theme:Get()
        Util.Tween(trigger, { BackgroundColor3 = t.ControlHover or t.SecondaryLight, BackgroundTransparency = 0 }, 0.14)
    end))
    self._cleaner:Add(trigger.MouseLeave:Connect(function()
        local t = self._theme:Get()
        Util.Tween(trigger, { BackgroundColor3 = t.SecondaryLight, BackgroundTransparency = t.ControlT }, 0.14)
    end))
    self._cleaner:Add(trigger.MouseButton1Down:Connect(function()
        local t = self._theme:Get()
        Util.Tween(trigger, { Size = UDim2.new(0.46, -4, 0, 36), BackgroundColor3 = t.ControlPressed or t.ControlHover or t.SecondaryLight }, 0.08)
    end))
    self._cleaner:Add(trigger.MouseButton1Up:Connect(function()
        Util.Tween(trigger, { Size = UDim2.new(0.46, -2, 0, 38) }, 0.12)
    end))
    self._cleaner:Add(trigger.MouseButton1Click:Connect(function() self:_toggleOpen() end))

    self._cleaner:Add(trigger:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if self._open then self:_positionMenu() end
    end))
    self._cleaner:Add(trigger:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if self._open then self:_positionMenu() end
    end))
    return self
end

function Dropdown:_formatValue(value)
    if type(value) == "table" then
        if #value == 0 then
            return "None"
        elseif #value == 1 then
            return tostring(value[1])
        else
            return "Various"
        end
    end
    return tostring(value or "Select...")
end

function Dropdown:_buildMenu()
    if self._menu then self._menu:Destroy() end
    local theme = self._theme:Get()

    local menu = Util.Create("Frame", {
        Name = "DropdownMenu",
        BackgroundColor3 = theme.Primary,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Size = UDim2.new(0, self._trigger.AbsoluteSize.X, 0, 0),
        ClipsDescendants = true,
        ZIndex = Z.Overlay + 1,
        Parent = self._overlay.Container,
    })
    Util.Corner(Spacing[3], menu)
    local menuStroke = Util.Stroke(menu, theme.Border, 1, 0.12)
    self._theme:Register(menu, function(m, t)
        m.BackgroundColor3 = t.Primary
        m.BackgroundTransparency = 0
    end)
    self._theme:Register(menuStroke, function(st, t)
        st.Color = t.Border
        st.Transparency = 0.12
    end)

    local scroll = Util.Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(170, 170, 175),
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = Z.Overlay + 2, Parent = menu,
    })
    local layout = LayoutManager.VerticalList(scroll, Spacing[1] / 2, Enum.HorizontalAlignment.Center)
    Util.Padding(scroll, Spacing[1])
    LayoutManager.BindScrollCanvas(scroll, layout)

    for i, opt in ipairs(self._options) do
        local isSel = self._multiple and type(self._value) == "table" and table.find(self._value, opt) ~= nil or (opt == self._value)
        local optBtn = Util.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = isSel and theme.Accent or theme.SecondaryLight,
            BackgroundTransparency = 0,
            AutoButtonColor = false, BorderSizePixel = 0,
            Font = CONFIG.Font, Text = tostring(opt), TextSize = 16,
            TextColor3 = isSel and theme.AccentText or theme.Text, LayoutOrder = i,
            ZIndex = Z.Overlay + 3, Parent = scroll,
        })
        Util.Corner(Spacing[2], optBtn)
        self._theme:Register(optBtn, function(b, t)
            local selectedNow = self._multiple and type(self._value) == "table" and table.find(self._value, opt) ~= nil or (opt == self._value)
            b.BackgroundColor3 = selectedNow and t.Accent or t.SecondaryLight
            b.BackgroundTransparency = 0
            b.TextColor3 = selectedNow and t.AccentText or t.Text
        end)
        optBtn.MouseEnter:Connect(function()
            local selectedNow = self._multiple and type(self._value) == "table" and table.find(self._value, opt) ~= nil or (opt == self._value)
            if not selectedNow then
                local t = self._theme:Get()
                Util.Tween(optBtn, { BackgroundColor3 = t.ControlHover or t.SecondaryLight, BackgroundTransparency = 0 }, 0.1)
            end
        end)
        optBtn.MouseLeave:Connect(function()
            local selectedNow = self._multiple and type(self._value) == "table" and table.find(self._value, opt) ~= nil or (opt == self._value)
            if not selectedNow then
                local t = self._theme:Get()
                Util.Tween(optBtn, { BackgroundColor3 = t.SecondaryLight, BackgroundTransparency = 0 }, 0.1)
            end
        end)
        optBtn.MouseButton1Click:Connect(function()
            self._closingFromOption = true
            self:Set(opt)
            self._closingFromOption = false
            self:_toggleOpen(false)
        end)
    end
    self._menu = menu
    self._menuScroll = scroll
end

function Dropdown:_targetMenuHeight()
    local baseHeight = math.min(#self._options * 32 + Spacing[2], 200)
    if not self._trigger or not self._overlay or not self._overlay.Container then
        return baseHeight
    end

    local triggerPos = self._trigger.AbsolutePosition
    local triggerSize = self._trigger.AbsoluteSize
    local overlayPos = self._overlay.Container.AbsolutePosition
    local overlaySize = self._overlay.Container.AbsoluteSize
    local gap = self._menuGap or 12
    local bottomPad = 8
    local y = triggerPos.Y - overlayPos.Y + triggerSize.Y + gap
    local availableBelow = overlaySize.Y - y - bottomPad

    return math.max(0, math.min(baseHeight, availableBelow))
end

function Dropdown:_positionMenu()
    if not self._menu or not self._trigger or not self._overlay or not self._overlay.Container then return end

    -- Keep the dropdown as a true overlay, but anchor it strictly below the
    -- trigger. The overlay is now a clipped descendant of the main window, so
    -- the menu cannot draw outside the panel while scrolling or resizing.
    local triggerPos = self._trigger.AbsolutePosition
    local triggerSize = self._trigger.AbsoluteSize
    local overlayPos = self._overlay.Container.AbsolutePosition
    local overlaySize = self._overlay.Container.AbsoluteSize
    local gap = self._menuGap or 12
    local sidePad = 8

    local x = triggerPos.X - overlayPos.X
    local y = triggerPos.Y - overlayPos.Y + triggerSize.Y + gap
    local width = math.min(triggerSize.X, math.max(0, overlaySize.X - sidePad * 2))
    x = math.clamp(x, sidePad, math.max(sidePad, overlaySize.X - width - sidePad))

    local height = self._menu.Size.Y.Offset
    local maxHeight = self:_targetMenuHeight()
    if height > maxHeight then
        height = maxHeight
    end

    self._menu.AnchorPoint = Vector2.new(0, 0)
    self._menu.Position = UDim2.new(0, x, 0, y)
    self._menu.Size = UDim2.new(0, width, 0, height)
end

function Dropdown:_isPointInsideOverlay(point)
    return Util.PointInGui(point, self._trigger)
        or Util.PointInGui(point, self._menu)
end

function Dropdown:_toggleOpen(force)
    if force ~= nil then self._open = force else self._open = not self._open end

    if self._open then
        self:_buildMenu()
        self:_positionMenu()
        task.defer(function()
            if self._open and self._menu then
                self:_positionMenu()
            end
        end)
        if self._positionConn then
            self._positionConn:Disconnect()
            self._positionConn = nil
        end
        self._positionConn = RunService.RenderStepped:Connect(function()
            if self._open and self._menu then
                self:_positionMenu()
            end
        end)
        local targetH = self:_targetMenuHeight()
        Util.Tween(self._menu, { Size = UDim2.new(0, self._trigger.AbsoluteSize.X, 0, targetH) }, 0.18)
        Util.Tween(self._arrow, { Rotation = 180 })

        self._overlay:Open(self, function() self:_toggleOpen(false) end)
    else
        Util.Tween(self._arrow, { Rotation = 0 })
        if self._positionConn then
            self._positionConn:Disconnect()
            self._positionConn = nil
        end
        self.Instance.Size = UDim2.new(1, 0, 0, self._baseHeight)
        if self._menu then
            local menu = self._menu
            self._menu = nil
            Util.Tween(menu, { Size = UDim2.new(0, menu.AbsoluteSize.X, 0, 0) }, 0.14)
            task.delay(CONFIG.AnimationDuration, function()
                if menu then menu:Destroy() end
            end)
        end
        self._overlay:Close(self)
    end
end

function Dropdown:Set(value)
    self._value = value
    self._selectedLabel.Text = self:_formatValue(value)
    if self._open and not self._closingFromOption then
        self:_buildMenu()
        self:_positionMenu()
        local targetH = self:_targetMenuHeight()
        self._menu.Size = UDim2.new(0, self._menu.AbsoluteSize.X, 0, targetH)
        self:_positionMenu()
        self.Instance.Size = UDim2.new(1, 0, 0, self._baseHeight)
    end
    if self._callback then task.spawn(self._callback, value) end
    self.Changed:Fire(value)
end

function Dropdown:Refresh(newValues)
    self._options = table.clone(newValues or {})
    if self._multiple then
        local kept = {}
        if type(self._value) == "table" then
            for _, value in ipairs(self._value) do
                if table.find(self._options, value) then
                    table.insert(kept, value)
                end
            end
        end
        self._value = kept
    elseif not table.find(self._options, self._value) then
        self._value = self._options[1]
    end
    self._selectedLabel.Text = self:_formatValue(self._value)
    if self._open then
        self:_buildMenu()
        self:_positionMenu()
        local targetH = self:_targetMenuHeight()
        self._menu.Size = UDim2.new(0, self._menu.AbsoluteSize.X, 0, targetH)
        self:_positionMenu()
        self.Instance.Size = UDim2.new(1, 0, 0, self._baseHeight)
    end
end

function Dropdown:Destroy()
    if self._positionConn then
        self._positionConn:Disconnect()
        self._positionConn = nil
    end
    if self._menu then self._menu:Destroy() end
    self._overlay:Close(self)
    BaseComponent.Destroy(self)
end

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
        BackgroundTransparency = 1, Size = UDim2.new(1, -86, 0, 26),
        Font = CONFIG.Font, Text = text, TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local valueLabel = Util.Create("TextBox", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -4, 0, 0),
        Size = UDim2.new(0, 74, 0, 28),
        BackgroundColor3 = theme.SecondaryLight,
        BackgroundTransparency = theme.ControlT,
        BorderSizePixel = 0,
        Font = CONFIG.FontRegular, Text = tostring(self._value), TextSize = 15,
        TextColor3 = Color3.fromRGB(18, 26, 21),
        TextStrokeTransparency = 1,
        PlaceholderColor3 = theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        Parent = row,
    })
    Util.Corner(Spacing[2], valueLabel)
    local valueStroke = Util.Stroke(valueLabel, theme.Border, 1, 0.32)
    self._valueLabel = valueLabel
    self._theme:Register(valueLabel, function(b, t)
        b.BackgroundColor3 = t.SecondaryLight
        b.BackgroundTransparency = t.ControlT
        b.TextColor3 = Color3.fromRGB(18, 26, 21)
        b.TextStrokeTransparency = 1
        b.PlaceholderColor3 = t.TextMuted
    end)
    self._theme:Register(valueStroke, function(st, t)
        st.Color = t.Border
        st.Transparency = 0.32
    end)
    self._cleaner:Add(valueLabel.Focused:Connect(function()
        Util.Tween(valueStroke, { Transparency = 0.08 }, 0.12)
    end))
    self._cleaner:Add(valueLabel.FocusLost:Connect(function()
        local typed = tonumber(valueLabel.Text)
        if typed then
            self:Set(typed)
        else
            valueLabel.Text = tostring(self._value)
        end
        Util.Tween(valueStroke, { Transparency = 0.32 }, 0.12)
    end))

    local track = Util.Create("Frame", {
        AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, -10, 0, 8), BackgroundColor3 = theme.ToggleOff,
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
    local rel = self._max == self._min and 0 or ((self._value - self._min) / (self._max - self._min))
    rel = math.clamp(rel, 0, 1)
    Util.Tween(self._fill, { Size = UDim2.new(rel, 0, 1, 0) }, 0.08)
    Util.Tween(self._knob, { Position = UDim2.new(rel, 0, 0.5, 0) }, 0.08)
    self._valueLabel.Text = tostring(self._value)
end

function Slider:Set(value)
    value = tonumber(value) or self._value
    value = math.floor(math.clamp(value, self._min, self._max) + 0.5)
    if value == self._value then
        self._valueLabel.Text = tostring(self._value)
        return
    end
    self._value = value
    self:_render()
    if self._callback then task.spawn(self._callback, value) end
    self.Changed:Fire(value)
end

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
    self._baseHeight = 40
    self._menuGap = 12

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(0.5, -Spacing[3], 1, 0),
        Font = CONFIG.Font, Text = text, TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local boxFrame = Util.Create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0.46, -2, 0, 36), BackgroundColor3 = theme.SecondaryLight,
        BackgroundTransparency = theme.ControlT,
        BorderSizePixel = 0, Parent = row,
    })
    Util.Corner(Spacing[3], boxFrame)
    Util.ChipGlass(boxFrame, self._theme)

    local focusRing = Util.Create("UIStroke", {
        Color = theme.Accent, Thickness = 1.6, Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = boxFrame,
    })
    self._theme:Register(focusRing, function(fr, t) fr.Color = t.Accent end)
    self._theme:Register(boxFrame, function(b, t)
        b.BackgroundColor3 = t.SecondaryLight
        b.BackgroundTransparency = t.ControlT
    end)

    local input = Util.Create("TextBox", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0), Font = CONFIG.FontRegular, Text = "",
        PlaceholderText = placeholder or "Enter text...",
        PlaceholderColor3 = theme.TextMuted, TextSize = 16, TextColor3 = Color3.fromRGB(18, 26, 21),
        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = boxFrame,
    })
    self._input = input
    self._theme:Register(input, function(b, t)
        b.Font = CONFIG.FontRegular
        b.TextColor3 = Color3.fromRGB(18, 26, 21)
        b.TextStrokeTransparency = 1
        b.PlaceholderColor3 = t.TextMuted
    end)

    self._cleaner:Add(boxFrame.MouseEnter:Connect(function()
        local t = self._theme:Get()
        Util.Tween(boxFrame, { BackgroundColor3 = t.ControlHover or t.SecondaryLight, BackgroundTransparency = 0 }, 0.14)
    end))
    self._cleaner:Add(boxFrame.MouseLeave:Connect(function()
        local t = self._theme:Get()
        if not input:IsFocused() then
            Util.Tween(boxFrame, { BackgroundColor3 = t.SecondaryLight, BackgroundTransparency = t.ControlT }, 0.14)
        end
    end))

    self._cleaner:Add(input.Focused:Connect(function()
        Util.Tween(focusRing, { Transparency = 0 }, 0.15)
    end))
    self._cleaner:Add(input.FocusLost:Connect(function()
        Util.Tween(focusRing, { Transparency = 1 }, 0.15)
        local t = self._theme:Get()
        Util.Tween(boxFrame, { BackgroundColor3 = t.SecondaryLight, BackgroundTransparency = t.ControlT }, 0.14)
        self._value = input.Text
        if self._callback then task.spawn(self._callback, input.Text) end
        self.Changed:Fire(input.Text)
    end))
    return self
end

function Textbox:Set(value)
    self._value = tostring(value)
    self._input.Text = self._value
    if self._callback then task.spawn(self._callback, self._value) end
    self.Changed:Fire(self._value)
end

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
        BackgroundColor3 = theme.SecondaryLight, BackgroundTransparency = theme.ControlT,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0, Parent = row,
    })
    Util.Corner(Spacing[3], container)
    local paraStroke = Util.Stroke(container, theme.Border, 1, 0.22)
    Util.Padding(container, Spacing[3])
    LayoutManager.VerticalList(container, Spacing[1] + 2, Enum.HorizontalAlignment.Left)
    self._theme:Register(container, function(c, t)
        c.BackgroundColor3 = t.SecondaryLight
        c.BackgroundTransparency = t.ControlT
    end)
    self._theme:Register(paraStroke, function(st, t)
        st.Color = t.Border
        st.Transparency = 0.22
    end)

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
    if type(body) == "table" then
        if body.Title and self._title then self._title.Text = tostring(body.Title) end
        if body.Content and self._body then self._body.Text = tostring(body.Content) end
        self.Changed:Fire(body)
        return
    end
    self._body.Text = tostring(body)
    self.Changed:Fire(body)
end

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
    self._baseHeight = 40
    self._menuGap = 12

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(0.6, 0, 1, 0),
        Font = CONFIG.Font, Text = text, TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)

    local keyBtn = Util.Create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.new(0, 110, 0, 34), BackgroundColor3 = theme.SecondaryLight,
        BackgroundTransparency = theme.ControlT,
        AutoButtonColor = false, BorderSizePixel = 0, Font = CONFIG.Font,
        Text = self._value.Name, TextSize = 15, TextColor3 = theme.Text, Parent = row,
    })
    Util.Corner(Spacing[3], keyBtn)
    Util.ChipSheen(keyBtn, self._theme)
    self._keyBtn = keyBtn
    self._theme:Register(keyBtn, function(b, t)
        b.BackgroundColor3 = t.SecondaryLight; b.TextColor3 = t.Text
        b.BackgroundTransparency = t.ControlT
    end)

    self._cleaner:Add(keyBtn.MouseEnter:Connect(function()
        if self._listening then return end
        local t = self._theme:Get()
        Util.Tween(keyBtn, { BackgroundColor3 = t.ControlHover or t.SecondaryLight, BackgroundTransparency = 0 }, 0.14)
    end))
    self._cleaner:Add(keyBtn.MouseLeave:Connect(function()
        if self._listening then return end
        local t = self._theme:Get()
        Util.Tween(keyBtn, { BackgroundColor3 = t.SecondaryLight, BackgroundTransparency = t.ControlT }, 0.14)
    end))
    self._cleaner:Add(keyBtn.MouseButton1Down:Connect(function()
        if self._listening then return end
        local t = self._theme:Get()
        Util.Tween(keyBtn, { Size = UDim2.new(0, 106, 0, 32), BackgroundColor3 = t.ControlPressed or t.ControlHover or t.SecondaryLight }, 0.08)
    end))
    self._cleaner:Add(keyBtn.MouseButton1Up:Connect(function()
        Util.Tween(keyBtn, { Size = UDim2.new(0, 110, 0, 34) }, 0.12)
    end))

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
    if type(keyCode) == "string" then
        keyCode = Enum.KeyCode[keyCode] or Enum.KeyCode.Unknown
    end
    self._value = keyCode
    self._keyBtn.Text = keyCode and keyCode.Name or "Unknown"
    self.Changed:Fire(keyCode)
end

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
    chev.Rotation = 180
    self._chev = chev
    self._theme:Register(chev, function(c, t) c.ImageColor3 = t.Text end)

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

function Section:Destroy()
    for _, comp in ipairs(self._components) do comp:Destroy() end
    table.clear(self._components)
    self._cleaner:Clean()
    if self.Wrapper then self.Wrapper:Destroy() end
end

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
        Name = "Tab_" .. name, Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = theme.Accent, BackgroundTransparency = 1,
        AutoButtonColor = false, BorderSizePixel = 0, Text = "",
        LayoutOrder = window:_nextTabOrder(), Parent = window.TabList,
    })
    Util.Corner(Spacing[3], button)
    self._button = button

    self._theme:Register(button, function(b, t)
        b.BackgroundColor3 = self._active and t.Accent or (t.SecondaryLight or t.Secondary)
        b.BackgroundTransparency = self._active and 0 or 1
    end)

    local iconHolder = Util.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, Spacing[3] + 2, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 2, Parent = button,
    })
    local iconWrap = Icons.Build(iconName or "blocks", iconHolder, theme.Text)
    self._iconImage = iconWrap:FindFirstChild("Image")
    self._theme:Register(iconHolder, function(_, t)
        if self._iconImage then
            self._iconImage.ImageColor3 = self._active and t.AccentText or t.Text
        end
    end)

    local label = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 48, 0, 0),
        Size = UDim2.new(1, -54, 1, 0), Font = CONFIG.Font, Text = name,
        TextSize = 18, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2, Parent = button,
    })
    self._label = label
    self._theme:Register(label, function(l, t)
        l.TextColor3 = self._active and t.AccentText or t.Text
    end)

    local page = Util.Create("ScrollingFrame", {
        Name = "Page_" .. name, Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(170, 170, 175), ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, Parent = window.ContentContainer,
    })
    Util.Padding(page, nil, { Top = Spacing[1], Bottom = Spacing[2], Left = Spacing[1], Right = Spacing[4] })
    self.Content = page
    local contentLayout = LayoutManager.VerticalList(page, Spacing[3] + 2, Enum.HorizontalAlignment.Center)
    LayoutManager.BindScrollCanvas(page, contentLayout)

    self._cleaner:Add(button.MouseButton1Click:Connect(function() window:_selectTab(self) end))
    self._cleaner:Add(button.MouseEnter:Connect(function()
        if not self._active then
            local t = self._theme:Get()
            button.BackgroundColor3 = t.ControlHover or t.SecondaryLight
            Util.Tween(button, { BackgroundTransparency = 0.08 }, 0.12)
        end
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
    local t = self._theme:Get()
    if active then
        self._button.BackgroundColor3 = t.Accent
        Util.Tween(self._button, { BackgroundTransparency = 0 }, 0.18)
        Util.Tween(self._label, { TextColor3 = t.AccentText }, 0.18)
        if self._iconImage then
            Util.Tween(self._iconImage, { ImageColor3 = t.AccentText }, 0.18)
        end
    else
        self._button.BackgroundColor3 = t.SecondaryLight or t.Secondary
        Util.Tween(self._button, { BackgroundTransparency = 1 }, 0.18)
        Util.Tween(self._label, { TextColor3 = t.Text }, 0.18)
        if self._iconImage then
            Util.Tween(self._iconImage, { ImageColor3 = t.Text }, 0.18)
        end
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

local Window = {}
Window.__index = Window

local MIN_W, MIN_H = 540, 360

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

    local gui = Util.Create("ScreenGui", {
        Name = "NatureUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 999,
    })

    -- Remove any older Nature UI instance first. Without this, an old build can
    -- remain underneath/above the new one and make the removed green decorations
    -- look like they are still present.
    local guiParent
    pcall(function() guiParent = Util.GetGuiParent() end)
    local function clearOldFrom(parent)
        if not parent then return end
        for _, child in ipairs(parent:GetChildren()) do
            if child ~= gui and child.Name == "NatureUI" then
                pcall(function() child:Destroy() end)
            end
        end
    end
    clearOldFrom(guiParent)
    pcall(function() clearOldFrom(CoreGui) end)
    pcall(function()
        if LocalPlayer then clearOldFrom(LocalPlayer:FindFirstChildOfClass("PlayerGui")) end
    end)

    if guiParent then
        gui.Parent = guiParent
    else
        pcall(function() gui.Parent = Util.GetGuiParent() end)
    end
    self.Gui = gui
    self._cleaner:Add(gui)

    local scale = Util.Create("UIScale", { Scale = 1, Parent = gui })
    self._scale = scale

    self._overlay = OverlayManager.new(gui)
    self._cleaner:Add(self._overlay)

    -- No outer backdrop / corner accent / green decoration.
    -- The window is only the clean white Rayfield-style panel.
    local backdrop = nil
    self.Backdrop = nil

    local main = Util.Create("Frame", {
        Name = "MainWindow", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 720, 0, 470),
        BackgroundColor3 = theme.PanelTop, BackgroundTransparency = theme.PanelT * 0.35,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = Z.Window + 1, Parent = gui,
    })
    Util.Corner(Spacing[4] + 2, main)

    local mainGrad = Util.GlassGradient(main, theme.PanelTop, theme.PanelBottom, 0.0, 0.14, 90)
    self.Main = main
    self._overlay:BindTo(main)
    self._theme:Register(main, function(m, t)
        m.BackgroundColor3 = t.PanelTop
        m.BackgroundTransparency = t.PanelT * 0.35
    end)
    self._theme:Register(mainGrad, function(g, t)
        g.Color = ColorSequence.new(t.PanelTop, t.PanelBottom)
    end)

    -- No backdrop tracking: removes the green outer/corner marks entirely.

    local header = Util.Create("Frame", {
        Name = "Header", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 64), Parent = main,
    })
    self.Header = header

    local logoHolder = Util.Create("Frame", {
        Name = "LogoSlot", BackgroundTransparency = 1,
        Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, Spacing[6] - 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), Parent = header,
    })
    local logoWrap = Icons.Build(opts.Icon or "leaf", logoHolder, theme.Accent)
    local logoImg = logoWrap:FindFirstChild("Image")
    if logoImg then
        self._theme:Register(logoImg, function(im, t) im.ImageColor3 = t.Accent end)
    end

    local titleHolder = Util.Create("Frame", {
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 60, 0, 0), Parent = header,
    })
    LayoutManager.HorizontalList(titleHolder, Spacing[2], Enum.VerticalAlignment.Center)

    local titleLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0), Font = CONFIG.FontBold,
        Text = "Nature", TextSize = 24, TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 1, Parent = titleHolder,
    })
    self._titleLabel = titleLabel
    self._theme:Register(titleLabel, function(l, t) l.TextColor3 = t.Text end)

    local subtitleLabel = Util.Create("TextLabel", {
        BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0), Font = CONFIG.FontRegular,
        Text = "Premium", TextSize = 24, TextColor3 = theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = 2, Parent = titleHolder,
    })
    self._subtitleLabel = subtitleLabel
    self._theme:Register(subtitleLabel, function(l, t) l.TextColor3 = t.TextDim end)

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
    local closeBtn = makeControl("×", -Spacing[4], Color3.fromRGB(255, 90, 90))
    local minBtn   = makeControl("–", -Spacing[12] + 2, Color3.fromRGB(160, 170, 175))
    self._cleaner:Add(closeBtn.MouseButton1Click:Connect(function() self:Close() end))
    self._cleaner:Add(minBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end))

    local divider = Util.Create("Frame", {
        BackgroundColor3 = theme.Border, BackgroundTransparency = 0.5, BorderSizePixel = 0,
        Size = UDim2.new(1, -Spacing[12] + 4, 0, 1), Position = UDim2.new(0, Spacing[6] - 2, 0, 64), Parent = main,
    })
    self._theme:Register(divider, function(d, t) d.BackgroundColor3 = t.Border end)

    local body = Util.Create("Frame", {
        Name = "Body", BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 72), Size = UDim2.new(1, 0, 1, -84), Parent = main,
    })
    self.Body = body

    local sidebar = Util.Create("Frame", {
        Name = "Sidebar", Position = UDim2.new(0, Spacing[4] + 2, 0, 0),
        Size = UDim2.new(0, 240, 1, 0), BackgroundColor3 = theme.PanelTop,
        BackgroundTransparency = theme.PanelT, BorderSizePixel = 0, Parent = body,
    })
    Util.Corner(Spacing[4] + 4, sidebar)
    local sidebarGrad = Util.GlassGradient(sidebar, theme.PanelTop, theme.PanelBottom,
        theme.PanelTopT, theme.PanelBottomT, 90)
    local sidebarStroke = Util.GlassStroke(sidebar, theme.Border, theme.BorderGlow, 1)
    Util.InnerHighlight(sidebar)
    self.Sidebar = sidebar
    self._theme:Register(sidebar, function(s, t)
        s.BackgroundColor3 = t.PanelTop
        s.BackgroundTransparency = t.PanelT
    end)
    self._theme:Register(sidebarGrad, function(g, t)
        g.Color = ColorSequence.new(t.PanelTop, t.PanelBottom)
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, t.PanelTopT),
            NumberSequenceKeypoint.new(1, t.PanelBottomT),
        })
    end)
    self._theme:Register(sidebarStroke, function(st, t)
        st.Color = t.Border
        st.Transparency = 0.22
    end)

    local tabList = Util.Create("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, -Spacing[4], 1, -Spacing[6]),
        Position = UDim2.new(0, Spacing[2], 0, Spacing[3] + 2), Parent = sidebar,
    })
    LayoutManager.VerticalList(tabList, Spacing[2], Enum.HorizontalAlignment.Center)
    self.TabList = tabList

    local contentPanel = Util.Create("Frame", {
        Name = "ContentPanel", Position = UDim2.new(0, 274, 0, 0),
        Size = UDim2.new(1, -292, 1, 0), BackgroundColor3 = theme.PanelTop,
        BackgroundTransparency = theme.PanelT, BorderSizePixel = 0, Parent = body,
    })
    Util.Corner(Spacing[4] + 4, contentPanel)
    local contentGrad = Util.GlassGradient(contentPanel, theme.PanelTop, theme.PanelBottom,
        theme.PanelTopT, theme.PanelBottomT, 90)
    local contentStroke = Util.GlassStroke(contentPanel, theme.Border, theme.BorderGlow, 1)
    Util.InnerHighlight(contentPanel)
    self._contentPanel = contentPanel
    self._theme:Register(contentPanel, function(c, t)
        c.BackgroundColor3 = t.PanelTop
        c.BackgroundTransparency = t.PanelT
    end)
    self._theme:Register(contentGrad, function(g, t)
        g.Color = ColorSequence.new(t.PanelTop, t.PanelBottom)
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, t.PanelTopT),
            NumberSequenceKeypoint.new(1, t.PanelBottomT),
        })
    end)
    self._theme:Register(contentStroke, function(st, t)
        st.Color = t.Border
        st.Transparency = 0.22
    end)

    local contentContainer = Util.Create("Frame", {
        Name = "ContentContainer", BackgroundTransparency = 1,
        Size = UDim2.new(1, -Spacing[8], 1, -Spacing[6] + 4),
        Position = UDim2.new(0, Spacing[4], 0, Spacing[4]), Parent = contentPanel,
    })
    self.ContentContainer = contentContainer

    self:_setupResize(main)
    self:_setupDragging(header, main)
    self:_setupViewportScaling()

    self._cleaner:Add(UserInputService.InputBegan:Connect(function(input)
        self._overlay:HandleOutsideInput(input)
    end))

    self:_playOpen()
    return self
end

function Window:_playOpen()
    local main = self.Main
    local openScale = Util.Create("UIScale", { Scale = 0.94, Parent = main })
    local baseT = self:_panelTransparency()
    main.BackgroundTransparency = 1
    task.wait()
    Util.Tween(openScale, { Scale = 1 }, 0.34, Enum.EasingStyle.Quint)
    Util.Tween(main, { BackgroundTransparency = baseT }, 0.3)
    task.delay(0.04, function()
        self._theme:_reapply()
    end)
    task.delay(0.4, function()
        if openScale and openScale.Parent then openScale:Destroy() end
    end)
end

function Window:_nextTabOrder()
    self._tabOrder += 1
    return self._tabOrder
end

function Window:_panelTransparency()
    return self._theme:Get().PanelT * 0.35
end

function Window:_setupDragging(handle, target)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local activeInput = nil
    local renderConn = nil
    local inputEndedConn = nil
    local SMOOTH = 0.45

    local function stopRender()
        if renderConn then
            renderConn:Disconnect()
            renderConn = nil
        end
    end

    local function disconnectInputEnd()
        if inputEndedConn then
            inputEndedConn:Disconnect()
            inputEndedConn = nil
        end
    end

    local function pointerPosition()
        if activeInput and activeInput.UserInputType == Enum.UserInputType.Touch then
            return Vector2.new(activeInput.Position.X, activeInput.Position.Y)
        end
        return UserInputService:GetMouseLocation()
    end

    local function desiredPosition()
        if not dragStart or not startPos then return target.Position end
        local current = pointerPosition()
        local delta = current - dragStart
        return UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    local function finishDrag()
        if not dragging then return end
        dragging = false
        local finalPos = desiredPosition()
        activeInput = nil
        disconnectInputEnd()
        stopRender()

        Util.Tween(target, {
            Position = finalPos,
            BackgroundTransparency = self:_panelTransparency(),
        }, 0.18, Enum.EasingStyle.Quint)

    end

    self._cleaner:Add(handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        activeInput = input
        dragStart = pointerPosition()
        startPos = target.Position

        Util.Tween(target, { BackgroundTransparency = self:_panelTransparency() * 0.6 }, 0.12)

        disconnectInputEnd()
        inputEndedConn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                finishDrag()
            end
        end)

        stopRender()
        renderConn = RunService.RenderStepped:Connect(function()
            if not dragging then return end
            local wanted = desiredPosition()
            local current = target.Position
            local nx = current.X.Offset + (wanted.X.Offset - current.X.Offset) * SMOOTH
            local ny = current.Y.Offset + (wanted.Y.Offset - current.Y.Offset) * SMOOTH
            target.Position = UDim2.new(wanted.X.Scale, nx, wanted.Y.Scale, ny)
        end)
    end))

    self._cleaner:Add(UserInputService.InputChanged:Connect(function(input)
        if dragging and input == activeInput then
            activeInput = input
        end
    end))

    self._cleaner:Add(UserInputService.InputEnded:Connect(function(input)
        if dragging and (input == activeInput
        or input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
            finishDrag()
        end
    end))

    self._cleaner:Add(function()
        disconnectInputEnd()
        stopRender()
    end)
end

function Window:_setupResize(main)
    local handle = Util.Create("TextButton", {
        Name = "ResizeHandle", AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -4, 1, -4), Size = UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        ZIndex = Z.Control, Parent = main,
    })
    self._resizeHandle = handle

    local resizing, startPos, startSize = false, nil, nil
    self._cleaner:Add(handle.InputBegan:Connect(function(input)
        if self._minimized then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing, startPos, startSize = true, input.Position, main.AbsoluteSize
            self._resizing = true
        end
    end))
    self._cleaner:Add(UserInputService.InputChanged:Connect(function(input)
        if self._minimized then
            resizing = false
            self._resizing = false
            return
        end
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
        or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
            self._resizing = false
        end
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

function Window:SetTitle(_) if self._titleLabel then self._titleLabel.Text = "Nature" end end
function Window:SetSubtitle(_) if self._subtitleLabel then self._subtitleLabel.Text = "Premium" end end

function Window:ToggleMinimize()
    self._overlay:CloseAll()
    self._minimized = not self._minimized
    self._resizing = false
    if self._resizeHandle then
        self._resizeHandle.Visible = not self._minimized
        self._resizeHandle.Active = not self._minimized
    end
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
    local main = self.Main
    local closeScale = Util.Create("UIScale", { Scale = 1, Parent = main })
    Util.Tween(closeScale, { Scale = 0.92 }, 0.26, Enum.EasingStyle.Quint)
    Util.Tween(main, { BackgroundTransparency = 1 }, 0.24)
    for _, d in ipairs(main:GetDescendants()) do
        if d:IsA("GuiObject") then
            pcall(function() Util.Tween(d, { BackgroundTransparency = 1, TextTransparency = 1, ImageTransparency = 1 }, 0.22) end)
        end
    end
    task.delay(0.3, function() self:Destroy() end)
end

function Window:Destroy()
    for _, tab in ipairs(self._tabs) do tab:Destroy() end
    table.clear(self._tabs)
    self._cleaner:Clean()
end

local Library = {}
Library.__index = Library

function Library.new()
    local self = setmetatable({}, Library)
    self._theme = ThemeManager.new(DEFAULT_THEME)
    self._windows = {}
    self.Flags = {}
    Logger.Init("Nature UI initialized — theme:", self._theme:GetCurrentName())
    return self
end

function Library:CreateWindow(opts)
    local window = Window.new(self, opts)
    table.insert(self._windows, window)
    Logger.Init("Window created:", "Nature Premium")
    return window
end

function Library:SetTheme(name)
    return self._theme:SetTheme(name)
end

function Library:NextTheme()
    return self._theme:NextTheme()
end

function Library:GetTheme()
    return self._theme:Get()
end

function Library:GetThemeName()
    return self._theme:GetCurrentName()
end

function Library:GetThemes()
    return table.clone(THEME_ORDER)
end

function Library:SetDebug(enabled)
    CONFIG.Debug = enabled and true or false
    Logger.Init("Debug logging", CONFIG.Debug and "ENABLED" or "disabled")
end

function Library:OnThemeChanged(fn)
    return self._theme.Changed:Connect(fn)
end

function Library:SetAnimationDuration(duration)
    CONFIG.AnimationDuration = duration
end

function Library:Destroy()
    for _, window in ipairs(self._windows) do window:Destroy() end
    table.clear(self._windows)
    Logger.Init("Library destroyed")
end

Library.Signal = Signal
Library.Cleaner = Cleaner
Library.Spacing = Spacing
Library.Logger = Logger


-- Rayfield-style compatibility helpers. These preserve Nature's existing Add* API
-- while allowing common Rayfield scripts to run with Create* method names.
local function _settings(value, fallbackName)
    if type(value) == "table" then return value end
    return { Name = tostring(value or fallbackName or "Element") }
end

local function _safeCallback(fn, ...)
    if type(fn) ~= "function" then return end
    local args = { ... }
    task.spawn(function()
        local ok, err = pcall(fn, table.unpack(args))
        if not ok then
            Logger.Exec("Callback error:", tostring(err))
        end
    end)
end

local function _registerFlagFromSection(section, settings, component)
    local lib = section and section._tab and section._tab._window and section._tab._window._library
    if lib and settings and settings.Flag then
        lib.Flags[settings.Flag] = component
        component.Flag = settings.Flag
    end
    return component
end

function Button:Set(newText)
    self._value = newText
    self._text = tostring(newText)
    if self._button then
        self._button.Text = self._text
    end
    self.Changed:Fire(self._text)
end

function Section:CreateButton(settings)
    settings = _settings(settings, "Button")
    local comp = self:AddButton(settings.Name or "Button", function()
        _safeCallback(settings.Callback)
    end)
    comp.Type = "Button"
    return _registerFlagFromSection(self, settings, comp)
end

function Section:CreateToggle(settings)
    settings = _settings(settings, "Toggle")
    local comp
    comp = self:AddToggle(settings.Name or "Toggle", function()
        comp.CurrentValue = true
        _safeCallback(settings.Callback, true)
    end, function()
        comp.CurrentValue = false
        _safeCallback(settings.Callback, false)
    end, settings.CurrentValue and true or false)
    comp.Type = "Toggle"
    comp.CurrentValue = comp:Get()
    return _registerFlagFromSection(self, settings, comp)
end

function Section:CreateSlider(settings)
    settings = _settings(settings, "Slider")
    local range = settings.Range or { settings.Min or 0, settings.Max or 100 }
    local min = range[1] or 0
    local max = range[2] or 100
    local comp
    comp = self:AddSlider(settings.Name or "Slider", min, max, settings.CurrentValue or settings.Default or min, function(value)
        if comp then comp.CurrentValue = value end
        _safeCallback(settings.Callback, value)
    end)
    comp.Type = "Slider"
    comp.CurrentValue = comp:Get()
    comp.Range = { min, max }
    comp.Increment = settings.Increment or 1
    comp.Suffix = settings.Suffix or ""
    return _registerFlagFromSection(self, settings, comp)
end

function Section:CreateInput(settings)
    settings = _settings(settings, "Input")
    local comp
    comp = self:AddTextbox(settings.Name or "Input", settings.PlaceholderText or settings.Placeholder or "Input", function(text)
        if comp then comp.CurrentValue = text end
        _safeCallback(settings.Callback, text)
        if comp and settings.RemoveTextAfterFocusLost and comp._input then
            comp._input.Text = ""
        end
    end)
    comp.Type = "Input"
    comp.CurrentValue = comp:Get() or ""
    return _registerFlagFromSection(self, settings, comp)
end

function Section:CreateDropdown(settings)
    settings = _settings(settings, "Dropdown")
    local options = settings.Options or {}
    local current = settings.CurrentOption or settings.Default or options[1]
    if type(current) == "table" and not settings.MultipleOptions then
        current = current[1]
    end
    local comp
    comp = self:AddDropdown(settings.Name or "Dropdown", options, function(value)
        if settings.MultipleOptions then
            comp.CurrentOption = type(value) == "table" and table.clone(value) or { value }
            _safeCallback(settings.Callback, table.clone(comp.CurrentOption))
        else
            local selected = type(value) == "table" and value[1] or value
            comp.CurrentOption = { selected }
            _safeCallback(settings.Callback, table.clone(comp.CurrentOption))
        end
    end, current)
    comp.Type = "Dropdown"
    comp._multiple = settings.MultipleOptions and true or false
    if comp._multiple and type(comp._value) ~= "table" then
        comp._value = comp._value and { comp._value } or {}
        if comp._selectedLabel then comp._selectedLabel.Text = comp:_formatValue(comp._value) end
    end
    comp.CurrentOption = comp._multiple and (type(comp._value) == "table" and table.clone(comp._value) or {}) or { comp:Get() }
    return _registerFlagFromSection(self, settings, comp)
end

function Section:CreateKeybind(settings)
    settings = _settings(settings, "Keybind")
    local key = settings.CurrentKeybind or settings.Keybind or settings.Default or Enum.KeyCode.Unknown
    if type(key) == "string" then key = Enum.KeyCode[key] or Enum.KeyCode.Unknown end
    local comp
    comp = self:AddKeybind(settings.Name or "Keybind", key, function()
        if comp then comp.CurrentKeybind = comp:Get() end
        _safeCallback(settings.Callback)
    end)
    comp.Type = "Keybind"
    comp.CurrentKeybind = comp:Get()
    return _registerFlagFromSection(self, settings, comp)
end

function Section:CreateLabel(settings)
    if type(settings) == "table" then settings = settings.Name or settings.Text or settings.Title or "Label" end
    local comp = self:AddLabel(tostring(settings or "Label"))
    comp.Type = "Label"
    return comp
end

function Section:CreateParagraph(settings)
    settings = type(settings) == "table" and settings or { Title = "Paragraph", Content = tostring(settings or "") }
    local comp = self:AddParagraph(settings.Title or "Paragraph", settings.Content or settings.Body or "")
    comp.Type = "Paragraph"
    return comp
end

function Section:CreateColorPicker(settings)
    settings = _settings(settings, "ColorPicker")
    local initial = settings.Color or Color3.fromRGB(255, 255, 255)
    local comp = self:AddButton((settings.Name or "ColorPicker") .. "  RGB(" .. math.floor(initial.R * 255) .. ", " .. math.floor(initial.G * 255) .. ", " .. math.floor(initial.B * 255) .. ")", function()
        _safeCallback(settings.Callback, initial)
    end)
    comp.Type = "ColorPicker"
    comp.Color = initial
    function comp:Set(color)
        if typeof(color) == "Color3" then
            self.Color = color
            if self._button then
                self._button.Text = (settings.Name or "ColorPicker") .. "  RGB(" .. math.floor(color.R * 255) .. ", " .. math.floor(color.G * 255) .. ", " .. math.floor(color.B * 255) .. ")"
            end
            _safeCallback(settings.Callback, color)
            self.Changed:Fire(color)
        end
    end
    return _registerFlagFromSection(self, settings, comp)
end

function Tab:_compatSection()
    if self._compatCurrentSection then return self._compatCurrentSection end
    self._compatCurrentSection = self:AddSection("Main")
    return self._compatCurrentSection
end

function Tab:CreateSection(sectionName)
    local section = self:AddSection(sectionName or "Section")
    self._compatCurrentSection = section
    return section
end

function Tab:CreateButton(settings) return self:_compatSection():CreateButton(settings) end
function Tab:CreateToggle(settings) return self:_compatSection():CreateToggle(settings) end
function Tab:CreateSlider(settings) return self:_compatSection():CreateSlider(settings) end
function Tab:CreateInput(settings) return self:_compatSection():CreateInput(settings) end
function Tab:CreateDropdown(settings) return self:_compatSection():CreateDropdown(settings) end
function Tab:CreateKeybind(settings) return self:_compatSection():CreateKeybind(settings) end
function Tab:CreateLabel(settings) return self:_compatSection():CreateLabel(settings) end
function Tab:CreateParagraph(settings) return self:_compatSection():CreateParagraph(settings) end
function Tab:CreateColorPicker(settings) return self:_compatSection():CreateColorPicker(settings) end

function Window:CreateTab(name, image)
    return self:AddTab(name, image)
end

function Library:Notify(settings)
    settings = settings or {}
    local gui
    if self._windows[1] and self._windows[1].Gui then
        gui = self._windows[1].Gui
    else
        gui = Util.Create("ScreenGui", {
            Name = "NatureNotifications", ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true,
            DisplayOrder = 1000, Parent = Util.GetGuiParent(),
        })
    end
    local theme = self._theme:Get()
    local card = Util.Create("Frame", {
        Name = "Notification", AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -24, 1, 80), Size = UDim2.new(0, 300, 0, 86),
        BackgroundColor3 = theme.PanelTop, BackgroundTransparency = 0.02,
        BorderSizePixel = 0, ZIndex = Z.Overlay + 20, Parent = gui,
    })
    Util.Corner(14, card)
    Util.Stroke(card, theme.Border, 1, 0.18)
    Util.Padding(card, 14)
    local title = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22),
        Font = CONFIG.FontBold, Text = tostring(settings.Title or "Notification"), TextSize = 17,
        TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = card.ZIndex + 1, Parent = card,
    })
    local body = Util.Create("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 1, -28),
        Font = CONFIG.FontRegular, Text = tostring(settings.Content or settings.Description or ""), TextSize = 14,
        TextWrapped = true, TextColor3 = theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, ZIndex = card.ZIndex + 1, Parent = card,
    })
    card.BackgroundTransparency = 1
    title.TextTransparency = 1
    body.TextTransparency = 1
    Util.Tween(card, { Position = UDim2.new(1, -24, 1, -24), BackgroundTransparency = 0.02 }, 0.32, Enum.EasingStyle.Quint)
    Util.Tween(title, { TextTransparency = 0 }, 0.22, Enum.EasingStyle.Quint)
    Util.Tween(body, { TextTransparency = 0 }, 0.22, Enum.EasingStyle.Quint)
    task.delay(settings.Duration or 6.5, function()
        if not card.Parent then return end
        Util.Tween(card, { Position = UDim2.new(1, -24, 1, 80), BackgroundTransparency = 1 }, 0.28, Enum.EasingStyle.Quint)
        Util.Tween(title, { TextTransparency = 1 }, 0.22, Enum.EasingStyle.Quint)
        Util.Tween(body, { TextTransparency = 1 }, 0.22, Enum.EasingStyle.Quint)
        task.delay(0.32, function() if card then card:Destroy() end end)
    end)
end

function Library:SaveConfiguration(fileName)
    local data = {}
    for flag, comp in pairs(self.Flags or {}) do
        if comp.Type == "ColorPicker" then
            local c = comp.Color or Color3.new(1,1,1)
            data[flag] = { R = math.floor(c.R * 255), G = math.floor(c.G * 255), B = math.floor(c.B * 255) }
        elseif comp.Type == "Dropdown" then
            data[flag] = comp.CurrentOption or comp:Get()
        elseif comp.Type == "Keybind" then
            local key = comp.CurrentKeybind or comp:Get()
            data[flag] = key and key.Name or "Unknown"
        else
            data[flag] = comp.CurrentValue or comp:Get()
        end
    end
    local encoded = HttpService:JSONEncode(data)
    if writefile then
        local folder = "NatureUI"
        if makefolder and not isfolder(folder) then pcall(makefolder, folder) end
        writefile(folder .. "/" .. (fileName or "configuration") .. ".json", encoded)
    end
    return encoded
end

function Library:LoadConfiguration(configOrFile)
    local raw = configOrFile
    if readfile and isfile and type(configOrFile) == "string" and isfile(configOrFile) then
        raw = readfile(configOrFile)
    end
    if type(raw) ~= "string" or raw == "" then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok or type(data) ~= "table" then return false end
    for flag, value in pairs(data) do
        local comp = self.Flags and self.Flags[flag]
        if comp and type(comp.Set) == "function" then
            if comp.Type == "ColorPicker" and type(value) == "table" and value.R then
                comp:Set(Color3.fromRGB(value.R, value.G, value.B))
            elseif comp.Type == "Keybind" and type(value) == "string" then
                comp:Set(Enum.KeyCode[value] or Enum.KeyCode.Unknown)
            else
                comp:Set(value)
            end
        end
    end
    return true
end

return Library.new()
