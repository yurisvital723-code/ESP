-- AJ Scripts | MM2 Utility UI v2.0
-- Interface criada em Luau: sem dependências de bibliotecas externas.
-- Algumas rotinas ligadas ao jogo dependem dos objetos replicados no servidor.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local parent = localPlayer:WaitForChild("PlayerGui")
pcall(function()
    if type(gethui) == "function" then parent = gethui() or parent end
end)
local old = parent:FindFirstChild("AJScriptsMM2")
if old then old:Destroy() end

local C = {
    bg=Color3.fromRGB(12,12,17), surface=Color3.fromRGB(20,20,28),
    card=Color3.fromRGB(27,25,35), hover=Color3.fromRGB(42,28,39),
    red=Color3.fromRGB(245,46,75), red2=Color3.fromRGB(134,19,40),
    pale=Color3.fromRGB(255,214,222), white=Color3.fromRGB(242,240,249),
    muted=Color3.fromRGB(150,145,165), line=Color3.fromRGB(69,45,60),
    green=Color3.fromRGB(73,225,155), blue=Color3.fromRGB(80,180,255),
    gold=Color3.fromRGB(255,190,92), off=Color3.fromRGB(60,56,68)
}
local W,H = 706,458
local alive = true
local connections = {}
local settings = {
    sound=true, animation=true, particles=true, speed=16, jump=50, fov=70,
    volumePercent=20,
    noclip=false, infiniteJump=false, autoCoins=false,
    esp=false, showDistance=true, highlightRoles=true,
    roleWatch=false, antiAfk=false, volume=0.2, windowOpacity=0,
}
local selectedPlayer = nil
local function bind(signal,callback)
    local con=signal:Connect(callback)
    table.insert(connections,con)
    return con
end
local function make(class,parentObject,props)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    if parentObject then o.Parent=parentObject end
    return o
end
local function round(o,r)
    make("UICorner",o,{CornerRadius=UDim.new(0,r or 10)})
    return o
end
local function edge(o,color,thickness,transparency)
    return make("UIStroke",o,{
        Color=color or C.line,Thickness=thickness or 1,
        Transparency=transparency or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    })
end
local function gradient(o,a,b,rotation)
    return make("UIGradient",o,{
        Color=ColorSequence.new(a,b),Rotation=rotation or 90
    })
end
local function tween(o,t,props,style,direction)
    local info=TweenInfo.new(settings.animation and t or 0.01,
        style or Enum.EasingStyle.Quint,direction or Enum.EasingDirection.Out)
    local tw=TweenService:Create(o,info,props)
    tw:Play()
    return tw
end
local function frame(p,pos,sz,color,r)
    local f=make("Frame",p,{Position=pos or UDim2.fromScale(0,0),
        Size=sz or UDim2.fromScale(1,1),BackgroundColor3=color or C.surface,
        BorderSizePixel=0})
    if r then round(f,r) end
    return f
end
local function text(p,s,pos,sz,fontSize,color,bold)
    return make("TextLabel",p,{Text=s,Position=pos,Size=sz,
        BackgroundTransparency=1,TextColor3=color or C.white,
        Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize=fontSize or 13,TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd})
end
local function hit(p,s,pos,sz,color,r)
    local b=make("TextButton",p,{Text=s or "",Position=pos,Size=sz,
        BackgroundColor3=color or C.surface,BorderSizePixel=0,
        Font=Enum.Font.GothamBold,TextSize=13,TextColor3=C.white,
        AutoButtonColor=false})
    round(b,r or 10)
    return b
end
local function padding(p,x,y)
    make("UIPadding",p,{PaddingLeft=UDim.new(0,x),PaddingRight=UDim.new(0,x),
        PaddingTop=UDim.new(0,y),PaddingBottom=UDim.new(0,y)})
end
local function layout(p,gap)
    return make("UIListLayout",p,{FillDirection=Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,gap or 8)})
end

local gui=make("ScreenGui",parent,{Name="AJScriptsMM2",ResetOnSpawn=false,
    IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    DisplayOrder=101})
local soundHolder=make("Folder",gui,{Name="SFX"})
local sfx={}
for name,data in pairs({
    click={"rbxasset://sounds/action_jump.mp3",2.2},
    page={"rbxasset://sounds/action_get_up.mp3",1.65},
    toggle={"rbxasset://sounds/action_jump_land.mp3",2.3},
    open={"rbxasset://sounds/action_get_up.mp3",1.1},
}) do
    sfx[name]=make("Sound",soundHolder,{Name=name,SoundId=data[1],
        PlaybackSpeed=data[2],Volume=settings.volume})
