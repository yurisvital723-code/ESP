-- AJ Scripts | MM2 Utility UI v2.1 | arquivo completo
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
                local entry=markersByPlayer[player]
                if entry and entry.character~=char then
                    if entry.outline then entry.outline:Destroy() end
                    if entry.sign then entry.sign:Destroy() end
                    entry=nil
                end
                if not entry then
                    entry={character=char}
                    markersByPlayer[player]=entry
                end
                if not entry.outline or not entry.outline.Parent then
                    entry.outline=make("Highlight",char,{
                        Name="AJ_EspGlow",FillTransparency=.82,
                        OutlineTransparency=.08,
                        DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    })
                end
                entry.outline.FillColor=color
                entry.outline.OutlineColor=settings.highlightRoles and color or C.white
                if settings.showDistance then
                    if not entry.sign or not entry.sign.Parent then
                        entry.sign=make("BillboardGui",head,{
                            Name="AJ_DistanceTag",Adornee=head,
                            Size=UDim2.fromOffset(190,36),
                            StudsOffset=Vector3.new(0,2.8,0),AlwaysOnTop=true
                        })
                        entry.caption=text(entry.sign,"",UDim2.new(),
                            UDim2.fromScale(1,1),12,C.white,true)
                        entry.caption.TextXAlignment=Enum.TextXAlignment.Center
                        entry.caption.TextStrokeTransparency=.2
                    end
                    local meters=ownRoot and math.floor((ownRoot.Position-head.Position).Magnitude) or 0
                    entry.caption.Text=player.DisplayName.."  •  "..meters.."m"
                    entry.caption.TextColor3=color
                elseif entry.sign then
                    entry.sign:Destroy()
                    entry.sign=nil
                    entry.caption=nil
                end
            end
        end
    end
    for player,entry in pairs(markersByPlayer) do
        if not seen[player] then
            if entry.outline then entry.outline:Destroy() end
            if entry.sign then entry.sign:Destroy() end
            markersByPlayer[player]=nil
        end
    end
end
local function findCoins()
    local results={}
    for _,inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") and inst.Name:lower():find("coin",1,true) then
            if inst.Transparency<.95 and inst.Parent then
                table.insert(results,inst)
            end
        end
    end
    return results
end
local function nearestCoin()
    local _,hum,root=characterParts()
    if not hum or not root then return nil end
    local target,best=nil,140
    for _,coin in ipairs(findCoins()) do
        local d=(root.Position-coin.Position).Magnitude
        if d<best and d>2 then target,best=coin,d end
    end
    return target
end
local coinScanInfo,coinInfoText
local function beginCoins()
    if not settings.autoCoins then return end
    task.spawn(function()
        while alive and settings.autoCoins do
            local _,hum,root=characterParts()
            local coin=nearestCoin()
            if coinScanInfo and coinScanInfo.Parent then
                coinInfoText.Text=coin and "Moeda detectada: deslocamento ativo"
                    or "Nenhuma moeda replicada encontrada"
            end
            if coin and hum and root then
                hum:MoveTo(coin.Position)
            end
            task.wait(1.4)
        end
    end)
end
local function stopCoins()
    local _,hum,root=characterParts()
    if hum and root then hum:MoveTo(root.Position) end
end
local function setAntiAfk(on)
    if on then notify("Anti-AFK ativo (somente enquanto a interface existir)",C.green)
    else notify("Anti-AFK desativado") end
end
bind(localPlayer.Idled,function()
    if settings.antiAfk then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0,0))
        end)
    end
end)

