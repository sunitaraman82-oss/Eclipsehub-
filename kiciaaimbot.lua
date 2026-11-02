local Aimbot = (function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local function worldToScreen(worldPos)
        local cam = Workspace.CurrentCamera
        local sp, onScreen = cam:WorldToViewportPoint(worldPos)
        return Vector2.new(sp.X, sp.Y), onScreen, sp.Z
    end

    local Spring = {}
    Spring.__index = Spring
    function Spring.new(initial, clock)
        initial = initial or 0
        clock = clock or os.clock
        return setmetatable({ _clock = clock, _t0 = clock(), _p0 = initial, _v0 = 0 * initial,
            _target = initial, _damper = 1, _speed = 1 }, Spring)
    end
    local function springPosVel(self, now)
        local p0, v0, p1, d, s = self._p0, self._v0, self._target, self._damper, self._speed
        local t = s * (now - self._t0)
        local d2 = d * d
        local h, si, co
        if d2 < 1 then
            h = math.sqrt(1 - d2); local ep = math.exp(-d * t) / h
            co, si = ep * math.cos(h * t), ep * math.sin(h * t)
        elseif d2 == 1 then
            h = 1; local ep = math.exp(-d * t) / h; co, si = ep, ep * t
        else
            h = math.sqrt(d2 - 1)
            local u, v = math.exp((-d + h) * t) / (2 * h), math.exp((-d - h) * t) / (2 * h)
            co, si = u + v, u - v
        end
        local a0, a1 = h * co + d * si, 1 - (h * co + d * si)
        local a2 = si / s
        local b0, b1, b2 = -s * si, s * si, h * co - d * si
        return a0 * p0 + a1 * p1 + a2 * v0, b0 * p0 + b1 * p1 + b2 * v0
    end
    function Spring:SetTarget(value, snap)
        if snap then
            self._p0, self._v0, self._target, self._t0 = value, 0 * value, value, self._clock()
        else self.Target = value end
    end
    Spring.__index = function(self, k)
        if Spring[k] then return Spring[k] end
        if k == "Position" or k == "p" then return (springPosVel(self, self._clock()))
        elseif k == "Velocity" or k == "v" then return select(2, springPosVel(self, self._clock()))
        elseif k == "Target" or k == "t" then return self._target
        elseif k == "Damper" or k == "d" then return self._damper
        elseif k == "Speed" or k == "s" then return self._speed
        elseif k == "Clock" then return self._clock end
        return nil
    end
    Spring.__newindex = function(self, k, v)
        local now = self._clock()
        if k == "Position" or k == "p" then
            local _, vel = springPosVel(self, now); self._p0, self._v0 = v, vel
        elseif k == "Velocity" or k == "v" then
            local pos = springPosVel(self, now); self._p0, self._v0 = pos, v
        elseif k == "Target" or k == "t" then
            local pos, vel = springPosVel(self, now); self._p0, self._v0, self._target = pos, vel, v
        elseif k == "Damper" or k == "d" then
            local pos, vel = springPosVel(self, now); self._p0, self._v0, self._damper = pos, vel, v
        elseif k == "Speed" or k == "s" then
            local pos, vel = springPosVel(self, now); self._p0, self._v0, self._speed = pos, vel, math.max(0, v)
        elseif k == "Clock" then
            local pos, vel = springPosVel(self, now)
            self._clock, self._t0, self._p0, self._v0 = v, v(), pos, vel
        else rawset(self, k, v) end
        self._t0 = now
    end

    local Humanizer = {}
    Humanizer.__index = Humanizer
    local function erf(x)
        local sign = x < 0 and -1 or 1; local ax = math.abs(x)
        local t = 1 / (1 + 0.3275911 * ax)
        return sign * (1 - (0.254829592 * t - 0.284496736 * t^2 + 1.421413741 * t^3 - 1.453152027 * t^4 + 1.061405429 * t^5) * math.exp(-ax * ax))
    end
    local function normalCdf(x) return 0.5 * (1 + erf(x / 1.4142135623730951)) end
    local function normalPdf(x) return 0.3989422804014327 * math.exp(-0.5 * x * x) end
    local function lognormalCdf(x, shift, mu, sigma)
        if x <= shift then return 0 end
        return normalCdf((math.log(x - shift) - mu) / sigma)
    end
    local function lognormalPdf(x, shift, mu, sigma)
        if x <= shift then return 0 end
        local n = x - shift; local z = (math.log(n) - mu) / sigma
        return 1 / (sigma * n) * normalPdf(z)
    end
    local function bellShape(t)
        if t <= 0 or t >= 1 then return 0 end
        return t * t * (1 - t) * (1 - t) * (1 - t) / 0.03456
    end
    local function curvatureProfile(theta)
        return 0.5 + 0.8 * math.abs(math.sin(theta)) - 0.15 * math.abs(math.cos(theta))
    end
    local function boxMuller(rng, mean, stddev)
        local u1 = rng:NextNumber(); local u2 = rng:NextNumber()
        if u1 < 1e-15 then u1 = 1e-15 end
        return mean + stddev * math.sqrt(-2 * math.log(u1)) * math.cos(6.2831853071795862 * u2)
    end
    local function gammaSample(rng, shape, scale)
        local k = shape; local n = 1
        if k < 1 then n = rng:NextNumber() ^ (1 / k); k += 1 end
        local d = k - 0.33333333333333331; local c = 1 / math.sqrt(9 * d)
        local v
        while true do
            local x = boxMuller(rng, 0, 1); v = (1 + c * x)^3
            if v > 0 then
                local u = rng:NextNumber(); if u < 1e-15 then u = 1e-15 end
                if u < 1 - 0.0331 * x^4 or math.log(u) < 0.5 * x * x + d * (1 - v + math.log(v)) then break end
            end
        end
        return d * v * scale * n
    end
    function Humanizer.new()
        return setmetatable({
            _fittsA = 50, _fittsB = 100, _target_width = 20,
            _undershoot_min = 0.92, _undershoot_max = 0.97,
            _peak_time_ratio = 0.35,
            _primary_sigma_min = 0.18, _primary_sigma_max = 0.28,
            _overshoot_prob = 0.15, _overshoot_min = 1.02, _overshoot_max = 1.08,
            _correction_sigma_min = 0.12, _correction_sigma_max = 0.2,
            _second_correction_prob = 0.25, _curvature_scale = 0.025,
            _ou_theta = 3.5, _ou_sigma = 1.2,
            _tremor_freq_min = 8, _tremor_freq_max = 12,
            _tremor_amp_min = 0.15, _tremor_amp_max = 0.55,
            _sdn_k = 0.04, _sample_dt_mean = 7.8, _gamma_shape = 3.5,
            _trajectory = nil, _trajectoryIndex = 1, _elapsed = 0,
            _lastTargetX = 0, _lastTargetY = 0, _rng = Random.new(),
        }, Humanizer)
    end
function Humanizer:Generate(x0, y0, x1, y1)
    local rng = self._rng
    local function uRange(a, b) return a + rng:NextNumber() * (b - a) end
    local function nRange(mean, sd) return boxMuller(rng, mean, sd) end
    local dx, dy = x1 - x0, y1 - y0
    local dist = math.sqrt(dx * dx + dy * dy)
    local angle = math.atan2(dy, dx)
    if dist < 1 then return { { X = x0, Y = y0, T = 0 }, { X = x1, Y = y1, T = 50 } } end
    local ux, uy = dx / dist, dy / dist
    local px, py = -uy, ux
    local duration = math.max((self._fittsA + self._fittsB * math.log(dist / self._target_width + 1) / 0.69314718055994529) * math.exp(nRange(0, 0.08)), 80)
    local overshoot = uRange(0, 1) < self._overshoot_prob
    local primaryDist = dist * (overshoot and uRange(self._overshoot_min, self._overshoot_max) or uRange(self._undershoot_min, self._undershoot_max))
    local sigma = uRange(self._primary_sigma_min, self._primary_sigma_max)
    local peakMu = math.log(duration * uRange(self._peak_time_ratio - 0.03, self._peak_time_ratio + 0.03)) + sigma * sigma
    local subMovements = {}
    local correction = dist - primaryDist
    if math.abs(correction) > 0.5 then
        local dir = correction > 0 and 1 or -1
        local cDist = math.abs(correction) * uRange(0.88, 1.02)
        local cSigma = uRange(self._correction_sigma_min, self._correction_sigma_max)
        local cMu = duration * uRange(0.12, 0.18)
        table.insert(subMovements, { D = cDist, T0 = duration * uRange(0.55, 0.68), Mu = math.log(cMu) + cSigma * cSigma, Sigma = cSigma, DirX = ux * dir, DirY = uy * dir })
        local remain = correction - cDist * dir
        if math.abs(remain) > 2 and uRange(0, 1) < self._second_correction_prob then
            local dir2 = remain > 0 and 1 or -1
            local cDist2 = math.abs(remain) * uRange(0.85, 1.05)
            local cSigma2 = uRange(0.1, 0.16)
            local cMu2 = duration * uRange(0.08, 0.12)
            table.insert(subMovements, { D = cDist2, T0 = duration * uRange(0.78, 0.88), Mu = math.log(cMu2) + cSigma2 * cSigma2, Sigma = cSigma2, DirX = ux * dir2, DirY = uy * dir2 })
        end
    end
    local curvature = dist * self._curvature_scale * curvatureProfile(angle) * nRange(0, 1)
    local tremorFreq = uRange(self._tremor_freq_min, self._tremor_freq_max)
    local tremorAmp = uRange(self._tremor_amp_min, self._tremor_amp_max)
    local tremorPhase1 = uRange(0, 6.2831853071795862)
    local tremorPhase2 = uRange(0, 6.2831853071795862)
    local ouX, ouY = 0, 0
    local total = duration * 1.15
    local dtScale = self._sample_dt_mean / self._gamma_shape
    local times = { 0 }
    local t = 0
    while t < total do
        t += math.clamp(gammaSample(rng, self._gamma_shape, dtScale), 2, 25)
        if t <= total + 1 then table.insert(times, t) end
    end
    local points = {}
    for k, time in ipairs(times) do
        local dt = k > 1 and (time - times[k - 1]) or self._sample_dt_mean
        local dts = dt / 1000
        local primaryT = lognormalCdf(time, 0, peakMu, sigma)
        local x = x0 + ux * primaryDist * primaryT + px * curvature * bellShape(primaryT)
        local y = y0 + uy * primaryDist * primaryT + py * curvature * bellShape(primaryT)
        for _, sm in ipairs(subMovements) do
            local f = lognormalCdf(time, sm.T0, sm.Mu, sm.Sigma)
            x += sm.DirX * sm.D * f; y += sm.DirY * sm.D * f
        end
        local primaryVel = primaryDist * lognormalPdf(time, 0, peakMu, sigma)
        ouX += -self._ou_theta * ouX * dts + self._ou_sigma * math.sqrt(dts) * nRange(0, 1)
        ouY += -self._ou_theta * ouY * dts + self._ou_sigma * math.sqrt(dts) * nRange(0, 1)
        local secs = time / 1000
        local ampScale = 1 / (1 + primaryVel * 0.3)
        local tx = tremorAmp * ampScale * math.sin(6.2831853071795862 * tremorFreq * secs + tremorPhase1)
        local ty = tremorAmp * ampScale * math.sin(6.2831853071795862 * tremorFreq * secs + tremorPhase2)
        table.insert(points, { X = x + ouX + tx + self._sdn_k * primaryVel * nRange(0, 1), Y = y + ouY + ty + self._sdn_k * primaryVel * nRange(0, 1), T = time })
    end
    return points
end
function Humanizer:Compute(start, target, dt)
    local delta = target - start
    if delta.Magnitude < 1 then return delta end
    if not self._trajectory or #self._trajectory == 0 or (target.X - self._lastTargetX)^2 + (target.Y - self._lastTargetY)^2 > 9 then
        self._trajectory = self:Generate(start.X, start.Y, target.X, target.Y)
        self._trajectoryIndex = 1; self._elapsed = 0
        self._lastTargetX = target.X; self._lastTargetY = target.Y
    end
    local traj = self._trajectory
    if #traj < 2 then return delta end
    self._elapsed = self._elapsed + dt * 1000
    local i = self._trajectoryIndex
    while i < #traj and traj[i + 1].T <= self._elapsed do i += 1 end
    self._trajectoryIndex = i
    if i >= #traj then self._trajectory = nil return delta end
    local a, b = traj[i], traj[i + 1]
    local span = b.T - a.T
    local f = span > 0 and math.clamp((self._elapsed - a.T) / span, 0, 1) or 1
    return Vector2.new(a.X + (b.X - a.X) * f - start.X, a.Y + (b.Y - a.Y) * f - start.Y)
end

local TargetSelector = {}
TargetSelector.__index = TargetSelector
function TargetSelector.new(getTargets, measure, comparator)
    return setmetatable({ _getTargets = getTargets, _measure = measure, _comparator = comparator, _mode = { Kind = "ClosestToCrosshair" } }, TargetSelector)
end
function TargetSelector:SetHitboxSelectionMode(mode) self._mode = mode end
function TargetSelector:SetMeasure(fn) self._measure = fn end
function TargetSelector:_SelectClosest(cam, target, skipConditions)
    local hitboxes = target:ResolveHitboxes()
    local best, bestScore = nil, math.huge
    for _, hb in ipairs(hitboxes) do
        local score = self._measure(cam, hb.Position)
        if score and score < bestScore then
            if skipConditions or target:HitboxMeetsConditions(hb, false) then bestScore, best = score, hb end
        end
    end
    return best, bestScore
end
function TargetSelector:_SelectRandom(cam, target, preferRandom, skipConditions, skipPart)
    local hitboxes = target:ResolveHitboxes()
    local n = #hitboxes
    if n == 0 then return nil, math.huge end
    if preferRandom ~= nil then
        local score = self._measure(cam, preferRandom.Position)
        if score and (skipConditions or target:HitboxMeetsConditions(preferRandom, false)) then return preferRandom, score end
    end
    local start = math.random(0, n - 1); local r = math.random(); local fallback = {}
    for i = 0, n - 1 do
        local hb = hitboxes[(start + i) % n + 1]
        if hb ~= skipPart then
            local score = self._measure(cam, hb.Position)
            if score then
                if not skipConditions and not target:HitboxMeetsConditions(hb, false) then continue end
                if self._mode.Prefer and self._mode.Prefer(score) ~= r then table.insert(fallback, hb) else return hb, score end
            end
        end
    end
    for _, hb in ipairs(fallback) do
        local score = self._measure(cam, hb.Position)
        if score then return hb, score end
    end
    return nil, math.huge
end
function TargetSelector:SelectBest(skipPart)
    local targets = self._getTargets()
    local best, bestScore, bestHitbox = nil, math.huge, nil
    local cam = Workspace.CurrentCamera
    for _, target in ipairs(targets) do
        if not target:TargetMeetsConditions() then continue end
        local hb, score
        if self._mode.Kind == "Random" then hb, score = self:_SelectRandom(cam, target, nil, false, skipPart)
        else hb, score = self:_SelectClosest(cam, target, false) end
        if hb then
            if self._comparator and not self._comparator(target, score, best, bestScore) then continue end
            best, bestScore, bestHitbox = target, score, hb
        end
    end
    return best, bestHitbox
end
function TargetSelector:SelectTarget(target, skipPart)
    if not target:TargetMeetsConditions() then return nil end
    local cam = Workspace.CurrentCamera
    if self._mode.Kind == "Random" then return self:_SelectRandom(cam, target, nil, false, skipPart) end
    return self:_SelectClosest(cam, target, false)
end
    local Aimbot = {}
    Aimbot.__index = Aimbot
    function Aimbot.new(opts)
        local self = setmetatable({}, Aimbot)
        self._opts = opts
        self._active = false
        self._lastHitbox = nil
        self._targetScreenPos = nil
        self._acquisition = { _prev = nil, _pending = nil, _pendingTime = nil }
        self._spring = Spring.new(0)
        self._spring.Speed = 1
        self._spring.Damper = 1
        self._humanizer = Humanizer.new()
        self._sigma = { _prevVelX = 0, _prevVelY = 0 }
        self._lockActive = false
        self._lockRequested = false
        self._lockedTarget = nil
        self._fovFollowSpring = nil
        self._connections = {}
        local function connect(sig, fn) table.insert(self._connections, sig:Connect(fn)) end

        local fovCircle = Instance.new("Frame")
        fovCircle.Name = "KiciaFovCircle"
        fovCircle.BackgroundTransparency = 1
        fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        fovCircle.Visible = false
        fovCircle.Parent = gethui and gethui() or game:GetService("CoreGui")

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Thickness = 1
        stroke.Parent = fovCircle

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = fovCircle

        self._fovCircle = { Frame = fovCircle, Stroke = stroke, Gradient = Instance.new("UIGradient") }
        self._fovCircle.Gradient.Parent = stroke

        connect(UserInputService.InputEnded, function(input, processed)
            if processed then return end
            local cfg = opts.GetConfig()
            if not cfg.TargetLock.Enabled then return end
            if input.KeyCode == cfg.TargetLock.Bind or input.UserInputType == cfg.TargetLock.Bind then
                if cfg.TargetLock.Mode == "ToggleLock" and self._lockActive then
                    self._lockActive = false
                    self._lockedTarget = nil
                else
                    self._lockRequested = true
                end
            end
        end)
        return self
    end

    function Aimbot:_Reset()
        self._lastHitbox = nil
        self._targetScreenPos = nil
        self._acquisition._prev = nil
        self._acquisition._pending = nil
        self._acquisition._pendingTime = nil
    end

    function Aimbot:_CheckActivation(cfg)
        local conds = cfg.ActivationConditions
        local gun = self._opts.GetEquippedGun()
        if gun == nil then return false end
        if conds.NotReloading and self._opts.IsReloading(gun) then return false end
        if conds.ScopedIn and not self._opts.IsFullyAiming(gun) then return false end
        return true
    end

    function Aimbot:_Acquire(dt, target, cfg)
        if self._acquisition._prev == target then
            self._acquisition._pending = nil
            self._acquisition._pendingTime = nil
            return true
        end
        local delay = (self._acquisition._prev == nil and cfg.ReactionTime or cfg.SwitchDelay)
        if delay == 0 then
            self._acquisition._prev = target
            return true
        end
        if self._acquisition._pending ~= target then
            self._acquisition._pending = target
            self._acquisition._pendingTime = 0
            return false
        end
        self._acquisition._pendingTime = (self._acquisition._pendingTime or 0) + dt
        if self._acquisition._pendingTime >= delay then
            self._acquisition._prev = target
            return true
        end
        return false
    end

    function Aimbot:_GetTargetPoint(cam, origin, hitbox, hitboxPoint)
        if hitboxPoint.Type == "Center" then
            return hitbox.Position
        end
        local reduction = hitboxPoint.Surface.SizeReductionPercentage / 100
        local ray = cam:ViewportPointToRay(origin.X, origin.Y)
        local cframe = hitbox.CFrame
        local localPos = cframe:PointToObjectSpace(ray.Origin + ray.Direction * ray.Direction:Dot(hitbox.Position - ray.Origin))
        local halfSize = hitbox.Size / 2
        local adjusted = Vector3.new(
            math.clamp(localPos.X, -halfSize.X * (1 - reduction), halfSize.X * (1 - reduction)),
            math.clamp(localPos.Y, -halfSize.Y * (1 - reduction), halfSize.Y * (1 - reduction)),
            math.clamp(localPos.Z, -halfSize.Z, halfSize.Z)
        )
        return cframe * adjusted
    end

    function Aimbot:_ApplyAim(targetPoint, dt, cfg)
        local aimMode = cfg.Mode
        local origin = self._opts.GetCameraOrigin()
        local screenPos, onScreen, _ = worldToScreen(targetPoint)
        if not onScreen then return end
        local dx = screenPos.X - origin.X
        local dy = screenPos.Y - origin.Y

        if aimMode.Type == "Lock" then
            self._opts.MoveCamera(dx, dy)
            return
        end
        if aimMode.Type == "Linear" then
            local mag = math.sqrt(dx * dx + dy * dy)
            if mag < 1 then return end
            local step = math.min(mag, aimMode.Speed * 10)
            self._opts.MoveCamera(dx / mag * step, dy / mag * step)
            return
        end
        if aimMode.Type == "Spring" then
            local spring = self._spring
            spring.Speed = aimMode.Speed
            spring.Damper = 1
            spring:SetTarget(screenPos)
            local pos = spring.Position
            self._opts.MoveCamera(pos.X - origin.X, pos.Y - origin.Y)
            return
        end
        if aimMode.Type == "AI" then
            local delta = self._humanizer:Compute(origin, screenPos, dt)
            self._opts.MoveCamera(delta.X, delta.Y)
            return
        end
        if aimMode.Type == "SigmaMouse" then
            local sigma = self._sigma
            local function sdStep(vel, targetV, dt)
                local n = 2 / dt
                local zeta = 1
                local wn = 1 / (1 + zeta * dt + 0.48 * dt * dt + 0.235 * dt * dt * dt)
                local d = targetV
                local newVel = (vel + n * d) * dt
                local newPos = (d + newVel) * wn
                return newPos, newVel
            end
            local nx, vx = sdStep(sigma._prevVelX, dx, dt)
            local ny, vy = sdStep(sigma._prevVelY, dy, dt)
            sigma._prevVelX, sigma._prevVelY = vx, vy
            self._opts.MoveCamera(nx, ny)
        end
    end

    function Aimbot:_BuildSelector(cfg)
        local cam = Workspace.CurrentCamera
        local provider = {
            PreScan = function() end,
            TargetMeetsConditions = function(t)
                if not t.Alive then return false end
                if t.IsInvincible and t.IsInvincible() then
                    if cfg.TargetConditions.Vulnerable then return false end
                end
                return true
            end,
            ResolveHitboxes = function(t)
                local parts = t.TargetPartsByName
                local state = t.HumanoidState
                local set = state == Enum.HumanoidStateType.Freefall and cfg.TargetHitboxes.Air or cfg.TargetHitboxes.Ground
                local out = {}
                for name in pairs(set) do
                    if parts[name] then table.insert(out, parts[name]) end
                end
                return out
            end,
            HitboxMeetsConditions = function(hb, skipConditions)
                return self._opts.CheckHitbox(self._opts.GetShooterPos(), hb, hb.Parent)
            end,
            GetTargets = self._opts.GetTargets,
        }

        local selector = TargetSelector.new(provider.GetTargets, nil, nil)
        selector:SetHitboxSelectionMode(cfg.HitboxSelection)
        local fovRadius = cfg.Fov.Radius
        local withinFov = cfg.TargetConditions.WithinFov
        selector:SetMeasure(function(cam, worldPos)
            local sp, _, depth = worldToScreen(worldPos)
            if depth < 0 then return nil end
            local mag = (sp - Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)).Magnitude
            if withinFov then
                if mag <= fovRadius then return mag end
                return nil
            end
            return mag
        end)
        provider.SelectBest = function(skipPart) return selector:SelectBest(skipPart) end
        provider.SelectTarget = function(target, skipPart) return selector:SelectTarget(target, skipPart) end
        return provider
    end

    function Aimbot:_SelectTarget(cfg, selector)
        local target, hitbox
        if cfg.TargetLock.Enabled then
            if self._lockRequested then
                self._lockRequested = false
                target, hitbox = selector:SelectBest(self._lastHitbox)
                self._lockActive = target ~= nil
                if target then self._lockedTarget = target end
            elseif self._lockActive and self._lockedTarget then
                if self._lockedTarget:TargetMeetsConditions() then
                    target, hitbox = selector:SelectTarget(self._lockedTarget, self._lastHitbox)
                else
                    self._lockActive = false
                    self._lockedTarget = nil
                end
            elseif cfg.TargetLock.Mode == "AutoLock" then
                target, hitbox = selector:SelectBest(self._lastHitbox)
                if target then
                    self._lockActive = true
                    self._lockedTarget = target
                end
            end
        else
            target, hitbox = selector:SelectBest(self._lastHitbox)
        end
        return target, hitbox
    end

    function Aimbot:Update(dt)
        local cfg = self._opts.GetConfig()
        if not cfg.Enabled or not self._opts.IsActive() then
            self:_Reset()
            self:_UpdateFovCircle(dt, cfg, false)
            return
        end
        if not self:_CheckActivation(cfg) then
            self:_Reset()
            self:_UpdateFovCircle(dt, cfg, false)
            return
        end
        local cam = Workspace.CurrentCamera
        local origin = self._opts.GetCameraOrigin()
        local selector = self:_BuildSelector(cfg)
        local target, hitbox = self:_SelectTarget(cfg, selector)

        if target == nil or hitbox == nil then
            self:_Reset()
            self:_UpdateFovCircle(dt, cfg, false)
            return
        end
        self._lastHitbox = hitbox
        local targetPoint = self:_GetTargetPoint(cam, origin, hitbox, cfg.HitboxPoint)
        local screenPos, onScreen = worldToScreen(targetPoint)
        self._targetScreenPos = onScreen and screenPos or nil

        if not self:_Acquire(dt, target, cfg) then
            self:_UpdateFovCircle(dt, cfg, false)
            return
        end
        self:_ApplyAim(targetPoint, dt, cfg)
        self:_UpdateFovCircle(dt, cfg, true)
    end

    function Aimbot:_UpdateFovCircle(dt, cfg, hasTarget)
        local fov = cfg.Fov
        local circle = fov.Circle
        local visible = cfg.Enabled and circle.Visible and self._opts.IsActive()
        local frame = self._fovCircle.Frame
        frame.Visible = visible
        if not visible then return end

        local radius = fov.Radius
        frame.Size = UDim2.fromOffset(radius * 2, radius * 2)

        local follow = circle.FollowTarget
        local center
        if follow.Enabled and hasTarget and self._targetScreenPos then
            if self._fovFollowSpring == nil then
                self._fovFollowSpring = Spring.new(self._targetScreenPos)
            end
            local s = self._fovFollowSpring
            s.Speed = follow.Speed
            s.Damper = follow.Damper
            s:SetTarget(self._targetScreenPos)
            if (self._targetScreenPos - s.Position).Magnitude < follow.SnapDistance then
                s:SetTarget(self._targetScreenPos, true)
            end
            center = s.Position
            s:SetTarget(nil)
        else
            self._fovFollowSpring = nil
            local cam = Workspace.CurrentCamera
            center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
        end
        frame.Position = UDim2.fromOffset(center.X, center.Y)
        self._fovCircle.Stroke.Color = circle.Stroke.Gradient.Keypoints[1].Value
        self._fovCircle.Stroke.Transparency = circle.Stroke.Transparency or 0
        self._fovCircle.Stroke.Thickness = circle.Stroke.Thickness or 1
    end

    function Aimbot:Destroy()
        for _, c in ipairs(self._connections) do c:Disconnect() end
        table.clear(self._connections)
        if self._fovCircle and self._fovCircle.Frame then
            self._fovCircle.Frame:Destroy()
        end
    end
    return Aimbot
