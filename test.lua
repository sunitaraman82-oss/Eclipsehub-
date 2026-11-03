-- This file was generated at discord.gg/syncrypt

local t1 = {}
local unpack_ = unpack or table.unpack

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local t2 = {
	value1 = game:GetService("Players"),
	value2 = game:GetService("Workspace"),
	value3 = game:GetService("ReplicatedStorage")
}
local RunService = game:GetService("RunService")

game:GetService("UserInputService")
t2.value4 = t2.value1.LocalPlayer

while not t2.value4 do
	task.wait()
	t2.value4 = t2.value1.LocalPlayer
end

t2.value5 = t2.value2.CurrentCamera

while not t2.value5 do
	t2.value2:GetPropertyChangedSignal("CurrentCamera"):Wait()
	t2.value5 = t2.value2.CurrentCamera
end

t2.value6 = nil
t2.value6 = "https://raw.githubusercontent.com/rayware/SerpentUI/refs/heads/main/ui"

local t3 = { pcall(function()
		local response = game:HttpGet(t2.value6, true)
		local chunk, v8 = loadstring(response)
		local v9 = "Cannot compile SerpentUI: " .. tostring(v8)

		assert(chunk, v9)

		return chunk({
			Demo = false
		})
	end) }
local v10 = t3[2]

if not t3[1] then
	error("[SerpentHub | RIVALS] SerpentUI failed to load: " .. tostring(v10), 0)
end

local assert_ = assert
local v12 = type(v10) == "table"

if v12 then
	local CreateWindow = v10.CreateWindow

	v12 = type(CreateWindow) == "function"
end

assert_(v12, "[SerpentHub | RIVALS] SerpentUI did not return CreateWindow.")

local v14 = v10:CreateWindow({
	Id = "SerpentHub_RIVALS",
	Title = "SerpentHub",
	Subtitle = "Rivals Script",
	Theme = "Default",
	Width = 650,
	Height = 460
})
local value1 = t1.value1
local value12 = t1.value1
local getgenv_ = getgenv

if getgenv_ then
	getgenv_ = getgenv()
end

t1.value1 = value1
t2.value7 = getgenv_ or _G

if t2.value7.__SERPENT_RIVALS_RENDER then
	pcall(function()
		t2.value7.__SERPENT_RIVALS_RENDER:Disconnect()
	end)
	t2.value7.__SERPENT_RIVALS_RENDER = nil
end

if t2.value7.__SERPENT_RIVALS_FOV_DRAWING then
	pcall(function()
		t2.value7.__SERPENT_RIVALS_FOV_DRAWING:Remove()
	end)
	t2.value7.__SERPENT_RIVALS_FOV_DRAWING = nil
end

if t2.value7.__SERPENT_RIVALS_FOV_GUI then
	pcall(function()
		t2.value7.__SERPENT_RIVALS_FOV_GUI:Destroy()
	end)
	t2.value7.__SERPENT_RIVALS_FOV_GUI = nil
end

t2.value8 = t2.value7.__SERPENT_RIVALS_STATE or {}
t2.value7.__SERPENT_RIVALS_STATE = t2.value8
t2.value8.Enabled = false
t2.value8.FOV = 150
t2.value8.MaxAngle = 30
t2.value8.TeamCheck = true
t2.value8.HitParts = { "Head", "UpperTorso", "HumanoidRootPart" }
t2.value8.Prediction = 0.06
t2.value8.ShowFOV = true
t2.value8.TargetRate = 0.05
t2.value8.CacheRate = 1
t2.value8.Cached = {}
t2.value8.LastCache = 0
t2.value8.LastTarget = nil
t2.value8.LastPart = nil
t2.value8.LastScan = 0
t2.value8.Locked = false
t2.value8.Shot = nil

local Remotes = t2.value3:FindFirstChild("Remotes") or t2.value3:WaitForChild("Remotes", 10)

t1.value1 = value12

local value13 = t1.value1

if Remotes then
	local value14 = t1.value1

	Remotes = Remotes:FindFirstChild("Replication") or Remotes:WaitForChild("Replication", 10)
	t1.value1 = value14