-- HOME
local home=newPage(1,"AJ SCRIPTS","RED EDITION  /  MURDER MYSTERY 2")
local hero=frame(home,nil,UDim2.new(1,-2,0,114),C.card,13)
edge(hero,C.red,1,.28)
gradient(hero,Color3.fromRGB(93,23,43),C.card,0)
local avatarBox=round(frame(hero,UDim2.fromOffset(14,14),UDim2.fromOffset(74,74),C.bg,37),37)
edge(avatarBox,C.red,2,.05)
local avatar=make("ImageLabel",avatarBox,{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Image=""})
round(avatar,37)
task.spawn(function()
    local ok,id=pcall(function()
        return Players:GetUserThumbnailAsync(localPlayer.UserId,
            Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
    end)
    if ok and alive and avatar.Parent then avatar.Image=id end
end)
text(hero,"BEM-VINDO AO AJ SCRIPTS",UDim2.fromOffset(102,17),UDim2.new(1,-115,0,26),16,C.white,true)
text(hero,"@"..localPlayer.Name,UDim2.fromOffset(102,45),UDim2.new(1,-115,0,20),12,C.pale)
text(hero,"◆ PREMIUM UI  •  BUILD 2.0  •  LUAU",UDim2.fromOffset(102,70),
    UDim2.new(1,-115,0,17),10,C.muted,true)
local quick=section(home,"ACESSO RÁPIDO","Menu interativo com atalhos e efeitos")
local quickRow=frame(quick,nil,UDim2.new(1,0,0,52),C.surface)
quickRow.BackgroundTransparency=1
local shortcuts={{"PLAYER",2},{"ASSASSIN",3},{"AUTO COINS",4},{"ESP",5}}
for i,data in ipairs(shortcuts) do
    local b=hit(quickRow,data[1],UDim2.new((i-1)/4,3,0,3),UDim2.new(.25,-6,0,43),C.card,9)
    edge(b,C.line,1,.25)
    b.TextSize=11
    animateButton(b)
    bind(b.Activated,function() changeTab(data[2]) end)
end
local overview=section(home,"SOBRE ESTA BUILD","Efeitos, sons e controles sem bibliotecas externas")
sectionLabel(overview,"VISUAL NATIVO ROBLOX","Avatar, brilhos, partículas e formas criadas por Luau")
sectionLabel(overview,"CONTROLES DE JOGO","Algumas ações dependem de objetos disponíveis no mapa")

-- PLAYER
local playerPage=newPage(2,"PLAYER","MOVIMENTAÇÃO E CONTROLES LOCAIS")
local movement=section(playerPage,"MOVEMENT","Ajustes do Humanoid local")
local _,setSpeedSlider=slider(movement,"Walk Speed",16,100,"speed","",function() applyMovement() end)
local _,setJumpSlider=slider(movement,"Jump Power",50,160,"jump","",function() applyMovement() end)
switch(movement,"Infinite Jump","Permite novos saltos pelo input local","infiniteJump")
switch(movement,"Noclip","Altera colisões locais enquanto habilitado","noclip",function(on)
    if not on then restoreCollisions() end
end)
action(movement,"RESTAURAR SPEED / JUMP",function()
    setSpeedSlider(16,true)
    setJumpSlider(50,true)
    notify("Valores padrão aplicados ao personagem")
end)
local cameraSection=section(playerPage,"CÂMERA","Ajustes locais de visualização")
slider(cameraSection,"Field of View",70,120,"fov","°",function(v)
    local cam=Workspace.CurrentCamera
    if cam then cam.FieldOfView=v end
end)
action(cameraSection,"VOLTAR CÂMERA AO PERSONAGEM",function()
    local _,hum=characterParts()
    if hum and Workspace.CurrentCamera then
        Workspace.CurrentCamera.CameraSubject=hum
        Workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
        notify("Câmera restaurada")
    end
end)

-- ASSASSIN / ROLE OBSERVATION
local assassin=newPage(3,"ASSASSIN","INSPEÇÃO DE FERRAMENTAS VISÍVEIS")
local roleBox=section(assassin,"ROLE SCANNER","Inferência por Knife/Gun visíveis, não é confirmação do servidor")
local murdererLabel,murdererValue=sectionLabel(roleBox,"POSSÍVEL ASSASSINO","Aguardando leitura...")
local sheriffLabel,sheriffValue=sectionLabel(roleBox,"POSSÍVEL XERIFE","Aguardando leitura...")
local function updateRoles()
    local murderer,sheriff="Não encontrado","Não encontrado"
    for _,p in ipairs(Players:GetPlayers()) do
        local role=roleOf(p)
        if role=="POSSÍVEL ASSASSINO" then murderer=p.DisplayName end
        if role=="POSSÍVEL XERIFE" then sheriff=p.DisplayName end
    end
    murdererValue.Text="Jogador: "..murderer
    sheriffValue.Text="Jogador: "..sheriff
end
action(roleBox,"ATUALIZAR LEITURA",function() updateRoles() notify("Leitura visual atualizada") end,true)
switch(roleBox,"Atualização automática","Atualiza os papéis inferidos periodicamente","roleWatch",function(on)
    if not on then return end
    task.spawn(function()
        while alive and settings.roleWatch do updateRoles() task.wait(2) end
    end)
end)
local spectate=section(assassin,"SPECTATE","Troca a câmera para um jogador encontrado")
local selectedName,selectedValue=sectionLabel(spectate,"ALVO","Nenhum jogador selecionado")
action(spectate,"SELECIONAR PRÓXIMO JOGADOR",function()
    local list=Players:GetPlayers()
    local targets={}
    for _,p in ipairs(list) do if p~=localPlayer then table.insert(targets,p) end end
    if #targets==0 then notify("Nenhum outro jogador disponível",C.gold) return end
    local index=1
    for i,p in ipairs(targets) do if p==selectedPlayer then index=i%#targets+1 end end
    selectedPlayer=targets[index]
    selectedValue.Text=selectedPlayer.DisplayName
end)
action(spectate,"ASSISTIR JOGADOR SELECIONADO",function()
    local hum=selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum and Workspace.CurrentCamera then
        Workspace.CurrentCamera.CameraSubject=hum
        notify("Assistindo: "..selectedPlayer.DisplayName)
    else notify("Selecione um jogador com personagem ativo",C.gold) end
end,true)
updateRoles()

-- AUTO COINS
local coins=newPage(4,"AUTO COINS","BUSCA DE MOEDAS E MOVIMENTO PELO MAPA")
local coinPanel=section(coins,"COIN DETECTOR","Procura BaseParts cujo nome contém 'coin'")
coinScanInfo,coinInfoText=sectionLabel(coinPanel,"ESTADO DA BUSCA","Clique em Escanear para começar")
switch(coinPanel,"Auto Walk Coins","Move o personagem até moedas próximas detectadas","autoCoins",function(on)
    if on then beginCoins() notify("Auto Walk Coins ativado",C.green)
    else stopCoins() notify("Auto Walk Coins desativado") end
end)
action(coinPanel,"ESCANEAR MOEDAS VISÍVEIS",function()
    local count=#findCoins()
    coinInfoText.Text="Moedas encontradas: "..count
    notify("Objetos de moeda detectados: "..count)
end,true)
sectionLabel(coinPanel,"ALCANCE: 140 STUDS","A coleta real depende das regras do servidor")

-- ESP
local espPage=newPage(5,"ESP","MARCADORES VISUAIS DE PERSONAGENS")
local espSection=section(espPage,"PLAYER HIGHLIGHTS","Outline, nome e distância aproximada")
switch(espSection,"Ativar ESP","Usa Highlight local em outros personagens","esp",updateMarkers)
switch(espSection,"Mostrar distância","Exibe etiqueta com nome e distância","showDistance",updateMarkers)
switch(espSection,"Cores por ferramenta","Vermelho para Knife e azul para Gun visível","highlightRoles",updateMarkers)
action(espSection,"ATUALIZAR MARCADORES",function() updateMarkers() notify("Marcadores atualizados") end)

-- TELEPORTS
local teleports=newPage(6,"TELEPORTS","ATALHOS LOCAIS DE MOVIMENTAÇÃO")
local tpSection=section(teleports,"DESTINOS","Dependem de partes replicadas no Workspace")
action(tpSection,"IR PARA LOBBY / SPAWN",function()
    local _,_,root=characterParts()
    if not root then notify("Personagem indisponível",C.gold) return end
    local target=nil
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj:IsA("SpawnLocation")
            or obj.Name=="LobbySpawn" or obj.Name=="Lobby") then
            target=obj
            break
        end
    end
    if target then
        root.CFrame=target.CFrame+Vector3.new(0,4,0)
        notify("Destino local aplicado: "..target.Name,C.green)
    else notify("Spawn do lobby não encontrado",C.gold) end
end,true)
action(tpSection,"IR PARA JOGADOR SELECIONADO",function()
    local _,_,root=characterParts()
    local other=selectedPlayer and selectedPlayer.Character
        and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and other then
        root.CFrame=other.CFrame*CFrame.new(3,0,0)
        notify("Movimento aplicado para "..selectedPlayer.DisplayName)
    else notify("Selecione um jogador na aba Assassin",C.gold) end
end)