end)()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local aimbotConfig = {
    Enabled = false,
    Keybind = "Always",
    Mode = { Type = "Spring", Speed = 0.35 },
    ActivationConditions = { NotReloading = true, ScopedIn = false },
    TargetConditions = { Visible = true, Vulnerable = true, NotDeflecting = true, NotShielded = true, WithinFov = true },
    TargetHitboxes = { Air = { HitboxHead = true, HitboxBody = true }, Ground = { HitboxHead = true, HitboxBody = true } },
    HitboxSelection = { Type = "ClosestToCrosshair", Random = { Head = 50 } },
    HitboxPoint = { Type = "Center", Surface = { SizeReductionPercentage = 50, PreserveDepth = false } },
    Fov = { Radius = 150, Circle = { Visible = true, Stroke = { Gradient = ColorSequence.new(Color3.fromRGB(255, 0, 0)), Transparency = 0, Thickness = 1 }, Fill = { Enabled = false, Gradient = ColorSequence.new(Color3.fromRGB(255, 200, 180)), Transparency = 0.85 }, Animated = { Enabled = false, Speed = 90 }, FollowTarget = { Enabled = false, Speed = 20, Damper = 1, SnapDistance = 5 } } },
    TargetLock = { Enabled = false, Mode = "ToggleLock", Bind = Enum.KeyCode.Y, BindShowInList = true, BindInvisible = false },
    ReactionTime = 0,
    SwitchDelay = 0,
}