end

t1.value1 = value13

local value14 = t1.value1

if Remotes then
	local value15 = t1.value1

	Remotes = Remotes:FindFirstChild("Fighter") or Remotes:WaitForChild("Fighter", 10)
	t1.value1 = value15
end

t1.value1 = value14

local value15 = t1.value1
local UpdateState

if Remotes then
	local value16 = t1.value1

	UpdateState = Remotes.FindFirstChild(Remotes, "UpdateState") or Remotes:WaitForChild("UpdateState", 10)
	t1.value1 = value16
else
	UpdateState = Remotes
end

t1.value1 = value15

local value16 = t1.value1

if Remotes then
	local value17 = t1.value1

	Remotes = Remotes:FindFirstChild("UpdateCameraRotation") or Remotes:WaitForChild("UpdateCameraRotation", 10)
	t1.value1 = value17
end

t1.value1 = value16

if not (UpdateState and Remotes) then
	v14:AddSection({
		Name = "RIVALS"
	})
	v14:AddLabel({
		Text = "RIVALS remotes were not found. Join a match and execute the script again.",
		Height = 60
	})
	v14:Notify("RIVALS remotes not found", 6)

	return
end

local Utility = nil

local function v29()
	Utility = require(t2.value3.Modules.Utility)
end

pcall(v29)

local v30 = utf8.char(0)
local v31 = utf8.char(1)
local v32 = utf8.char(2)
local v33 = utf8.char(3)
local v34 = utf8.char(4)
local v35 = utf8.char(5)
local v36 = nil

local function v37(p1)
	local v38, v39, v40 = p1:ToOrientation()

	return {
		[v30] = p1.X,
		[v31] = p1.Y,
		[v32] = p1.Z,
		[v33] = v38,
		[v34] = v39,
		[v36] = v40
	}
end
local function v41(p2)
	local value2 = t2.value2
	local cFrame = CFrame.new((value2.CurrentCamera or t2.value5).CFrame.Position, p2)
	local v44, v45 = cFrame.ToOrientation(cFrame)
	local v46 = Utility

	if v46 then
		local EncodeCameraRotation = Utility.EncodeCameraRotation

		v46 = type(EncodeCameraRotation) == "function"
	end

	if v46 then
		local function v48()
			return Utility:EncodeCameraRotation(unpack_({ Vector2.new(v44, v45) }))
		end

		local ok, result = pcall(v48)

		if ok and result then
			return result
		end
	end

	local function v51(p3)
		local char = utf8.char
		local clamp = math.clamp
		local v54 = p3 % 6.2831853 / 6.2831853 * 256 + 0.5

		return char((clamp(math.floor(v54), 0, 255)))
	end

	return v51(v44) .. v51(v45)
end

local Circle = nil

v36 = v35

local function v56()
	local Drawing_ = Drawing

	if Drawing_ then
		Drawing_ = Drawing.new
	end

	if not Drawing_ then
		return
	end

	Circle = Drawing.new("Circle")
	Circle.Color = Color3.fromRGB(125, 125, 140)
	Circle.Thickness = 1
	Circle.NumSides = 64
	Circle.Filled = false
	Circle.Visible = false
	t2.value7.__SERPENT_RIVALS_FOV_DRAWING = Circle
end

Circle = nil

local Frame = nil
local UIStroke = nil

if not (pcall(v56) and Circle) then
	local ScreenGui = Instance.new("ScreenGui")

	ScreenGui.Name = "SerpentHub_RIVALS_FOV"
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ScreenGui.DisplayOrder = 999999

	local u61 = false

	function t1.value2()
		ScreenGui.Parent = t2.value4:WaitForChild("PlayerGui")
		u61 = true
	end

	pcall(t1.value2)

	if u61 then
		Frame = Instance.new("Frame")
		Frame.Name = "Circle"
		t1.value3 = Vector2.new(0.5, 0.5)
		Frame.AnchorPoint = t1.value3
		Frame.BackgroundTransparency = 1
		Frame.Visible = false
		Frame.Parent = ScreenGui
		t1.value2 = Instance.new("UICorner")
		t1.value3 = UDim.new(1, 0)
		t1.value2.CornerRadius = t1.value3
		t1.value2.Parent = Frame
		UIStroke = Instance.new("UIStroke")
		UIStroke.Thickness = 1
		t1.value5 = Color3.fromRGB(125, 125, 140)
		UIStroke.Color = t1.value5
		UIStroke.Parent = Frame

		local value7 = t2.value7

		t1.value4 = ScreenGui
		value7.__SERPENT_RIVALS_FOV_GUI = t1.value4
	else
		ScreenGui:Destroy()
	end