-- VISUALS
local visuals=newPage(7,"VISUALS","PERSONALIZAÇÃO E EFEITOS DA INTERFACE")
local visualBox=section(visuals,"AJ RED ENGINE","Luzes e animações geradas por Luau")
switch(visualBox,"Partículas de neon","Pontos decorativos discretos na janela","particles")
switch(visualBox,"Animações suaves","Transições, escala e resposta dos botões","animation")
slider(visualBox,"FOV da câmera",70,120,"fov","°",function(v)
    local cam=Workspace.CurrentCamera
    if cam then cam.FieldOfView=v end
end)
sectionLabel(visualBox,"PALETA AJ SCRIPTS","Charcoal / Crimson / Metallic White")

-- MISC
local misc=newPage(8,"MISC","AJUSTES ADICIONAIS")
local miscBox=section(misc,"UTILITY","Controles opcionais")
switch(miscBox,"Anti-AFK","Envia interação local quando o jogador fica inativo","antiAfk",setAntiAfk)
action(miscBox,"RESTABELECER CÂMERA",function()
    local _,hum=characterParts()
    local cam=Workspace.CurrentCamera
    if cam and hum then cam.CameraSubject=hum cam.CameraType=Enum.CameraType.Custom end
    notify("Câmera restaurada")
end)
sectionLabel(miscBox,"SEM REMOTES PRIVADOS","Recursos do jogo podem mudar entre versões")

