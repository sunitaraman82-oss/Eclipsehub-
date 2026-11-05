local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Options = Library.Options
local Toggles = Library.Toggles
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
Library.IsMobile = isMobile
Library.ShowCustomCursor = false
Library.ShowToggleFrameInKeybinds = isMobile

Library.MainColor       = Color3.fromRGB(18, 18, 20)
Library.BackgroundColor = Color3.fromRGB(10, 10, 12)
Library.AccentColor     = Color3.fromRGB(235, 64, 80)
Library.OutlineColor    = Color3.fromRGB(35, 35, 40)
Library.FontColor       = Color3.fromRGB(255, 255, 255)

local Window = Library:CreateWindow({
    Title = 'Eclipse',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
    NotifySide = 'Right',
    Resizable = true,
    UnlockMouseWhileOpen = true,
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Movement = Window:AddTab('Movement'),
    Automation = Window:AddTab('Automation'),
    Settings = Window:AddTab('Settings'),
}

local function T(n) local t = Toggles[n]; return t and t.Value or false end
local function O(n) local o = Options[n]; return o and o.Value end

local AimAssist = Tabs.Combat:AddLeftGroupbox('Aim Assist')
AimAssist:AddToggle('Aimbot', { Text = 'Aimbot', Default = false })
    :AddKeyPicker('AimbotKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = true, Text = 'Aimbot' })
AimAssist:AddDropdown('AimMode', { Values = {'Normal', 'Spring', 'AI', 'Linear'}, Default = 'Linear', Text = 'Aim Mode' })
AimAssist:AddSlider('Smoothness', { Text = 'Smoothness (1 smooth - 100 snap)', Default = 80, Min = 1, Max = 100, Rounding = 0 })
AimAssist:AddSlider('FOVSize', { Text = 'FOV Size', Default = 500, Min = 20, Max = 2000, Rounding = 0 })
AimAssist:AddDropdown('HitPart', { Values = {'Head', 'Torso', 'HumanoidRootPart'}, Default = 'Head', Text = 'Hit Part' })
AimAssist:AddToggle('ShowFOVCircle', { Text = 'Show FOV Circle', Default = false })
AimAssist:AddToggle('TeamCheck', { Text = 'Team Check', Default = true })
AimAssist:AddToggle('WallCheck', { Text = 'Wall Check', Default = true })

AimAssist:AddToggle('SilentAim', { Text = 'Silent Aim', Default = false })
    :AddKeyPicker('SilentAimKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = true, Text = 'Silent Aim' })
AimAssist:AddSlider('SilentAimHitChance', { Text = 'Silent Aim Hit Chance', Default = 100, Min = 0, Max = 100, Rounding = 0 })
AimAssist:AddDropdown('SilentAimPart', { Values = {'Head', 'Torso', 'Closest'}, Default = 'Head', Text = 'Silent Aim Part' })

local Ragebot = Tabs.Combat:AddRightGroupbox('Ragebot')
Ragebot:AddToggle('RagebotEnabled', { Text = 'Enabled', Default = false })
    :AddKeyPicker('RagebotKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = true, Text = 'Ragebot' })
Ragebot:AddDropdown('RagebotWeapon', { Values = {'Primary', 'Secondary', 'Melee'}, Default = 'Melee', Text = 'Start Weapon' })
Ragebot:AddSlider('RagebotFireRate', { Text = 'Fire Rate (0 = Instant)', Default = 0, Min = 0, Max = 0.1, Rounding = 4 })

local Triggerbot = Tabs.Combat:AddRightGroupbox('Triggerbot')
Triggerbot:AddToggle('TriggerbotEnabled', { Text = 'Enabled', Default = false })
Triggerbot:AddSlider('TriggerReaction', { Text = 'Reaction Delay (s)', Default = 0, Min = 0, Max = 1, Rounding = 2 })
Triggerbot:AddSlider('TriggerRelease', { Text = 'Release Delay (s)', Default = 0, Min = 0, Max = 1, Rounding = 2 })

local WeaponMods = Tabs.Combat:AddRightGroupbox('Weapon Mods')
WeaponMods:AddToggle('NoBulletSpread', { Text = 'No Bullet Spread', Default = false })
WeaponMods:AddToggle('RapidFire', { Text = 'Rapid Fire', Default = false })
WeaponMods:AddToggle('NoScytheCooldown', { Text = 'No Scythe Cooldown', Default = false })

local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP')
ESPGroup:AddToggle('EnableESP', { Text = 'Enable ESP', Default = false })
    :AddKeyPicker('ESPKey', { Default = 'None', Mode = 'Toggle', SyncToggleState = true, Text = 'ESP' })
ESPGroup:AddToggle('ESPBox', { Text = 'Box', Default = true })
ESPGroup:AddToggle('ESPNames', { Text = 'Names', Default = true })
ESPGroup:AddToggle('ESPHealth', { Text = 'Health Bar', Default = true })
ESPGroup:AddToggle('ESPHealthText', { Text = 'Health Text', Default = false })
ESPGroup:AddToggle('ESPDistance', { Text = 'Distance', Default = false })
ESPGroup:AddToggle('ESPTeam', { Text = 'Show Teammates', Default = false })
ESPGroup:AddSlider('ESPMaxDist', { Text = 'Max Distance', Default = 500, Min = 50, Max = 2000, Rounding = 0 })
ESPGroup:AddToggle('ESPHighlight', { Text = 'Highlight', Default = false })
ESPGroup:AddDropdown('ESPHighlightMethod', { Values = {'Highlight', 'Chams'}, Default = 'Highlight', Text = 'Highlight Method' })
ESPGroup:AddToggle('ESPSkeleton', { Text = 'Skeleton', Default = false })
ESPGroup:AddToggle('ESPLookDir', { Text = 'Look Direction', Default = false })
ESPGroup:AddSlider('ESPTextSize', { Text = 'Text Size', Default = 13, Min = 10, Max = 24, Rounding = 0 })

local ESPColors = Tabs.Visuals:AddLeftGroupbox('ESP Colors')
ESPColors:AddLabel('Visible Color'):AddColorPicker('ColorVisible', { Default = Color3.fromRGB(0, 255, 0) })
ESPColors:AddLabel('Hidden Color'):AddColorPicker('ColorHidden', { Default = Color3.fromRGB(255, 0, 0) })
ESPColors:AddLabel('Teammate Color'):AddColorPicker('ColorTeam', { Default = Color3.fromRGB(0, 150, 255) })

local Throwables = Tabs.Visuals:AddLeftGroupbox('Throwables ESP')
Throwables:AddToggle('ThrowableESP', { Text = 'Enable Throwables ESP', Default = false })
Throwables:AddSlider('ThrowableMaxDist', { Text = 'Max Distance', Default = 500, Min = 50, Max = 2000, Rounding = 0 })

local Removals = Tabs.Visuals:AddRightGroupbox('Effect Removals')
Removals:AddToggle('NoFlashbang', { Text = 'No Flashbang Effect', Default = false })
Removals:AddToggle('NoBurn', { Text = 'No Burn Effect', Default = false })
Removals:AddToggle('NoScopeOverlay', { Text = 'No Scope Overlay', Default = false })
Removals:AddToggle('NoScopeReticle', { Text = 'No Scope Reticle', Default = false })
Removals:AddToggle('NoADS', { Text = 'No ADS Vignette', Default = false })
Removals:AddToggle('NoMuzzle', { Text = 'No Muzzle Flash', Default = false })
Removals:AddToggle('NoTracers', { Text = 'No Gun Tracers', Default = false })
Removals:AddToggle('NoHitmarker', { Text = 'No Hitmarker', Default = false })

local CamGroup = Tabs.Visuals:AddRightGroupbox('Camera Effects')
CamGroup:AddToggle('NoCameraShake', { Text = 'No Camera Shake', Default = true })
CamGroup:AddToggle('CustomFOV', { Text = 'Custom Camera FOV', Default = false })
CamGroup:AddSlider('FOVValue', { Text = 'FOV Value', Default = 130, Min = 50, Max = 130, Rounding = 0 })
CamGroup:AddToggle('ThirdPerson', { Text = 'Third Person', Default = false })

local Viewmodel = Tabs.Visuals:AddRightGroupbox('Viewmodel Effects')
Viewmodel:AddToggle('NoViewModelMotion', { Text = 'No Viewmodel Motion', Default = false })
Viewmodel:AddToggle('NoShootAnim', { Text = 'No Shoot Animation', Default = false })
Viewmodel:AddToggle('NoSprintAnim', { Text = 'No Sprint Animation', Default = false })
Viewmodel:AddToggle('NoReloadAnim', { Text = 'No Reload Animation', Default = false })
Viewmodel:AddToggle('NoEquipAnim', { Text = 'No Equip Animation', Default = false })

local Stretched = Tabs.Visuals:AddRightGroupbox('Stretched Resolution')
Stretched:AddToggle('StretchedEnabled', { Text = 'Stretched Resolution', Default = false })
Stretched:AddSlider('StretchedX', { Text = 'X Ratio', Default = 100, Min = 10, Max = 100, Rounding = 0 })
Stretched:AddSlider('StretchedY', { Text = 'Y Ratio', Default = 83, Min = 10, Max = 100, Rounding = 0 })

local MoveGroup = Tabs.Movement:AddLeftGroupbox('Movement')
MoveGroup:AddToggle('WalkSpeed', { Text = 'WalkSpeed', Default = false })
MoveGroup:AddSlider('WalkSpeedMulti', { Text = 'Walk Speed Multiplier', Default = 2.00, Min = 1, Max = 10, Rounding = 2 })
MoveGroup:AddToggle('SlidingSpeed', { Text = 'Sliding Speed', Default = false })
MoveGroup:AddSlider('SlidingMulti', { Text = 'Sliding Multiplier', Default = 10.00, Min = 1, Max = 20, Rounding = 2 })
MoveGroup:AddToggle('JumpPower', { Text = 'Jump Power', Default = false })
MoveGroup:AddSlider('JumpPowerMulti', { Text = 'Jump Power Multiplier', Default = 2.00, Min = 1, Max = 10, Rounding = 2 })
MoveGroup:AddToggle('Noclip', { Text = 'Noclip', Default = false })
MoveGroup:AddToggle('SlideBoost', { Text = 'Slide Boost', Default = false })
MoveGroup:AddSlider('SlideBoostSpeed', { Text = 'Slide Boost Speed', Default = 100, Min = 10, Max = 300, Rounding = 0 })

local FlightGroup = Tabs.Movement:AddRightGroupbox('Flight & Strafe')
FlightGroup:AddToggle('Flight', { Text = 'Flight', Default = false })
FlightGroup:AddSlider('FlightSpeed', { Text = 'Flight Speed', Default = 100, Min = 20, Max = 500, Rounding = 0 })
FlightGroup:AddToggle('AutoStrafe', { Text = 'Auto Strafe', Default = false })
FlightGroup:AddSlider('AutoStrafeSpeed', { Text = 'Auto Strafe Speed', Default = 50, Min = 10, Max = 150, Rounding = 0 })

local JumpGroup = Tabs.Movement:AddRightGroupbox('Jump')
JumpGroup:AddToggle('InfDoubleJumps', { Text = 'Infinite Double Jumps', Default = false })
JumpGroup:AddToggle('LongJump', { Text = 'Long Jump', Default = false })
JumpGroup:AddDropdown('LongJumpMode', { Values = {'Under Feet', 'Look Direction'}, Default = 'Under Feet', Text = 'Long Jump Mode' })

local AutoQueue = Tabs.Automation:AddLeftGroupbox('Auto Queue')
AutoQueue:AddToggle('AutoQueueEnabled', { Text = 'Enabled', Default = false })
AutoQueue:AddDropdown('QueueMode', { Values = {'1v1', '2v2', '3v3', '4v4', '5v5', '2v2_beginner'}, Default = '1v1', Text = 'Queue' })

local AutoBan = Tabs.Automation:AddRightGroupbox('Auto Weapon Ban')
AutoBan:AddToggle('AutoBanEnabled', { Text = 'Enabled', Default = false })
AutoBan:AddTextBox('BanWeaponList', { Text = 'Weapons (comma separated)', Placeholder = 'Assault Rifle, Sniper, Katana', Default = 'Assault Rifle, Sniper' })

local AutoMap = Tabs.Automation:AddLeftGroupbox('Auto Map Vote')
AutoMap:AddToggle('AutoMapEnabled', { Text = 'Enabled', Default = false })
AutoMap:AddDropdown('MapsToVote', {
    Values = {'Arena', 'Big Graveyard', 'Docks', 'Splash', 'Bridge', 'Crossroads', 'Big Crossroads', 'Big Backrooms', 'Battleground', 'Big Arena', 'Construction', 'Playground', 'Onyx', 'Graveyard', 'Big Splash', 'Big Onyx', 'Backrooms', 'Station', 'Dimension'},
    Default = 'Arena', Text = 'Map'
})

local AutoLoadout = Tabs.Automation:AddLeftGroupbox('Auto Loadout')
AutoLoadout:AddToggle('AutoLoadoutEnabled', { Text = 'Enabled', Default = false })
AutoLoadout:AddDropdown('PrimarySlot', { Values = {'Crossbow', 'Grenade Launcher', 'Brust Rifle', 'Distortion', 'Flamethrower', 'Shotgun', 'RPG', 'Assault Rifle', 'Sniper', 'Minigun', 'Energy Rifle', 'Paintball Gun', 'Bow', 'Gunblade'}, Default = 'Assault Rifle', Text = 'Primary' })
AutoLoadout:AddDropdown('SecondarySlot', { Values = {'Slingshot', 'Flare Gun', 'Spray', 'Shorty', 'Energy Pistols', 'Warper', 'Daggers', 'Scepter', 'Exogun', 'Revolver', 'Uzi', 'Glass Cannon', 'Handgun'}, Default = 'Handgun', Text = 'Secondary' })
AutoLoadout:AddDropdown('MeleeSlot', { Values = {'Fists', 'Scythe', 'Battle Axe', 'Trowel', 'Riot Shield', 'Glast Shard', 'Knife', 'Chainsaw', 'Katana'}, Default = 'Fists', Text = 'Melee' })
AutoLoadout:AddDropdown('UtilitySlot', { Values = {'Medkit', 'Flashbang', 'Elixir', 'Subspace Tripmine', 'War Horn', 'Grenade', 'Warpstone', 'Molotov', 'Freeze Ray', 'RNG Dice', 'Smoke Grenade', 'Jump Pad', 'Satchel'}, Default = 'Grenade', Text = 'Utility' })

local AutoPickup = Tabs.Automation:AddLeftGroupbox('Auto Pickup')
AutoPickup:AddToggle('AutoPickupEnabled', { Text = 'Enabled', Default = false })
AutoPickup:AddDropdown('PickupTypes', { Values = {'Ammo', 'Health', 'Both'}, Default = 'Both', Text = 'Pickup Types' })

local Tripmines = Tabs.Automation:AddRightGroupbox('Subspace Tripmines')
Tripmines:AddToggle('TripmineAuto', { Text = 'Auto Trigger', Default = false })
Tripmines:AddToggle('TripmineTeam', { Text = 'Team Trigger', Default = false })

local AutoRespawn = Tabs.Automation:AddRightGroupbox('Auto Respawn')
AutoRespawn:AddToggle('AutoRespawnEnabled', { Text = 'Enabled', Default = false })

local AntiKatana = Tabs.Automation:AddLeftGroupbox('Anti Katana')
AntiKatana:AddToggle('AntiKatanaEnabled', { Text = 'Enabled', Default = false })

local ModDetector = Tabs.Automation:AddRightGroupbox('Moderator Detector')
ModDetector:AddToggle('ModDetectorEnabled', { Text = 'Enabled', Default = false })
ModDetector:AddDropdown('ModResponses', { Values = {'Notify', 'Kick', 'Crash'}, Default = 'Notify', Text = 'Moderator Responses' })
ModDetector:AddDropdown('ModFriends', { Values = {'None', 'Notify', 'Kick'}, Default = 'None', Text = 'Mod Friends' })

local HackerDetector = Tabs.Automation:AddLeftGroupbox('Hacker Detector')
HackerDetector:AddToggle('HackerDetectorEnabled', { Text = 'Enabled', Default = false })
HackerDetector:AddToggle('HackerNotify', { Text = 'Notify', Default = true })

local Settings = Tabs.Settings:AddLeftGroupbox('Menu')
Settings:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightShift', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('Eclipse')
SaveManager:SetFolder('Eclipse/configs')
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false

local SpringState = { pos = Vector3.zero, initialized = false }
local AIState = { lastTarget = Vector3.zero, lead = Vector3.zero, acquireAt = 0 }
local switchState = { lastTarget = nil, switchAt = 0 }
local lastFrameTime = tick()

local function GetTarget()
    local fov = O("FOVSize") or 80
    local shortestDistance = fov
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local hitPartName = O("HitPart") or "Head"
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { LocalPlayer.Character }
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local closestTarget = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetPart = player.Character:FindFirstChild(hitPartName)
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart and humanoid and enemyHRP and humanoid.Health > 0 then
                local distance = (myHRP.Position - enemyHRP.Position).Magnitude
                if distance <= 300 then
                    local skip = false
                    if T("TeamCheck") and player.Team ~= nil and LocalPlayer.Team ~= nil then
                        if player.Team == LocalPlayer.Team then skip = true end
                    end
                    if not skip then
                        if T("WallCheck") then
                            local result = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rp)
                            if result and result.Instance and not player.Character:IsAncestorOf(result.Instance) then
                                skip = true
                            end
                        end
                        if not skip then
                            local sp, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local dist = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                                if dist < shortestDistance then
                                    shortestDistance = dist
                                    closestTarget = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

local function aimNormal(targetPos)
    return CFrame.new(Camera.CFrame.Position, targetPos)
end

local function aimSpring(targetPos, dt)
    if not SpringState.initialized then
        SpringState.pos = Camera.CFrame.Position + Camera.CFrame.LookVector
        SpringState.initialized = true
    end
    local s = math.clamp((O("Smoothness") or 80) / 100, 0.01, 1)
    local speed = 1 + s * 15
    local alpha = 1 - math.exp(-speed * dt)
    SpringState.pos = SpringState.pos:Lerp(targetPos, alpha)
    return CFrame.new(Camera.CFrame.Position, SpringState.pos)
end

local function aimAI(targetPos, hrp, dt)
    local vel = hrp and hrp.AssemblyLinearVelocity or Vector3.zero
    local dist = (targetPos - Camera.CFrame.Position).Magnitude
    local travelTime = dist / 500
    AIState.lead = vel * travelTime
    local aimPos = targetPos + AIState.lead
    local targetCF = CFrame.new(Camera.CFrame.Position, aimPos)
    local s = math.clamp((O("Smoothness") or 80) / 100, 0.01, 1)
    local speed = 1 + s * 30
    local alpha = 1 - math.exp(-speed * dt)
    return Camera.CFrame:Lerp(targetCF, math.clamp(alpha, 0.001, 1))
end

local function aimLinear(targetPos, dt)
    local targetCF = CFrame.new(Camera.CFrame.Position, targetPos)
    local s = math.clamp((O("Smoothness") or 80) / 100, 0.01, 1)
    local speed = 1 + s * 34
    local alpha = 1 - math.exp(-speed * dt)
    return Camera.CFrame:Lerp(targetCF, math.clamp(alpha, 0.001, 1))
end

RunService:BindToRenderStep("AimbotRender", Enum.RenderPriority.Camera.Value + 1, function()
    local now = tick()
    local dt = math.clamp(now - lastFrameTime, 0, 0.1)
    lastFrameTime = now

    local fov = O("FOVSize") or 80
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Radius = fov
    FOVCircle.Visible = T("ShowFOVCircle") and T("Aimbot")

    if not T("Aimbot") then
        SpringState.initialized = false
        switchState.lastTarget = nil
        return
    end

    local target = GetTarget()
    if target and target.Character and target.Character:FindFirstChild(O("HitPart") or "Head") then
        local targetPart = target.Character[O("HitPart") or "Head"]
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")

        if switchState.lastTarget ~= target then
            switchState.switchAt = now + 0.05
            switchState.lastTarget = target
        end

        if now >= switchState.switchAt then
            local mode = O("AimMode") or "Linear"
            if mode == "Normal" then
                Camera.CFrame = aimNormal(targetPart.Position)
            elseif mode == "Spring" then
                Camera.CFrame = aimSpring(targetPart.Position, dt)
            elseif mode == "AI" then
                Camera.CFrame = aimAI(targetPart.Position, hrp, dt)
            else
                Camera.CFrame = aimLinear(targetPart.Position, dt)
            end
        end
    else
        SpringState.initialized = false
        switchState.lastTarget = nil
    end
end)

local Rivals = { Ready = false, Gun = nil, Util = nil, Fighter = nil }
task.spawn(function()
    local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    local modules = playerScripts:WaitForChild("Modules")
    local itemTypes = modules:WaitForChild("ItemTypes")
    local gunModule = itemTypes:WaitForChild("Gun")
    local ok, gun = pcall(require, gunModule)
    if ok then Rivals.Gun = gun end
    local repModules = ReplicatedStorage:WaitForChild("Modules")
    local utilityModule = repModules:WaitForChild("Utility")
    local ok2, util = pcall(require, utilityModule)
    if ok2 then Rivals.Util = util end
    local controllers = playerScripts:WaitForChild("Controllers")
    local fighterModule = controllers:WaitForChild("FighterController")
    local ok3, fighter = pcall(require, fighterModule)
    if ok3 then Rivals.Fighter = fighter end
    if Rivals.Gun and Rivals.Util then
        Rivals.Ready = true
        task.wait(1)
    end
end)

local silentConfig = {
    SilentAim = false,
    SilentAimTargetPart = "Head",
    SilentAimFOV = 250,
    SilentAimHitChance = 100,
    TeamCheck = true,
    MaxDistance = 1200,
    PredictiveLead = true,
    LeadCap = 15,
    ServerProcessingMs = 30,
}

Library.Toggles.SilentAim:OnChanged(function(v) silentConfig.SilentAim = v end)
Library.Options.SilentAimPart:OnChanged(function(v) silentConfig.SilentAimTargetPart = v end)
Library.Options.SilentAimHitChance:OnChanged(function(v) silentConfig.SilentAimHitChance = v end)

local HEAD_PARTS = { "HitboxHead", "HitboxHeadSmall", "Head" }
local TORSO_PARTS = { "HitboxBody", "UpperTorso", "HumanoidRootPart", "LowerTorso" }

local function isTeammate(player)
    local a, b = LocalPlayer:GetAttribute("TeamID"), player:GetAttribute("TeamID")
    if a == nil or b == nil then return LocalPlayer.Team == player.Team end
    return a == b
end

local function pickPart(char, mode)
    if mode == "Closest" then
        local best, bestDist = nil, math.huge
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
        for _, name in ipairs({"HitboxHead","Head","UpperTorso","LowerTorso","HumanoidRootPart"}) do
            local p = char:FindFirstChild(name)
            if p then
                local sp, on = Camera:WorldToViewportPoint(p.Position)
                if on then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestDist then best, bestDist = p, d end
                end
            end
        end
        if best then return best end
    end
    local list = mode == "Torso" and TORSO_PARTS or HEAD_PARTS
    for _, name in ipairs(list) do
        local p = char:FindFirstChild(name)
        if p then return p end
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function lookCF(fromPos, toPos)
    local dir = toPos - fromPos
    if dir.Magnitude < 1e-4 then dir = Vector3.new(0, -1, 0) end
    local up = Vector3.new(0, 1, 0)
    if math.abs(dir.Unit.Y) > 0.999 then up = Vector3.new(0, 0, 1) end
    return CFrame.lookAt(fromPos, fromPos + dir, up)
end

local function encodeShot(camData, hitPart, targetChar, fromCamPos)
    if not hitPart or not camData or not Rivals.Util then return false end
    local lead = Vector3.zero
    if silentConfig.PredictiveLead then
        local hrp = targetChar:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            if vel.Magnitude > 120 then vel = Vector3.zero end
            local lat = (LocalPlayer:GetNetworkPing() or 0.05) + (silentConfig.ServerProcessingMs / 1000)
            lead = vel * lat
            if lead.Magnitude > silentConfig.LeadCap then lead = lead.Unit * silentConfig.LeadCap end
        end
    end
    local leadedPos = hitPart.Position + lead
    local eyeCF = lookCF(fromCamPos, leadedPos)
    local muzzlePos = fromCamPos + (eyeCF.RightVector * 0.2) + Vector3.new(0, -0.07, 0)
    local muzzleCF = lookCF(muzzlePos, leadedPos)
    local objSpace = hitPart.CFrame:PointToObjectSpace(leadedPos)
    camData[utf8.char(0)] = Rivals.Util:EncodeCFrame(eyeCF)
    camData[utf8.char(1)] = Rivals.Util:EncodeCFrame(muzzleCF)
    camData[utf8.char(2)] = hitPart
    camData[utf8.char(3)] = Rivals.Util:EncodeCFrame(hitPart.CFrame:ToObjectSpace(CFrame.new(leadedPos)))
    return true
end

local function hookSilentAim()
    if not Rivals.Ready or not Rivals.Gun then return end
    local oldStart = Rivals.Gun.StartShooting
    if type(oldStart) ~= "function" then return end
    local hookWrapper = function(self, ...)
        local results = { oldStart(self, ...) }
        pcall(function()
            if not silentConfig.SilentAim then return end
            if not self.ClientFighter or not self.ClientFighter.IsLocalPlayer then return end
            local camData = results[3]
            if not camData or typeof(camData) ~= "table" then return end
            local tgt, part = nil, nil
            local bestScore = math.huge
            local vp = Camera.ViewportSize
            local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and not isTeammate(p) then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local part1 = pickPart(p.Character, silentConfig.SilentAimTargetPart)
                        if part1 then
                            local sp, on = Camera:WorldToViewportPoint(part1.Position)
                            if on then
                                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if d < bestScore and d < silentConfig.SilentAimFOV then
                                    bestScore = d
                                    tgt = p
                                    part = part1
                                end
                            end
                        end
                    end
                end
            end
            if tgt and part and math.random(1, 100) <= silentConfig.SilentAimHitChance then
                if encodeShot(camData, part, tgt.Character, Camera.CFrame.Position) then
                    results[4] = true
                end
            end
        end)
        return unpack(results)
    end
    pcall(function() setreadonly(Rivals.Gun, false) end)
    Rivals.Gun.StartShooting = hookWrapper
end

task.spawn(function()
    task.wait(3)
    pcall(hookSilentAim)
end)

local RageConfig = { Enabled = false, FireRate = 0 }
Library.Toggles.RagebotEnabled:OnChanged(function(v) RageConfig.Enabled = v end)
Library.Options.RagebotFireRate:OnChanged(function(v) RageConfig.FireRate = v end)

local lastFire = 0
local deflecting = {}
Players.PlayerRemoving:Connect(function(p) deflecting[p] = nil end)

RunService.Heartbeat:Connect(function()
    if not RageConfig.Enabled or not Rivals.Ready then return end
    if not Rivals.Fighter or not Rivals.Fighter.Objects then return end
    
    for _, fighterObj in Rivals.Fighter.Objects do
        local player = fighterObj.Player
        if player then
            if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get("IsSpectating") then
                deflecting[player] = false
            else
                local equipped = fighterObj.EquippedItem
                local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == "Katana"
                deflecting[player] = isKatana and (equipped._attack_cooldown and equipped._attack_cooldown > tick()) or false
            end
        end
    end

    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local targetPlayer, targetHead = nil, nil
    local closestDist = 500
    
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character then
            local pTeam = player:GetAttribute("TeamID")
            local lTeam = LocalPlayer:GetAttribute("TeamID")
            local isEnemy = pTeam and lTeam and pTeam ~= lTeam or (pTeam == nil and lTeam == nil)
            
            if isEnemy then
                local pChar = player.Character
                local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                local pHead = pChar:FindFirstChild("Head")
                local pHum = pChar:FindFirstChildWhichIsA("Humanoid")
                if pRoot and pHead and pHum and pHum.Health > 0 and not pChar:FindFirstChildOfClass("ForceField") then
                    local dist = (myRoot.Position - pRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        targetPlayer = player
                        targetHead = pHead
                    end
                end
            end
        end
    end
    
    if not targetPlayer or not targetHead or deflecting[targetPlayer] then return end
    if tick() - lastFire < RageConfig.FireRate then return end
    lastFire = tick()

    local FighterController = Rivals.Fighter
    if not FighterController or not FighterController.LocalFighter then return end
    local item = FighterController.LocalFighter.EquippedItem
    if not item then return end
    
    local info = rawget(item, "Info")
    local data = rawget(item, "Data")
    if info and info.Type == "Gun" and data and data.Ammo <= 0 then return end

    local aimCF = CFrame.lookAt(myRoot.Position, targetHead.Position)
    local targetCF = targetHead.CFrame
    local util = Rivals.Util
    local enum = require(ReplicatedStorage.Modules.EnumLibrary)
    
    local cameradata = {}
    cameradata[utf8.char(1)] = {
        [utf8.char(0)] = util:EncodeCFrame(aimCF),
        [utf8.char(1)] = util:EncodeCFrame(targetCF),
        [utf8.char(2)] = targetHead,
        [utf8.char(3)] = util:EncodeCFrame(CFrame.new(0, 0, 0))
    }
    
    if info and info.Type == "Melee" then
        local anim = enum:ToEnum("AttackAnimation1")
        if anim then
            ReplicatedStorage.Remotes.Replication.Fighter.UseItem:FireServer(
                item:Get("ObjectID"),
                enum:ToEnum("StartShooting"),
                { [utf8.char(1)] = cameradata[utf8.char(1)], [utf8.char(2)] = anim },
                nil
            )
        end
    else
        ReplicatedStorage.Remotes.Replication.Fighter.UseItem:FireServer(
            item:Get("ObjectID"),
            enum:ToEnum("StartShooting"),
            cameradata,
            nil
        )
    end
end)

task.spawn(function()
    task.wait(5)
    if not Rivals.Ready or not Rivals.Gun then return end
    local old = Rivals.Gun.StartShooting
    if type(old) ~= "function" then return end
    Rivals.Gun.StartShooting = function(controller, is_empty, debounce)
        local client_fighter = controller.ClientFighter
        if not client_fighter.IsLocalPlayer then
            return old(controller, is_empty, debounce)
        end
        if not is_empty and controller:Get("Ammo") <= 0 then
            return false
        end
        local shoot_result = {old(controller, is_empty, debounce)}
        local current_item = client_fighter.EquippedItem
        if current_item and T("NoBulletSpread") then
            shoot_result[4] = true
        end
        return unpack(shoot_result)
    end
end)
local espObjects = {}
local highlightObjects = {}
local throwableObjects = {}

local R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local function visible(part)
    if not part then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ig = {part.Parent}
    if LocalPlayer.Character then table.insert(ig, LocalPlayer.Character) end
    params.FilterDescendantsInstances = ig
    return Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params) == nil
end

local function teamColor(plr)
    local visC = O("ColorVisible") or Color3.fromRGB(0,255,0)
    local hidC = O("ColorHidden") or Color3.fromRGB(255,0,0)
    local tmC = O("ColorTeam") or Color3.fromRGB(0,150,255)
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return tmC end
    local char = plr.Character
    local head = char and char:FindFirstChild("Head")
    if head and visible(head) then return visC end
    return hidC
end

local function makeESP(plr)
    if espObjects[plr] then return espObjects[plr] end
    local o = {}
    o.box = Drawing.new("Square"); o.box.Visible = false; o.box.Thickness = 1
    o.name = Drawing.new("Text"); o.name.Visible = false; o.name.Center = true; o.name.Outline = true; o.name.Font = Drawing.Fonts.UI
    o.hpBg = Drawing.new("Square"); o.hpBg.Visible = false; o.hpBg.Filled = true; o.hpBg.Color = Color3.new(0,0,0); o.hpBg.Transparency = 0.5
    o.hpFill = Drawing.new("Square"); o.hpFill.Visible = false; o.hpFill.Filled = true
    o.hpText = Drawing.new("Text"); o.hpText.Visible = false; o.hpText.Center = true; o.hpText.Outline = true; o.hpText.Font = Drawing.Fonts.UI
    o.dist = Drawing.new("Text"); o.dist.Visible = false; o.dist.Center = true; o.dist.Outline = true; o.dist.Font = Drawing.Fonts.UI
    o.look = Drawing.new("Line"); o.look.Visible = false; o.look.Thickness = 2
    o.skel = {}
    for i = 1, #R15 do
        local l = Drawing.new("Line"); l.Visible = false; l.Thickness = 1
        o.skel[i] = l
    end
    espObjects[plr] = o
    return o
end

local function hide(o)
    o.box.Visible = false; o.name.Visible = false
    o.hpBg.Visible = false; o.hpFill.Visible = false; o.hpText.Visible = false
    o.dist.Visible = false; o.look.Visible = false
    for i = 1, #o.skel do o.skel[i].Visible = false end
end

local function highlightFor(plr, char)
    local h = highlightObjects[plr]
    if h and h.Parent and h.Adornee == char then return h end
    if h and h.Parent then h:Destroy() end
    h = Instance.new("Highlight")
    h.Name = "NexusESP_HL"
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = char
    h.Parent = char
    highlightObjects[plr] = h
    return h
end

local function updatePlayer(plr)
    if plr == LocalPlayer and not T("ESPTeam") then
        local o = espObjects[plr]; if o then hide(o) end
        return
    end
    local o = espObjects[plr] or makeESP(plr)
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not hum or hum.Health <= 0 then
        hide(o)
        if highlightObjects[plr] and highlightObjects[plr].Parent then highlightObjects[plr].Enabled = false end
        return
    end
    if not T("ESPTeam") and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        hide(o); return
    end
    local maxDist = O("ESPMaxDist") or 500
    local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
    if dist > maxDist then hide(o); return end
    local rp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
    if not onScreen or rp.Z <= 0 then hide(o); return end
    local hp = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
    local fp = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
    local h = math.abs(hp.Y - fp.Y)
    local w = h * 0.55
    if h < 3 or w < 1 then hide(o); return end
    local x = rp.X - w/2
    local y = hp.Y
    local col = teamColor(plr)
    local textSize = O("ESPTextSize") or 13

    if T("ESPBox") then
        o.box.Visible = true
        o.box.Size = Vector2.new(w, h)
        o.box.Position = Vector2.new(x, y)
        o.box.Color = col
    else o.box.Visible = false end

    if T("ESPNames") then
        o.name.Visible = true
        o.name.Text = plr.DisplayName
        o.name.Size = textSize
        o.name.Color = Color3.new(1,1,1)
        o.name.Position = Vector2.new(rp.X, y - textSize - 2)
    else o.name.Visible = false end

    if T("ESPHealth") then
        local r = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local bw = 3
        local bx = x - bw - 3
        o.hpBg.Visible = true
        o.hpBg.Size = Vector2.new(bw, h)
        o.hpBg.Position = Vector2.new(bx, y)
        o.hpFill.Visible = true
        o.hpFill.Size = Vector2.new(bw, h * r)
        o.hpFill.Position = Vector2.new(bx, y + h * (1 - r))
        o.hpFill.Color = Color3.fromHSV(r * 0.3, 1, 1)
        if T("ESPHealthText") then
            o.hpText.Visible = true
            o.hpText.Text = tostring(math.floor(hum.Health))
            o.hpText.Size = textSize - 2
            o.hpText.Color = Color3.new(1,1,1)
            o.hpText.Position = Vector2.new(bx + bw/2, y + h/2)
        else o.hpText.Visible = false end
    else
        o.hpBg.Visible = false; o.hpFill.Visible = false; o.hpText.Visible = false
    end

    if T("ESPDistance") then
        o.dist.Visible = true
        o.dist.Text = string.format("%d studs", math.floor(dist))
        o.dist.Size = textSize - 2
        o.dist.Color = Color3.fromRGB(220,220,220)
        o.dist.Position = Vector2.new(rp.X, y + h + 2)
    else o.dist.Visible = false end

    if T("ESPSkeleton") then
        local skel = char:FindFirstChild("UpperTorso") and R15 or R6
        for i, p in ipairs(skel) do
            local l = o.skel[i]
            if l then
                local a = char:FindFirstChild(p[1])
                local b = char:FindFirstChild(p[2])
                if a and b then
                    local sp1, on1 = Camera:WorldToViewportPoint(a.Position)
                    local sp2, on2 = Camera:WorldToViewportPoint(b.Position)
                    if on1 and on2 and sp1.Z > 0 and sp2.Z > 0 then
                        l.Visible = true
                        l.From = Vector2.new(sp1.X, sp1.Y)
                        l.To = Vector2.new(sp2.X, sp2.Y)
                        l.Color = col
                    else l.Visible = false end
                else l.Visible = false end
            end
        end
        for i = #skel + 1, #o.skel do o.skel[i].Visible = false end
    else
        for i = 1, #o.skel do o.skel[i].Visible = false end
    end

    if T("ESPLookDir") then
        local head = char:FindFirstChild("Head")
        if head then
            local e = Camera:WorldToViewportPoint(head.Position + head.CFrame.LookVector * 4)
            local s = Camera:WorldToViewportPoint(head.Position)
            if e.Z > 0 and s.Z > 0 then
                o.look.Visible = true
                o.look.From = Vector2.new(s.X, s.Y)
                o.look.To = Vector2.new(e.X, e.Y)
                o.look.Color = col
            else o.look.Visible = false end
        else o.look.Visible = false end
    else o.look.Visible = false end

    if T("ESPHighlight") and (O("ESPHighlightMethod") == "Highlight") then
        local hl = highlightFor(plr, char)
        hl.Enabled = true
        hl.FillColor = col
    elseif highlightObjects[plr] and highlightObjects[plr].Parent then
        highlightObjects[plr].Enabled = false
    end
end

local function updateThrowables()
    for _, o in pairs(throwableObjects) do
        for _, d in ipairs(o) do pcall(function() d:Remove() end) end
    end
    throwableObjects = {}
    if not T("ThrowableESP") then return end
    local maxD = O("ThrowableMaxDist") or 500
    local names = {"Grenade","Molotov","Flashbang","Subspace","Satchel","Smoke"}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local ln = obj.Name:lower()
            local hit = false
            for _, n in ipairs(names) do if ln:find(n:lower()) then hit = true; break end end
            if hit then
                local p = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if p then
                    local dist = (Camera.CFrame.Position - p.Position).Magnitude
                    if dist <= maxD then
                        local sp, on = Camera:WorldToViewportPoint(p.Position)
                        if on and sp.Z > 0 then
                            local t = Drawing.new("Text")
                            t.Text = obj.Name; t.Size = 11
                            t.Color = Color3.fromRGB(255,165,0); t.Center = true; t.Outline = true
                            t.Font = Drawing.Fonts.UI; t.Position = Vector2.new(sp.X, sp.Y); t.Visible = true
                            local d = Drawing.new("Text")
                            d.Text = string.format("%d studs", math.floor(dist)); d.Size = 9
                            d.Color = Color3.fromRGB(200,200,200); d.Center = true; d.Outline = true
                            d.Font = Drawing.Fonts.UI; d.Position = Vector2.new(sp.X, sp.Y + 11); d.Visible = true
                            table.insert(throwableObjects, {t, d})
                        end
                    end
                end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then makeESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    local o = espObjects[p]
    if o then
        for _, d in pairs(o) do
            if type(d) == "table" then
                for _, l in ipairs(d) do pcall(function() l:Remove() end) end
            elseif d and d.Remove then pcall(function() d:Remove() end) end
        end
    end
    if highlightObjects[p] and highlightObjects[p].Parent then highlightObjects[p]:Destroy() end
    espObjects[p] = nil; highlightObjects[p] = nil
end)

RunService.RenderStepped:Connect(function()
    if not T("EnableESP") then
        for _, o in pairs(espObjects) do hide(o) end
        return
    end
    for p, _ in pairs(espObjects) do
        if p.Parent then pcall(updatePlayer, p) end
    end
    pcall(updateThrowables)
end)

-- =====================================================================
-- AUTOMATION
-- =====================================================================
local QueueGonnaUse = "1v1"
local AutoMatch = false
Library.Toggles.AutoQueueEnabled:OnChanged(function(v) AutoMatch = v end)
Library.Options.QueueMode:OnChanged(function(v) QueueGonnaUse = v end)

local function is_in_match()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum ~= nil and hum.Health > 0 and LocalPlayer:GetAttribute("TeamID") ~= nil
end

RunService.Heartbeat:Connect(function()
    if AutoMatch and not is_in_match() then
        pcall(function()
            ReplicatedStorage.Remotes.Matchmaking.JoinQueue:InvokeServer(QueueGonnaUse)
        end)
    end
end)

local autovote = false
local selectedmap = "Arena"
Library.Toggles.AutoMapEnabled:OnChanged(function(v) autovote = v end)
Library.Options.MapsToVote:OnChanged(function(v) selectedmap = v end)
RunService.Heartbeat:Connect(function()
    if autovote then
        pcall(function()
            ReplicatedStorage.Remotes.Duels.Vote:FireServer(selectedmap)
        end)
    end
end)

local ban_index = 1
local ban_weapons = {}
Library.Toggles.AutoBanEnabled:OnChanged(function(v)
    if v then
        local list = O("BanWeaponList") or ""
        ban_weapons = {}
        for w in list:gmatch("[^,]+") do
            table.insert(ban_weapons, w:match("^%s*(.-)%s*$"))
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if T("AutoBanEnabled") and #ban_weapons > 0 then
            pcall(function()
                ReplicatedStorage.Remotes.Duels.Vote:FireServer(ban_weapons[ban_index])
            end)
            ban_index = ban_index % #ban_weapons + 1
        end
    end
end)

local chosenWeapons = { Primary = "Assault Rifle", Secondary = "Handgun", Melee = "Fists", Utility = "Grenade" }
Library.Options.PrimarySlot:OnChanged(function(v) chosenWeapons.Primary = v end)
Library.Options.SecondarySlot:OnChanged(function(v) chosenWeapons.Secondary = v end)
Library.Options.MeleeSlot:OnChanged(function(v) chosenWeapons.Melee = v end)
Library.Options.UtilitySlot:OnChanged(function(v) chosenWeapons.Utility = v end)

RunService.Heartbeat:Connect(function()
    if T("AutoLoadoutEnabled") then
        pcall(function()
            ReplicatedStorage.Remotes.Replication.Fighter.PickWeapons:FireServer({
                chosenWeapons.Primary, chosenWeapons.Secondary, chosenWeapons.Melee, chosenWeapons.Utility
            })
        end)
        task.wait(2)
    end
end)

local visitedDrops = {}
local function forceRemoteRespawn()
    pcall(function()
        ReplicatedStorage.Remotes.Duels.RespawnNow:FireServer()
    end)
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    local humanoid = newCharacter:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if not T("AutoRespawnEnabled") then return end
        task.spawn(function()
            while T("AutoRespawnEnabled") do
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then break end
                forceRemoteRespawn()
                task.wait(0.1)
            end
        end)
    end)
end)