end

local function v63(p4)
	local Enabled = t2.value8.Enabled

	if Enabled then
		Enabled = t2.value8.ShowFOV
	end

	if p4 then
		p4 = Color3.fromRGB(255, 75, 85)
	end

	local color3 = p4 or Color3.fromRGB(125, 125, 140)

	t2.value5 = t2.value2.CurrentCamera or t2.value5

	local ViewportSize = t2.value5.ViewportSize
	local v67 = ViewportSize.X * 0.5
	local v68 = ViewportSize.Y * 0.5

	if Circle then
		Circle.Position = Vector2.new(v67, v68)
		Circle.Radius = t2.value8.FOV
		Circle.Color = color3
		Circle.Visible = Enabled

		return
	end

	if not Frame then
		return
	end

	local v69 = t2.value8.FOV * 2

	Frame.Position = UDim2.fromOffset(v67, v68)
	Frame.Size = UDim2.fromOffset(v69, v69)
	Frame.Visible = Enabled

	if not UIStroke then
		return
	end

	UIStroke.Color = color3
end
local function v70(p5)
	if not t2.value8.TeamCheck then
		return false
	end

	local playerFromCharacter = t2.value1:GetPlayerFromCharacter(p5)

	if not playerFromCharacter then
		return false
	end

	local attribute = t2.value4:GetAttribute("TeamID")
	local attribute2 = playerFromCharacter:GetAttribute("TeamID")
	local v74 = attribute ~= nil

	if v74 then
		v74 = attribute2 ~= nil

		if v74 then
			v74 = attribute == attribute2
		end
	end

	if v74 then
		return true
	end

	local Team = t2.value4.Team

	if Team then
	elseif Team then
		return true
	else
		return false
	end

	Team = playerFromCharacter.Team

	if Team then
	elseif Team then
		return true
	else
		return false
	end

	Team = t2.value4.Team == playerFromCharacter.Team

	if Team then
		return true
	else
		return false
	end
end

t1.value3 = game:GetService("CollectionService")

local value3 = t1.value3

function t1.value4()
	if not (tick() - t2.value8.LastCache < t2.value8.CacheRate) then
		t2.value8.LastCache = tick()
		table.clear(t2.value8.Cached)

		local ipairs_ = ipairs
		local value17 = t2.value1
		local v79, v80, v81 = ipairs_(value17.GetPlayers(value17))

		while true do
			local v82

			v81, v82 = v79(v80, v81)

			if not v81 then
				break
			end

			local v83 = v82 ~= t2.value4

			if v83 then
				v83 = v82.Character

				if v83 then
					v83 = not v70(v82.Character)
				end
			end

			if v83 then
				ipairs_ = table.insert
				ipairs_(t2.value8.Cached, v82.Character)
			end
		end

		local v84 = value3

		for _, v in ipairs(v84.GetTagged(v84, "Entity")) do
			local isModel = v:IsA("Model")

			if isModel then
				if v == t2.value4.Character then
					isModel = false
				else
					isModel = not v70(v)
				end
			end

			if isModel then
				local Cached = t2.value8.Cached

				table.insert(Cached, v)
			end
		end

		local ShootingRangeEntities = t2.value2:FindFirstChild("ShootingRangeEntities")

		if not ShootingRangeEntities then
			return
		end

		for _, child in ipairs(ShootingRangeEntities.GetChildren(ShootingRangeEntities)) do
			if child:IsA("Model") then
				local Cached = t2.value8.Cached

				table.insert(Cached, child)
			end
		end
	end
end

local value4 = t1.value4