-- SETTINGS
local options=newPage(9,"SETTINGS","SOM, NAVEGAÇÃO E CONTROLES")
local settingsBox=section(options,"AUDIO & INTERFACE","Personalize feedback visual e sonoro")
switch(settingsBox,"Sons de clique","Usa sons locais do pacote Roblox","sound",function(on)
    soundToggle.Text=on and "◖))" or "MUTE"
    if on then play("open") end
end)
slider(settingsBox,"Volume dos efeitos",0,100,"volumePercent","%",function(v)
    settings.volume=v/100
end)
switch(settingsBox,"Efeitos e partículas","Detalhes luminosos animados","particles")
switch(settingsBox,"Transições animadas","Troca de página e abertura","animation")
action(settingsBox,"RESETAR AJUSTES DE PERSONAGEM",function()
    setSpeedSlider(16,true) setJumpSlider(50,true) settings.fov=70
    settings.noclip=false settings.infiniteJump=false
    restoreCollisions() applyMovement()
    if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=70 end
    notify("Ajustes de personagem restaurados",C.green)
end)
sectionLabel(settingsBox,"ATALHOS","Right Shift abre/fecha; o botão AJ funciona no celular")

changeTab=function(i)
    if i==current then return end
    local previous=pages[current]
    if previous then previous.Visible=false end
    current=i
    for index,entry in ipairs(tabs) do
        local active=index==i
        tween(entry.button,.16,{BackgroundColor3=active and C.red2 or C.surface})
        tween(entry.label,.16,{TextColor3=active and C.white or C.muted})
        tween(entry.icon,.16,{TextColor3=active and C.pale or C.red})
    end
    local page=pages[i]
    if page then
        page.Visible=true
        page.GroupTransparency=1
        page.Position=UDim2.fromOffset(12,0)
        tween(page,.23,{Position=UDim2.fromOffset(0,0),GroupTransparency=0})
    end
    play("page")