end
local function play(name)
    if not settings.sound then return end
    local s=sfx[name] or sfx.click
    if s then
        s.Volume=settings.volume
        s.TimePosition=0
        pcall(function() s:Play() end)
    end
end
local function ornament(p,sz)
    local o=frame(p,UDim2.new(1,-sz.X.Offset-8,0,8),sz,C.red2,6)
    gradient(o,C.red,C.red2,0)
    o.BackgroundTransparency=.65
    return o
end

-- Fundo externo totalmente transparente; apenas a própria janela tem superfície.
local launcher=hit(gui,"AJ",UDim2.new(0,18,.5,-25),UDim2.fromOffset(52,52),C.bg,15)
launcher.TextSize=18
local launcherStroke=edge(launcher,C.red,2,0)
gradient(launcher,Color3.fromRGB(85,19,33),C.bg,55)
local launchScale=make("UIScale",launcher,{Scale=1})
local launchDot=round(frame(launcher,UDim2.new(1,-10,0,8),UDim2.fromOffset(5,5),C.green,3),3)

local shadow=frame(gui,UDim2.fromScale(.5,.5),UDim2.fromOffset(W+8,H+8),C.red,19)
shadow.AnchorPoint=Vector2.new(.5,.5)
shadow.BackgroundTransparency=.92
local glowStroke=edge(shadow,C.red,3,.48)
local window=make("CanvasGroup",gui,{Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(W,H),BackgroundColor3=C.bg,BorderSizePixel=0})
round(window,16)
window.AnchorPoint=Vector2.new(.5,.5)
local windowStroke=edge(window,C.red,1.5,.1)
gradient(window,Color3.fromRGB(23,14,24),C.bg,90)
local uiScale=make("UIScale",window,{Scale=1})
local shadowScale=make("UIScale",shadow,{Scale=1})
local function fit()
    local cam=Workspace.CurrentCamera
    if not cam then return end
    local v=cam.ViewportSize
    local scale=math.clamp(math.min((v.X-30)/W,(v.Y-30)/H),.34,1)
    uiScale.Scale=scale
    shadowScale.Scale=scale
end
fit()
if Workspace.CurrentCamera then
    bind(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),fit)
end
bind(Workspace:GetPropertyChangedSignal("CurrentCamera"),function()
    fit()
    if Workspace.CurrentCamera then
        bind(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),fit)
    end
end)

local header=frame(window,UDim2.fromOffset(1,1),UDim2.new(1,-2,0,62),C.surface,15)
gradient(header,Color3.fromRGB(54,20,34),C.surface,0)
local underline=frame(window,UDim2.fromOffset(12,62),UDim2.new(1,-24,0,2),C.red)
underline.BackgroundTransparency=.20
local crown=text(header,"♛",UDim2.fromOffset(17,8),UDim2.fromOffset(36,43),29,C.red,true)
crown.TextXAlignment=Enum.TextXAlignment.Center
text(header,"AJ",UDim2.fromOffset(57,7),UDim2.fromOffset(36,31),22,C.white,true)
text(header,"SCRIPTS",UDim2.fromOffset(94,7),UDim2.fromOffset(125,31),22,C.red,true)
text(header,"MURDER MYSTERY  •  UTILITY EDITION",UDim2.fromOffset(58,37),UDim2.fromOffset(260,15),9,C.muted,true)
-- Imagem opcional: publique o logo como imagem Roblox e defina o ID abaixo.
local CUSTOM_LOGO_ASSET_ID=""
if CUSTOM_LOGO_ASSET_ID~="" then
    make("ImageLabel",header,{Image="rbxassetid://"..CUSTOM_LOGO_ASSET_ID,
        Position=UDim2.fromOffset(14,8),Size=UDim2.fromOffset(36,36),
        BackgroundTransparency=1,ScaleType=Enum.ScaleType.Fit})
end
local soundToggle=hit(header,"◖))",UDim2.new(1,-142,0,14),UDim2.fromOffset(43,34),C.card,9)
edge(soundToggle,C.line,1,.35)
local collapse=hit(header,"—",UDim2.new(1,-93,0,14),UDim2.fromOffset(36,34),C.card,9)
edge(collapse,C.line,1,.35)
local close=hit(header,"×",UDim2.new(1,-52,0,14),UDim2.fromOffset(36,34),C.red2,9)
edge(close,C.red,1,.2)
local bars={}
for i=1,8 do
    bars[i]=round(frame(header,UDim2.new(1,-216+(i-1)*6,0,28),
        UDim2.fromOffset(3,5+((i*13)%20)),C.red,3),3)