t1.value5 = RaycastParams.new()

local value5 = t1.value5

t1.value5 = value5
t1.value7 = Enum.RaycastFilterType.Exclude
t1.value5.FilterType = t1.value7
t1.value5 = value5
t1.value5.IgnoreWater = true

function t1.value7()
	t2.value8.LastTarget = nil
	t2.value8.LastPart = nil
	t2.value8.Locked = false
end
function t1.value6(p6, p7, p8)
	t2.value5 = t2.value2.CurrentCamera or t2.value5
	value5.FilterDescendantsInstances = { t2.value4.Character, t2.value5 }

	local hit = t2.value2:Raycast(p6, p7 - p6, value5)

	if hit then
		local Instance_ = hit.Instance

		return Instance_.IsDescendantOf(Instance_, p8)
	else
		return true
	end
end

local value6 = t1.value6
local value7 = t1.value7

function t1.value8()
	t2.value5 = t2.value2.CurrentCamera or t2.value5
	t2.value5 = t2.value2.CurrentCamera or t2.value5

	local ViewportSize = t2.value5.ViewportSize
	local v100 = ViewportSize.X * 0.5
	local v101 = ViewportSize.Y * 0.5

	if not t2.value8.Enabled then
		value7()
		v63(false)

		return nil, nil
	end

	if tick() - t2.value8.LastScan < t2.value8.TargetRate then
		v63(t2.value8.Locked)

		return t2.value8.LastTarget, t2.value8.LastPart
	end

	t2.value8.LastScan = tick()
	value4()

	local Position = t2.value5.CFrame.Position
	local LookVector = t2.value5.CFrame.LookVector
	local FOV = t2.value8.FOV
	local v105 = nil
	local v106 = nil

	for _, v in ipairs(t2.value8.Cached) do
		local Parent

		if v then
			Parent = v.Parent
		else
			Parent = v
		end

		if Parent then
			local Humanoid = v:FindFirstChildOfClass("Humanoid")

			if Humanoid then
				Humanoid = Humanoid.Health > 0
			end

			if Humanoid then
				for _, hitPart in ipairs(t2.value8.HitParts) do
					local v113 = v:FindFirstChild(hitPart)
					local isBasePart

					if v113 then
						isBasePart = v113:IsA("BasePart")
					else
						isBasePart = v113
					end

					if isBasePart then
						local AssemblyLinearVelocity = v113.AssemblyLinearVelocity
						local v116 = AssemblyLinearVelocity.Magnitude > 2

						if v116 then
							v116 = v113.Position + AssemblyLinearVelocity * t2.value8.Prediction
						end

						local Position2 = v116 or v113.Position
						local v118, v119 = t2.value5:WorldToViewportPoint(Position2)

						if v119 then
							local v120 = v118.X - v100
							local v121 = v118.Y - v101
							local v122 = v120 * v120 + v121 * v121
							local v123 = math.sqrt(v122)

							if v123 < FOV then
								local v124 = LookVector:Dot((Position2 - Position).Unit)
								local MaxAngle = t2.value8.MaxAngle
								local v126 = math.rad(MaxAngle)

								if math.cos(v126) < v124 and value6(Position, Position2, v) then
									v106 = v113
									v105 = Position2
									FOV = v123
								end
							end
						end

						break
					end
				end
			end
		end
	end

	t2.value8.LastTarget = v105
	t2.value8.LastPart = v106
	t2.value8.Locked = v105 ~= nil

	if not v105 then
		v63(t2.value8.Locked)

		return v105, v106
	end

	t2.value8.Shot = {
		Pos = v105,
		T = tick()
	}
	v63(t2.value8.Locked)

	return v105, v106
end

local value8 = t1.value8

t1.value8 = t2.value7
t1.value13 = RunService.RenderStepped

function t1.value11()
	local ok, result = pcall(value8)

	if ok then
		return
	end

	warn("[SerpentHub | RIVALS] Target loop:", result)
end

t1.value10 = t1.value13:Connect(t1.value11)
t1.value8.__SERPENT_RIVALS_RENDER = t1.value10