end
local visible=true
local openSeq=0
local function setVisible(on)
    if on==visible then return end
    visible=on
    openSeq=openSeq+1
    local serial=openSeq
    if on then
        window.Visible=true
        shadow.Visible=true
        window.GroupTransparency=1
        uiScale.Scale=math.max(.28,uiScale.Scale*.95)
        fit()
        tween(window,.26,{GroupTransparency=0})
        play("open")
    else
        local a=tween(window,.18,{GroupTransparency=1})
        a.Completed:Once(function()
            if alive and not visible and serial==openSeq then
                window.Visible=false shadow.Visible=false
            end
        end)
    end
end
bind(launcher.Activated,function() setVisible(not visible) end)
bind(collapse.Activated,function() setVisible(false) end)
bind(close.Activated,function() setVisible(false) end)
bind(soundToggle.Activated,function()
    settings.sound=not settings.sound
    soundToggle.Text=settings.sound and "◖))" or "MUTE"
    for _,redraw in ipairs(switchRefresh.sound or {}) do redraw() end
    if settings.sound then play("open") end
end)
bind(UserInputService.InputBegan,function(event,processed)
    if not processed and event.KeyCode==Enum.KeyCode.RightShift then
        setVisible(not visible)
    end
end)

-- Drag com mouse e toque.
local activeDrag,dragOrigin,windowOrigin
bind(header.InputBegan,function(event)
    if event.UserInputType==Enum.UserInputType.MouseButton1
        or event.UserInputType==Enum.UserInputType.Touch then
        activeDrag=event
        dragOrigin=event.Position
        windowOrigin=window.Position
    end
end)
bind(UserInputService.InputChanged,function(event)
    if not activeDrag then return end
    if event==activeDrag or (activeDrag.UserInputType==Enum.UserInputType.MouseButton1
        and event.UserInputType==Enum.UserInputType.MouseMovement) then
        local delta=event.Position-dragOrigin
        window.Position=UDim2.new(windowOrigin.X.Scale,windowOrigin.X.Offset+delta.X,
            windowOrigin.Y.Scale,windowOrigin.Y.Offset+delta.Y)
        shadow.Position=window.Position
    end
end)
bind(UserInputService.InputEnded,function(event)
    if event==activeDrag then activeDrag=nil end
end)

-- Brilho pulsante e partículas leves, sem manipulação do cenário.
task.spawn(function()
    while alive and gui.Parent do
        if settings.particles and visible then
            local spark=round(frame(window,UDim2.fromOffset(
                math.random(3,W-8),math.random(4,H-10)),
                UDim2.fromOffset(3,3),math.random(1,3)==1 and C.pale or C.red,2),2)
            spark.ZIndex=8
            spark.BackgroundTransparency=.1
            tween(spark,.9,{Position=spark.Position+UDim2.fromOffset(0,-24),BackgroundTransparency=1},
                Enum.EasingStyle.Sine)
            task.delay(.95,function() if spark.Parent then spark:Destroy() end end)
        end
        task.wait(.28)
    end
end)
task.spawn(function()
    while alive and gui.Parent do
        tween(glowStroke,1.2,{Transparency=.78},Enum.EasingStyle.Sine)
        for i,b in ipairs(bars) do
            tween(b,.24,{Size=UDim2.fromOffset(3,4+math.random(5,22))},Enum.EasingStyle.Sine)
        end
        task.wait(1.2)
        tween(glowStroke,1.2,{Transparency=.28},Enum.EasingStyle.Sine)
        task.wait(1.2)
    end
end)

-- Atualização visual periódica, apenas quando o ESP está ligado.
task.spawn(function()
    while alive and gui.Parent do
        if settings.esp then updateMarkers() end
        task.wait(1.5)
    end
end)

-- Limpeza para evitar duplicação de conexões após reinjetar.
bind(gui.Destroying,function()
    alive=false
    settings.autoCoins=false
    settings.esp=false
    settings.noclip=false
    settings.roleWatch=false
    restoreCollisions()
    clearMarkers()
    stopCoins()
    for _,con in ipairs(connections) do
        if con.Connected then con:Disconnect() end
    end
end)
applyMovement()
window.GroupTransparency=1
uiScale.Scale=uiScale.Scale*.96
fit()
tween(window,.36,{GroupTransparency=0})
notify("AJ SCRIPTS  •  UI CARREGADA",C.green)