local aimbotActive = false
local toggleState = false
local holdState = false

local function UpdateActive()
    if aimbotConfig.Keybind == "Always" then aimbotConfig.Enabled = true aimbotActive = true
    elseif aimbotConfig.Keybind == "Toggle" then aimbotActive = aimbotConfig.Enabled and toggleState
    elseif aimbotConfig.Keybind == "Hold" then aimbotActive = aimbotConfig.Enabled and holdState end
end

local keybindCode = Enum.KeyCode.RightShift
local function setKey(code) keybindCode = code UpdateActive() end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == keybindCode then
        if aimbotConfig.Keybind == "Toggle" then toggleState = not toggleState UpdateActive()
        elseif aimbotConfig.Keybind == "Hold" then holdState = true UpdateActive() end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == keybindCode and aimbotConfig.Keybind == "Hold" then holdState = false UpdateActive() end
end)

-- MOBILE TOUCH CAMERA TRACKER (No PC mouse)
local function moveCamera(dx, dy)
    local cam = Workspace.CurrentCamera
    if not cam then return end
    
    -- get current camera rotation
    local rx, ry, rz = cam.CFrame:ToEulerAnglesYXZ()
    
    -- apply new rotation based on target delta (inverted for mobile)
    local newYaw = ry - math.rad(dx * 0.1)
    local newPitch = math.clamp(rx - math.rad(dy * 0.1), -math.rad(80), math.rad(80))
    
    -- set camera CFrame
    cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(newPitch, newYaw, rz)