function t1.value8(p9, p10)
	local oth_ = oth

	if oth_ then
		oth_ = oth.hook

		if oth_ then
			oth_ = oth.get_root_callback
		end
	end

	if oth_ then
		oth.hook(p9.FireServer, function(p11, ...)
			return p10(oth.get_root_callback(), p11, ...)
		end)

		return true
	end

	local hookfunction_ = hookfunction

	if hookfunction_ then
		hookfunction_ = newcclosure
	end

	if not hookfunction_ then
		return false
	end

	local v132 = nil

	local function v133(p12, ...)
		return p10(v132, p12, ...)
	end

	v132 = hookfunction(p9.FireServer, newcclosure(v133))

	return true
end

t1.value10 = t2.value7

if not t1.value10.__SERPENT_RIVALS_HOOKED then
	function t1.value10(p13, p14, p15, ...)
		local __SERPENT_RIVALS_STATE = t2.value7.__SERPENT_RIVALS_STATE

		if not (__SERPENT_RIVALS_STATE and __SERPENT_RIVALS_STATE.Enabled) then
			return p13(p14, p15, ...)
		end

		local Shot = __SERPENT_RIVALS_STATE.Shot
		local v136

		if Shot then
			if tick() - Shot.T < 0.5 then
				v136 = p15 ~= nil
			else
				v136 = false
			end
		else
			v136 = Shot
		end

		if not v136 then
			return p13(p14, p15, ...)
		end

		p15 = v41(Shot.Pos)

		return p13(p14, p15, ...)
	end
	function t1.value13(p16, p17, p18, p19, p20, ...)
		local __SERPENT_RIVALS_STATE = t2.value7.__SERPENT_RIVALS_STATE

		if not (__SERPENT_RIVALS_STATE and __SERPENT_RIVALS_STATE.Enabled) then
			return p16(p17, p18, p19, p20, ...)
		end

		if type(p20) ~= "table" then
			return p16(p17, p18, p19, p20, ...)
		end

		local LastTarget = __SERPENT_RIVALS_STATE.LastTarget
		local LastPart = __SERPENT_RIVALS_STATE.LastPart
		local Parent

		if LastTarget then
			if LastPart then
				Parent = LastPart.Parent
			else
				Parent = LastPart
			end
		else
			Parent = LastTarget
		end

		if not Parent then
			return p16(p17, p18, p19, p20, ...)
		end

		local ok, result = pcall(function()
			return LastPart.CFrame
		end)

		if ok then
			local v143 = v37(result.Inverse(result) * CFrame.new(LastTarget))
			local v144 = table.clone(p20)

			for k, v in pairs(v144) do
				local v147 = type(v) == "table"

				if v147 then
					v147 = v[v32] ~= nil
				end

				if v147 then
					local v148 = table.clone(v)

					v148[v32] = LastPart
					v148[v33] = v143
					v144[k] = v148
				end
			end

			return p16(p17, p18, p19, v144, ...)
		else
			return p16(p17, p18, p19, p20, ...)
		end
	end

	t1.value9 = t1.value8(UpdateState, t1.value13)
	t1.value13 = t1.value8(Remotes, t1.value10)
	t1.value10 = t2.value7

	local value9 = t1.value9
	local value17 = t1.value1

	t1.value12 = value9
	t1.value14 = value17

	local value92 = t1.value9

	if value92 then
		value92 = t1.value13
	end

	t1.value12 = value92
	t1.value10.__SERPENT_RIVALS_HOOKED = t1.value12
	t1.value12 = t2.value7

	if not t1.value12.__SERPENT_RIVALS_HOOKED then
		warn("[SerpentHub | RIVALS] Executor does not expose a supported hook API.")
	end
end

t1.value10 = "Instance"
t1.value16 = 10160464695931
t1.value13 = Instance
t1.value16 = 27294883328422
t1.value15 = "qO\165\226\164S"
t1.value13 = t1.value13.new("Folder")

local value132 = t1.value13

