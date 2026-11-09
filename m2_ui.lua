
local P=game:GetService("Players")
local T=game:GetService("TweenService")
local U=game:GetService("UserInputService")
local lp=P.LocalPlayer
local parent=lp:WaitForChild("PlayerGui")
pcall(function() parent=gethui() or parent end)
local old=parent:FindFirstChild("MM2SpecialUI")
if old then old:Destroy() end

local bg=Color3.fromRGB(14,14,20)
local panel=Color3.fromRGB(25,25,35)
local red=Color3.fromRGB(230,57,70)
local white=Color3.fromRGB(236,236,246)
local gray=Color3.fromRGB(150,150,170)

local function new(c,p,props,r)
 local o=Instance.new(c)
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=p
 if r then
  local a=Instance.new("UICorner",o)
  a.CornerRadius=UDim.new(0,r)
 end
 return o
end

local function text(p,s,pos,size,color)
 return new("TextLabel",p,{
  Text=s,Position=pos,Size=size,
  BackgroundTransparency=1,
  TextColor3=color or white,
  Font=Enum.Font.GothamBold,
  TextSize=13
 })
end

local function btn(p,s,pos,size)
 return new("TextButton",p,{
  Text=s,Position=pos,Size=size,
  BackgroundColor3=panel,
  TextColor3=white,
  Font=Enum.Font.GothamBold,
  TextSize=13,BorderSizePixel=0
 },9)
end

local gui=new("ScreenGui",parent,{
 Name="MM2SpecialUI",ResetOnSpawn=false,
 IgnoreGuiInset=true
})

local open=btn(gui,"M",UDim2.new(0,15,.5,-23),UDim2.fromOffset(46,46))
open.BackgroundColor3=red

local win=new("CanvasGroup",gui,{
 Size=UDim2.fromOffset(440,310),
 Position=UDim2.new(.5,-220,.5,-155),
 BackgroundColor3=bg,
 BorderSizePixel=0
},12)

local scale=new("UIScale",win,{Scale=1})
local top=new("Frame",win,{
 Size=UDim2.new(1,0,0,42),
 BackgroundColor3=panel,
 BorderSizePixel=0
},10)

text(top,"◆ MM2 SPECIAL UI",UDim2.fromOffset(12,0),UDim2.fromOffset(230,42))
local close=btn(top,"X",UDim2.new(1,-37,0,7),UDim2.fromOffset(28,28))

local side=new("Frame",win,{
 Position=UDim2.fromOffset(0,43),
 Size=UDim2.new(0,110,1,-43),
 BackgroundColor3=panel,
 BorderSizePixel=0
})

local pages={}
local buttons={}
local names={"Início","Visual","Sobre"}

for i,name in ipairs(names) do
 local b=btn(side,name,UDim2.fromOffset(7,8+(i-1)*45),UDim2.new(1,-14,0,37))
 buttons[i]=b
 pages[i]=new("Frame",win,{
  Position=UDim2.fromOffset(110,43),
  Size=UDim2.new(1,-110,1,-43),
  BackgroundTransparency=1,
  Visible=i==1
 })
 b.MouseButton1Click:Connect(function()
  for j,page in ipairs(pages) do
   page.Visible=i==j
   buttons[j].BackgroundColor3=i==j and red or panel
  end
 end)
end
buttons[1].BackgroundColor3=red

local home=pages[1]
local avatar=new("ImageLabel",home,{
 Position=UDim2.fromOffset(15,18),
 Size=UDim2.fromOffset(68,68),
 BackgroundColor3=panel,
 Image=""
},34)

task.spawn(function()
 local ok,url=pcall(function()
  return P:GetUserThumbnailAsync(lp.UserId,
   Enum.ThumbnailType.HeadShot,
   Enum.ThumbnailSize.Size150x150)
 end)
 if ok and avatar.Parent then avatar.Image=url end
end)

text(home,lp.DisplayName,UDim2.fromOffset(94,23),UDim2.new(1,-105,0,25))
text(home,"@"..lp.Name,UDim2.fromOffset(94,50),UDim2.new(1,-105,0,22),gray)
text(home,"STATUS: READY",UDim2.fromOffset(15,115),UDim2.fromOffset(270,30),red)
text(home,"EXECUTOR: DELTA",UDim2.fromOffset(15,150),UDim2.fromOffset(270,30))
text(home,"BUILD: 1.0",UDim2.fromOffset(15,185),UDim2.fromOffset(270,30),gray)

local visual=pages[2]
for i,name in ipairs({
 "Modo escuro reforçado",
 "Efeitos de blur",
 "Sons de interface",
 "Animação de abertura"
}) do
 local b=btn(visual,name.."  ○",
  UDim2.fromOffset(12,12+(i-1)*53),
  UDim2.new(1,-24,0,43))
 local enabled=i==1 or i==3 or i==4
 local function update()
  b.Text=name..(enabled and "  ●" or "  ○")
  b.BackgroundColor3=enabled and Color3.fromRGB(65,32,43) or panel
 end
 b.MouseButton1Click:Connect(function()
  enabled=not enabled
  update()
 end)
 update()
end

text(pages[3],"MM2 SPECIAL UI",UDim2.fromOffset(15,20),UDim2.new(1,-30,0,35),red)
local about=text(pages[3],
 "Interface visual\nVersão 1.0\nCompatível com toque\nSem funções de jogo",
 UDim2.fromOffset(15,65),UDim2.new(1,-30,0,140),gray)
about.TextWrapped=true
about.TextYAlignment=Enum.TextYAlignment.Top

local visible=true
local function toggle()
 visible=not visible
 if visible then win.Visible=true end
 T:Create(win,TweenInfo.new(.2),{
  GroupTransparency=visible and 0 or 1
 }):Play()
 T:Create(scale,TweenInfo.new(.2),{
  Scale=visible and 1 or .9
 }):Play()
 if not visible then
  task.delay(.21,function()
   if not visible then win.Visible=false end
  end)
 end
end
open.MouseButton1Click:Connect(toggle)
close.MouseButton1Click:Connect(toggle)

local dragging,start,origin
top.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.MouseButton1
 or input.UserInputType==Enum.UserInputType.Touch then
  dragging=input
  start=input.Position
  origin=win.Position
 end
end)
U.InputChanged:Connect(function(input)
 if dragging and (input==dragging or
  input.UserInputType==Enum.UserInputType.MouseMovement
  and dragging.UserInputType==Enum.UserInputType.MouseButton1) then
  local d=input.Position-start
  win.Position=UDim2.new(
   origin.X.Scale,origin.X.Offset+d.X,
   origin.Y.Scale,origin.Y.Offset+d.Y)
 end
end)
U.InputEnded:Connect(function(input)
 if input==dragging then dragging=nil end
end)