end

local AimbotInstance = Aimbot.new({
    GetConfig = function() return aimbotConfig end,
    IsActive = function() return aimbotActive end,
    GetTargets = function()
        local out = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                local head = plr.Character:FindFirstChild("Head")
                local torso = plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso")
                if hum and root and head then
                    table.insert(out, {
                        Player = plr, Alive = hum.Health > 0, IsInvincible = function() return false end, HumanoidState = hum:GetState(),
                        TargetPartsByName = { HitboxHead = head, HitboxBody = torso or root, HitboxHeadSmall = head, HitboxBodySmall = torso or root },
                        TargetMeetsConditions = function(self) return self.Alive end,
                        ResolveHitboxes = function(self)
                            local set = self.HumanoidState == Enum.HumanoidStateType.Freefall and aimbotConfig.TargetHitboxes.Air or aimbotConfig.TargetHitboxes.Ground
                            local list = {}
                            for name in pairs(set) do if self.TargetPartsByName[name] then table.insert(list, self.TargetPartsByName[name]) end end
                            return list
                        end,
                        HitboxMeetsConditions = function(self, hb) return true end,
                    })
                end
            end
        end
        return out
    end,
    GetShooterPos = function() return Workspace.CurrentCamera.CFrame.Position end,
    GetCameraOrigin = function() local cam = Workspace.CurrentCamera return Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2) end,
    MoveCamera = function(dx, dy) moveCamera(dx, dy) end,
    CheckHitbox = function(origin, part, model)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Include
        params.FilterDescendantsInstances = { part }
        local hit = Workspace:Raycast(origin, part.Position - origin, params)
        return hit ~= nil and hit.Instance == part
    end,
    GetEquippedGun = function() return nil end,
    IsReloading = function(gun) return gun and gun.IsReloading and gun:IsReloading() or false end,
    IsFullyAiming = function(gun) return gun and gun.IsFullyAiming and gun:IsFullyAiming() or false end,
})