t1.value13 = value132
t1.value16 = 10146448527988
t1.value17 = 11598249547032
t1.value13.Name = "SerpentHub_RIVALS_ESP"
t1.value13 = value132
t1.value16 = 6676269157412
t1.value15 = "\20\160\235\192\161\196"
t1.value11 = t2.value2
t1.value13.Parent = t1.value11

local enabled = false
local t4 = {}

t1.value13 = Color3.fromRGB
t1.value14 = 255
t1.value15 = 72
t1.value16 = 72
t1.value12 = t1.value13(t1.value14, t1.value15, t1.value16)
t1.value15 = "Color3"

local value122 = t1.value12

t1.value12 = Color3.fromRGB
t1.value16 = 215
t1.value15 = 255
t1.value17 = 70
t1.value14 = t1.value12(t1.value15, t1.value16, t1.value17)

local value142 = t1.value14

function t1.value15(p21)
	if p21 == t2.value4 then
		return true
	end

	local attribute = t2.value4:GetAttribute("TeamID")
	local attribute2 = p21:GetAttribute("TeamID")
	local v159 = attribute ~= nil

	if v159 then
		v159 = attribute2 ~= nil
	end

	if v159 then
		return attribute == attribute2
	end

	local v160

	if t2.value4.Team == nil then
		v160 = false
	else
		v160 = p21.Team ~= nil
	end

	if v160 then
		return t2.value4.Team == p21.Team
	end

	local TeamColor = t2.value4.TeamColor

	if TeamColor then
	elseif TeamColor then
		return t2.value4.TeamColor == p21.TeamColor
	else
		return false
	end

	TeamColor = p21.TeamColor

	if TeamColor then
		return t2.value4.TeamColor == p21.TeamColor
	else
		return false
	end
end

local value152 = t1.value15

local function v163(player)
	local v164 = t4[player]

	if not v164 then
		return
	end

	if v164.Highlight then
		pcall(function()
			v164.Highlight:Destroy()
		end)
	end

	if not v164.Billboard then
		t4[player] = nil

		return
	end

	pcall(function()
		v164.Billboard:Destroy()
	end)
	t4[player] = nil
end

local value17 = nil

local function v166()
	local ipairs_ = ipairs
	local value18 = t2.value1

	for _, player in ipairs_(value18.GetPlayers(value18)) do
		if player ~= t2.value4 then
			local v171 = t4[player]

			if enabled then
				local v172

				if not v171 or v171.Character ~= player.Character then
					value17(player)
					v171 = t4[player]
					v172 = v171
				else
					v172 = v171
				end

				if v171 then
					local v173 = value152(player)

					if v173 then
						v173 = value142
					end

					local v174 = v173 or value122

					v171.Highlight.FillColor = v174
					v171.Highlight.OutlineColor = v174
					v171.Highlight.Enabled = true
					v171.Billboard.Enabled = true
					v171.Label.TextColor3 = v174
					v171.Label.Text = player.DisplayName
				end
			elseif v171 then
				v171.Highlight.Enabled = false
				v171.Billboard.Enabled = false
			end
		end
	end
end

function t1.value17(p22)
	if p22 ~= t2.value4 then
		v163(p22)

		local Character = p22.Character

		if Character then
			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart") or (Character:FindFirstChild("Head") or Character:FindFirstChildWhichIsA("BasePart"))

			if HumanoidRootPart then
				local v177 = value152(p22) and value142 or value122
				local Highlight = Instance.new("Highlight")

				Highlight.Name = "SerpentPlayerESP"
				Highlight.Adornee = Character
				Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				Highlight.FillColor = v177
				Highlight.OutlineColor = v177
				Highlight.FillTransparency = 0.78
				Highlight.OutlineTransparency = 0.05
				Highlight.Enabled = enabled
				Highlight.Parent = value132

				local BillboardGui = Instance.new("BillboardGui")

				BillboardGui.Name = "SerpentPlayerLabel"
				BillboardGui.Adornee = HumanoidRootPart
				BillboardGui.AlwaysOnTop = true
				BillboardGui.Size = UDim2.fromOffset(180, 30)
				BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 3.2, 0)
				BillboardGui.MaxDistance = 2000
				BillboardGui.Enabled = enabled
				BillboardGui.Parent = value132

				local TextLabel = Instance.new("TextLabel")

				TextLabel.Size = UDim2.fromScale(1, 1)
				TextLabel.BackgroundTransparency = 1
				TextLabel.Font = Enum.Font.GothamBold
				TextLabel.TextSize = 12
				TextLabel.TextColor3 = v177
				TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				TextLabel.TextStrokeTransparency = 0.25
				TextLabel.Text = p22.DisplayName
				TextLabel.Parent = BillboardGui
				t4[p22] = {
					Highlight = Highlight,
					Billboard = BillboardGui,
					Label = TextLabel,
					Character = Character
				}

				return
			else
				return
			end
		else
			return
		end
	end