end

local side=frame(window,UDim2.fromOffset(11,75),UDim2.fromOffset(151,346),C.surface,12)
edge(side,C.line,1,.5)
local sideAccent=frame(side,UDim2.fromOffset(0,14),UDim2.fromOffset(2,316),C.red)
sideAccent.BackgroundTransparency=.35
local body=frame(window,UDim2.fromOffset(173,75),UDim2.fromOffset(521,346),C.bg,11)
body.BackgroundTransparency=1
local foot=frame(window,UDim2.fromOffset(12,428),UDim2.new(1,-24,0,20),C.surface,8)
foot.BackgroundTransparency=.1
local statusDot=round(frame(foot,UDim2.fromOffset(11,7),UDim2.fromOffset(6,6),C.green,3),3)
text(foot,"AJ SCRIPTS • MM2 UI",UDim2.fromOffset(24,0),UDim2.fromOffset(170,20),10,C.muted,true)
text(foot,"RIGHT SHIFT  /  BOTÃO AJ",UDim2.new(1,-195,0,0),
    UDim2.fromOffset(185,20),10,C.muted,true).TextXAlignment=Enum.TextXAlignment.Right

local toastFrame=round(frame(gui,UDim2.new(.5,0,.84,0),UDim2.fromOffset(360,44),C.surface,12),12)
toastFrame.AnchorPoint=Vector2.new(.5,.5)
toastFrame.Visible=false
edge(toastFrame,C.red,1,.25)
local toastLabel=text(toastFrame,"",UDim2.fromOffset(16,0),UDim2.new(1,-32,1,0),13,C.white,true)
local toastScale=make("UIScale",toastFrame,{Scale=.85})
local toastSeq=0
local function notify(message,color)
    if not alive then return end
    toastSeq=toastSeq+1
    local serial=toastSeq
    toastLabel.Text=message
    toastLabel.TextColor3=color or C.white
    toastFrame.Visible=true
    toastFrame.BackgroundTransparency=0
    toastScale.Scale=.88
    tween(toastScale,.23,{Scale=1},Enum.EasingStyle.Back)
    task.delay(2.2,function()
        if not alive or serial~=toastSeq then return end
        local t=tween(toastFrame,.20,{BackgroundTransparency=1})
        t.Completed:Once(function()
            if alive and serial==toastSeq then toastFrame.Visible=false end
        end)
    end)
end

local function animateButton(b)
    local sc=make("UIScale",b,{Scale=1})
    bind(b.MouseEnter,function() tween(sc,.16,{Scale=1.025}) end)
    bind(b.MouseLeave,function() tween(sc,.16,{Scale=1}) end)
    bind(b.Activated,function()
        play("click")
        tween(sc,.07,{Scale=.965},Enum.EasingStyle.Quad)
        task.delay(.07,function() if alive and sc.Parent then tween(sc,.18,{Scale=1},Enum.EasingStyle.Back) end end)
    end)
end
animateButton(launcher)
animateButton(soundToggle)
animateButton(collapse)
animateButton(close)

local tabNames={"Home","Player","Assassin","Auto Coins","ESP","Teleports","Visuals","Misc","Settings"}
local tabIcons={"⌂","◉","⚔","◈","◎","⌖","✧","▦","⚙"}
local tabs,pages={},{}
local current=1
local changeTab
for i,name in ipairs(tabNames) do
    local b=hit(side,"",UDim2.fromOffset(8,9+(i-1)*37),UDim2.fromOffset(135,32),C.surface,8)
    edge(b,C.line,1,.80)
    local icon=text(b,tabIcons[i],UDim2.fromOffset(10,0),UDim2.fromOffset(24,32),18,C.red,true)
    icon.TextXAlignment=Enum.TextXAlignment.Center
    local nameLabel=text(b,name,UDim2.fromOffset(41,0),UDim2.fromOffset(90,32),12,C.muted,true)
    tabs[i]={button=b,icon=icon,label=nameLabel}
    bind(b.Activated,function() if changeTab then changeTab(i) end end)
    bind(b.MouseEnter,function()
        if current~=i then tween(b,.13,{BackgroundColor3=C.hover}) end
    end)
    bind(b.MouseLeave,function()
        if current~=i then tween(b,.13,{BackgroundColor3=C.surface}) end
    end)