RunService.RenderStepped:Connect(function(dt) AimbotInstance:Update(dt) end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "kiciahook | mobile",
    LoadingTitle = "kiciahook",
    LoadingSubtitle = "mobile",
    ConfigurationSaving = { Enabled = true, FolderName = "KiciaAimbot", FileName = "config" },
    KeySystem = false,
})

local AimbotTab = Window:CreateTab("Aimbot", 4483362458)
AimbotTab:CreateSection("Activation")

AimbotTab:CreateToggle({
    Name = "Enable Aimbot", CurrentValue = aimbotConfig.Enabled, Flag = "aimbot_enabled",
    Callback = function(v) aimbotConfig.Enabled = v UpdateActive() end,
})
AimbotTab:CreateDropdown({
    Name = "Activation Mode", Options = { "Always", "Toggle", "Hold" }, CurrentOption = { aimbotConfig.Keybind }, MultipleOptions = false, Flag = "aimbot_activation",
    Callback = function(option) aimbotConfig.Keybind = option[1] UpdateActive() end,
})
AimbotTab:CreateKeybind({
    Name = "Aimbot Keybind", CurrentKeybind = "RightShift", HoldToInteract = false, Flag = "aimbot_keybind",
    Callback = function(key) local ok, code = pcall(function() return Enum.KeyCode[key] end) if ok then setKey(code) end end,
})
AimbotTab:CreateDropdown({
    Name = "Activation Conditions", Options = { "NotReloading", "ScopedIn" }, CurrentOption = { "NotReloading" }, MultipleOptions = true, Flag = "aimbot_activation_conditions",
    Callback = function(options)
        aimbotConfig.ActivationConditions.NotReloading = false
        aimbotConfig.ActivationConditions.ScopedIn = false
        for _, o in ipairs(options) do aimbotConfig.ActivationConditions[o] = true end
    end,
})
AimbotTab:CreateSlider({
    Name = "Reaction Time (s)", Range = { 0, 2 }, Increment = 0.01, Suffix = "s", CurrentValue = aimbotConfig.ReactionTime, Flag = "aimbot_reaction",
    Callback = function(v) aimbotConfig.ReactionTime = v end,
})
AimbotTab:CreateSlider({
    Name = "Switch Delay (s)", Range = { 0, 2 }, Increment = 0.01, Suffix = "s", CurrentValue = aimbotConfig.SwitchDelay, Flag = "aimbot_switch",
    Callback = function(v) aimbotConfig.SwitchDelay = v end,
})