end

value17 = t1.value17

local ipairs_ = ipairs
local value18 = t2.value1
local v183 = value17
local u184 = enabled

for _, player in ipairs_(value18.GetPlayers(value18)) do
	if player ~= t2.value4 then
		t1.value20 = player.CharacterAdded

		function t1.value19()
			task.wait(0.5)

			if not u184 then
				return
			end

			v183(player)
		end

		t1.value20:Connect(t1.value19)
	end
end

t2.value1.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5)

		if not u184 then
			return
		end

		v183(player)
	end)
end)
t2.value1.PlayerRemoving:Connect(v163)
RunService.RenderStepped:Connect(function()
	local v187 = u184

	if v187 then
		v187 = os.clock() - 0 >= 0.35
	end

	if not v187 then
		return
	end

	os.clock()
	v166()
end)
v14.AddSection(v14, {
	Name = "Aim"
})

local AddToggle = v14.AddToggle

function t1.value18(p23)
	t2.value8.Enabled = p23

	if p23 then
		return
	end

	value7()
	t2.value8.Shot = nil
end

AddToggle(v14, {
	Name = "Silent Aim",
	Default = false,
	Callback = t1.value18
})

function t1.value18(p24)
	t2.value8.ShowFOV = p24
end

v14:AddToggle({
	Name = "Show FOV",
	Default = true,
	Callback = t1.value18
})

local AddSlider = v14.AddSlider

function t1.value21(p25)
	t2.value8.FOV = p25
end

AddSlider(v14, {
	Name = "FOV",
	Min = 25,
	Max = 500,
	Default = 150,
	Step = 5,
	Callback = t1.value21
})

local AddToggle2 = v14.AddToggle

function t1.value18(p26)
	t2.value8.TeamCheck = p26
	t2.value8.LastCache = 0
end

AddToggle2(v14, {
	Name = "Team Check",
	Default = true,
	Callback = t1.value18
})
v14:AddSection({
	Name = "Visuals"
})

function t1.value18(p27)
	u184 = p27

	if p27 then
		v166()
	else
		for _, v in pairs(t4) do
			if v.Highlight then
				v.Highlight.Enabled = false
			end

			if v.Billboard then
				v.Billboard.Enabled = false
			end
		end
	end
end

local t5 = {
	Name = "Player ESP",
	Default = false,
	Callback = t1.value18
}

v14.AddToggle(v14, t5)
v14:AddSection({
	Name = "Targeting"
})

local AddSlider2 = v14.AddSlider

function t1.value21(p28)
	t2.value8.Prediction = p28 / 100
end

AddSlider2(v14, {
	Name = "Prediction",
	Min = 0,
	Max = 20,
	Default = 6,
	Step = 1,
	Callback = t1.value21
})

local AddSlider3 = v14.AddSlider

function t1.value21(p29)
	t2.value8.MaxAngle = p29
end

AddSlider3(v14, {
	Name = "Max Angle",
	Min = 5,
	Max = 90,
	Default = 30,
	Step = 5,
	Callback = t1.value21
})
v14.AddLabel(v14, {
	Tab = "Settings",
	Text = "SerpentHub · RIVALS\nSilent Aim + FOV\nby rayware",
	Height = 70
})

if t2.value7.__SERPENT_RIVALS_HOOKED then
	v14:Notify("RIVALS Script loaded", 4)
else
	v14:Notify("Loaded, but remote hooks are unsupported by this executor", 7)
end