end

local function newPage(i,titleString,subtitle)
    local page=make("CanvasGroup",body,{Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,Visible=i==1,GroupTransparency=i==1 and 0 or 1})
    pages[i]=page
    local title=text(page,titleString,UDim2.fromOffset(9,3),UDim2.new(1,-18,0,30),21,C.white,true)
    local accent=frame(page,UDim2.fromOffset(9,36),UDim2.fromOffset(34,2),C.red)
    local caption=text(page,subtitle,UDim2.fromOffset(9,43),UDim2.new(1,-18,0,19),11,C.muted)
    local list=make("ScrollingFrame",page,{Position=UDim2.fromOffset(0,70),
        Size=UDim2.new(1,0,1,-73),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=C.red,ScrollingDirection=Enum.ScrollingDirection.Y,
        CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ElasticBehavior=Enum.ElasticBehavior.WhenScrollable})
    padding(list,7,5)
    layout(list,10)
    return list
end

local function section(list,titleString,description)
    local box=frame(list,nil,UDim2.new(1,-2,0,0),C.surface,12)
    box.Position=UDim2.new()
    box.AutomaticSize=Enum.AutomaticSize.Y
    edge(box,C.line,1,.4)
    padding(box,12,11)
    layout(box,7)
    local head=frame(box,nil,UDim2.new(1,0,0,31),C.surface)
    head.BackgroundTransparency=1
    text(head,titleString,UDim2.fromOffset(0,0),UDim2.new(1,-45,0,20),14,C.white,true)
    text(head,description or "",UDim2.fromOffset(0,20),UDim2.new(1,-30,0,12),10,C.muted)
    ornament(head,UDim2.fromOffset(34,4))
    return box
end
local function sectionLabel(parent,titleString,subtitle)
    local label=frame(parent,nil,UDim2.new(1,0,0,45),C.card,9)
    edge(label,C.line,1,.55)
    text(label,titleString,UDim2.fromOffset(11,5),UDim2.new(1,-20,0,21),13,C.white,true)
    local detail=text(label,subtitle,UDim2.fromOffset(11,25),UDim2.new(1,-20,0,14),10,C.muted)
    return label,detail
end
local function action(parent,caption,handler,red)
    local b=hit(parent,caption,UDim2.new(),UDim2.new(1,0,0,39),red and C.red2 or C.card,9)
    edge(b,red and C.red or C.line,1,.3)
    animateButton(b)
    bind(b.Activated,handler)
    return b
end
local switchRefresh={}
local function switch(parent,caption,desc,key,onChange)
    local row=frame(parent,nil,UDim2.new(1,0,0,51),C.card,9)
    edge(row,C.line,1,.65)
    text(row,caption,UDim2.fromOffset(12,6),UDim2.new(1,-85,0,21),13,C.white,true)
    text(row,desc or "",UDim2.fromOffset(12,26),UDim2.new(1,-85,0,16),10,C.muted)
    local track=round(frame(row,UDim2.new(1,-61,.5,-11),UDim2.fromOffset(47,22),C.off,12),12)
    local knob=round(frame(track,UDim2.fromOffset(2,2),UDim2.fromOffset(18,18),C.white,9),9)
    local btn=hit(row,"",UDim2.new(),UDim2.fromScale(1,1),C.card,9)
    btn.BackgroundTransparency=1
    local function render()
        local on=settings[key]
        tween(track,.2,{BackgroundColor3=on and C.red or C.off})
        tween(knob,.2,{Position=UDim2.fromOffset(on and 27 or 2,2)})
    end
    switchRefresh[key]=switchRefresh[key] or {}
    table.insert(switchRefresh[key],render)
    render()
    bind(btn.Activated,function()
        settings[key]=not settings[key]
        play("toggle")
        for _,redraw in ipairs(switchRefresh[key]) do redraw() end
        if onChange then onChange(settings[key]) end
    end)
    return row,render