AimbotTab:CreateSection("Aim Mode")
AimbotTab:CreateDropdown({
    Name = "Aim Mode", Options = { "Lock", "Linear", "Spring", "AI", "SigmaMouse" }, CurrentOption = { aimbotConfig.Mode.Type }, MultipleOptions = false, Flag = "aimbot_mode",
    Callback = function(option) aimbotConfig.Mode.Type = option[1] end,
})
AimbotTab:CreateSlider({
    Name = "Aim Speed", Range = { 0.01, 1 }, Increment = 0.01, Suffix = "", CurrentValue = aimbotConfig.Mode.Speed or 0.35, Flag = "aimbot_speed",
    Callback = function(v) aimbotConfig.Mode.Speed = v end,
})

AimbotTab:CreateSection("Target Lock")
AimbotTab:CreateToggle({
    Name = "Enable Target Lock", CurrentValue = aimbotConfig.TargetLock.Enabled, Flag = "aimbot_lock",
    Callback = function(v) aimbotConfig.TargetLock.Enabled = v end,
})
AimbotTab:CreateDropdown({
    Name = "Lock Mode", Options = { "ToggleLock", "AutoLock", "ManualOnly" }, CurrentOption = { aimbotConfig.TargetLock.Mode }, MultipleOptions = false, Flag = "aimbot_lock_mode",
    Callback = function(option) aimbotConfig.TargetLock.Mode = option[1] end,
})
AimbotTab:CreateKeybind({
    Name = "Lock Keybind", CurrentKeybind = "Y", HoldToInteract = false, Flag = "aimbot_lock_bind",
    Callback = function(key) local ok, code = pcall(function() return Enum.KeyCode[key] end) if ok then aimbotConfig.TargetLock.Bind = code end end,
})