local function handleNewDrop(object)
    if not T("AutoPickupEnabled") then return end
    if not (object:IsA("BasePart") and object.Name == "_drop") then return end
    if visitedDrops[object] then return end
    visitedDrops[object] = true
    task.wait()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and object:IsDescendantOf(Workspace) then
        pcall(function()
            object.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
            object.Anchored = true
            object.CanCollide = false
            object.Transparency = 1
            for _, child in pairs(object:GetDescendants()) do
                if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("MeshPart") then
                    pcall(function() child.Transparency = 1; child.CanCollide = false end)
                elseif child:IsA("BillboardGui") or child:IsA("SurfaceGui") or child:IsA("ParticleEmitter") or child:IsA("SelectionBox") then
                    pcall(function() child.Enabled = false end)
                end
            end
        end)
    end
end
Workspace.DescendantAdded:Connect(handleNewDrop)

local MechanicsController = nil
task.spawn(function()
    local ok, mech = pcall(require, LocalPlayer.PlayerScripts.Controllers.MechanicsController)
    if ok then MechanicsController = mech end
end)
RunService.RenderStepped:Connect(function()
    if not T("SlideBoost") then return end
    if not MechanicsController then return end
    if MechanicsController.IsSliding then
        local speed = O("SlideBoostSpeed") or 100
        pcall(function()
            MechanicsController._sliding_velocity.Velocity = MechanicsController._sliding_velocity.Velocity.Unit * speed
        end)
    end
end)

local thirdPersonEnabled = false
local CameraController = nil
task.spawn(function()
    local ok, cc = pcall(require, LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Controllers"):WaitForChild("CameraController"))
    if ok then CameraController = cc end
end)
Library.Toggles.ThirdPerson:OnChanged(function(v)
    thirdPersonEnabled = v
    if CameraController then
        pcall(function() CameraController:SetThirdPersonOverride(v) end)
    end
end)
RunService.Heartbeat:Connect(function()
    if thirdPersonEnabled and CameraController then
        pcall(function()
            if CameraController.CameraState:GetPublicState() ~= CameraController.CameraState.States.ThirdPerson then
                CameraController.CameraState:TogglePOV()
            end
        end)
    end
end)

print("[Eclipse] Full loaded — RightShift to open menu")