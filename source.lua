local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local CONFIG = {
AnimationDuration = 0.22,
AnimationStyle    = Enum.EasingStyle.Quad,
AnimationDirection= Enum.EasingDirection.Out,
Font              = Enum.Font.GothamMedium,
FontBold          = Enum.Font.GothamBold,
FontRegular       = Enum.Font.Gotham,
}

local DEFAULT_THEME = {
    Primary        = Color3.fromRGB(28, 37, 31),
    PrimaryLight   = Color3.fromRGB(34, 46, 38),

    Secondary      = Color3.fromRGB(40, 54, 44),
    SecondaryLight = Color3.fromRGB(48, 64, 53),

    Accent         = Color3.fromRGB(77, 214, 122),
    AccentDim      = Color3.fromRGB(63, 175, 101),

    Text           = Color3.fromRGB(255,255,255),
    TextDim        = Color3.fromRGB(185,195,188),
    TextMuted      = Color3.fromRGB(130,140,134),

    Background     = Color3.fromRGB(20,28,23),

    Border         = Color3.fromRGB(65,85,72),

    ToggleOff      = Color3.fromRGB(55,65,59),

    ToggleThumb    = Color3.fromRGB(255,255,255),

    Shadow         = Color3.fromRGB(0,0,0),
}

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
CornerRadius = UDim.new(0, radius or 8),
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
function Util.Shadow(parent, transparency, size)
local shadow = Util.Create("ImageLabel", {
Name = "Shadow",
BackgroundTransparency = 1,
Image = "rbxassetid://6014261993",
ImageColor3 = DEFAULT_THEME.Shadow,
ImageTransparency = transparency or 0.5,
ScaleType = Enum.ScaleType.Slice,
SliceCenter = Rect.new(49, 49, 450, 450),
Size = UDim2.new(1, (size or 40), 1, (size or 40)),
Position = UDim2.new(0.5, 0, 0.5, 0),
AnchorPoint = Vector2.new(0.5, 0.5),
ZIndex = 0,
Parent = parent,
})
return shadow
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
return LocalPlayer:WaitForChild("PlayerGui")
end
return CoreGui
end
local Icons = {}
local function newPixel(parent, color, size, pos, rot, corner)
local p = Util.Create("Frame", {
BackgroundColor3 = color,
BorderSizePixel = 0,
Size = size,
Position = pos,
AnchorPoint = Vector2.new(0.5, 0.5),
Rotation = rot or 0,
Parent = parent,
})
if corner then Util.Corner(corner, p) end
return p
end
function Icons.wrench(parent, color)
newPixel(parent, color, UDim2.new(0, 16, 0, 6), UDim2.new(0.5, 1, 0.5, 1), 45, 3)
newPixel(parent, color, UDim2.new(0, 8, 0, 8), UDim2.new(0.5, -6, 0.5, -6), 0, 8)
newPixel(parent, color, UDim2.new(0, 8, 0, 8), UDim2.new(0.5, 6, 0.5, 6), 0, 8)
end
function Icons.gear(parent, color)
newPixel(parent, color, UDim2.new(0, 18, 0, 18), UDim2.new(0.5, 0, 0.5, 0), 0, 9)
for i = 0, 5 do
newPixel(parent, color, UDim2.new(0, 6, 0, 6), UDim2.new(0.5, 0, 0.5, 0), i * 30, 2)
.Position = UDim2.new(0.5, math.cos(math.rad(i * 60)) * 11, 0.5, math.sin(math.rad(i * 60)) * 11)
end
newPixel(parent, DEFAULT_THEME.Primary, UDim2.new(0, 7, 0, 7), UDim2.new(0.5, 0, 0.5, 0), 0, 4)
end
function Icons.bug(parent, color)
newPixel(parent, color, UDim2.new(0, 12, 0, 14), UDim2.new(0.5, 0, 0.5, 1), 0, 6)
newPixel(parent, color, UDim2.new(0, 8, 0, 6), UDim2.new(0.5, 0, 0.5, -7), 0, 4)
newPixel(parent, color, UDim2.new(0, 14, 0, 2), UDim2.new(0.5, 0, 0.5, 0), 0, 1)
newPixel(parent, color, UDim2.new(0, 2, 0, 8), UDim2.new(0.5, -8, 0.5, 2), 25, 1)
newPixel(parent, color, UDim2.new(0, 2, 0, 8), UDim2.new(0.5, 8, 0.5, 2), -25, 1)
end
function Icons.blocks(parent, color)
newPixel(parent, color, UDim2.new(0, 8, 0, 8), UDim2.new(0.5, -5, 0.5, -5), 0, 2)
newPixel(parent, color, UDim2.new(0, 8, 0, 8), UDim2.new(0.5, 5, 0.5, -5), 0, 2)
newPixel(parent, color, UDim2.new(0, 8, 0, 8), UDim2.new(0.5, -5, 0.5, 5), 0, 2)
newPixel(parent, color, UDim2.new(0, 8, 0, 8), UDim2.new(0.5, 5, 0.5, 5), 45, 2)
end
function Icons.leaf(parent, color)
newPixel(parent, color, UDim2.new(0, 14, 0, 14), UDim2.new(0.5, 0, 0.5, 0), 45, 7)
newPixel(parent, color, UDim2.new(0, 2, 0, 12), UDim2.new(0.5, 0, 0.5, 0), 45, 1)
end
function Icons.chevron(parent, color)
local holder = Util.Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
Parent = parent,
})
newPixel(holder, color, UDim2.new(0, 9, 0, 2.5), UDim2.new(0.5, -3, 0.5, 0), 45, 2)
newPixel(holder, color, UDim2.new(0, 9, 0, 2.5), UDim2.new(0.5, 3, 0.5, 0), -45, 2)
return holder
end
function Icons.Build(name, parent, color)
local holder = Util.Create("Frame", {
Name = "Icon",
BackgroundTransparency = 1,
Size = UDim2.new(0, 22, 0, 22),
Parent = parent,
})
local builder = Icons[name]
if builder then
builder(holder, color)
else
newPixel(holder, color, UDim2.new(0, 10, 0, 10), UDim2.new(0.5, 0, 0.5, 0), 0, 5)
end
return holder
end
local Signal = {}
Signal.__index = Signal
local Connection = {}
Connection.__index = Connection
function Connection.new(signal, fn)
return setmetatable({
_signal = signal,
_fn = fn,
Connected = true,
}, Connection)
end
function Connection:Disconnect()
if not self.Connected then return end
self.Connected = false
local conns = self._signal._connections
for i, c in ipairs(conns) do
if c == self then
table.remove(conns, i)
break
end
end
end
Connection.Destroy = Connection.Disconnect
function Signal.new()
return setmetatable({
_connections = {},
_threads = {},
}, Signal)
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
if entry.inst and entry.inst.Parent ~= nil or typeof(entry.inst) ~= "Instance" then
entry.fn(entry.inst, self.Theme)
else
table.remove(self._registry, i)
end
end
self.Changed:Fire(self.Theme)
end
local LayoutManager = {}
LayoutManager.__index = LayoutManager
function LayoutManager.VerticalList(container, padding, alignment)
local layout = Util.Create("UIListLayout", {
FillDirection = Enum.FillDirection.Vertical,
SortOrder = Enum.SortOrder.LayoutOrder,
Padding = UDim.new(0, padding or 8),
HorizontalAlignment = alignment or Enum.HorizontalAlignment.Center,
Parent = container,
})
return layout
end
function LayoutManager.HorizontalList(container, padding, valign)
local layout = Util.Create("UIListLayout", {
FillDirection = Enum.FillDirection.Horizontal,
SortOrder = Enum.SortOrder.LayoutOrder,
Padding = UDim.new(0, padding or 8),
VerticalAlignment = valign or Enum.VerticalAlignment.Center,
Parent = container,
})
return layout
end
function LayoutManager.AutoHeight(frame)
frame.AutomaticSize = Enum.AutomaticSize.Y
end
function LayoutManager.BindScrollCanvas(scroll, layout)
local function update()
scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
end
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
update()
end
local BaseComponent = {}
BaseComponent.__index = BaseComponent
function BaseComponent.new(section)
local self = setmetatable({}, BaseComponent)
self._section = section
self._theme   = section._theme
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
if self.Instance then
self.Instance:Destroy()
end
self._cleaner:Clean()
end
function BaseComponent:_makeRow(height)
local theme = self._theme:Get()
local row = Util.Create("Frame", {
Name = "Row",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, height or 40),
LayoutOrder = self._section:_nextOrder(),
Parent = self._section.Container,
})
return row
end
local Toggle = setmetatable({}, { __index = BaseComponent })
Toggle.__index = Toggle
function Toggle.new(section, text, onFn, offFn, default)
local self = BaseComponent.new(section)
setmetatable(self, Toggle)
self._onFn  = onFn
self._offFn = offFn
self._value = default or false
local theme = self._theme:Get()
local row = self:_makeRow(42)
self.Instance = row
local label = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -70, 1, 0),
Position = UDim2.new(0, 2, 0, 0),
Font = CONFIG.Font,
Text = text,
TextSize = 18,
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
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
Text = "",
Parent = track,
})
self._track = track
self._thumb = thumb
self._cleaner:Add(btn.MouseButton1Click:Connect(function()
self:Set(not self._value)
end))
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
if value == self._value then
self:_render(true)
return
end
self._value = value
self:_render(true)
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
AutoButtonColor = false,
BorderSizePixel = 0,
Font = CONFIG.Font,
Text = text,
TextSize = 17,
TextColor3 = theme.Text,
Parent = row,
})
Util.Corner(8, btn)
Util.Gradient(btn, theme.SecondaryLight, theme.Secondary, 90)
self._theme:Register(btn, function(b, t)
b.TextColor3 = t.Text
b.BackgroundColor3 = t.SecondaryLight
end)
local rippleHolder = Util.Create("Frame", {
BackgroundTransparency = 1,
ClipsDescendants = true,
Size = UDim2.new(1, 0, 1, 0),
Parent = btn,
})
Util.Corner(8, rippleHolder)
self._cleaner:Add(btn.MouseEnter:Connect(function()
Util.Tween(btn, { BackgroundColor3 = theme.Accent })
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
local localX = x - abs.X
local localY = y - abs.Y
local ripple = Util.Create("Frame", {
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
BackgroundTransparency = 0.7,
Position = UDim2.new(0, localX, 0, localY),
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.new(0, 0, 0, 0),
Parent = holder,
})
Util.Corner(999, ripple)
Util.Tween(ripple, {
Size = UDim2.new(0, 200, 0, 200),
BackgroundTransparency = 1,
}, 0.5)
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
self._value    = default or (self._options[1])
local theme = self._theme:Get()
local row = self:_makeRow(40)
self.Instance = row
local label = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(0.5, -10, 1, 0),
Font = CONFIG.Font,
Text = text,
TextSize = 18,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = row,
})
self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)
local box = Util.Create("TextButton", {
Name = "Box",
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, 0, 0.5, 0),
Size = UDim2.new(0.46, 0, 0, 38),
BackgroundColor3 = theme.SecondaryLight,
AutoButtonColor = false,
BorderSizePixel = 0,
Text = "",
Parent = row,
})
Util.Corner(8, box)
Util.Gradient(box, theme.SecondaryLight, theme.Secondary, 90)
self._theme:Register(box, function(b, t) b.BackgroundColor3 = t.SecondaryLight end)
local selected = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -44, 1, 0),
Position = UDim2.new(0, 14, 0, 0),
Font = CONFIG.Font,
Text = tostring(self._value or "Select..."),
TextSize = 17,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = box,
})
self._selectedLabel = selected
self._theme:Register(selected, function(l, t) l.TextColor3 = t.Text end)
local arrowHolder = Util.Create("Frame", {
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, -12, 0.5, 0),
Size = UDim2.new(0, 18, 0, 18),
Parent = box,
})
Icons.chevron(arrowHolder, theme.Text)
self._arrow = arrowHolder
local listFrame = Util.Create("Frame", {
Name = "OptionList",
Position = UDim2.new(1, 0, 1, 4),
AnchorPoint = Vector2.new(1, 0),
Size = UDim2.new(0.46, 0, 0, 0),
BackgroundColor3 = theme.Secondary,
BorderSizePixel = 0,
ClipsDescendants = true,
Visible = false,
ZIndex = 5,
Parent = box,
})
Util.Corner(8, listFrame)
Util.Stroke(listFrame, theme.Border, 1, 0.4)
local scroll = Util.Create("ScrollingFrame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
BorderSizePixel = 0,
ScrollBarThickness = 3,
ScrollBarImageColor3 = theme.Accent,
CanvasSize = UDim2.new(0, 0, 0, 0),
ZIndex = 6,
Parent = listFrame,
})
local listLayout = LayoutManager.VerticalList(scroll, 2, Enum.HorizontalAlignment.Center)
Util.Padding(scroll, 4)
LayoutManager.BindScrollCanvas(scroll, listLayout)
self._listFrame = listFrame
self._scroll = scroll
self._box = box
self._cleaner:Add(box.MouseButton1Click:Connect(function()
self:_toggleOpen()
end))
self:_buildOptions()
return self
end
function Dropdown:_buildOptions()
for _, child in ipairs(self._scroll:GetChildren()) do
if child:IsA("TextButton") then child:Destroy() end
end
local theme = self._theme:Get()
for i, opt in ipairs(self._options) do
local optBtn = Util.Create("TextButton", {
Size = UDim2.new(1, 0, 0, 30),
BackgroundColor3 = (opt == self._value) and theme.Accent or theme.SecondaryLight,
BackgroundTransparency = (opt == self._value) and 0 or 0.4,
AutoButtonColor = false,
BorderSizePixel = 0,
Font = CONFIG.Font,
Text = tostring(opt),
TextSize = 16,
TextColor3 = theme.Text,
LayoutOrder = i,
ZIndex = 7,
Parent = self._scroll,
})
Util.Corner(6, optBtn)
optBtn.MouseEnter:Connect(function()
if opt ~= self._value then
Util.Tween(optBtn, { BackgroundTransparency = 0.1 }, 0.1)
end
end)
optBtn.MouseLeave:Connect(function()
if opt ~= self._value then
Util.Tween(optBtn, { BackgroundTransparency = 0.4 }, 0.1)
end
end)
optBtn.MouseButton1Click:Connect(function()
self:Set(opt)
self:_toggleOpen(false)
end)
end
end
function Dropdown:_toggleOpen(force)
if force ~= nil then
self._open = force
else
self._open = not self._open
end
local count = #self._options
local targetHeight = math.min(count * 32 + 8, 180)
if self._open then
self._listFrame.Visible = true
Util.Tween(self._listFrame, { Size = UDim2.new(0.46, 0, 0, targetHeight) })
Util.Tween(self._arrow, { Rotation = 180 })
Util.Tween(self.Instance, { Size = UDim2.new(1, 0, 0, 40 + targetHeight + 6) })
else
Util.Tween(self._listFrame, { Size = UDim2.new(0.46, 0, 0, 0) })
Util.Tween(self._arrow, { Rotation = 0 })
Util.Tween(self.Instance, { Size = UDim2.new(1, 0, 0, 40) })
task.delay(CONFIG.AnimationDuration, function()
if not self._open and self._listFrame then
self._listFrame.Visible = false
end
end)
end
end
function Dropdown:Set(value)
self._value = value
self._selectedLabel.Text = tostring(value)
self:_buildOptions()
if self._callback then task.spawn(self._callback, value) end
self.Changed:Fire(value)
end
function Dropdown:Refresh(newValues)
self._options = table.clone(newValues or {})
if not table.find(self._options, self._value) then
self._value = self._options[1]
self._selectedLabel.Text = tostring(self._value or "Select...")
end
self:_buildOptions()
end
local Slider = setmetatable({}, { __index = BaseComponent })
Slider.__index = Slider
function Slider.new(section, text, min, max, default, callback)
local self = BaseComponent.new(section)
setmetatable(self, Slider)
self._min = min or 0
self._max = max or 100
self._callback = callback
self._value = math.clamp(default or self._min, self._min, self._max)
local theme = self._theme:Get()
local row = self:_makeRow(54)
self.Instance = row
local label = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -60, 0, 22),
Font = CONFIG.Font,
Text = text,
TextSize = 18,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = row,
})
self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)
local valueLabel = Util.Create("TextLabel", {
BackgroundTransparency = 1,
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, 0, 0, 0),
Size = UDim2.new(0, 60, 0, 22),
Font = CONFIG.FontBold,
Text = tostring(self._value),
TextSize = 18,
TextColor3 = theme.Accent,
TextXAlignment = Enum.TextXAlignment.Right,
Parent = row,
})
self._valueLabel = valueLabel
self._theme:Register(valueLabel, function(l, t) l.TextColor3 = t.Accent end)
local track = Util.Create("Frame", {
AnchorPoint = Vector2.new(0, 1),
Position = UDim2.new(0, 0, 1, -6),
Size = UDim2.new(1, 0, 0, 8),
BackgroundColor3 = theme.ToggleOff,
BorderSizePixel = 0,
Parent = row,
})
Util.Corner(4, track)
self._theme:Register(track, function(t2, t) t2.BackgroundColor3 = t.ToggleOff end)
local fill = Util.Create("Frame", {
Size = UDim2.new(0, 0, 1, 0),
BackgroundColor3 = theme.Accent,
BorderSizePixel = 0,
Parent = track,
})
Util.Corner(4, fill)
self._fill = fill
self._theme:Register(fill, function(f, t) f.BackgroundColor3 = t.Accent end)
local knob = Util.Create("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0, 0, 0.5, 0),
Size = UDim2.new(0, 16, 0, 16),
BackgroundColor3 = theme.ToggleThumb,
BorderSizePixel = 0,
ZIndex = 3,
Parent = track,
})
Util.Corner(8, knob)
self._knob = knob
local btn = Util.Create("TextButton", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 20, 1, 20),
Position = UDim2.new(0, -10, 0, -10),
Text = "",
ZIndex = 4,
Parent = track,
})
self._track = track
local dragging = false
local function updateFromX(x)
local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
local raw = self._min + (self._max - self._min) * rel
self:Set(math.floor(raw + 0.5))
end
self._cleaner:Add(btn.MouseButton1Down:Connect(function(x)
dragging = true
updateFromX(x)
end))
self._cleaner:Add(UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
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
BackgroundTransparency = 1,
Size = UDim2.new(0.5, -10, 1, 0),
Font = CONFIG.Font,
Text = text,
TextSize = 18,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = row,
})
self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)
local boxFrame = Util.Create("Frame", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, 0, 0.5, 0),
Size = UDim2.new(0.46, 0, 0, 36),
BackgroundColor3 = theme.SecondaryLight,
BorderSizePixel = 0,
Parent = row,
})
Util.Corner(8, boxFrame)
local stroke = Util.Stroke(boxFrame, theme.Border, 1, 0.6)
self._theme:Register(boxFrame, function(b, t) b.BackgroundColor3 = t.SecondaryLight end)
local input = Util.Create("TextBox", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -20, 1, 0),
Position = UDim2.new(0, 12, 0, 0),
Font = CONFIG.Font,
Text = "",
PlaceholderText = placeholder or "Enter text...",
PlaceholderColor3 = theme.TextMuted,
TextSize = 16,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
ClearTextOnFocus = false,
Parent = boxFrame,
})
self._input = input
self._theme:Register(input, function(b, t)
b.TextColor3 = t.Text
b.PlaceholderColor3 = t.TextMuted
end)
self._cleaner:Add(input.Focused:Connect(function()
Util.Tween(stroke, { Transparency = 0, Color = theme.Accent }, 0.15)
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
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
Font = CONFIG.Font,
Text = text,
TextSize = 17,
TextColor3 = theme.TextDim,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = row,
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
BackgroundColor3 = theme.Secondary,
BackgroundTransparency = 0.3,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
BorderSizePixel = 0,
Parent = row,
})
Util.Corner(8, container)
Util.Padding(container, 12)
LayoutManager.VerticalList(container, 6, Enum.HorizontalAlignment.Left)
self._theme:Register(container, function(c, t) c.BackgroundColor3 = t.Secondary end)
local titleLabel = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 22),
Font = CONFIG.FontBold,
Text = title,
TextSize = 18,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = container,
})
self._theme:Register(titleLabel, function(l, t) l.TextColor3 = t.Text end)
local bodyLabel = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
Font = CONFIG.FontRegular,
Text = body,
TextSize = 15,
TextColor3 = theme.TextDim,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
TextWrapped = true,
Parent = container,
})
self._title = titleLabel
self._body = bodyLabel
self._theme:Register(bodyLabel, function(l, t) l.TextColor3 = t.TextDim end)
return self
end
function Paragraph:Set(body)
self._body.Text = body
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
local label = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Size = UDim2.new(0.6, 0, 1, 0),
Font = CONFIG.Font,
Text = text,
TextSize = 18,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = row,
})
self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)
local keyBtn = Util.Create("TextButton", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, 0, 0.5, 0),
Size = UDim2.new(0, 110, 0, 34),
BackgroundColor3 = theme.SecondaryLight,
AutoButtonColor = false,
BorderSizePixel = 0,
Font = CONFIG.Font,
Text = self._value.Name,
TextSize = 15,
TextColor3 = theme.Text,
Parent = row,
})
Util.Corner(8, keyBtn)
self._keyBtn = keyBtn
self._theme:Register(keyBtn, function(b, t)
b.BackgroundColor3 = t.SecondaryLight
b.TextColor3 = t.Text
end)
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
and input.KeyCode == self._value
and self._value ~= Enum.KeyCode.Unknown then
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
BackgroundTransparency = 1,
Size = UDim2.new(0.7, 0, 1, 0),
Font = CONFIG.Font,
Text = text,
TextSize = 18,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = row,
})
self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)
local swatch = Util.Create("TextButton", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, 0, 0.5, 0),
Size = UDim2.new(0, 50, 0, 28),
BackgroundColor3 = self._value,
AutoButtonColor = false,
BorderSizePixel = 0,
Text = "",
Parent = row,
})
Util.Corner(6, swatch)
Util.Stroke(swatch, theme.Border, 1, 0.4)
self._swatch = swatch
local popup = Util.Create("Frame", {
Name = "Picker",
AnchorPoint = Vector2.new(1, 0),
Position = UDim2.new(1, 0, 1, 6),
Size = UDim2.new(0, 200, 0, 0),
BackgroundColor3 = theme.Secondary,
BorderSizePixel = 0,
ClipsDescendants = true,
Visible = false,
ZIndex = 8,
Parent = swatch,
})
Util.Corner(8, popup)
Util.Stroke(popup, theme.Border, 1, 0.4)
self._popup = popup
local inner = Util.Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
ZIndex = 9,
Parent = popup,
})
Util.Padding(inner, 10)
LayoutManager.VerticalList(inner, 8, Enum.HorizontalAlignment.Center)
local svBox = Util.Create("ImageButton", {
Size = UDim2.new(1, 0, 0, 120),
BackgroundColor3 = Color3.fromHSV(self._h, 1, 1),
BorderSizePixel = 0,
AutoButtonColor = false,
ZIndex = 9,
Parent = inner,
})
Util.Corner(6, svBox)
local satGrad = Util.Create("UIGradient", {
Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)),
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0),
NumberSequenceKeypoint.new(1, 1),
}),
Parent = svBox,
})
local valOverlay = Util.Create("Frame", {
Size = UDim2.new(1,0,1,0),
BackgroundColor3 = Color3.new(0,0,0),
BorderSizePixel = 0,
ZIndex = 9,
Parent = svBox,
})
Util.Corner(6, valOverlay)
Util.Create("UIGradient", {
Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)),
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(1, 0),
}),
Rotation = 90,
Parent = valOverlay,
})
self._svBox = svBox
local svCursor = Util.Create("Frame", {
Size = UDim2.new(0, 8, 0, 8),
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundColor3 = Color3.new(1,1,1),
BorderSizePixel = 0,
ZIndex = 10,
Parent = svBox,
})
Util.Corner(4, svCursor)
Util.Stroke(svCursor, Color3.new(0,0,0), 1, 0)
self._svCursor = svCursor
local hueBar = Util.Create("ImageButton", {
Size = UDim2.new(1, 0, 0, 16),
BorderSizePixel = 0,
AutoButtonColor = false,
ZIndex = 9,
Parent = inner,
})
Util.Corner(6, hueBar)
Util.Create("UIGradient", {
Color = ColorSequence.new({
ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
}),
Parent = hueBar,
})
self._hueBar = hueBar
local hueCursor = Util.Create("Frame", {
Size = UDim2.new(0, 4, 1, 4),
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(self._h, 0, 0.5, 0),
BackgroundColor3 = Color3.new(1,1,1),
BorderSizePixel = 0,
ZIndex = 10,
Parent = hueBar,
})
Util.Corner(2, hueCursor)
Util.Stroke(hueCursor, Color3.new(0,0,0), 1, 0)
self._hueCursor = hueCursor
self._cleaner:Add(swatch.MouseButton1Click:Connect(function()
self:_togglePopup()
end))
local svDragging, hueDragging = false, false
local function updateSV(x, y)
local rx = math.clamp((x - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
local ry = math.clamp((y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
self._s = rx
self._v = 1 - ry
svCursor.Position = UDim2.new(rx, 0, ry, 0)
self:_apply()
end
local function updateHue(x)
local rx = math.clamp((x - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
self._h = rx
hueCursor.Position = UDim2.new(rx, 0, 0.5, 0)
svBox.BackgroundColor3 = Color3.fromHSV(self._h, 1, 1)
self:_apply()
end
self._cleaner:Add(svBox.MouseButton1Down:Connect(function(x, y) svDragging = true; updateSV(x, y) end))
self._cleaner:Add(hueBar.MouseButton1Down:Connect(function(x) hueDragging = true; updateHue(x) end))
self._cleaner:Add(UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
svDragging, hueDragging = false, false
end
end))
self._cleaner:Add(UserInputService.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch then
if svDragging then updateSV(input.Position.X, input.Position.Y) end
if hueDragging then updateHue(input.Position.X) end
end
end))
svCursor.Position = UDim2.new(self._s, 0, 1 - self._v, 0)
return self
end
function ColorPicker:_apply()
local color = Color3.fromHSV(self._h, self._s, self._v)
self._value = color
self._swatch.BackgroundColor3 = color
if self._callback then task.spawn(self._callback, color) end
self.Changed:Fire(color)
end
function ColorPicker:_togglePopup()
self._open = not self._open
if self._open then
self._popup.Visible = true
Util.Tween(self._popup, { Size = UDim2.new(0, 200, 0, 200) })
Util.Tween(self.Instance, { Size = UDim2.new(1, 0, 0, 40 + 206) })
else
Util.Tween(self._popup, { Size = UDim2.new(0, 200, 0, 0) })
Util.Tween(self.Instance, { Size = UDim2.new(1, 0, 0, 40) })
task.delay(CONFIG.AnimationDuration, function()
if not self._open and self._popup then self._popup.Visible = false end
end)
end
end
function ColorPicker:Set(color)
self._value = color
self._h, self._s, self._v = color:ToHSV()
self._swatch.BackgroundColor3 = color
self._svBox.BackgroundColor3 = Color3.fromHSV(self._h, 1, 1)
self._svCursor.Position = UDim2.new(self._s, 0, 1 - self._v, 0)
self._hueCursor.Position = UDim2.new(self._h, 0, 0.5, 0)
self.Changed:Fire(color)
end
local Section = {}
Section.__index = Section
function Section.new(tab, title)
local self = setmetatable({}, Section)
self._tab = tab
self._theme = tab._theme
self._cleaner = Cleaner.new()
self._components = {}
self._order = 0
self._expanded = true
local theme = self._theme:Get()
self.Wrapper = Util.Create("Frame", {
Name = "Section_" .. title,
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
LayoutOrder = tab:_nextSectionOrder(),
Parent = tab.Content,
})
LayoutManager.VerticalList(self.Wrapper, 6, Enum.HorizontalAlignment.Center)
local header = Util.Create("TextButton", {
Name = "Header",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 36),
AutoButtonColor = false,
Text = "",
LayoutOrder = 0,
Parent = self.Wrapper,
})
local chevHolder = Util.Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(0, 26, 0, 26),
Position = UDim2.new(0, 0, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
Parent = header,
})
local chev = Icons.chevron(chevHolder, theme.Text)
chev.Rotation = 180
self._chev = chev
local titleLabel = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 36, 0, 0),
Size = UDim2.new(1, -40, 1, 0),
Font = CONFIG.FontBold,
Text = title,
TextSize = 22,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = header,
})
self._theme:Register(titleLabel, function(l, t) l.TextColor3 = t.Text end)
self.Container = Util.Create("Frame", {
Name = "Container",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 0),
AutomaticSize = Enum.AutomaticSize.Y,
ClipsDescendants = true,
LayoutOrder = 1,
Parent = self.Wrapper,
})
LayoutManager.VerticalList(self.Container, 10, Enum.HorizontalAlignment.Center)
Util.Padding(self.Container, nil, { Top = 6, Bottom = 6 })
self._cleaner:Add(header.MouseButton1Click:Connect(function()
self:_toggleExpand()
end))
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
local function register(self, component)
table.insert(self._components, component)
self._cleaner:Add(component)
return component
end
function Section:AddToggle(text, onFn, offFn, default)
return register(self, Toggle.new(self, text, onFn, offFn, default))
end
function Section:AddButton(text, callback)
return register(self, Button.new(self, text, callback))
end
function Section:AddDropdown(text, options, callback, default)
return register(self, Dropdown.new(self, text, options, callback, default))
end
function Section:AddSlider(text, min, max, default, callback)
return register(self, Slider.new(self, text, min, max, default, callback))
end
function Section:AddTextbox(text, placeholder, callback)
return register(self, Textbox.new(self, text, placeholder, callback))
end
function Section:AddLabel(text)
return register(self, Label.new(self, text))
end
function Section:AddParagraph(title, body)
return register(self, Paragraph.new(self, title, body))
end
function Section:AddKeybind(text, defaultKey, callback)
return register(self, Keybind.new(self, text, defaultKey, callback))
end
function Section:AddColorPicker(text, defaultColor, callback)
return register(self, ColorPicker.new(self, text, defaultColor, callback))
end
function Section:Destroy()
for _, comp in ipairs(self._components) do
comp:Destroy()
end
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
self._cleaner = Cleaner.new()
self._sections = {}
self._sectionOrder = 0
self._active = false
local theme = self._theme:Get()
local button = Util.Create("TextButton", {
Name = "Tab_" .. name,
Size = UDim2.new(1, 0, 0, 50),
BackgroundColor3 = theme.SecondaryLight,
BackgroundTransparency = 1,
AutoButtonColor = false,
BorderSizePixel = 0,
Text = "",
LayoutOrder = window:_nextTabOrder(),
Parent = window.TabList,
})
Util.Corner(10, button)
self._button = button
local highlight = Util.Create("Frame", {
Name = "Highlight",
Size = UDim2.new(1, 0, 1, 0),
BackgroundColor3 = theme.SecondaryLight,
BackgroundTransparency = 1,
BorderSizePixel = 0,
Parent = button,
})
Util.Corner(10, highlight)
Util.Gradient(highlight, theme.SecondaryLight, theme.Secondary, 0)
self._highlight = highlight
local iconHolder = Util.Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(0, 26, 0, 26),
Position = UDim2.new(0, 16, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
ZIndex = 2,
Parent = button,
})
Icons.Build(iconName or "blocks", iconHolder, theme.Text)
self._iconHolder = iconHolder
local label = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 54, 0, 0),
Size = UDim2.new(1, -60, 1, 0),
Font = CONFIG.Font,
Text = name,
TextSize = 19,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
ZIndex = 2,
Parent = button,
})
self._label = label
self._theme:Register(label, function(l, t) l.TextColor3 = t.Text end)
local page = Util.Create("ScrollingFrame", {
Name = "Page_" .. name,
Size = UDim2.new(1, 0, 1, 0),
BackgroundTransparency = 1,
BorderSizePixel = 0,
ScrollBarThickness = 4,
ScrollBarImageColor3 = theme.Accent,
ScrollBarImageTransparency = 0.3,
CanvasSize = UDim2.new(0, 0, 0, 0),
Visible = false,
Parent = window.ContentContainer,
})
Util.Padding(page, nil, { Top = 4, Bottom = 8, Left = 4, Right = 8 })
self.Content = page
local contentLayout = LayoutManager.VerticalList(page, 14, Enum.HorizontalAlignment.Center)
LayoutManager.BindScrollCanvas(page, contentLayout)
self._cleaner:Add(button.MouseButton1Click:Connect(function()
window:_selectTab(self)
end))
self._cleaner:Add(button.MouseEnter:Connect(function()
if not self._active then
Util.Tween(button, { BackgroundTransparency = 0.85 }, 0.12)
end
end))
self._cleaner:Add(button.MouseLeave:Connect(function()
if not self._active then
Util.Tween(button, { BackgroundTransparency = 1 }, 0.12)
end
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
for _, section in ipairs(self._sections) do
section:Destroy()
end
table.clear(self._sections)
self._cleaner:Clean()
if self._button then self._button:Destroy() end
if self.Content then self.Content:Destroy() end
end
local Window = {}
Window.__index = Window
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
Name = "NatureUI",
ResetOnSpawn = false,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
IgnoreGuiInset = true,
DisplayOrder = 999,
})
pcall(function() gui.Parent = Util.GetGuiParent() end)
self.Gui = gui
self._cleaner:Add(gui)
local scale = Util.Create("UIScale", {
Scale = 1,
Parent = gui,
})
self._scale = scale
local main = Util.Create("Frame", {
Name = "MainWindow",
AnchorPoint = Vector2.new(0.5, 0.5),
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 720, 0, 470),
BackgroundColor3 = theme.Primary,
BorderSizePixel = 0,
Parent = gui,
})
Util.Corner(14, main)
Util.Gradient(main, theme.PrimaryLight, theme.Primary, 135)
Util.Stroke(main, theme.Border, 1.5, 0.3)
Util.Shadow(main, 0.45, 60)
self.Main = main
self._theme:Register(main, function(m, t) m.BackgroundColor3 = t.Primary end)
local header = Util.Create("Frame", {
Name = "Header",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 64),
Parent = main,
})
self.Header = header
local logoHolder = Util.Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(0, 28, 0, 28),
Position = UDim2.new(0, 22, 0.5, 0),
AnchorPoint = Vector2.new(0, 0.5),
Parent = header,
})
Icons.Build("leaf", logoHolder, theme.Text)
local titleLabel = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 60, 0, 0),
Size = UDim2.new(0, 0, 1, 0),
AutomaticSize = Enum.AutomaticSize.X,
Font = CONFIG.FontBold,
Text = opts.Title or "Nature",
TextSize = 24,
TextColor3 = theme.Text,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = header,
})
self._titleLabel = titleLabel
self._theme:Register(titleLabel, function(l, t) l.TextColor3 = t.Text end)
local subtitleLabel = Util.Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 60, 0, 0),
Size = UDim2.new(0, 0, 1, 0),
AutomaticSize = Enum.AutomaticSize.X,
Font = CONFIG.FontRegular,
Text = "  " .. (opts.Subtitle or "Basic"),
TextSize = 24,
TextColor3 = theme.TextDim,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = header,
})
self._subtitleLabel = subtitleLabel
self._theme:Register(subtitleLabel, function(l, t) l.TextColor3 = t.TextDim end)
local function repositionSubtitle()
subtitleLabel.Position = UDim2.new(0, 60 + titleLabel.AbsoluteSize.X, 0, 0)
end
self._cleaner:Add(titleLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(repositionSubtitle))
task.defer(repositionSubtitle)
local function makeControl(symbol, xOffset, hoverColor)
local btn = Util.Create("TextButton", {
AnchorPoint = Vector2.new(1, 0.5),
Position = UDim2.new(1, xOffset, 0.5, 0),
Size = UDim2.new(0, 34, 0, 34),
BackgroundTransparency = 1,
Font = CONFIG.FontBold,
Text = symbol,
TextSize = 26,
TextColor3 = theme.Text,
Parent = header,
})
Util.Corner(8, btn)
btn.MouseEnter:Connect(function()
Util.Tween(btn, { BackgroundColor3 = hoverColor, BackgroundTransparency = 0.7 }, 0.12)
end)
btn.MouseLeave:Connect(function()
Util.Tween(btn, { BackgroundTransparency = 1 }, 0.12)
end)
return btn
end
local closeBtn = makeControl("×", -18, Color3.fromRGB(200, 70, 70))
local minBtn   = makeControl("–", -60, theme.SecondaryLight)
self._cleaner:Add(closeBtn.MouseButton1Click:Connect(function()
self:Close()
end))
self._cleaner:Add(minBtn.MouseButton1Click:Connect(function()
self:ToggleMinimize()
end))
local divider = Util.Create("Frame", {
BackgroundColor3 = theme.Border,
BackgroundTransparency = 0.5,
BorderSizePixel = 0,
Size = UDim2.new(1, -44, 0, 1),
Position = UDim2.new(0, 22, 0, 64),
Parent = main,
})
self._theme:Register(divider, function(d, t) d.BackgroundColor3 = t.Border end)
local body = Util.Create("Frame", {
Name = "Body",
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 72),
Size = UDim2.new(1, 0, 1, -84),
Parent = main,
})
self.Body = body
local sidebar = Util.Create("Frame", {
Name = "Sidebar",
Position = UDim2.new(0, 18, 0, 0),
Size = UDim2.new(0, 270, 1, 0),
BackgroundColor3 = theme.Secondary,
BackgroundTransparency = 0.25,
BorderSizePixel = 0,
Parent = body,
})
Util.Corner(12, sidebar)
Util.Gradient(sidebar, theme.PrimaryLight, theme.Secondary, 160)
Util.Stroke(sidebar, theme.Border, 1, 0.6)
self.Sidebar = sidebar
self._theme:Register(sidebar, function(s, t) s.BackgroundColor3 = t.Secondary end)
local tabList = Util.Create("Frame", {
BackgroundTransparency = 1,
Size = UDim2.new(1, -24, 1, -24),
Position = UDim2.new(0, 12, 0, 14),
Parent = sidebar,
})
LayoutManager.VerticalList(tabList, 10, Enum.HorizontalAlignment.Center)
self.TabList = tabList
local contentPanel = Util.Create("Frame", {
Name = "ContentPanel",
Position = UDim2.new(0, 306, 0, 0),
Size = UDim2.new(1, -324, 1, 0),
BackgroundColor3 = theme.Secondary,
BackgroundTransparency = 0.25,
BorderSizePixel = 0,
Parent = body,
})
Util.Corner(12, contentPanel)
Util.Gradient(contentPanel, theme.PrimaryLight, theme.Secondary, 200)
Util.Stroke(contentPanel, theme.Border, 1, 0.6)
self._theme:Register(contentPanel, function(c, t) c.BackgroundColor3 = t.Secondary end)
local contentContainer = Util.Create("Frame", {
Name = "ContentContainer",
BackgroundTransparency = 1,
Size = UDim2.new(1, -36, 1, -28),
Position = UDim2.new(0, 18, 0, 16),
Parent = contentPanel,
})
self.ContentContainer = contentContainer
self:_setupDragging(header, main)
self:_setupViewportScaling()
return self
end
function Window:_nextTabOrder()
self._tabOrder += 1
return self._tabOrder
end
function Window:_setupDragging(handle, target)
local dragging = false
local dragStart, startPos
self._cleaner:Add(handle.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = target.Position
end
end))
self._cleaner:Add(UserInputService.InputChanged:Connect(function(input)
if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
or input.UserInputType == Enum.UserInputType.Touch) then
local delta = input.Position - dragStart
target.Position = UDim2.new(
startPos.X.Scale, startPos.X.Offset + delta.X,
startPos.Y.Scale, startPos.Y.Offset + delta.Y
)
end
end))
self._cleaner:Add(UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1
or input.UserInputType == Enum.UserInputType.Touch then
dragging = false
end
end))
end
function Window:_setupViewportScaling()
local camera = workspace.CurrentCamera
local function update()
if not camera then return end
local vp = camera.ViewportSize
local scaleX = vp.X / 760
local scaleY = vp.Y / 520
local s = math.clamp(math.min(scaleX, scaleY), 0.45, 1)
self._scale.Scale = s
end
self._cleaner:Add(camera:GetPropertyChangedSignal("ViewportSize"):Connect(update))
update()
end
function Window:_selectTab(tab)
if self._activeTab == tab then return end
for _, t in ipairs(self._tabs) do
t:_setActive(t == tab)
end
self._activeTab = tab
end
function Window:AddTab(name, iconName)
local tab = Tab.new(self, name, iconName)
table.insert(self._tabs, tab)
if #self._tabs == 1 then
self:_selectTab(tab)
end
return tab
end
function Window:SetTitle(text)
self._titleLabel.Text = text
end
function Window:SetSubtitle(text)
self._subtitleLabel.Text = "  " .. text
end
function Window:ToggleMinimize()
self._minimized = not self._minimized
if self._minimized then
self._savedSize = self.Main.Size
self.Body.Visible = false
Util.Tween(self.Main, { Size = UDim2.new(self.Main.Size.X.Scale, self.Main.Size.X.Offset, 0, 64) })
else
self.Body.Visible = true
Util.Tween(self.Main, { Size = self._savedSize or UDim2.new(0, 720, 0, 470) })
end
end
function Window:Close()
Util.Tween(self.Main, {
Size = UDim2.new(0, 0, 0, 0),
BackgroundTransparency = 1,
}, 0.25)
task.delay(0.28, function()
self:Destroy()
end)
end
function Window:Destroy()
for _, tab in ipairs(self._tabs) do
tab:Destroy()
end
table.clear(self._tabs)
self._cleaner:Clean()
end
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
function Library:SetAnimationDuration(duration)
CONFIG.AnimationDuration = duration
end
function Library:Destroy()
for _, window in ipairs(self._windows) do
window:Destroy()
end
table.clear(self._windows)
end

Library.Signal = Signal
Library.Cleaner = Cleaner

return Library.new()