local TargetingTab = Window:CreateTab("Targeting", 4483362458)
TargetingTab:CreateSection("Target Conditions")
TargetingTab:CreateDropdown({
    Name = "Target Filters", Options = { "Visible", "Vulnerable", "NotDeflecting", "NotShielded", "WithinFov" }, CurrentOption = { "Visible", "Vulnerable", "NotDeflecting", "NotShielded", "WithinFov" }, MultipleOptions = true, Flag = "aimbot_target_conditions",
    Callback = function(options)
        for k in pairs(aimbotConfig.TargetConditions) do aimbotConfig.TargetConditions[k] = false end
        for _, o in ipairs(options) do aimbotConfig.TargetConditions[o] = true end
    end,
})
TargetingTab:CreateSection("Hitboxes")
TargetingTab:CreateDropdown({
    Name = "Air Hitboxes", Options = { "HitboxHead", "HitboxBody" }, CurrentOption = { "HitboxHead", "HitboxBody" }, MultipleOptions = true, Flag = "aimbot_air_hitboxes",
    Callback = function(options) aimbotConfig.TargetHitboxes.Air = {} for _, o in ipairs(options) do aimbotConfig.TargetHitboxes.Air[o] = true end end,
})
TargetingTab:CreateDropdown({
    Name = "Ground Hitboxes", Options = { "HitboxHead", "HitboxBody" }, CurrentOption = { "HitboxHead", "HitboxBody" }, MultipleOptions = true, Flag = "aimbot_ground_hitboxes",
    Callback = function(options) aimbotConfig.TargetHitboxes.Ground = {} for _, o in ipairs(options) do aimbotConfig.TargetHitboxes.Ground[o] = true end end,
})
TargetingTab:CreateDropdown({
    Name = "Hitbox Selection", Options = { "ClosestToCrosshair", "Random" }, CurrentOption = { "ClosestToCrosshair" }, MultipleOptions = false, Flag = "aimbot_hitbox_selection",
    Callback = function(option) aimbotConfig.HitboxSelection.Type = option[1] end,
})
TargetingTab:CreateSlider({
    Name = "Head Random %", Range = { 0, 100 }, Increment = 1, Suffix = "%", CurrentValue = 50, Flag = "aimbot_head_random",
    Callback = function(v) aimbotConfig.HitboxSelection.Random.Head = v end,
})
TargetingTab:CreateSection("Hitbox Point")
TargetingTab:CreateDropdown({
    Name = "Aim Point", Options = { "Center", "Surface" }, CurrentOption = { "Center" }, MultipleOptions = false, Flag = "aimbot_hitbox_point",
    Callback = function(option) aimbotConfig.HitboxPoint.Type = option[1] end,
})
TargetingTab:CreateSlider({
    Name = "Surface Reduction %", Range = { 0, 100 }, Increment = 0.01, Suffix = "%", CurrentValue = 50, Flag = "aimbot_surface_reduction",
    Callback = function(v) aimbotConfig.HitboxPoint.Surface.SizeReductionPercentage = v end,
})
TargetingTab:CreateToggle({
    Name = "Preserve Depth", CurrentValue = false, Flag = "aimbot_preserve_depth",
    Callback = function(v) aimbotConfig.HitboxPoint.Surface.PreserveDepth = v end,
})