end
local function slider(parent,caption,min,max,key,suffix,onChange)
    local row=frame(parent,nil,UDim2.new(1,0,0,69),C.card,9)
    edge(row,C.line,1,.65)
    text(row,caption,UDim2.fromOffset(12,6),UDim2.new(1,-90,0,20),13,C.white,true)
    local value=text(row,"",UDim2.new(1,-85,0,6),UDim2.fromOffset(72,20),13,C.red,true)
    value.TextXAlignment=Enum.TextXAlignment.Right
    local rail=round(frame(row,UDim2.fromOffset(15,46),UDim2.new(1,-30,0,7),C.off,4),4)
    local fill=round(frame(rail,UDim2.new(),UDim2.fromScale(.3,1),C.red,4),4)
    local handle=round(frame(rail,UDim2.new(.3,-7,.5,-7),UDim2.fromOffset(14,14),C.pale,7),7)
    edge(handle,C.red,2,.1)
    local touchArea=frame(row,UDim2.fromOffset(15,35),UDim2.new(1,-30,0,30),C.card)
    touchArea.BackgroundTransparency=1
    local dragging=false
    local activeInput
    local function setValue(n,fire)
        n=math.clamp(math.floor(n+.5),min,max)
        settings[key]=n
        local f=(n-min)/(max-min)
        value.Text=tostring(n)..(suffix or "")
        fill.Size=UDim2.fromScale(f,1)
        handle.Position=UDim2.new(f,-7,.5,-7)
        if fire and onChange then onChange(n) end
    end
    local function point(event)
        if rail.AbsoluteSize.X <= 0 then return end
        local f=math.clamp((event.Position.X-rail.AbsolutePosition.X)/rail.AbsoluteSize.X,0,1)
        setValue(min+f*(max-min),true)
    end
    setValue(settings[key],false)
    bind(touchArea.InputBegan,function(event)
        if event.UserInputType==Enum.UserInputType.MouseButton1
            or event.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            activeInput=event
            point(event)
        end
    end)
    bind(UserInputService.InputChanged,function(event)
        if dragging and (event==activeInput or (activeInput
            and activeInput.UserInputType==Enum.UserInputType.MouseButton1
            and event.UserInputType==Enum.UserInputType.MouseMovement)) then
            point(event)
        end
    end)
    bind(UserInputService.InputEnded,function(event)
        if event==activeInput then dragging=false activeInput=nil play("click") end
    end)
    return row,setValue
end

-- Utilidades do personagem
local function characterParts()
    local char=localPlayer.Character
    return char,char and char:FindFirstChildOfClass("Humanoid"),
        char and char:FindFirstChild("HumanoidRootPart")
end
local function applyMovement()
    local _,hum=characterParts()
    if not hum then return end
    pcall(function()
        hum.WalkSpeed=settings.speed
        hum.UseJumpPower=true
        hum.JumpPower=settings.jump
    end)
end
local lastCollisions={}
local function restoreCollisions()
    for part,value in pairs(lastCollisions) do
        if part and part.Parent then pcall(function() part.CanCollide=value end) end
    end
    table.clear(lastCollisions)
end
bind(RunService.Stepped,function()
    if not settings.noclip then return end
    local char=localPlayer.Character
    if not char then return end
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if lastCollisions[part]==nil then lastCollisions[part]=part.CanCollide end
            part.CanCollide=false
        end
    end
end)
bind(UserInputService.JumpRequest,function()
    if not settings.infiniteJump then return end
    local _,hum=characterParts()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
bind(localPlayer.CharacterAdded,function()
    restoreCollisions()
    task.delay(.4,function() if alive then applyMovement() end end)
end)

local function roleOf(player)
    local char=player.Character
    if not char then return "DESCONHECIDO",C.muted end
    local function hasTool(container,name)
        if not container then return false end
        for _,obj in ipairs(container:GetChildren()) do
            if obj:IsA("Tool") and obj.Name:lower()==name then return true end
        end
        return false
    end
    local pack=player==localPlayer and player:FindFirstChildOfClass("Backpack") or nil
    if hasTool(char,"knife") or hasTool(pack,"knife") then return "POSSÍVEL ASSASSINO",C.red end
    if hasTool(char,"gun") or hasTool(char,"revolver") or hasTool(pack,"gun") then
        return "POSSÍVEL XERIFE",C.blue
    end
    return "NÃO IDENTIFICADO",C.muted
end
local markersByPlayer={}
local function clearMarkers()
    for player,entry in pairs(markersByPlayer) do
        if entry.outline then entry.outline:Destroy() end
        if entry.sign then entry.sign:Destroy() end
        markersByPlayer[player]=nil
    end
end
local function updateMarkers()
    if not settings.esp then clearMarkers() return end
    local seen={}
    local _,_,ownRoot=characterParts()
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=localPlayer then
            local char=player.Character
            local head=char and char:FindFirstChild("Head")
            local living=char and char:FindFirstChildOfClass("Humanoid")
            if head and living and living.Health>0 then
                seen[player]=true
                local role,color=roleOf(player)
                local entry=mark