local FovTab = Window:CreateTab("FOV", 4483362458)
FovTab:CreateSection("FOV Settings")
FovTab:CreateSlider({
    Name = "FOV Radius", Range = { 1, 600 }, Increment = 1, Suffix = "px", CurrentValue = aimbotConfig.Fov.Radius, Flag = "aimbot_fov_radius",
    Callback = function(v) aimbotConfig.Fov.Radius = v end,
})
FovTab:CreateSection("FOV Circle")
FovTab:CreateToggle({
    Name = "Show Circle", CurrentValue = aimbotConfig.Fov.Circle.Visible, Flag = "aimbot_fov_visible",
    Callback = function(v) aimbotConfig.Fov.Circle.Visible = v end,
})
FovTab:CreateSlider({
    Name = "Circle Thickness", Range = { 0, 25 }, Increment = 1, Suffix = "", CurrentValue = 1, Flag = "aimbot_fov_thickness",
    Callback = function(v) aimbotConfig.Fov.Circle.Stroke.Thickness = v end,
})
FovTab:CreateColorPicker({
    Name = "Circle Color", Color = Color3.fromRGB(255, 0, 0), Flag = "aimbot_fov_color",
    Callback = function(color) aimbotConfig.Fov.Circle.Stroke.Gradient = ColorSequence.new(color) end,
})
FovTab:CreateToggle({
    Name = "Filled Circle", CurrentValue = false, Flag = "aimbot_fov_filled",
    Callback = function(v) aimbotConfig.Fov.Circle.Fill.Enabled = v end,
})
FovTab:CreateColorPicker({
    Name = "Fill Color", Color = Color3.fromRGB(255, 200, 180), Flag = "aimbot_fov_fill_color",
    Callback = function(color) aimbotConfig.Fov.Circle.Fill.Gradient = ColorSequence.new(color) end,
})
FovTab:CreateToggle({
    Name = "Animated Circle", CurrentValue = false, Flag = "aimbot_fov_animated",
    Callback = function(v) aimbotConfig.Fov.Circle.Animated.Enabled = v end,
})
FovTab:CreateSlider({
    Name = "Animation Speed", Range = { 0, 360 }, Increment = 1, Suffix = "deg/s", CurrentValue = 90, Flag = "aimbot_fov_anim_speed",
    Callback = function(v) aimbotConfig.Fov.Circle.Animated.Speed = v end,
})
FovTab:CreateSection("Follow Target")
FovTab:CreateToggle({
    Name = "Follow Target", CurrentValue = false, Flag = "aimbot_fov_follow",
    Callback = function(v) aimbotConfig.Fov.Circle.FollowTarget.Enabled = v end,
})
FovTab:CreateSlider({
    Name = "Follow Speed", Range = { 1, 50 }, Increment = 1, Suffix = "", CurrentValue = 20, Flag = "aimbot_fov_follow_speed",
    Callback = function(v) aimbotConfig.Fov.Circle.FollowTarget.Speed = v end,
})
FovTab:CreateSlider({
    Name = "Follow Damper", Range = { 0, 30 }, Increment = 1, Suffix = "", CurrentValue = 1, Flag = "aimbot_fov_follow_damper",
    Callback = function(v) aimbotConfig.Fov.Circle.FollowTarget.Damper = v end,
})
FovTab:CreateSlider({
    Name = "Snap Distance", Range = { 0, 10 }, Increment = 1, Suffix = "", CurrentValue = 5, Flag = "aimbot_fov_snap",
    Callback = function(v) aimbotConfig.Fov.Circle.FollowTarget.SnapDistance = v end,
})

Rayfield:LoadConfiguration()
Rayfield:Notify({ Title = "kiciahook", Content = "mobile loaded", Duration = 5, Image = 4483362458 })
