--[[
================================================================================
	i2Library  —  Premium Roblox Client-Side UI Framework
	Theme: Black / Purple  •  Modular  •  Event-driven  •  Config-aware
--------------------------------------------------------------------------------
	Single-file distributable. Despite being one file, the library is internally
	modular: each subsystem is defined as an isolated module and wired together
	through a tiny embedded loader (`define` / `import`). This gives you the
	zero-dependency convenience of `loadstring(game:HttpGet(...))()` while keeping
	the codebase organized exactly like a multi-file project.

	Quick start:
		local i2 = loadstring(game:HttpGet("<url>/i2Library.lua"))()
		local Window = i2:CreateWindow({ Title = "My Hub", SubTitle = "v1.0" })
		local Tab    = Window:AddTab({ Name = "Main", Icon = "home" })
		local Sec    = Tab:AddSection("Combat")
		Sec:AddToggle({ Name = "God Mode", Flag = "godmode", Callback = print })

	Author: i2  •  License: MIT


	its fcking built with claude, 100% Vibe Coded
================================================================================
--]]

--==[ Embedded module loader ]===============================================--
-- Lets us keep clean module boundaries inside a single file.

local _modules, _cache = {}, {}
local function define(name, factory) _modules[name] = factory end
local function import(name)
	local cached = _cache[name]
	if cached ~= nil then return cached end
	local factory = _modules[name]
	if not factory then error("i2Library: unknown module '" .. tostring(name) .. "'", 2) end
	local result = factory(import)
	_cache[name] = result
	return result
end


--============================================================================--
--  MODULE :: Util
--============================================================================--
define("Util", function()
	local Util = {}

	function Util.Create(className, props, children)
		local inst = Instance.new(className)
		if props then
			local deferredParent = props.Parent
			props.Parent = nil
			for key, value in pairs(props) do inst[key] = value end
			if children then for _, c in ipairs(children) do c.Parent = inst end end
			if deferredParent then inst.Parent = deferredParent end
		elseif children then
			for _, c in ipairs(children) do c.Parent = inst end
		end
		return inst
	end

	function Util.Clamp(v, min, max)
		if v < min then return min elseif v > max then return max end
		return v
	end
	function Util.Lerp(a, b, t) return a + (b - a) * t end
	function Util.Alpha(v, a, b)
		if a == b then return 0 end
		return Util.Clamp((v - a) / (b - a), 0, 1)
	end
	function Util.Round(v, d)
		local m = 10 ^ (d or 0)
		return math.floor(v * m + 0.5) / m
	end
	function Util.SnapToStep(v, step)
		if step <= 0 then return v end
		return math.floor(v / step + 0.5) * step
	end

	function Util.Shade(color, amount)
		local h, s, v = color:ToHSV()
		return Color3.fromHSV(h, s, Util.Clamp(v + amount, 0, 1))
	end
	function Util.ColorToHex(c)
		return string.format("#%02X%02X%02X",
			math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5))
	end
	function Util.HexToColor(hex)
		hex = tostring(hex):gsub("#", "")
		if #hex < 6 then return Color3.new(1,1,1) end
		return Color3.fromRGB(tonumber(hex:sub(1,2),16) or 0, tonumber(hex:sub(3,4),16) or 0, tonumber(hex:sub(5,6),16) or 0)
	end
	function Util.SerializeColor(c)
		return { math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5) }
	end
	function Util.DeserializeColor(t)
		if typeof(t) == "Color3" then return t end
		if type(t) == "table" and t[1] then return Color3.fromRGB(t[1], t[2], t[3]) end
		return Color3.new(1, 1, 1)
	end

	function Util.DeepCopy(value)
		if type(value) ~= "table" then return value end
		local copy = {}
		for k, v in pairs(value) do copy[k] = Util.DeepCopy(v) end
		return copy
	end
	function Util.Merge(dst, src)
		if src then for k, v in pairs(src) do dst[k] = v end end
		return dst
	end
	function Util.Defaults(overrides, defaults)
		local r = Util.DeepCopy(defaults)
		if overrides then for k, v in pairs(overrides) do r[k] = v end end
		return r
	end
	function Util.Count(t)
		local n = 0; for _ in pairs(t) do n += 1 end; return n
	end
	function Util.IndexOf(list, value)
		for i, v in ipairs(list) do if v == value then return i end end
		return nil
	end

	function Util.Trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end
	function Util.Matches(haystack, needle)
		if needle == "" then return true end
		return string.find(tostring(haystack):lower(), needle:lower(), 1, true) ~= nil
	end

	local counter = 0
	function Util.UID(prefix)
		counter += 1
		return (prefix or "id") .. "_" .. counter .. "_" .. math.random(1000, 9999)
	end

	return Util
end)


--============================================================================--
--  MODULE :: Signal   (RBXScriptSignal-like event)
--============================================================================--
define("Signal", function()
	local Signal = {}; Signal.__index = Signal
	local Conn = {}; Conn.__index = Conn

	function Conn.new(sig, fn) return setmetatable({ Connected = true, _signal = sig, _fn = fn }, Conn) end
	function Conn:Disconnect()
		if not self.Connected then return end
		self.Connected = false
		local h = self._signal._handlers
		for i = #h, 1, -1 do if h[i] == self then table.remove(h, i) break end end
	end
	Conn.Destroy = Conn.Disconnect

	function Signal.new() return setmetatable({ _handlers = {} }, Signal) end
	function Signal:Connect(fn)
		assert(type(fn) == "function", "Signal:Connect expects a function")
		local c = Conn.new(self, fn)
		table.insert(self._handlers, c)
		return c
	end
	function Signal:Once(fn)
		local c; c = self:Connect(function(...) c:Disconnect() fn(...) end)
		return c
	end
	function Signal:Wait()
		local thread = coroutine.running()
		local c; c = self:Connect(function(...) c:Disconnect() task.spawn(thread, ...) end)
		return coroutine.yield()
	end
	function Signal:Fire(...)
		local h = self._handlers
		for i = 1, #h do
			local c = h[i]
			if c and c.Connected then task.spawn(c._fn, ...) end
		end
	end
	function Signal:DisconnectAll()
		for _, c in ipairs(self._handlers) do c.Connected = false end
		table.clear(self._handlers)
	end
	Signal.Destroy = Signal.DisconnectAll
	return Signal
end)


--============================================================================--
--  MODULE :: Maid   (deterministic cleanup)
--============================================================================--
define("Maid", function()
	local Maid = {}; Maid.__index = Maid
	function Maid.new() return setmetatable({ _tasks = {} }, Maid) end

	function Maid:Give(t)
		if t == nil then return end
		table.insert(self._tasks, t)
		return t
	end
	function Maid:GiveKeyed(key, t)
		self._keyed = self._keyed or {}
		if self._keyed[key] then self:_clean(self._keyed[key]) end
		self._keyed[key] = t
		return t
	end
	function Maid:_clean(t)
		local k = typeof(t)
		if k == "Instance" then t:Destroy()
		elseif k == "RBXScriptConnection" then t:Disconnect()
		elseif k == "function" then t()
		elseif k == "table" then
			if t.Disconnect then t:Disconnect()
			elseif t.Destroy then t:Destroy() end
		end
	end
	function Maid:DoCleaning()
		local tasks = self._tasks
		self._tasks = {}
		for i = #tasks, 1, -1 do self:_clean(tasks[i]) end
		if self._keyed then
			for key, t in pairs(self._keyed) do self._keyed[key] = nil; self:_clean(t) end
		end
	end
	Maid.Destroy = Maid.DoCleaning
	return Maid
end)


--============================================================================--
--  MODULE :: Tween   (centralized animation layer)
--============================================================================--
define("Tween", function()
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local Tween = {}
	Tween.Enabled = true
	Tween.SpeedMultiplier = 1

	Tween.Presets = {
		Hover  = { time = 0.16, style = Enum.EasingStyle.Quart, dir = Enum.EasingDirection.Out },
		Press  = { time = 0.10, style = Enum.EasingStyle.Quad,  dir = Enum.EasingDirection.Out },
		Toggle = { time = 0.22, style = Enum.EasingStyle.Back,  dir = Enum.EasingDirection.Out },
		Slide  = { time = 0.18, style = Enum.EasingStyle.Quart, dir = Enum.EasingDirection.Out },
		Window = { time = 0.34, style = Enum.EasingStyle.Quint, dir = Enum.EasingDirection.Out },
		Expand = { time = 0.24, style = Enum.EasingStyle.Quart, dir = Enum.EasingDirection.Out },
		Notify = { time = 0.40, style = Enum.EasingStyle.Quint, dir = Enum.EasingDirection.Out },
		Linear = { time = 0.20, style = Enum.EasingStyle.Linear, dir = Enum.EasingDirection.InOut },
	}

	local function resolve(spec)
		if type(spec) == "string" then return Tween.Presets[spec] or Tween.Presets.Hover
		elseif type(spec) == "number" then return { time = spec, style = Enum.EasingStyle.Quart, dir = Enum.EasingDirection.Out }
		elseif type(spec) == "table" then return spec end
		return Tween.Presets.Hover
	end

	function Tween.to(instance, props, spec, onComplete)
		local p = resolve(spec)
		if not Tween.Enabled then
			for k, v in pairs(props) do pcall(function() instance[k] = v end) end
			if onComplete then task.spawn(onComplete) end
			return nil
		end
		local info = TweenInfo.new(
			math.max(p.time * Tween.SpeedMultiplier, 0.01),
			p.style or Enum.EasingStyle.Quart, p.dir or Enum.EasingDirection.Out,
			p.repeatCount or 0, p.reverses or false, p.delay or 0)
		local tw = TweenService:Create(instance, info, props)
		if onComplete then tw.Completed:Once(onComplete) end
		tw:Play()
		return tw
	end

	function Tween.bind(callback, interval)
		local accum = 0
		return RunService.RenderStepped:Connect(function(dt)
			if interval then
				accum += dt
				if accum < interval then return end
				dt, accum = accum, 0
			end
			callback(dt)
		end)
	end
	return Tween
end)


--============================================================================--
--  MODULE :: Icons   (image-asset registry — no glyphs/emoji)
--  The core UI is intentionally icon-free. This module only resolves real image
--  asset ids, so plugin authors who explicitly pass an rbxassetid:// can still
--  use images; named/glyph icons resolve to nil and render nothing.
--============================================================================--
define("Icons", function()
	local Icons = {}
	-- Embedded Hero icon set (StyearX)   named icons resolve to real image assets.
	Icons._map = {
	["academic-cap"] = "rbxassetid://95044489519004",
	["adjustments-horizontal"] = "rbxassetid://121106582749003",
	["adjustments-vertical"] = "rbxassetid://77684762199471",
	["archive-box"] = "rbxassetid://109264228000795",
	["archive-box-arrow-down"] = "rbxassetid://82014794854897",
	["archive-box-x-mark"] = "rbxassetid://107545574607398",
	["arrow-down"] = "rbxassetid://85781416601733",
	["arrow-down-circle"] = "rbxassetid://112897933367029",
	["arrow-down-left"] = "rbxassetid://132114585753619",
	["arrow-down-on-square"] = "rbxassetid://78471596442003",
	["arrow-down-on-square-stack"] = "rbxassetid://124820312431868",
	["arrow-down-right"] = "rbxassetid://136248481688618",
	["arrow-down-tray"] = "rbxassetid://91393120298587",
	["arrow-left"] = "rbxassetid://108232373377799",
	["arrow-left-circle"] = "rbxassetid://136775707990164",
	["arrow-left-end-on-rectangle"] = "rbxassetid://110471662054598",
	["arrow-left-on-rectangle"] = "rbxassetid://79049263963166",
	["arrow-left-start-on-rectangle"] = "rbxassetid://135182641404561",
	["arrow-long-down"] = "rbxassetid://73981958178970",
	["arrow-long-left"] = "rbxassetid://95060703044216",
	["arrow-long-right"] = "rbxassetid://130230185082571",
	["arrow-long-up"] = "rbxassetid://117748532531164",
	["arrow-path"] = "rbxassetid://126507323720888",
	["arrow-path-rounded-square"] = "rbxassetid://100787498323887",
	["arrow-right"] = "rbxassetid://118236194525563",
	["arrow-right-circle"] = "rbxassetid://92591863986153",
	["arrow-right-end-on-rectangle"] = "rbxassetid://130896133223788",
	["arrow-right-on-rectangle"] = "rbxassetid://113208805843461",
	["arrow-right-start-on-rectangle"] = "rbxassetid://86028498821065",
	["arrow-small-down"] = "rbxassetid://96558579501823",
	["arrow-small-left"] = "rbxassetid://93500272131422",
	["arrow-small-right"] = "rbxassetid://120470590185662",
	["arrow-small-up"] = "rbxassetid://109912264317782",
	["arrow-top-right-on-square"] = "rbxassetid://105269931979252",
	["arrow-trending-down"] = "rbxassetid://115720487133348",
	["arrow-trending-up"] = "rbxassetid://106881011903998",
	["arrow-turn-down-left"] = "rbxassetid://125109528196535",
	["arrow-turn-down-right"] = "rbxassetid://119938622574062",
	["arrow-turn-left-down"] = "rbxassetid://139542073600314",
	["arrow-turn-left-up"] = "rbxassetid://123253601096535",
	["arrow-turn-right-down"] = "rbxassetid://137674535196343",
	["arrow-turn-right-up"] = "rbxassetid://140285568278770",
	["arrow-turn-up-left"] = "rbxassetid://128089019716159",
	["arrow-turn-up-right"] = "rbxassetid://110150192641007",
	["arrow-up"] = "rbxassetid://135585694640557",
	["arrow-up-circle"] = "rbxassetid://136909827495642",
	["arrow-up-left"] = "rbxassetid://114407992896484",
	["arrow-up-on-square"] = "rbxassetid://134726202694679",
	["arrow-up-on-square-stack"] = "rbxassetid://109531237047357",
	["arrow-up-right"] = "rbxassetid://136721440310293",
	["arrow-up-tray"] = "rbxassetid://95482407704905",
	["arrow-uturn-down"] = "rbxassetid://106474802007361",
	["arrow-uturn-left"] = "rbxassetid://86881902163659",
	["arrow-uturn-right"] = "rbxassetid://138139817355232",
	["arrow-uturn-up"] = "rbxassetid://131222351842512",
	["arrows-pointing-in"] = "rbxassetid://134438115949071",
	["arrows-pointing-out"] = "rbxassetid://102341843775417",
	["arrows-right-left"] = "rbxassetid://103979153869808",
	["arrows-up-down"] = "rbxassetid://89933255349678",
	["at-symbol"] = "rbxassetid://101916258124812",
	["backspace"] = "rbxassetid://131713019363443",
	["backward"] = "rbxassetid://115030412513066",
	["banknotes"] = "rbxassetid://119604409041516",
	["bars-2"] = "rbxassetid://119228815601634",
	["bars-3"] = "rbxassetid://87504331083682",
	["bars-3-bottom-left"] = "rbxassetid://81952540396524",
	["bars-3-bottom-right"] = "rbxassetid://109318889548116",
	["bars-3-center-left"] = "rbxassetid://127973609552929",
	["bars-4"] = "rbxassetid://100841597435937",
	["bars-arrow-down"] = "rbxassetid://84804776081176",
	["bars-arrow-up"] = "rbxassetid://124207628717464",
	["battery-0"] = "rbxassetid://108598778228572",
	["battery-100"] = "rbxassetid://127451352288227",
	["battery-50"] = "rbxassetid://137599615320333",
	["beaker"] = "rbxassetid://78256955421345",
	["bell"] = "rbxassetid://75839997611276",
	["bell-alert"] = "rbxassetid://136302490259339",
	["bell-slash"] = "rbxassetid://84662188785492",
	["bell-snooze"] = "rbxassetid://119275009680468",
	["bold"] = "rbxassetid://100195602233933",
	["bolt"] = "rbxassetid://125273037601044",
	["bolt-slash"] = "rbxassetid://135471826784793",
	["book-open"] = "rbxassetid://76520151950746",
	["bookmark"] = "rbxassetid://93368685211690",
	["bookmark-slash"] = "rbxassetid://75540809108437",
	["bookmark-square"] = "rbxassetid://136752534816170",
	["briefcase"] = "rbxassetid://85703721819367",
	["bug-ant"] = "rbxassetid://109637004335642",
	["building-library"] = "rbxassetid://111998221971140",
	["building-office"] = "rbxassetid://117914763346987",
	["building-office-2"] = "rbxassetid://128032875805595",
	["building-storefront"] = "rbxassetid://83866667568382",
	["cake"] = "rbxassetid://81738673825633",
	["calculator"] = "rbxassetid://81600998875697",
	["calendar"] = "rbxassetid://77966763436189",
	["calendar-date-range"] = "rbxassetid://130922340112873",
	["calendar-days"] = "rbxassetid://102075872672080",
	["camera"] = "rbxassetid://121306290139200",
	["chart-bar"] = "rbxassetid://137651256074086",
	["chart-bar-square"] = "rbxassetid://81375088837384",
	["chart-pie"] = "rbxassetid://78113604799528",
	["chat-bubble-bottom-center"] = "rbxassetid://103930845503928",
	["chat-bubble-bottom-center-text"] = "rbxassetid://86523419876339",
	["chat-bubble-left"] = "rbxassetid://112797089408431",
	["chat-bubble-left-ellipsis"] = "rbxassetid://124907394830646",
	["chat-bubble-left-right"] = "rbxassetid://84600411785340",
	["chat-bubble-oval-left"] = "rbxassetid://121237148108429",
	["chat-bubble-oval-left-ellipsis"] = "rbxassetid://101651132994968",
	["check"] = "rbxassetid://86322753393961",
	["check-badge"] = "rbxassetid://118040906940663",
	["check-circle"] = "rbxassetid://137543516409789",
	["chevron-double-down"] = "rbxassetid://103576611701206",
	["chevron-double-left"] = "rbxassetid://95465991128315",
	["chevron-double-right"] = "rbxassetid://94359849622068",
	["chevron-double-up"] = "rbxassetid://113144089647673",
	["chevron-down"] = "rbxassetid://114011636642377",
	["chevron-left"] = "rbxassetid://104613410271641",
	["chevron-right"] = "rbxassetid://117866012135559",
	["chevron-up"] = "rbxassetid://91232381101256",
	["chevron-up-down"] = "rbxassetid://125369546636879",
	["circle-stack"] = "rbxassetid://111477718101976",
	["clipboard"] = "rbxassetid://89882045792915",
	["clipboard-document"] = "rbxassetid://133116585851443",
	["clipboard-document-check"] = "rbxassetid://97199593253990",
	["clipboard-document-list"] = "rbxassetid://106224971680506",
	["clock"] = "rbxassetid://116830552874284",
	["cloud"] = "rbxassetid://102181186024181",
	["cloud-arrow-down"] = "rbxassetid://78835096974755",
	["cloud-arrow-up"] = "rbxassetid://107964035750979",
	["code-bracket"] = "rbxassetid://73556761011263",
	["code-bracket-square"] = "rbxassetid://85345010847008",
	["cog"] = "rbxassetid://112247400920814",
	["cog-6-tooth"] = "rbxassetid://133633182595557",
	["cog-8-tooth"] = "rbxassetid://118882514272937",
	["command-line"] = "rbxassetid://94033402394522",
	["computer-desktop"] = "rbxassetid://122873587858614",
	["cpu-chip"] = "rbxassetid://82778991358664",
	["credit-card"] = "rbxassetid://76812574139263",
	["cube"] = "rbxassetid://112588844215590",
	["cube-transparent"] = "rbxassetid://75911265368584",
	["currency-bangladeshi"] = "rbxassetid://136595025394847",
	["currency-dollar"] = "rbxassetid://101992014239422",
	["currency-euro"] = "rbxassetid://104060195949386",
	["currency-pound"] = "rbxassetid://97559366640886",
	["currency-rupee"] = "rbxassetid://103623868876250",
	["currency-yen"] = "rbxassetid://127889384143178",
	["cursor-arrow-rays"] = "rbxassetid://89933751117611",
	["cursor-arrow-ripple"] = "rbxassetid://89260700803974",
	["device-phone-mobile"] = "rbxassetid://121066060351577",
	["device-tablet"] = "rbxassetid://78849602258381",
	["divide"] = "rbxassetid://117782129998946",
	["document"] = "rbxassetid://137691811073348",
	["document-arrow-down"] = "rbxassetid://129064851211511",
	["document-arrow-up"] = "rbxassetid://76468179649383",
	["document-chart-bar"] = "rbxassetid://91594567758394",
	["document-check"] = "rbxassetid://124250552098194",
	["document-currency-bangladeshi"] = "rbxassetid://85668778191195",
	["document-currency-dollar"] = "rbxassetid://73230179553545",
	["document-currency-euro"] = "rbxassetid://88758934294126",
	["document-currency-pound"] = "rbxassetid://74140324725171",
	["document-currency-rupee"] = "rbxassetid://97830260747155",
	["document-currency-yen"] = "rbxassetid://133989033216194",
	["document-duplicate"] = "rbxassetid://98973053218552",
	["document-magnifying-glass"] = "rbxassetid://124749794258733",
	["document-minus"] = "rbxassetid://134480322203694",
	["document-plus"] = "rbxassetid://112825861148902",
	["document-text"] = "rbxassetid://76088755917235",
	["ellipsis-horizontal"] = "rbxassetid://91812129374441",
	["ellipsis-horizontal-circle"] = "rbxassetid://94943308512653",
	["ellipsis-vertical"] = "rbxassetid://113700842800573",
	["envelope"] = "rbxassetid://126137728622716",
	["envelope-open"] = "rbxassetid://76892697932907",
	["equals"] = "rbxassetid://72464196740343",
	["exclamation-circle"] = "rbxassetid://111076785189240",
	["exclamation-triangle"] = "rbxassetid://118006344384363",
	["eye"] = "rbxassetid://132092165787522",
	["eye-dropper"] = "rbxassetid://78701063713830",
	["eye-slash"] = "rbxassetid://74642456171419",
	["face-frown"] = "rbxassetid://81035899825327",
	["face-smile"] = "rbxassetid://109930072253062",
	["film"] = "rbxassetid://108221122006366",
	["finger-print"] = "rbxassetid://115939697633820",
	["fire"] = "rbxassetid://97421605306074",
	["flag"] = "rbxassetid://93899883114467",
	["folder"] = "rbxassetid://128667138751703",
	["folder-arrow-down"] = "rbxassetid://72035250308788",
	["folder-minus"] = "rbxassetid://119920289110394",
	["folder-open"] = "rbxassetid://103494334707062",
	["folder-plus"] = "rbxassetid://118592609635554",
	["forward"] = "rbxassetid://94933009887401",
	["funnel"] = "rbxassetid://134276326701136",
	["gif"] = "rbxassetid://122570118029883",
	["gift"] = "rbxassetid://103217894689175",
	["gift-top"] = "rbxassetid://104712822335918",
	["globe-alt"] = "rbxassetid://86433311127989",
	["globe-americas"] = "rbxassetid://116052470782382",
	["globe-asia-australia"] = "rbxassetid://136098149423733",
	["globe-europe-africa"] = "rbxassetid://134068575348833",
	["h1"] = "rbxassetid://72964924132876",
	["h2"] = "rbxassetid://102654343570312",
	["h3"] = "rbxassetid://122960882331564",
	["hand-raised"] = "rbxassetid://118545169572460",
	["hand-thumb-down"] = "rbxassetid://73492555103568",
	["hand-thumb-up"] = "rbxassetid://131718478887011",
	["hashtag"] = "rbxassetid://88312653573794",
	["heart"] = "rbxassetid://86770718504993",
	["home"] = "rbxassetid://90273397485310",
	["home-modern"] = "rbxassetid://85277666030352",
	["identification"] = "rbxassetid://86751970614850",
	["inbox"] = "rbxassetid://140404029294359",
	["inbox-arrow-down"] = "rbxassetid://136647993776449",
	["inbox-stack"] = "rbxassetid://91454427863896",
	["information-circle"] = "rbxassetid://111877338438290",
	["italic"] = "rbxassetid://128712577566459",
	["key"] = "rbxassetid://90585420615181",
	["language"] = "rbxassetid://111600868103105",
	["lifebuoy"] = "rbxassetid://97626747207639",
	["light-bulb"] = "rbxassetid://108062802119701",
	["link"] = "rbxassetid://101628518595098",
	["link-slash"] = "rbxassetid://114897164334701",
	["list-bullet"] = "rbxassetid://132761529443720",
	["lock-closed"] = "rbxassetid://109812096539748",
	["lock-open"] = "rbxassetid://86774230269139",
	["magnifying-glass"] = "rbxassetid://87412908229213",
	["magnifying-glass-circle"] = "rbxassetid://84416909594850",
	["magnifying-glass-minus"] = "rbxassetid://131574249178735",
	["magnifying-glass-plus"] = "rbxassetid://110257293617560",
	["map"] = "rbxassetid://140163273218602",
	["map-pin"] = "rbxassetid://128048220092952",
	["megaphone"] = "rbxassetid://96204747117752",
	["microphone"] = "rbxassetid://128325740969631",
	["minus"] = "rbxassetid://115577225620354",
	["minus-circle"] = "rbxassetid://137354385413315",
	["minus-small"] = "rbxassetid://85126747607694",
	["moon"] = "rbxassetid://70641164306806",
	["musical-note"] = "rbxassetid://82503656689212",
	["newspaper"] = "rbxassetid://83346501787853",
	["no-symbol"] = "rbxassetid://136786449904344",
	["numbered-list"] = "rbxassetid://106877213930440",
	["paint-brush"] = "rbxassetid://89879698906381",
	["paper-airplane"] = "rbxassetid://89111667635128",
	["paper-clip"] = "rbxassetid://131668960133819",
	["pause"] = "rbxassetid://97267694791637",
	["pause-circle"] = "rbxassetid://76076372417462",
	["pencil"] = "rbxassetid://79865664222568",
	["pencil-square"] = "rbxassetid://126749464896997",
	["percent-badge"] = "rbxassetid://107898497150982",
	["phone"] = "rbxassetid://95433049000932",
	["phone-arrow-down-left"] = "rbxassetid://97410829173196",
	["phone-arrow-up-right"] = "rbxassetid://122265349840882",
	["phone-x-mark"] = "rbxassetid://107168533549641",
	["photo"] = "rbxassetid://86382890188254",
	["play"] = "rbxassetid://116849545551394",
	["play-circle"] = "rbxassetid://116946103390832",
	["play-pause"] = "rbxassetid://119493035810891",
	["plus"] = "rbxassetid://81017621140508",
	["plus-circle"] = "rbxassetid://107083973516657",
	["plus-small"] = "rbxassetid://129314601753487",
	["power"] = "rbxassetid://78241210024697",
	["presentation-chart-bar"] = "rbxassetid://132722202935666",
	["presentation-chart-line"] = "rbxassetid://131942845480512",
	["printer"] = "rbxassetid://93888721647210",
	["puzzle-piece"] = "rbxassetid://127092930605451",
	["question-mark-circle"] = "rbxassetid://99572332522462",
	["queue-list"] = "rbxassetid://107905181495763",
	["radio"] = "rbxassetid://97305392454893",
	["receipt-percent"] = "rbxassetid://96269196258518",
	["receipt-refund"] = "rbxassetid://88720916467050",
	["rectangle-group"] = "rbxassetid://78974133016688",
	["rectangle-stack"] = "rbxassetid://76521684798992",
	["rocket-launch"] = "rbxassetid://76871741551331",
	["rss"] = "rbxassetid://121180491815106",
	["scale"] = "rbxassetid://86420949359093",
	["scissors"] = "rbxassetid://123666251731998",
	["server"] = "rbxassetid://127014138782932",
	["server-stack"] = "rbxassetid://90930980380768",
	["share"] = "rbxassetid://90083500947855",
	["shield-check"] = "rbxassetid://131653980234063",
	["shield-exclamation"] = "rbxassetid://110063049781725",
	["shopping-bag"] = "rbxassetid://121810489944952",
	["shopping-cart"] = "rbxassetid://70440196600561",
	["signal"] = "rbxassetid://130036279873227",
	["signal-slash"] = "rbxassetid://123739070077733",
	["slash"] = "rbxassetid://139628283384331",
	["sparkles"] = "rbxassetid://78926934618896",
	["speaker-wave"] = "rbxassetid://138670612877674",
	["speaker-x-mark"] = "rbxassetid://90559712769417",
	["square-2-stack"] = "rbxassetid://139144739942759",
	["square-3-stack-3d"] = "rbxassetid://77369495069948",
	["squares-2x2"] = "rbxassetid://90134669598629",
	["squares-plus"] = "rbxassetid://82096572751413",
	["star"] = "rbxassetid://119068550695403",
	["stop"] = "rbxassetid://117254110390817",
	["stop-circle"] = "rbxassetid://109165025933981",
	["strikethrough"] = "rbxassetid://131563559822205",
	["sun"] = "rbxassetid://81756836497152",
	["swatch"] = "rbxassetid://87375770983487",
	["table-cells"] = "rbxassetid://86046045634169",
	["tag"] = "rbxassetid://79477713758276",
	["ticket"] = "rbxassetid://77100129332601",
	["trash"] = "rbxassetid://120046673744592",
	["trophy"] = "rbxassetid://86778536567364",
	["truck"] = "rbxassetid://100231480303125",
	["tv"] = "rbxassetid://117952637415489",
	["underline"] = "rbxassetid://118358865486974",
	["user"] = "rbxassetid://126318879901509",
	["user-circle"] = "rbxassetid://108556427914694",
	["user-group"] = "rbxassetid://123579515106333",
	["user-minus"] = "rbxassetid://121785997849012",
	["user-plus"] = "rbxassetid://110783601977038",
	["users"] = "rbxassetid://97690748017524",
	["variable"] = "rbxassetid://107982855065152",
	["video-camera"] = "rbxassetid://89116007091611",
	["video-camera-slash"] = "rbxassetid://134322302556225",
	["view-columns"] = "rbxassetid://90580611987566",
	["viewfinder-circle"] = "rbxassetid://122720680599484",
	["wallet"] = "rbxassetid://132138689525705",
	["wifi"] = "rbxassetid://120058902966890",
	["window"] = "rbxassetid://123943456491477",
	["wrench"] = "rbxassetid://104557416094523",
	["wrench-screwdriver"] = "rbxassetid://107807280480187",
	["x-circle"] = "rbxassetid://123201040316647",
	["x-mark"] = "rbxassetid://111674557552737",
	}
	-- Friendly aliases used throughout the library, mapped onto the Hero set.
	for alias, target in pairs({
		settings = "cog-6-tooth", save = "folder-arrow-down", download = "arrow-down-tray",
		copy = "document-duplicate", edit = "pencil-square", upload = "arrow-up-tray",
		refresh = "arrow-path", close = "x-mark", search = "magnifying-glass",
	}) do
		if Icons._map[target] then Icons._map[alias] = Icons._map[target] end
	end
	function Icons.get(name)
		if not name then return nil end
		if type(name) == "number" then return "rbxassetid://" .. name end
		if type(name) == "string" and (name:match("^rbxassetid://") or name:match("^rbxasset://")) then return name end
		return Icons._map[name] -- named icons only resolve if explicitly registered as images
	end
	function Icons.isImage(value)
		return type(value) == "string" and (value:match("^rbxassetid://") or value:match("^rbxasset://")) ~= nil
	end
	function Icons.register(name, assetId)
		Icons._map[name] = type(assetId) == "number" and ("rbxassetid://" .. assetId) or assetId
	end
	return Icons
end)


--============================================================================--
--  MODULE :: Theme   (design tokens + live theming engine)
--============================================================================--
define("Theme", function(import)
	local Signal = import("Signal")
	local Tween = import("Tween")
	local Util = import("Util")

	local Theme = {}; Theme.__index = Theme

	Theme.Presets = {
		["Midnight Purple"] = {
			Accent = Color3.fromRGB(149,90,255), AccentDim = Color3.fromRGB(108,64,196),
			AccentGlow = Color3.fromRGB(170,120,255),
			Background = Color3.fromRGB(12,12,16), Surface = Color3.fromRGB(18,18,24),
			SurfaceAlt = Color3.fromRGB(24,24,32), Elevated = Color3.fromRGB(30,30,40),
			Overlay = Color3.fromRGB(8,8,11),
			Border = Color3.fromRGB(38,38,50), BorderActive = Color3.fromRGB(149,90,255),
			Text = Color3.fromRGB(236,236,244), TextDim = Color3.fromRGB(150,150,165),
			TextMuted = Color3.fromRGB(96,96,112),
			Success = Color3.fromRGB(86,214,140), Warning = Color3.fromRGB(246,190,84),
			Error = Color3.fromRGB(244,96,108), Info = Color3.fromRGB(96,168,255),
			Shadow = Color3.fromRGB(0,0,0),
		},
		["Obsidian"] = {
			Accent = Color3.fromRGB(120,120,132), AccentDim = Color3.fromRGB(80,80,90),
			AccentGlow = Color3.fromRGB(160,160,175),
			Background = Color3.fromRGB(10,10,12), Surface = Color3.fromRGB(16,16,19),
			SurfaceAlt = Color3.fromRGB(22,22,26), Elevated = Color3.fromRGB(28,28,33),
			Overlay = Color3.fromRGB(6,6,8),
			Border = Color3.fromRGB(34,34,40), BorderActive = Color3.fromRGB(120,120,132),
			Text = Color3.fromRGB(232,232,236), TextDim = Color3.fromRGB(150,150,158),
			TextMuted = Color3.fromRGB(96,96,104),
			Success = Color3.fromRGB(86,214,140), Warning = Color3.fromRGB(246,190,84),
			Error = Color3.fromRGB(244,96,108), Info = Color3.fromRGB(96,168,255),
			Shadow = Color3.fromRGB(0,0,0),
		},
		["Neon Violet"] = {
			Accent = Color3.fromRGB(189,88,255), AccentDim = Color3.fromRGB(138,52,214),
			AccentGlow = Color3.fromRGB(214,130,255),
			Background = Color3.fromRGB(14,10,20), Surface = Color3.fromRGB(20,15,28),
			SurfaceAlt = Color3.fromRGB(28,21,38), Elevated = Color3.fromRGB(36,27,48),
			Overlay = Color3.fromRGB(9,6,14),
			Border = Color3.fromRGB(46,36,62), BorderActive = Color3.fromRGB(189,88,255),
			Text = Color3.fromRGB(240,234,248), TextDim = Color3.fromRGB(168,156,182),
			TextMuted = Color3.fromRGB(110,100,124),
			Success = Color3.fromRGB(86,214,140), Warning = Color3.fromRGB(246,190,84),
			Error = Color3.fromRGB(244,96,108), Info = Color3.fromRGB(96,168,255),
			Shadow = Color3.fromRGB(0,0,0),
		},
		["Crimson"] = {
			Accent = Color3.fromRGB(244,96,108), AccentDim = Color3.fromRGB(190,60,72),
			AccentGlow = Color3.fromRGB(255,130,140),
			Background = Color3.fromRGB(14,11,12), Surface = Color3.fromRGB(20,15,16),
			SurfaceAlt = Color3.fromRGB(28,21,22), Elevated = Color3.fromRGB(36,27,28),
			Overlay = Color3.fromRGB(9,6,7),
			Border = Color3.fromRGB(48,36,38), BorderActive = Color3.fromRGB(244,96,108),
			Text = Color3.fromRGB(244,236,238), TextDim = Color3.fromRGB(176,156,160),
			TextMuted = Color3.fromRGB(120,100,104),
			Success = Color3.fromRGB(86,214,140), Warning = Color3.fromRGB(246,190,84),
			Error = Color3.fromRGB(244,96,108), Info = Color3.fromRGB(96,168,255),
			Shadow = Color3.fromRGB(0,0,0),
		},
	}

	function Theme.new(presetName)
		local self = setmetatable({}, Theme)
		self.Name = presetName or "Midnight Purple"
		self.Colors = Util.DeepCopy(Theme.Presets[self.Name] or Theme.Presets["Midnight Purple"])
		self.Tokens = {
			CornerRadius = 8, Padding = 10, BackgroundOpacity = 0.26, ShadowIntensity = 0.5,
			BlurAmount = 14, UIScale = 1,
			Font = Enum.Font.GothamMedium, FontBold = Enum.Font.GothamBold,
		}
		self._bindings = setmetatable({}, { __mode = "k" })
		self.Changed = Signal.new()
		return self
	end

	function Theme:Get(token)
		if self.Colors[token] ~= nil then return self.Colors[token] end
		return self.Tokens[token]
	end

	function Theme:Apply(instance, spec, animate)
		local b = self._bindings[instance]
		if not b then b = {}; self._bindings[instance] = b end
		for prop, def in pairs(spec) do
			b[prop] = def
			self:_applyOne(instance, prop, def, animate)
		end
		return instance
	end

	function Theme:_resolve(def)
		if type(def) == "string" then return self:Get(def)
		elseif type(def) == "function" then return def(self)
		elseif type(def) == "table" then
			local base = self:Get(def.token)
			if def.transform then return def.transform(base, self) end
			return base
		end
		return def
	end

	function Theme:_applyOne(instance, prop, def, animate)
		local value = self:_resolve(def)
		if value == nil then return end
		local t = typeof(value)
		if animate and (t == "Color3" or t == "number" or t == "UDim2" or t == "UDim") then
			Tween.to(instance, { [prop] = value }, "Hover")
		else
			instance[prop] = value
		end
	end

	function Theme:Refresh(animate)
		for instance, bindings in pairs(self._bindings) do
			for prop, def in pairs(bindings) do
				pcall(self._applyOne, self, instance, prop, def, animate)
			end
		end
		self.Changed:Fire(self)
	end

	function Theme:SetPreset(name)
		if not Theme.Presets[name] then return end
		self.Name = name
		self.Colors = Util.DeepCopy(Theme.Presets[name])
		self:Refresh(true)
	end
	function Theme:SetAccent(color)
		self.Colors.Accent = color
		self.Colors.AccentDim = Util.Shade(color, -0.18)
		self.Colors.AccentGlow = Util.Shade(color, 0.12)
		self.Colors.BorderActive = color
		self:Refresh(true)
	end
	function Theme:SetToken(name, value)
		self.Tokens[name] = value
		self:Refresh(true)
	end
	function Theme:Serialize()
		return { Name = self.Name, Accent = Util.SerializeColor(self.Colors.Accent), Tokens = Util.DeepCopy(self.Tokens) }
	end
	function Theme:Deserialize(data)
		if not data then return end
		if data.Name and Theme.Presets[data.Name] then
			self.Name = data.Name
			self.Colors = Util.DeepCopy(Theme.Presets[data.Name])
		end
		if data.Accent then self:SetAccent(Util.DeserializeColor(data.Accent)) end
		if data.Tokens then
			for k, v in pairs(data.Tokens) do
				if k ~= "Font" and k ~= "FontBold" then self.Tokens[k] = v end
			end
		end
		self:Refresh(false)
	end
	return Theme
end)


--============================================================================--
--  MODULE :: Primitives   (reusable styled building blocks)
--============================================================================--
define("Primitives", function(import)
	local Util = import("Util")
	local Tween = import("Tween")
	local Icons = import("Icons")
	local Create = Util.Create

	local P = {}

	-- Render an icon ONLY if `name` resolves to a real image asset; otherwise
	-- returns nil and renders nothing (the core UI is icon-free by design).
	function P.icon(parent, name, size, color, props)
		local resolved = Icons.get(name)
		if not Icons.isImage(resolved) then return nil end
		size = size or 16
		local img = Create("ImageLabel", Util.Merge({
			BackgroundTransparency = 1, Image = resolved, ImageColor3 = color or Color3.new(1, 1, 1),
			Size = UDim2.fromOffset(size, size),
		}, props or {}))
		img.Parent = parent
		return img
	end

	function P.corner(parent, radius)
		return Create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
	end

	function P.stroke(parent, color, thickness, transparency)
		return Create("UIStroke", {
			Color = color or Color3.fromRGB(40, 40, 52),
			Thickness = thickness or 1,
			Transparency = transparency or 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = parent,
		})
	end

	function P.padding(parent, all, extra)
		local v = all or 0
		local props = {
			PaddingTop = UDim.new(0, v), PaddingBottom = UDim.new(0, v),
			PaddingLeft = UDim.new(0, v), PaddingRight = UDim.new(0, v),
			Parent = parent,
		}
		if extra then Util.Merge(props, extra) end
		return Create("UIPadding", props)
	end

	function P.listLayout(parent, gap, dir)
		return Create("UIListLayout", {
			Padding = UDim.new(0, gap or 6),
			FillDirection = dir or Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Parent = parent,
		})
	end

	function P.gridLayout(parent, cellSize, cellPad)
		return Create("UIGridLayout", {
			CellSize = cellSize or UDim2.fromOffset(100, 100),
			CellPadding = cellPad or UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = parent,
		})
	end

	-- Soft drop shadow using the classic 9-slice glow asset.
	function P.shadow(parent, intensity, spread)
		intensity = intensity or 0.5
		spread = spread or 30
		return Create("ImageLabel", {
			Name = "Shadow", AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 4),
			Size = UDim2.new(1, spread, 1, spread),
			ZIndex = (parent.ZIndex or 1) - 1,
			Image = "rbxassetid://6014261993",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 1 - intensity,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(49, 49, 450, 450),
			Parent = parent,
		})
	end

	-- Accent glow halo around a frame (used on active/hover states).
	function P.glow(parent, color, transparency)
		local s = P.stroke(parent, color, 1.5, transparency or 0.4)
		s.Name = "Glow"
		return s
	end

	function P.gradient(parent, colorSeq, rotation, transparencySeq)
		return Create("UIGradient", {
			Color = colorSeq,
			Rotation = rotation or 90,
			Transparency = transparencySeq or NumberSequence.new(0),
			Parent = parent,
		})
	end

	-- A standard themed surface card.
	function P.card(props)
		local card = Create("Frame", Util.Merge({
			BackgroundColor3 = Color3.fromRGB(18, 18, 24),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 40),
		}, props or {}))
		P.corner(card, 8)
		return card
	end

	-- Material-style ripple feedback on click (object-pooled per parent).
	function P.ripple(parent, x, y, color)
		local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.6
		local rel = parent.AbsolutePosition
		local circle = Create("Frame", {
			BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.82,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(x - rel.X, y - rel.Y),
			Size = UDim2.fromOffset(0, 0),
			ZIndex = (parent.ZIndex or 1) + 5,
			Parent = parent,
		})
		P.corner(circle, 999)
		local clip = parent.ClipsDescendants
		parent.ClipsDescendants = true
		Tween.to(circle, { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 }, 0.45, function()
			circle:Destroy()
			parent.ClipsDescendants = clip
		end)
	end

	-- Scaling input region helper (Touch + Mouse) — returns press/release signals.
	function P.scaleText(parent, min, max)
		return Create("UITextSizeConstraint", {
			MinTextSize = min or 8, MaxTextSize = max or 24, Parent = parent,
		})
	end

	return P
end)


--============================================================================--
--  MODULE :: State   (global flag registry — source of truth for config)
--============================================================================--
define("State", function(import)
	local Signal = import("Signal")
	local State = {}; State.__index = State

	function State.new()
		return setmetatable({
			Flags = {},        -- flag -> current value
			_components = {},   -- flag -> component handle (with :Set / :Get)
			Changed = Signal.new(), -- fires (flag, value)
		}, State)
	end

	-- Register a component under a flag. `component` must expose Get/Set.
	function State:Register(flag, component, defaultValue)
		if not flag then return end
		self._components[flag] = component
		if self.Flags[flag] == nil then
			self.Flags[flag] = defaultValue
		end
	end

	function State:Get(flag) return self.Flags[flag] end

	-- Set a flag's stored value AND push it into its component (if present).
	function State:Set(flag, value, silent)
		self.Flags[flag] = value
		local comp = self._components[flag]
		if comp and comp.Set then
			comp:Set(value, true) -- true => don't re-write state (avoid loops)
		end
		if not silent then self.Changed:Fire(flag, value) end
	end

	-- Called by components when their value changes from user interaction.
	function State:Push(flag, value)
		self.Flags[flag] = value
		self.Changed:Fire(flag, value)
	end

	-- Snapshot all flags for serialization.
	function State:Snapshot()
		local out = {}
		for flag, value in pairs(self.Flags) do
			-- Serialize special types so they survive JSON encoding.
			if typeof(value) == "Color3" then
				out[flag] = { __type = "Color3", value = { math.floor(value.R*255+0.5), math.floor(value.G*255+0.5), math.floor(value.B*255+0.5) } }
			elseif typeof(value) == "EnumItem" then
				out[flag] = { __type = "Enum", value = tostring(value) }
			else
				out[flag] = value
			end
		end
		return out
	end

	-- Restore a snapshot, pushing each value into its component.
	function State:Restore(snapshot)
		if type(snapshot) ~= "table" then return end
		for flag, raw in pairs(snapshot) do
			local value = raw
			if type(raw) == "table" and raw.__type then
				if raw.__type == "Color3" then
					value = Color3.fromRGB(raw.value[1], raw.value[2], raw.value[3])
				elseif raw.__type == "Enum" then
					-- "Enum.KeyCode.E" -> EnumItem
					local parts = string.split(raw.value, ".")
					if #parts == 3 then
						local ok, item = pcall(function() return Enum[parts[2]][parts[3]] end)
						value = ok and item or raw.value
					end
				end
			end
			self:Set(flag, value, true)
		end
	end

	return State
end)


--============================================================================--
--  MODULE :: Hotkeys   (centralized keybind / hotkey manager)
--============================================================================--
define("Hotkeys", function(import)
	local UserInputService = game:GetService("UserInputService")
	local Signal = import("Signal")
	local Maid = import("Maid")

	local Hotkeys = {}; Hotkeys.__index = Hotkeys

	function Hotkeys.new()
		local self = setmetatable({}, Hotkeys)
		self._binds = {}              -- id -> { key, mode, callback, state }
		self._maid = Maid.new()
		self.ConflictDetected = Signal.new() -- fires (key, list of ids)
		self:_listen()
		return self
	end

	function Hotkeys:_listen()
		self._maid:Give(UserInputService.InputBegan:Connect(function(input, gpe)
			-- NOTE: Roblox marks some keys (RightShift / LeftShift / Ctrl, etc.) as
			-- `gameProcessedEvent = true` because the core scripts watch them (shift
			-- lock). Blanket-ignoring gpe would make those keys unusable as hotkeys,
			-- so we only bail when the player is actually typing in a text box.
			if gpe and UserInputService:GetFocusedTextBox() then return end
			self:_dispatch(input, true)
		end))
		self._maid:Give(UserInputService.InputEnded:Connect(function(input, gpe)
			self:_dispatch(input, false)
		end))
	end

	local function keyOf(input)
		if input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then return Enum.UserInputType.MouseButton1
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then return Enum.UserInputType.MouseButton2
		elseif input.UserInputType == Enum.UserInputType.MouseButton3 then return Enum.UserInputType.MouseButton3 end
		return nil
	end

	function Hotkeys:_dispatch(input, began)
		-- While a keybind is being captured, every hotkey is muted so the key the
		-- user is pressing doesn't also trigger actions (e.g. toggling the UI).
		if self._capturing then return end
		local key = keyOf(input)
		if not key then return end
		for _, bind in pairs(self._binds) do
			if bind.key == key and bind.enabled ~= false then
				if bind.mode == "Toggle" then
					if began then
						bind.state = not bind.state
						task.spawn(bind.callback, bind.state)
					end
				elseif bind.mode == "Hold" then
					bind.state = began
					task.spawn(bind.callback, began)
				else -- "Always" fires on press
					if began then task.spawn(bind.callback, true) end
				end
			end
		end
	end

	-- Bind. mode: "Toggle" | "Hold" | "Always". Returns the bind id.
	function Hotkeys:Bind(id, key, mode, callback)
		self._binds[id] = { key = key, mode = mode or "Toggle", callback = callback, state = false, enabled = true }
		return id
	end

	function Hotkeys:Rebind(id, newKey)
		local b = self._binds[id]
		if not b then return end
		b.key = newKey
		-- Conflict detection: report any other bind sharing this key.
		local clashing = {}
		for otherId, ob in pairs(self._binds) do
			if otherId ~= id and ob.key == newKey then table.insert(clashing, otherId) end
		end
		if #clashing > 0 then self.ConflictDetected:Fire(newKey, clashing) end
		return clashing
	end

	function Hotkeys:SetEnabled(id, enabled)
		if self._binds[id] then self._binds[id].enabled = enabled end
	end
	function Hotkeys:Unbind(id) self._binds[id] = nil end
	function Hotkeys:Get(id) return self._binds[id] end

	-- Duplicate-key protection: returns the id of any OTHER action already using
	-- `key` (or nil if free). Reserved/disabled binds still count as "in use".
	function Hotkeys:KeyInUse(key, exceptId)
		if key == nil then return nil end
		for id, b in pairs(self._binds) do
			if id ~= exceptId and b.key == key then return id end
		end
		return nil
	end

	-- Register a non-firing placeholder so a key (e.g. the window toggle key) is
	-- accounted for by KeyInUse without being dispatched as a hotkey.
	function Hotkeys:Reserve(id, key)
		self._binds[id] = { key = key, mode = "Reserved", callback = function() end,
			state = false, enabled = false, reserved = true }
		return id
	end

	-- Capture mode: while active, no hotkey/toggle fires. Used by Keybind controls
	-- so the key being assigned doesn't simultaneously trigger an action.
	function Hotkeys:BeginCapture() self._capturing = true end
	function Hotkeys:EndCapture() self._capturing = false end
	function Hotkeys:IsCapturing() return self._capturing == true end

	function Hotkeys:Destroy()
		self._maid:DoCleaning()
		table.clear(self._binds)
	end

	-- Human-readable name for a key for display.
	function Hotkeys.KeyName(key)
		if typeof(key) == "EnumItem" then
			local n = tostring(key):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
			return n
		end
		return tostring(key)
	end

	return Hotkeys
end)


--============================================================================--
--  MODULE :: Notify   (notification system: queue, progress, sounds, types)
--============================================================================--
define("Notify", function(import)
	local Util = import("Util")
	local Tween = import("Tween")
	local Maid = import("Maid")
	local Icons = import("Icons")
	local P = import("Primitives")
	local Create = Util.Create

	local SoundService = game:GetService("SoundService")

	local Notify = {}; Notify.__index = Notify

	-- Per-type presets: color token, monochrome status glyph, sound id.
	local TYPES = {
		success = { color = "Success", glyph = "✓", sound = "rbxassetid://9116367941" },
		error   = { color = "Error",   glyph = "✕", sound = "rbxassetid://9116367941" },
		warning = { color = "Warning", glyph = "!", sound = "rbxassetid://9116367941" },
		info    = { color = "Info",    glyph = "i", sound = "rbxassetid://9116367941" },
	}

	function Notify.new(theme, parentGui)
		local self = setmetatable({}, Notify)
		self.Theme = theme
		self.SoundEnabled = true
		self.MaxVisible = 5
		self._queue = {}
		self._active = {}
		self._maid = Maid.new()

		self.Holder = Create("Frame", {
			Name = "i2_Notifications",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.new(0, 300, 1, -32),
			ZIndex = 5000,
			Parent = parentGui,
		})
		Create("UIListLayout", {
			Padding = UDim.new(0, 10),
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = self.Holder,
		})
		self._maid:Give(self.Holder)
		return self
	end

	function Notify:_playSound(id)
		if not self.SoundEnabled or not id then return end
		local s = Create("Sound", { SoundId = id, Volume = 0.5, Parent = SoundService })
		s:Play()
		s.Ended:Once(function() s:Destroy() end)
		task.delay(3, function() if s.Parent then s:Destroy() end end)
	end

	--[[
		Notify:Push({
			Title = "Saved", Content = "Config stored.",
			Type = "success" | "error" | "warning" | "info",
			Icon = "save", Duration = 4, Sound = true,
			Buttons = { { Text = "Undo", Callback = fn } },
		})
	--]]
	function Notify:Push(opts)
		opts = opts or {}
		table.insert(self._queue, opts)
		self:_drain()
		return opts
	end

	function Notify:_drain()
		while #self._queue > 0 and #self._active < self.MaxVisible do
			local opts = table.remove(self._queue, 1)
			self:_render(opts)
		end
	end

	function Notify:_render(opts)
		local theme = self.Theme
		local typ = TYPES[(opts.Type or "info"):lower()] or TYPES.info
		local accent = theme:Get(typ.color)
		local duration = opts.Duration or 4
		local maid = Maid.new()

		local hasContent = opts.Content and opts.Content ~= ""
		local hasButtons = opts.Buttons ~= nil
		local barH = hasButtons and 74 or (hasContent and 52 or 40)

		-- Thin toast bar — no outline; the content slides in from the right.
		local card = Create("CanvasGroup", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.25,
			GroupTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, barH),
			ClipsDescendants = true,
			ZIndex = 5001,
			Parent = self.Holder,
		})
		P.corner(card, 10)
		P.shadow(card, 0.4, 34)

		-- Left accent strip indicating the notification type (this is not an outline).
		local strip = Create("Frame", {
			BackgroundColor3 = accent, BorderSizePixel = 0,
			Size = UDim2.new(0, 3, 1, 0), ZIndex = 5004, Parent = card,
		})
		P.gradient(strip, ColorSequence.new(Util.Shade(accent, -0.12), Util.Shade(accent, 0.18)), 90)

		-- Sliding content holder — animates from off-right into place.
		local inner = Create("Frame", {
			BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			Position = UDim2.new(1, 0, 0, 0), ZIndex = 5002, Parent = card,
		})

		-- Compact icon badge, vertically centred.
		local badge = Create("Frame", {
			BackgroundColor3 = accent, BackgroundTransparency = 0.85, BorderSizePixel = 0,
			Size = UDim2.fromOffset(26, 26), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0),
			ZIndex = 5003, Parent = inner,
		})
		P.corner(badge, 8)
		-- If an explicit image icon was passed, use it; otherwise the monochrome glyph.
		if not P.icon(badge, opts.Icon, 16, accent, { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), ZIndex = 5004 }) then
			Create("TextLabel", { BackgroundTransparency = 1, Text = typ.glyph, Font = theme:Get("FontBold"),
				TextSize = 15, TextColor3 = accent, AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(18, 18), ZIndex = 5004, Parent = badge })
		end

		-- Text column, centred vertically, with room reserved for the close button.
		local col = Create("Frame", {
			BackgroundTransparency = 1, Position = UDim2.fromOffset(50, 0),
			Size = UDim2.new(1, -50 - 24, 1, 0), ZIndex = 5003, Parent = inner,
		})
		Create("UIListLayout", { Padding = UDim.new(0, 2), VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder, Parent = col })

		Create("TextLabel", {
			BackgroundTransparency = 1, Text = opts.Title or "Notification",
			Font = theme:Get("FontBold"), TextSize = 13, TextColor3 = theme:Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left, RichText = opts.RichText ~= false,
			Size = UDim2.new(1, 0, 0, 15), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5003, Parent = col,
		})
		if hasContent then
			Create("TextLabel", {
				BackgroundTransparency = 1, Text = opts.Content,
				Font = theme:Get("Font"), TextSize = 12, TextColor3 = theme:Get("TextDim"),
				TextXAlignment = Enum.TextXAlignment.Left, RichText = opts.RichText ~= false,
				Size = UDim2.new(1, 0, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5003, Parent = col,
			})
		end

		-- Action buttons (optional).
		if hasButtons then
			local brow = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), ZIndex = 5003, Parent = col })
			Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
				HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = brow })
			for _, b in ipairs(opts.Buttons) do
				local btn = Create("TextButton", {
					BackgroundColor3 = b.Primary and accent or theme:Get("SurfaceAlt"),
					BackgroundTransparency = b.Primary and 0.1 or 0, AutoButtonColor = false,
					Text = b.Text or "OK", Font = theme:Get("FontBold"), TextSize = 12,
					TextColor3 = theme:Get("Text"), Size = UDim2.fromOffset(72, 22), ZIndex = 5004, Parent = brow,
				})
				P.corner(btn, 6)
				btn.MouseButton1Click:Connect(function() if b.Callback then task.spawn(b.Callback) end end)
			end
		end

		-- Close button — same X image asset the window's close control uses.
		local closeBtn = Create("ImageButton", {
			BackgroundTransparency = 1, Image = "rbxassetid://10747384394", ImageColor3 = theme:Get("TextMuted"),
			Size = UDim2.fromOffset(13, 13), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0), ZIndex = 5005, Parent = inner,
		})
		closeBtn.MouseEnter:Connect(function() Tween.to(closeBtn, { ImageColor3 = theme:Get("Text") }, "Hover") end)
		closeBtn.MouseLeave:Connect(function() Tween.to(closeBtn, { ImageColor3 = theme:Get("TextMuted") }, "Hover") end)

		-- Bottom progress line (countdown).
		local progressTrack = Create("Frame", {
			BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 0.5, BorderSizePixel = 0,
			Size = UDim2.new(1, -22, 0, 2), AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -8, 1, -5), ZIndex = 5005, Parent = inner,
		})
		P.corner(progressTrack, 2)
		local progressFill = Create("Frame", {
			BackgroundColor3 = accent, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = 5006, Parent = progressTrack,
		})
		P.corner(progressFill, 2)
		P.gradient(progressFill, ColorSequence.new(Util.Shade(accent, -0.1), Util.Shade(accent, 0.15)), 0)

		-- Slide in from the right + fade.
		Tween.to(card, { GroupTransparency = 0 }, "Notify")
		Tween.to(inner, { Position = UDim2.new(0, 0, 0, 0) }, "Slide")
		if opts.Sound ~= false then self:_playSound(opts.Sound and opts.Sound or typ.sound) end

		local entry = { card = card, maid = maid }
		table.insert(self._active, entry)

		local dismissed = false
		local function dismiss()
			if dismissed then return end
			dismissed = true
			Tween.to(inner, { Position = UDim2.new(1, 0, 0, 0) }, "Slide")
			Tween.to(card, { GroupTransparency = 1 }, "Notify", function()
				maid:DoCleaning()
				card:Destroy()
				local idx = Util.IndexOf(self._active, entry)
				if idx then table.remove(self._active, idx) end
				self:_drain()
			end)
		end
		closeBtn.MouseButton1Click:Connect(dismiss)

		if duration and duration > 0 then
			Tween.to(progressFill, { Size = UDim2.new(0, 0, 1, 0) }, { time = duration, style = Enum.EasingStyle.Linear })
			maid:Give(task.delay(duration, dismiss))
		else
			progressTrack:Destroy()
		end
		return { Dismiss = dismiss }
	end

	function Notify:Destroy()
		self._maid:DoCleaning()
		table.clear(self._active)
		table.clear(self._queue)
	end

	return Notify
end)


--============================================================================--
--  MODULE :: Components   (every built-in UI element)
--============================================================================--
define("Components", function(import)
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local Util = import("Util")
	local Tween = import("Tween")
	local Maid = import("Maid")
	local Icons = import("Icons")
	local P = import("Primitives")
	local Signal = import("Signal")
	local Create = Util.Create

	local C = {}

	-- Keybind capture rules (shared by Keybind + Toggle bind-to-key).
	--   CLEAR_KEYS  -> pressing one of these clears the bind to None.
	--   SKIP_KEYS   -> reserved/navigation keys that simply cancel the capture
	--                  (the existing bind is kept) instead of being assigned.
	local CLEAR_KEYS = {
		[Enum.KeyCode.Escape] = true,
		[Enum.KeyCode.Backspace] = true,
		[Enum.KeyCode.Delete] = true,
	}
	local SKIP_KEYS = {
		[Enum.KeyCode.Unknown] = true,
		[Enum.KeyCode.Tab] = true,
		[Enum.KeyCode.Return] = true,
		[Enum.KeyCode.LeftSuper] = true,
		[Enum.KeyCode.RightSuper] = true,
		[Enum.KeyCode.Menu] = true,
	}

	-- Shared context fields expected on `ctx`:
	--   theme, state, hotkeys, notify, parent (container Instance), maid
	-- Each constructor returns a `handle` table.

	-- A standard horizontal "row card": label/desc on the left, control area right.
	local function baseRow(ctx, opts, height)
		local theme = ctx.theme
		local row = P.card({
            BackgroundColor3 = theme:Get("Surface"),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, height or 40),
			Parent = ctx.parent,
			LayoutOrder = opts.LayoutOrder,
		})
		theme:Apply(row, { BackgroundColor3 = "Surface" })
		local stroke = P.stroke(row, theme:Get("Border"), 1, 0.35)
		theme:Apply(stroke, { Color = "Border" })

		local textHolder = Create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -24, 1, 0),
			Parent = row,
		})
		Create("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, Parent = textHolder,
		})
		local title = Create("TextLabel", {
			BackgroundTransparency = 1, Text = opts.Name or opts.Text or "Label",
			Font = theme:Get("FontBold"), TextSize = 14, TextColor3 = theme:Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 16), Parent = textHolder,
		})
		theme:Apply(title, { TextColor3 = "Text" })
		local desc
		if opts.Description then
			desc = Create("TextLabel", {
				BackgroundTransparency = 1, Text = opts.Description,
				Font = theme:Get("Font"), TextSize = 12, TextColor3 = theme:Get("TextDim"),
				TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
				AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 14), Parent = textHolder,
			})
			theme:Apply(desc, { TextColor3 = "TextDim" })
		end

		-- Hover feedback.
        local hoverConn1 = row.MouseEnter:Connect(function()
            Tween.to(row, { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 0.7 }, "Hover")
        end)
        local hoverConn2 = row.MouseLeave:Connect(function()
            Tween.to(row, { BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1 }, "Hover")
        end)
		ctx.maid:Give(hoverConn1); ctx.maid:Give(hoverConn2)

		return row, title, desc, textHolder
	end

	-- Tooltips have been removed from the library entirely. This no-op stub is kept
	-- so the existing internal call sites remain valid without creating any UI.
	local function attachTooltip() end


	----------------------------------------------------------------------------
	-- Label
	----------------------------------------------------------------------------
	function C.Label(ctx, opts)
		local theme = ctx.theme
		local lbl = Create("TextLabel", {
			BackgroundTransparency = 1, Text = opts.Text or "Label",
			Font = theme:Get(opts.Bold and "FontBold" or "Font"),
			TextSize = opts.TextSize or 14, TextColor3 = theme:Get(opts.Color or "Text"),
			TextXAlignment = opts.Align or Enum.TextXAlignment.Left,
			TextWrapped = true, RichText = opts.RichText ~= false,
			AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 16),
			LayoutOrder = opts.LayoutOrder, Parent = ctx.parent,
		})
		theme:Apply(lbl, { TextColor3 = opts.Color or "Text" })
		return {
			Instance = lbl,
			Set = function(_, txt) lbl.Text = txt end,
			Get = function() return lbl.Text end,
			Destroy = function() lbl:Destroy() end,
		}
	end

	----------------------------------------------------------------------------
	-- Paragraph (title + body block)
	----------------------------------------------------------------------------
	function C.Paragraph(ctx, opts)
		local theme = ctx.theme
        local card = P.card({ BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = opts.LayoutOrder, Parent = ctx.parent })
		theme:Apply(card, { BackgroundColor3 = "Surface" })
		P.stroke(card, theme:Get("Border"), 1, 0.4)
		P.padding(card, 12)
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
		local title = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Title or "Title",
			Font = theme:Get("FontBold"), TextSize = 14, TextColor3 = theme:Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 16), Parent = card })
		theme:Apply(title, { TextColor3 = "Text" })
		local body = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Content or opts.Text or "",
			Font = theme:Get("Font"), TextSize = 13, TextColor3 = theme:Get("TextDim"),
			TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, RichText = opts.RichText ~= false,
			AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 14), Parent = card })
		theme:Apply(body, { TextColor3 = "TextDim" })
		return {
			Instance = card,
			Set = function(_, txt) body.Text = txt end,
			SetTitle = function(_, t) title.Text = t end,
			Get = function() return body.Text end,
			Destroy = function() card:Destroy() end,
		}
	end

	----------------------------------------------------------------------------
	-- Divider
	----------------------------------------------------------------------------
    function C.Divider(ctx, opts)
        local theme = ctx.theme
        local holder = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, opts.Text and 20 or 8),
            LayoutOrder = opts.LayoutOrder, Parent = ctx.parent })
        if opts.Text then
            local lbl = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Text:upper(),
                Font = theme:Get("FontBold"), TextSize = 12, TextColor3 = theme:Get("TextMuted"),
                AutomaticSize = Enum.AutomaticSize.XY, AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5), Parent = holder })
            theme:Apply(lbl, { TextColor3 = "TextMuted" })
        else
            local line = Create("Frame", { BackgroundColor3 = theme:Get("Border"), BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 0, 1), Parent = holder })
            theme:Apply(line, { BackgroundColor3 = "Border" })
        end
        return { Instance = holder, Destroy = function() holder:Destroy() end }
    end

	----------------------------------------------------------------------------
	-- Button
	----------------------------------------------------------------------------
	function C.Button(ctx, opts)
		local theme = ctx.theme
		local btn = Create("TextButton", {
			BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1, AutoButtonColor = false,
			Text = "", Size = UDim2.new(1, 0, 0, opts.Height or 38),
			LayoutOrder = opts.LayoutOrder, ClipsDescendants = true, Parent = ctx.parent,
		})
		theme:Apply(btn, { BackgroundColor3 = "Surface" })
		P.corner(btn, 8)
		local stroke = P.stroke(btn, theme:Get("Border"), 1, 0.3)
		theme:Apply(stroke, { Color = "Border" })

		-- Icon only renders if an explicit image asset was passed.
		local ic = opts.Icon and P.icon(btn, opts.Icon, 16, theme:Get(opts.Primary and "Text" or "Accent"), {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0) })
		local label = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Name or opts.Text or "Button",
			Font = theme:Get("FontBold"), TextSize = 14, TextColor3 = theme:Get("Text"),
			Size = UDim2.new(1, 0, 1, 0),
			TextXAlignment = ic and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center, Parent = btn })
		if ic then label.Position = UDim2.fromOffset(36, 0); label.Size = UDim2.new(1, -36, 1, 0) end
		theme:Apply(label, { TextColor3 = "Text" })
        if opts.Primary then
            theme:Apply(label, { TextColor3 = "Accent" })
            theme:Apply(stroke, { Color = "Accent" })
            if ic then theme:Apply(ic, { ImageColor3 = "Accent" }) end
        end
        btn.MouseEnter:Connect(function()
            Tween.to(btn, { BackgroundColor3 = opts.Primary and theme:Get("Accent") or theme:Get("SurfaceAlt"), BackgroundTransparency = 0.8 }, "Hover")
        end)
        btn.MouseLeave:Connect(function()
            Tween.to(btn, { BackgroundColor3 = opts.Primary and theme:Get("Accent") or theme:Get("Surface"), BackgroundTransparency = 1 }, "Hover")
        end)
		btn.MouseButton1Down:Connect(function() Tween.to(btn, { Size = UDim2.new(1, -4, 0, (opts.Height or 38) - 2) }, "Press") end)
		btn.MouseButton1Up:Connect(function() Tween.to(btn, { Size = UDim2.new(1, 0, 0, opts.Height or 38) }, "Press") end)
		btn.MouseButton1Click:Connect(function(...)
			local x, y = UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y
			P.ripple(btn, x, y, opts.Primary and Color3.new(1,1,1) or theme:Get("Accent"))
			if opts.Callback then task.spawn(opts.Callback) end
		end)
		attachTooltip(ctx, btn, opts.Tooltip)

		return {
			Instance = btn,
			SetText = function(_, t) label.Text = t end,
			Fire = function() if opts.Callback then task.spawn(opts.Callback) end end,
			Destroy = function() btn:Destroy() end,
		}
	end

	----------------------------------------------------------------------------
	-- Toggle  (also serves "Switch")
	----------------------------------------------------------------------------
	function C.Toggle(ctx, opts)
		local theme = ctx.theme
		local value = opts.Default
		if opts.Flag and ctx.state:Get(opts.Flag) ~= nil then value = ctx.state:Get(opts.Flag) end
		value = value and true or false

		-- Toggles are expandable. The visible row is a header; an attached settings
		-- panel (collapsed by default) holds nested controls. Every toggle ships with
		-- at least a keybind control inside that panel, so the whole thing lives in an
		-- auto-growing card rather than the fixed-height baseRow.
		local card = P.card({
			BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = opts.LayoutOrder, Parent = ctx.parent,
		})
		theme:Apply(card, { BackgroundColor3 = "Surface" })
		local cardStroke = P.stroke(card, theme:Get("Border"), 1, 0.35)
		theme:Apply(cardStroke, { Color = "Border" })
		Create("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })

		-- Header row: the clickable / hover surface. Left-click toggles the value,
		-- right-click expands the settings panel.
		local row = Create("TextButton", {
			BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1, AutoButtonColor = false,
			Text = "", Size = UDim2.new(1, 0, 0, 40), LayoutOrder = 0, Parent = card,
		})
		P.corner(row, 8)

		local textHolder = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(1, -24, 1, 0), Parent = row })
		Create("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, Parent = textHolder })
		local title = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Name or opts.Text or "Toggle",
			Font = theme:Get("FontBold"), TextSize = 14, TextColor3 = theme:Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 16), Parent = textHolder })
		theme:Apply(title, { TextColor3 = "Text" })
		if opts.Description then
			local desc = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Description,
				Font = theme:Get("Font"), TextSize = 12, TextColor3 = theme:Get("TextDim"),
				TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
				AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 14), Parent = textHolder })
			theme:Apply(desc, { TextColor3 = "TextDim" })
		end

		-- Hover feedback (header only — never the expanded panel).
		ctx.maid:Give(row.MouseEnter:Connect(function()
			Tween.to(row, { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 0.7 }, "Hover")
		end))
		ctx.maid:Give(row.MouseLeave:Connect(function()
			Tween.to(row, { BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1 }, "Hover")
		end))

		-- Right-hand controls, right-aligned: [switch] [keybind tag] [expand arrow].
		local controls = Create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X, Parent = row })
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = controls })

		local track = Create("Frame", {
			BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.fromOffset(42, 22), LayoutOrder = 1, Parent = controls,
		})
		P.corner(track, 11)
		local trackStroke = P.stroke(track, theme:Get("Border"), 1, 0.2)
		local knob = Create("Frame", {
			BackgroundColor3 = theme:Get("TextDim"), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
			Size = UDim2.fromOffset(16, 16), Parent = track,
		})
		P.corner(knob, 8)

		-- Keybind tag: only parented (shown) while a key is bound. LayoutOrder 0 puts it
		-- LEFT of the toggle switch (and the arrow), not between them.
		local keyTag = Create("TextLabel", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 0.4,
			Text = "", Font = theme:Get("FontBold"), TextSize = 12, TextColor3 = theme:Get("Accent"),
			AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 22), LayoutOrder = 0 })
		P.corner(keyTag, 6); P.stroke(keyTag, theme:Get("Border"), 1, 0.3)
		P.padding(keyTag, 0, { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
		ctx.maid:Give(keyTag)

		-- Expand / collapse arrow (chevron, matching the dropdown icon).
		local arrowBtn = Create("TextButton", { BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
			Size = UDim2.fromOffset(18, 18), LayoutOrder = 3, Parent = controls })
		local arrow = Create("ImageLabel", { BackgroundTransparency = 1, Image = Icons.get("chevron-down") or "",
			ImageColor3 = theme:Get("TextDim"), Size = UDim2.fromScale(1, 1), Parent = arrowBtn })

		-- Settings panel (collapsed by default), with a thin top divider.
		local panelClip = Create("Frame", { BackgroundTransparency = 1, ClipsDescendants = true,
			Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 1, Parent = card })
		local panel = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, Parent = panelClip })
		Create("UIListLayout", { Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder, Parent = panel })
		local divider = Create("Frame", { BackgroundColor3 = theme:Get("Border"), BackgroundTransparency = 0.4,
			BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), LayoutOrder = 0, Parent = panel })
		theme:Apply(divider, { BackgroundColor3 = "Border" })
		local panelBody = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = panel })
		P.padding(panelBody, 0, { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 6) })
		P.listLayout(panelBody, 8)

		local handle = { Instance = card }
		handle.Changed = Signal.new()
		local function visual(animate)
			local spec = animate and "Toggle" or 0
			if value then
				Tween.to(track, { BackgroundColor3 = theme:Get("Accent"), BackgroundTransparency = 0 }, spec)
				Tween.to(knob, { Position = UDim2.new(1, -19, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1) }, spec)
				Tween.to(trackStroke, { Color = theme:Get("AccentGlow"), Transparency = 0.1 }, spec)
			else
				Tween.to(track, { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1 }, spec)
				Tween.to(knob, { Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = theme:Get("TextDim") }, spec)
				Tween.to(trackStroke, { Color = theme:Get("Border"), Transparency = 0.2 }, spec)
			end
		end

		function handle:Set(v, fromState)
			value = v and true or false
			visual(true)
			if not fromState then
				if opts.Flag then ctx.state:Push(opts.Flag, value) end
			end
			handle.Changed:Fire(value)
			if opts.Callback then task.spawn(opts.Callback, value) end
		end
		function handle:Get() return value end

		--==[ Expand / collapse the settings panel ]==--
		local expanded = false
		local function applyExpand(animate)
			Tween.to(arrow, { Rotation = expanded and 180 or 0 }, "Hover")
			if animate then
				panelClip.ClipsDescendants = true
				local fromH = panelClip.AbsoluteSize.Y
				local toH = expanded and panel.AbsoluteSize.Y or 0
				panelClip.AutomaticSize = Enum.AutomaticSize.None
				panelClip.Size = UDim2.new(1, 0, 0, fromH)
				Tween.to(panelClip, { Size = UDim2.new(1, 0, 0, toH) }, "Expand", function()
					if expanded then
						panelClip.AutomaticSize = Enum.AutomaticSize.Y
						panelClip.ClipsDescendants = false
					end
				end)
			elseif expanded then
				panelClip.AutomaticSize = Enum.AutomaticSize.Y
				panelClip.ClipsDescendants = false
			else
				panelClip.AutomaticSize = Enum.AutomaticSize.None
				panelClip.Size = UDim2.new(1, 0, 0, 0)
				panelClip.ClipsDescendants = true
			end
		end
		local function setExpanded(state)
			if expanded == state then return end
			expanded = state
			applyExpand(true)
		end
		function handle:Expand() setExpanded(true) end
		function handle:Collapse() setExpanded(false) end
		function handle:ToggleSettings() setExpanded(not expanded) end
		function handle:IsExpanded() return expanded end

		--==[ Nested settings controls (sliders / toggles / buttons / dropdowns…) ]==--
		local panelCtx = {
			theme = ctx.theme, state = ctx.state, hotkeys = ctx.hotkeys, notify = ctx.notify,
			root = ctx.root, parent = panelBody, maid = ctx.maid,
			library = ctx.library, window = ctx.window,
		}
		local function addControl(kind, o)
			local ctor = C[kind]
			assert(ctor, "i2Library: unknown component type '" .. tostring(kind) .. "'")
			return ctor(panelCtx, o or {})
		end
		function handle:Add(kind, o) return addControl(kind, o) end
		for _, n in ipairs({ "Label", "Paragraph", "Divider", "Button", "Toggle", "Checkbox",
			"RadioGroup", "Code", "Slider", "Dropdown", "MultiDropdown", "SearchDropdown",
			"Keybind", "Textbox", "ColorPicker", "Image", "Avatar", "ProgressBar", "Spinner" }) do
			handle["Add" .. n] = function(_, o) return addControl(n, o) end
		end

		--==[ Default keybind control: binds a key that toggles this toggle ]==--
		local function updateKeyTag(k)
			if k then
				keyTag.Text = ctx.hotkeys.KeyName(k)
				keyTag.Parent = controls
			else
				keyTag.Parent = nil
			end
		end
		local kbHandle
		if not opts.NoKeybind then
			kbHandle = addControl("Keybind", {
				Name = opts.KeybindName or "Keybind",
				Description = opts.KeybindDescription or "Bind a key to toggle this",
				Mode = "Always", Default = opts.Key,
				Flag = opts.Flag and (opts.Flag .. "__togglekey") or nil,
				Callback = function() handle:Set(not value) end,
				OnChanged = function(k) updateKeyTag(k) end,
			})
			updateKeyTag(kbHandle:Get())
		end
		function handle:SetKeybind(k) if kbHandle then kbHandle:Set(k) end end
		function handle:GetKeybind() return kbHandle and kbHandle:Get() or nil end

		--==[ Input wiring ]==--
		arrowBtn.MouseEnter:Connect(function() Tween.to(arrow, { ImageColor3 = theme:Get("Text") }, "Hover") end)
		arrowBtn.MouseLeave:Connect(function() Tween.to(arrow, { ImageColor3 = theme:Get("TextDim") }, "Hover") end)
		arrowBtn.MouseButton1Click:Connect(function() handle:ToggleSettings() end)
		arrowBtn.MouseButton2Click:Connect(function() handle:ToggleSettings() end)
		-- Row input. Single tap/click flips the value; a quick DOUBLE tap/click opens
		-- the settings panel. Double-tap is the primary way to reach a toggle's settings
		-- on mobile/touch, where there is no right-click and the little arrow is fiddly
		-- to hit. The second tap of a double-tap reverts the value the first tap applied,
		-- so a double-tap leaves the toggle's value unchanged and just expands/collapses.
		local DOUBLE_TAP_WINDOW = 0.32
		local lastRowTap = 0
		row.MouseButton1Click:Connect(function()
			local now = os.clock()
			if now - lastRowTap <= DOUBLE_TAP_WINDOW then
				lastRowTap = 0
				handle:Set(not value)        -- undo the first tap's toggle
				handle:ToggleSettings()
			else
				lastRowTap = now
				handle:Set(not value)
			end
		end)
		row.MouseButton2Click:Connect(function() handle:ToggleSettings() end)

		-- Optional builder: opts.Build(handle) lets callers populate the panel inline.
		if opts.Build then opts.Build(handle) end

		applyExpand(false) -- start collapsed
		visual(false)
		function handle:Destroy()
			if kbHandle then kbHandle:Destroy() end
			card:Destroy()
		end
		if opts.Flag then ctx.state:Register(opts.Flag, handle, value) end
		attachTooltip(ctx, row, opts.Tooltip or opts.Description or ("Toggle: " .. (opts.Name or "")))
		return handle
	end

	----------------------------------------------------------------------------
	-- Checkbox
	----------------------------------------------------------------------------
	function C.Checkbox(ctx, opts)
		local theme = ctx.theme
		local value = opts.Default
		if opts.Flag and ctx.state:Get(opts.Flag) ~= nil then value = ctx.state:Get(opts.Flag) end
		value = value and true or false
		local row = baseRow(ctx, opts)
		local box = Create("Frame", { BackgroundColor3 = theme:Get("SurfaceAlt"), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(22, 22), Parent = row })
		P.corner(box, 6)
		local boxStroke = P.stroke(box, theme:Get("Border"), 1.5, 0.1)
		local tick = Create("TextLabel", { BackgroundTransparency = 1, Text = "✓", Font = Enum.Font.GothamBold,
			TextSize = 14, TextColor3 = Color3.new(1,1,1), TextTransparency = value and 0 or 1,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(16, 16), Parent = box })

		local handle = { Instance = row }
		local function visual(a)
			local spec = a and "Toggle" or 0
			if value then
				Tween.to(box, { BackgroundColor3 = theme:Get("Accent"), BackgroundTransparency = 0 }, spec)
				Tween.to(boxStroke, { Color = theme:Get("AccentGlow") }, spec)
				Tween.to(tick, { TextTransparency = 0 }, spec)
			else
				Tween.to(box, { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1 }, spec)
				Tween.to(boxStroke, { Color = theme:Get("Border") }, spec)
				Tween.to(tick, { TextTransparency = 1 }, spec)
			end
		end
		function handle:Set(v, fromState)
			value = v and true or false; visual(true)
			if not fromState and opts.Flag then ctx.state:Push(opts.Flag, value) end
			if opts.Callback then task.spawn(opts.Callback, value) end
		end
		function handle:Get() return value end
		function handle:Destroy() row:Destroy() end
		local click = Create("TextButton", { BackgroundTransparency = 1, Text = "", Size = UDim2.fromScale(1,1), Parent = row })
		click.MouseButton1Click:Connect(function()
			handle:Set(not value)
		end)
		visual(false)
		if opts.Flag then ctx.state:Register(opts.Flag, handle, value) end
		return handle
	end

	----------------------------------------------------------------------------
	-- Radio group
	----------------------------------------------------------------------------
	function C.RadioGroup(ctx, opts)
		local theme = ctx.theme
		local options = opts.Options or {}
		local value = opts.Default or options[1]
		if opts.Flag and ctx.state:Get(opts.Flag) ~= nil then value = ctx.state:Get(opts.Flag) end

		local card = P.card({ BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0),
			AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = opts.LayoutOrder, Parent = ctx.parent })
		theme:Apply(card, { BackgroundColor3 = "Surface" })
		local cardStroke = P.stroke(card, theme:Get("Border"), 1, 0.35); theme:Apply(cardStroke, { Color = "Border" })
		P.padding(card, 10)
		Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
		if opts.Name then
			local nameLabel = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Name, Font = theme:Get("FontBold"),
				TextSize = 14, TextColor3 = theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 16), Parent = card })
			theme:Apply(nameLabel, { TextColor3 = "Text" })
		end
		local dots = {}
		local handle = { Instance = card }
		local function refresh()
			for opt, dot in pairs(dots) do
				local on = (opt == value)
				Tween.to(dot.fill, { Size = on and UDim2.fromOffset(8,8) or UDim2.fromOffset(0,0) }, "Toggle")
				Tween.to(dot.ring, { Color = on and theme:Get("Accent") or theme:Get("Border") }, "Hover")
			end
		end
		for _, opt in ipairs(options) do
			local optRow = Create("TextButton", { BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 24), Parent = card })
        local circle = Create("Frame", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.fromOffset(18, 18), Parent = optRow })
			P.corner(circle, 9)
			-- Ring colour is driven by refresh()/hover, so it is intentionally not
			-- registered with theme:Apply (mirrors the Toggle/Checkbox stroke handling).
			local ring = P.stroke(circle, theme:Get("Border"), 2, 0)
			-- Flat accent dot, sized in offsets and centred via AnchorPoint so it stays
			-- perfectly concentric with the ring (a scale-sized + gradient dot read as
			-- off-centre). Matches the solid indicators used by Toggle/Checkbox.
			local fill = Create("Frame", { BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(0,0), Parent = circle })
			P.corner(fill, 999); theme:Apply(fill, { BackgroundColor3 = "Accent" })
			local optLabel = Create("TextLabel", { BackgroundTransparency = 1, Text = tostring(opt), Font = theme:Get("Font"),
				TextSize = 13, TextColor3 = theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(26, 0), Size = UDim2.new(1, -26, 1, 0), Parent = optRow })
			theme:Apply(optLabel, { TextColor3 = "Text" })
			dots[opt] = { ring = ring, fill = fill }
			-- Subtle hover feedback to match the new-style interactive rows.
			ctx.maid:Give(optRow.MouseEnter:Connect(function()
				if opt ~= value then Tween.to(ring, { Color = theme:Get("TextDim") }, "Hover") end
			end))
			ctx.maid:Give(optRow.MouseLeave:Connect(function()
				if opt ~= value then Tween.to(ring, { Color = theme:Get("Border") }, "Hover") end
			end))
			optRow.MouseButton1Click:Connect(function() handle:Set(opt) end)
		end
		function handle:Set(v, fromState)
			value = v; refresh()
			if not fromState and opts.Flag then ctx.state:Push(opts.Flag, value) end
			if opts.Callback then task.spawn(opts.Callback, value) end
		end
		function handle:Get() return value end
		function handle:Destroy() card:Destroy() end
		refresh()
		if opts.Flag then ctx.state:Register(opts.Flag, handle, value) end
		return handle
	end

	----------------------------------------------------------------------------
	-- Slider  (min/max/decimals, drag, input box, touch)
	----------------------------------------------------------------------------
	function C.Slider(ctx, opts)
		local theme = ctx.theme
		local min, max = opts.Min or 0, opts.Max or 100
		local decimals = opts.Decimals or 0
		local value = opts.Default or min
		if opts.Flag and ctx.state:Get(opts.Flag) ~= nil then value = ctx.state:Get(opts.Flag) end
		value = Util.Clamp(value, min, max)
        local row, title, desc, textHolder = baseRow(ctx, opts, 56)
        row.Size = UDim2.new(1, 0, 0, desc and 74 or 56)
        textHolder.Size = UDim2.new(1, -80, 1, -24)
        local ll = textHolder:FindFirstChildOfClass("UIListLayout")
        if ll then ll.VerticalAlignment = Enum.VerticalAlignment.Top end

		-- Value display / editable box at the top-right.
		local valueBox = Create("TextBox", {
            BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1, Text = tostring(value),
            Font = theme:Get("FontBold"), TextSize = 13, TextColor3 = theme:Get("Accent"),
			ClearTextOnFocus = false, AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 9), Size = UDim2.fromOffset(64, 20),
			Parent = row,
		})
		P.corner(valueBox, 6); P.stroke(valueBox, theme:Get("Border"), 1, 0.4)
		theme:Apply(valueBox, { TextColor3 = "Accent" })
        local track = Create("Frame", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1, BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, -12),
			Size = UDim2.new(1, -24, 0, 6), Parent = row })
		P.corner(track, 3)
		local fill = Create("Frame", { BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0), Parent = track })
		P.corner(fill, 3)
		theme:Apply(fill, { BackgroundColor3 = "Accent" })
		P.gradient(fill, ColorSequence.new(theme:Get("AccentDim"), theme:Get("AccentGlow")), 0)
		local knob = Create("Frame", { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(14, 14), ZIndex = 3, Parent = track })
		P.corner(knob, 7); P.stroke(knob, theme:Get("Accent"), 2, 0)

		local handle = { Instance = row, Changed = Signal.new() }
		local function format(v) return Util.Round(v, decimals) end
		local function visual()
			local a = Util.Alpha(value, min, max)
			Tween.to(fill, { Size = UDim2.new(a, 0, 1, 0) }, "Slide")
			Tween.to(knob, { Position = UDim2.new(a, 0, 0.5, 0) }, "Slide")
			valueBox.Text = tostring(format(value)) .. (opts.Suffix or "")
		end

		function handle:Set(v, fromState)
			v = Util.SnapToStep(Util.Clamp(tonumber(v) or value, min, max), opts.Step or 0)
			value = format(v)
			visual()
			if not fromState and opts.Flag then ctx.state:Push(opts.Flag, value) end
			if opts.Callback then task.spawn(opts.Callback, value) end
		end
		function handle:Get() return value end
		function handle:Destroy() row:Destroy() end

		-- Dragging (mouse + touch via UserInputService).
		local dragging = false
		local function updateFromX(px)
			local a = Util.Clamp((px - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
			handle:Set(min + (max - min) * a)
		end
		local hit = Create("TextButton", { BackgroundTransparency = 1, Text = "",
			Position = UDim2.fromOffset(0, -8), Size = UDim2.new(1, 0, 0, 22), Parent = track })
		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				Tween.to(knob, { Size = UDim2.fromOffset(18, 18) }, "Hover")
				updateFromX(input.Position.X)
			end
		end)
		ctx.maid:Give(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateFromX(input.Position.X)
			end
		end))
		ctx.maid:Give(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if dragging then Tween.to(knob, { Size = UDim2.fromOffset(14, 14) }, "Hover") end
				dragging = false
			end
		end))

		-- Editable input box.
		valueBox.FocusLost:Connect(function()
			local n = tonumber((valueBox.Text:gsub("[^%d%.%-]", "")))
			if n then handle:Set(n) else visual() end
		end)

		visual()
		if opts.Flag then ctx.state:Register(opts.Flag, handle, value) end
		attachTooltip(ctx, row, opts.Tooltip)
		return handle
	end

	----------------------------------------------------------------------------
	-- Dropdown  (icons, search, multi-select, runtime add/remove)
	----------------------------------------------------------------------------
	function C.Dropdown(ctx, opts)
		local theme = ctx.theme
		local multi = opts.Multi or opts.MultiSelect or false
		local searchable = opts.Search or opts.Searchable or false
		local items = Util.DeepCopy(opts.Options or opts.Items or {})

		-- value: single -> any; multi -> { [item]=true }
		local value
		if multi then
			value = {}
			if type(opts.Default) == "table" then for _, v in ipairs(opts.Default) do value[v] = true end end
		else
			value = opts.Default
		end
		if opts.Flag and ctx.state:Get(opts.Flag) ~= nil then value = ctx.state:Get(opts.Flag) end

		local row = baseRow(ctx, opts)
        local control = Create("TextButton", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1, AutoButtonColor = false,
            Text = "", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(opts.ControlWidth or 150, 28), Parent = row })
		P.corner(control, 6); local cStroke = P.stroke(control, theme:Get("Border"), 1, 0.3)
		local selLabel = Create("TextLabel", { BackgroundTransparency = 1, Text = "Select...",
			Font = theme:Get("Font"), TextSize = 13, TextColor3 = theme:Get("TextDim"),
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -34, 1, 0), Parent = control })
		local arrow = Create("ImageLabel", { BackgroundTransparency = 1, Image = Icons.get("chevron-down") or "",
			ImageColor3 = theme:Get("TextDim"), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(14, 14), Parent = control })

		-- Popup list (parented to the screen root for correct z-ordering).
		-- Fixed/capped height + a real ScrollingFrame so long lists scroll.
		local ITEM_H, GAP, MAX_VISIBLE = 30, 3, 6
		local root = ctx.root or row
		-- Transparent, glassy popup: just a tinted backdrop + a crisp outline (no drop
		-- shadow), matching the rest of the UI's flat/outlined style.
		local popup = Create("Frame", { BackgroundColor3 = theme:Get("Background"), BackgroundTransparency = 0.25,
			Active = true, BorderSizePixel = 0, Visible = false, ClipsDescendants = true, ZIndex = 6000,
			Size = UDim2.fromOffset(180, 0), Parent = root })
		P.corner(popup, 10); P.stroke(popup, theme:Get("Border"), 1.5, 0)

		-- Inner content frame holds the UIListLayout. The shadow lives on `popup`
		-- (which has no layout) so it never gets swept into the option list.
		local content = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
			ZIndex = 6001, Parent = popup })
		P.padding(content, 6)
		Create("UIListLayout", { Padding = UDim.new(0, GAP), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

		local searchBox
		if searchable then
			searchBox = Create("TextBox", { BackgroundColor3 = theme:Get("Surface"), PlaceholderText = "Search...",
				Text = "", Font = theme:Get("Font"), TextSize = 13, TextColor3 = theme:Get("Text"),
				PlaceholderColor3 = theme:Get("TextMuted"), ClearTextOnFocus = false,
				Size = UDim2.new(1, 0, 0, 28), LayoutOrder = -1, ZIndex = 6001, Parent = content })
			P.corner(searchBox, 6); P.stroke(searchBox, theme:Get("Border"), 1, 0.4); P.padding(searchBox, 6, { PaddingLeft = UDim.new(0,8) })
		end

		local listScroll = Create("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0), CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = true,
			ScrollBarThickness = 4, ScrollBarImageColor3 = theme:Get("Accent"), ScrollBarImageTransparency = 0.25,
			ZIndex = 6001, Parent = content })
		Create("UIListLayout", { Padding = UDim.new(0, GAP), SortOrder = Enum.SortOrder.LayoutOrder, Parent = listScroll })

		local handle = { Instance = row, Changed = Signal.new() }
		local open = false
		local optionButtons = {}

		-- Full-screen invisible catcher behind the popup. Clicking it closes the
		-- dropdown; clicks on the popup/options sit above it. This avoids fragile
		-- mouse-vs-GUI coordinate math (the ScreenGui uses IgnoreGuiInset, which
		-- doesn't line up with UserInputService:GetMouseLocation()).
		local scrim = Create("TextButton", { BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
			Visible = false, Size = UDim2.fromScale(1, 1), ZIndex = 5999, Parent = root })
		scrim.MouseButton1Click:Connect(function() handle:_close() end)

		local function isSelected(item)
			if multi then return value[item] == true else return value == item end
		end
		local function displayText()
			if multi then
				local names = {}
				for _, it in ipairs(items) do if value[it] then table.insert(names, tostring(it)) end end
				if #names == 0 then return "Select...", true end
				return table.concat(names, ", "), false
			else
				if value == nil then return "Select...", true end
				return tostring(value), false
			end
		end
		local function refreshLabel()
			local txt, placeholder = displayText()
			selLabel.Text = txt
			selLabel.TextColor3 = placeholder and theme:Get("TextDim") or theme:Get("Text")
		end

		local visibleCount = 0
		local function rebuild(filter)
			-- Destroy by iterating the children we actually created (not a key->button
			-- map): duplicate option values would otherwise overwrite a map entry and
			-- leak the previous button, stacking copies in the list on every refresh.
			for _, child in ipairs(listScroll:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end
			table.clear(optionButtons)
			visibleCount = 0
			for i, item in ipairs(items) do
				local label = type(item) == "table" and (item.Text or item.Name or tostring(item.Value)) or tostring(item)
				local key = type(item) == "table" and (item.Value ~= nil and item.Value or label) or item
				if not filter or filter == "" or Util.Matches(label, filter) then
					visibleCount += 1
					local optBtn = Create("TextButton", { BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1,
						AutoButtonColor = false, Text = "", Size = UDim2.new(1, 0, 0, ITEM_H), LayoutOrder = i, ZIndex = 6002, Parent = listScroll })
					P.corner(optBtn, 7)
					local tx = 10
					local ic = type(item) == "table" and item.Icon and P.icon(optBtn, item.Icon, 16, theme:Get("TextDim"), {
						AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 8, 0.5, 0), ZIndex = 6003 })
					if ic then tx = 32 end
					Create("TextLabel", { BackgroundTransparency = 1, Text = label, Font = theme:Get("Font"),
						TextSize = 13, TextColor3 = theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Position = UDim2.fromOffset(tx, 0), Size = UDim2.new(1, -tx-26, 1, 0), ZIndex = 6003, Parent = optBtn })
					local checkLbl = Create("TextLabel", { BackgroundTransparency = 1, Text = "✓", Font = Enum.Font.GothamBold,
						TextSize = 14, TextColor3 = theme:Get("Accent"), TextTransparency = isSelected(key) and 0 or 1,
						AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
						Size = UDim2.fromOffset(16, 16), ZIndex = 6003, Parent = optBtn })
					optBtn.MouseEnter:Connect(function() Tween.to(optBtn, { BackgroundTransparency = 0.15 }, "Hover"); Tween.to(optBtn, { BackgroundColor3 = theme:Get("SurfaceAlt") }, "Hover") end)
					optBtn.MouseLeave:Connect(function() Tween.to(optBtn, { BackgroundTransparency = 1 }, "Hover"); Tween.to(optBtn, { BackgroundColor3 = theme:Get("Surface") }, "Hover") end)
					optBtn.MouseButton1Click:Connect(function()
						if multi then
							value[key] = (not value[key]) or nil
							checkLbl.TextTransparency = value[key] and 0 or 1
							refreshLabel()
							if opts.Flag then ctx.state:Push(opts.Flag, value) end
							if opts.Callback then task.spawn(opts.Callback, value) end
						else
							value = key
							refreshLabel()
							handle:_close()
							if opts.Flag then ctx.state:Push(opts.Flag, value) end
							if opts.Callback then task.spawn(opts.Callback, value) end
						end
					end)
					optionButtons[key] = optBtn
				end
			end
		end

		-- Compute the popup's target height (capped, scrollable beyond cap).
		local function targetHeight()
			local shown = math.max(visibleCount, 1)
			local listH = math.min(shown, MAX_VISIBLE) * (ITEM_H + GAP) - GAP
			listScroll.Size = UDim2.new(1, 0, 0, listH)
			return 12 + listH + (searchBox and (28 + GAP) or 0)
		end

		function handle:_position()
			local p, s = control.AbsolutePosition, control.AbsoluteSize
			popup.Position = UDim2.fromOffset(p.X, p.Y + s.Y + 6)
		end
		function handle:_open()
			open = true
			if searchBox then searchBox.Text = "" end
			rebuild(nil)
			handle:_position()
			local w = math.max(control.AbsoluteSize.X, 180)
			local h = targetHeight()
			popup.Size = UDim2.fromOffset(w, 0)
			scrim.Visible = true
			popup.Visible = true
			Tween.to(popup, { Size = UDim2.fromOffset(w, h) }, "Expand")
			Tween.to(arrow, { Rotation = 180 }, "Hover")
			Tween.to(cStroke, { Color = theme:Get("Accent"), Transparency = 0.1 }, "Hover")
		end
		function handle:_close()
			if not open then return end
			open = false
			scrim.Visible = false
			Tween.to(arrow, { Rotation = 0 }, "Hover")
			Tween.to(cStroke, { Color = theme:Get("Border"), Transparency = 0.3 }, "Hover")
			Tween.to(popup, { Size = UDim2.fromOffset(popup.AbsoluteSize.X, 0) }, "Expand", function()
				if not open then popup.Visible = false end
			end)
		end
		-- Live search: filter + resize while open.
		local function applyFilter()
			rebuild(searchBox and searchBox.Text or nil)
			if open then Tween.to(popup, { Size = UDim2.fromOffset(popup.AbsoluteSize.X, targetHeight()) }, "Expand") end
		end
		control.MouseButton1Click:Connect(function() if open then handle:_close() else handle:_open() end end)
		if searchBox then searchBox:GetPropertyChangedSignal("Text"):Connect(applyFilter) end

		-- Public API
		function handle:Set(v, fromState)
			value = v
			refreshLabel(); if open then applyFilter() end
			if not fromState and opts.Flag then ctx.state:Push(opts.Flag, value) end
			if opts.Callback then task.spawn(opts.Callback, value) end
		end
		function handle:Get() return value end
		function handle:GetItems() return items end
		function handle:SetOptions(newItems)
			items = Util.DeepCopy(newItems)
			refreshLabel(); if open then applyFilter() end
		end
		function handle:AddItem(item)
			table.insert(items, item)
			if open then applyFilter() end
		end
		function handle:RemoveItem(item)
			local idx = Util.IndexOf(items, item)
			if idx then table.remove(items, idx) end
			if multi and type(value) == "table" and value[item] then value[item] = nil end
			refreshLabel(); if open then applyFilter() end
		end
		function handle:Destroy() scrim:Destroy(); popup:Destroy(); row:Destroy() end

		refreshLabel()
		if opts.Flag then ctx.state:Register(opts.Flag, handle, value) end
		attachTooltip(ctx, row, opts.Tooltip)
		return handle
	end

	-- Convenience aliases.
	function C.MultiDropdown(ctx, opts) opts.Multi = true; return C.Dropdown(ctx, opts) end
	function C.SearchDropdown(ctx, opts) opts.Search = true; return C.Dropdown(ctx, opts) end
	C.ComboBox = C.Dropdown
	C.List = C.Dropdown

	----------------------------------------------------------------------------
	-- Keybind  (Hold / Toggle / Always, rebind, conflict detection, display)
	----------------------------------------------------------------------------
	function C.Keybind(ctx, opts)
		local theme = ctx.theme
		-- A cleared ("None") bind must survive save/load. nil can't be stored in the
		-- state/config table (Lua drops nil values, so the flag vanishes and the bind
		-- silently reverts to its Default on reload). So we persist a sentinel string
		-- for None and translate it back to nil here.
		local NONE = "__i2_none"
		local function fromStore(v) if v == NONE then return nil end return v end
		local key = opts.Default
		if opts.Flag and ctx.state:Get(opts.Flag) ~= nil then key = fromStore(ctx.state:Get(opts.Flag)) end
		local mode = opts.Mode or "Toggle"
		local id = opts.Id or opts.Flag or Util.UID("kb")

		local row = baseRow(ctx, opts)
        local btn = Create("TextButton", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1, AutoButtonColor = false,
            Text = key and ctx.hotkeys.KeyName(key) or "None", Font = theme:Get("FontBold"), TextSize = 13,
			TextColor3 = theme:Get("Accent"), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(96, 28),
			AutomaticSize = Enum.AutomaticSize.X, Parent = row })
		P.corner(btn, 6); local bStroke = P.stroke(btn, theme:Get("Border"), 1, 0.3)
		P.padding(btn, 0, { PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10) })
		Create("UISizeConstraint", { MinSize = Vector2.new(64, 28), Parent = btn })

		local handle = { Instance = row }
		local listening = false

		local function bindIt()
			if opts.NoBind then
				-- Display/rebind only: no live hotkey, but still reserve the key so the
				-- duplicate-key guard accounts for it.
				if key then ctx.hotkeys:Reserve(id, key) else ctx.hotkeys:Unbind(id) end
				return
			end
			if key then
				ctx.hotkeys:Bind(id, key, mode, function(active)
					if opts.Callback then task.spawn(opts.Callback, active, key) end
				end)
			else
				ctx.hotkeys:Unbind(id)
			end
		end
		function handle:Set(k, fromState)
			k = fromStore(k) -- a restored "None" sentinel comes back as nil
			-- Duplicate-key protection: refuse a key already claimed by another
			-- action. Config restore (fromState) is exempt so saved setups load.
			if k ~= nil and not fromState then
				local taken = ctx.hotkeys:KeyInUse(k, id)
				if taken then
					if ctx.notify then
						ctx.notify:Push({ Type = "error", Title = "Key already in use",
							Content = ctx.hotkeys.KeyName(k) .. " is already bound to another action." })
					end
					btn.Text = key and ctx.hotkeys.KeyName(key) or "None"
					return
				end
			end
			key = k
			btn.Text = key and ctx.hotkeys.KeyName(key) or "None"
			bindIt()
			-- Persist nil as the NONE sentinel so a cleared bind is remembered on reload.
			if not fromState and opts.Flag then ctx.state:Push(opts.Flag, key ~= nil and key or NONE) end
			if opts.OnChanged then task.spawn(opts.OnChanged, key) end
		end
		function handle:Get() return key end
		function handle:SetMode(m) mode = m; bindIt() end
		function handle:Destroy() ctx.hotkeys:Unbind(id); row:Destroy() end

		btn.MouseButton1Click:Connect(function()
			listening = true
			ctx.hotkeys:BeginCapture() -- mute all hotkeys/toggle while we capture a key
			btn.Text = "..."
			Tween.to(bStroke, { Color = theme:Get("Accent"), Transparency = 0 }, "Hover")
		end)
		ctx.maid:Give(UserInputService.InputBegan:Connect(function(input, gpe)
			if not listening then return end
			listening = false
			-- Defer so capture mode stays active for the rest of THIS input event
			-- (the key we just pressed must not leak to the toggle/other binds).
			task.defer(function() ctx.hotkeys:EndCapture() end)
			Tween.to(bStroke, { Color = theme:Get("Border"), Transparency = 0.3 }, "Hover")
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				if CLEAR_KEYS[input.KeyCode] then
					-- Escape / Backspace / Delete clear the keybind to None.
					handle:Set(nil)
				elseif SKIP_KEYS[input.KeyCode] then
					-- Reserved key: cancel without changing the current bind.
					btn.Text = key and ctx.hotkeys.KeyName(key) or "None"
				else
					handle:Set(input.KeyCode)
				end
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				handle:Set(Enum.UserInputType.MouseButton2)
			end
		end))

		bindIt()
		if opts.Flag then ctx.state:Register(opts.Flag, handle, key) end
		return handle
	end

	----------------------------------------------------------------------------
	-- Textbox  (single / multiline, validation, placeholder)
	----------------------------------------------------------------------------
	function C.Code(ctx, opts)
		local theme = ctx.theme
		local value = opts.Code or opts.Text or ""
		local row = baseRow(ctx, opts)

		local box = Create("Frame", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(opts.ControlWidth or 200, 28), Parent = row })
		P.corner(box, 6); local bStroke = P.stroke(box, theme:Get("Border"), 1, 0.3)
		
		local label = Create("TextLabel", { BackgroundTransparency = 1, Text = value,
			Font = theme:Get("Font"), TextSize = 13, TextColor3 = theme:Get("TextDim"),
			TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -56, 1, 0), Parent = box })
		
		local copyBtn = Create("TextButton", { BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1,
			Text = "Copy", Font = theme:Get("FontBold"), TextSize = 11, TextColor3 = theme:Get("TextDim"),
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -4, 0.5, 0),
			Size = UDim2.fromOffset(44, 20), Parent = box })
		P.corner(copyBtn, 4); local cStroke = P.stroke(copyBtn, theme:Get("Border"), 1, 0.3)

		copyBtn.MouseEnter:Connect(function()
			Tween.to(copyBtn, { BackgroundTransparency = 0.8 }, "Hover")
			Tween.to(copyBtn, { TextColor3 = theme:Get("Text") }, "Hover")
		end)
		copyBtn.MouseLeave:Connect(function()
			Tween.to(copyBtn, { BackgroundTransparency = 1 }, "Hover")
			Tween.to(copyBtn, { TextColor3 = theme:Get("TextDim") }, "Hover")
		end)
		copyBtn.MouseButton1Click:Connect(function()
			if setclipboard then setclipboard(value) end
			if ctx.notify then ctx.notify:Push({ Type = "success", Title = "Copied!", Content = "Text copied to clipboard.", Duration = 2 }) end
		end)

		local handle = { Instance = row }
		function handle:Set(v) value = tostring(v); label.Text = value end
		function handle:Get() return value end
		function handle:Destroy() row:Destroy() end
		return handle
	end

	----------------------------------------------------------------------------
	function C.Textbox(ctx, opts)
		local theme = ctx.theme
		local value = opts.Default or ""
		if opts.Flag and ctx.state:Get(opts.Flag) ~= nil then value = ctx.state:Get(opts.Flag) end

		-- Stacked layout: label (+desc) pinned to the top, full-width input box below it.
		-- This guarantees the box never overlaps the label no matter how wide the control is
		-- or how long the typed text gets (the old right-anchored fixed-width box overlapped
		-- the label). ControlWidth is ignored here on purpose — the box spans the row.
		local multi  = opts.MultiLine or false
		local boxH   = multi and 60 or 30
		local labelH = opts.Description and 32 or 16
		local row, _t, _d, textHolder = baseRow(ctx, opts, 8 + labelH + 6 + boxH + 8)
		textHolder.AnchorPoint = Vector2.new(0, 0)
		textHolder.Position = UDim2.fromOffset(12, 8)
		textHolder.Size = UDim2.new(1, -24, 0, labelH)
        local box = Create("TextBox", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1, Text = value,
            PlaceholderText = opts.Placeholder or "", PlaceholderColor3 = theme:Get("TextMuted"),
			Font = theme:Get("Font"), TextSize = 13, TextColor3 = theme:Get("Text"),
			ClearTextOnFocus = opts.ClearOnFocus or false, MultiLine = multi,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = multi and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
			TextWrapped = multi, ClipsDescendants = true,
			AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 12, 1, -8),
			Size = UDim2.new(1, -24, 0, boxH), Parent = row })
		P.corner(box, 6); local bStroke = P.stroke(box, theme:Get("Border"), 1, 0.3)
		P.padding(box, 0, { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,8) })
		theme:Apply(box, { TextColor3 = "Text", BackgroundColor3 = "SurfaceAlt" })

		local handle = { Instance = row }
		box.Focused:Connect(function() Tween.to(bStroke, { Color = theme:Get("Accent"), Transparency = 0 }, "Hover") end)
		box.FocusLost:Connect(function(enter)
			Tween.to(bStroke, { Color = theme:Get("Border"), Transparency = 0.3 }, "Hover")
			local txt = box.Text
			if opts.Validate then
				local ok, fixed = opts.Validate(txt)
				if not ok then box.Text = value; return end
				if fixed ~= nil then txt = fixed; box.Text = fixed end
			end
			value = txt
			if opts.Flag then ctx.state:Push(opts.Flag, value) end
			if opts.Callback then task.spawn(opts.Callback, value, enter) end
		end)
		function handle:Set(v, fromState) value = tostring(v); box.Text = value
			if not fromState and opts.Flag then ctx.state:Push(opts.Flag, value) end end
		function handle:Get() return value end
		function handle:Destroy() row:Destroy() end
		if opts.Flag then ctx.state:Register(opts.Flag, handle, value) end
		return handle
	end

	----------------------------------------------------------------------------
	-- ColorPicker  (HSV area + hue bar + hex, popup)
	----------------------------------------------------------------------------
	function C.ColorPicker(ctx, opts)
		local theme = ctx.theme
		local value = opts.Default or Color3.fromRGB(255, 255, 255)
		if opts.Flag and ctx.state:Get(opts.Flag) ~= nil then value = ctx.state:Get(opts.Flag) end

		local row = baseRow(ctx, opts)
		local swatch = Create("TextButton", { BackgroundColor3 = value, AutoButtonColor = false, Text = "",
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.fromOffset(42, 24), Parent = row })
		P.corner(swatch, 6); P.stroke(swatch, theme:Get("Border"), 1, 0.2)

		local root = ctx.root or row
		local popup = Create("Frame", { BackgroundColor3 = theme:Get("Elevated"), BorderSizePixel = 0,
			Visible = false, ZIndex = 6500, Size = UDim2.fromOffset(220, 200), Parent = root })
		P.corner(popup, 10); P.stroke(popup, theme:Get("Border"), 1, 0.1); P.shadow(popup, 0.5); P.padding(popup, 10)

		local h, s, v = value:ToHSV()

		local area = Create("ImageButton", { BackgroundColor3 = Color3.fromHSV(h, 1, 1), AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 120), ZIndex = 6501, Parent = popup })
		P.corner(area, 6)
		-- Saturation overlay: opaque white (left) -> transparent (right). A UIGradient
		-- COLOR multiplies the hue base and can never produce white, so the white edge
		-- is done with a white frame faded out by a transparency gradient instead.
		local satOverlay = Create("Frame", { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0,
			Size = UDim2.fromScale(1,1), ZIndex = 6502, Parent = area })
		P.corner(satOverlay, 6)
		P.gradient(satOverlay, ColorSequence.new(Color3.new(1,1,1)), 0,
			NumberSequence.new({ NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1) }))
		-- Value overlay: transparent (top) -> black (bottom).
		local valOverlay = Create("Frame", { BackgroundColor3 = Color3.new(0,0,0), BorderSizePixel = 0,
			Size = UDim2.fromScale(1,1), ZIndex = 6503, Parent = area })
		P.corner(valOverlay, 6)
		P.gradient(valOverlay, ColorSequence.new(Color3.new(0,0,0)), 90,
			NumberSequence.new({ NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0) }))
		local cursor = Create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5,0.5),
			Size = UDim2.fromOffset(10,10), ZIndex = 6504, Parent = area })
		P.corner(cursor, 5); P.stroke(cursor, Color3.new(1,1,1), 2, 0)

		local hueBar = Create("ImageButton", { AutoButtonColor = false, BackgroundColor3 = Color3.new(1,1,1),
			Position = UDim2.new(0, 0, 0, 128), Size = UDim2.new(1, 0, 0, 14), ZIndex = 6501, Parent = popup })
		P.corner(hueBar, 7)
		P.gradient(hueBar, ColorSequence.new({
			ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
		}), 0)
		local hueCursor = Create("Frame", { BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(h, 0, 0.5, 0),
			Size = UDim2.fromOffset(4, 18), ZIndex = 6502, Parent = hueBar })
		P.corner(hueCursor, 2); P.stroke(hueCursor, theme:Get("Border"), 1, 0)

		local hexBox = Create("TextBox", { BackgroundColor3 = theme:Get("Surface"), Text = Util.ColorToHex(value),
			Font = theme:Get("Font"), TextSize = 13, TextColor3 = theme:Get("Text"), ClearTextOnFocus = false,
			Position = UDim2.new(0, 0, 0, 150), Size = UDim2.new(1, 0, 0, 28), ZIndex = 6501, Parent = popup })
		P.corner(hexBox, 6); P.stroke(hexBox, theme:Get("Border"), 1, 0.4)

		local handle = { Instance = row }
		local function recompute(push)
			value = Color3.fromHSV(h, s, v)
			swatch.BackgroundColor3 = value
			-- Only the hue base changes; the white/black overlays are static.
			area.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			cursor.Position = UDim2.fromScale(s, 1 - v)
			hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
			hexBox.Text = Util.ColorToHex(value)
			if push then
				if opts.Flag then ctx.state:Push(opts.Flag, value) end
				if opts.Callback then task.spawn(opts.Callback, value) end
			end
		end

		local draggingArea, draggingHue = false, false
		local function areaUpdate(p)
			s = Util.Clamp((p.X - area.AbsolutePosition.X) / math.max(area.AbsoluteSize.X,1), 0, 1)
			v = 1 - Util.Clamp((p.Y - area.AbsolutePosition.Y) / math.max(area.AbsoluteSize.Y,1), 0, 1)
			recompute(true)
		end
		local function hueUpdate(p)
			h = Util.Clamp((p.X - hueBar.AbsolutePosition.X) / math.max(hueBar.AbsoluteSize.X,1), 0, 1)
			recompute(true)
		end
		area.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingArea = true; areaUpdate(i.Position) end end)
		hueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingHue = true; hueUpdate(i.Position) end end)
		ctx.maid:Give(UserInputService.InputChanged:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
				if draggingArea then areaUpdate(i.Position) elseif draggingHue then hueUpdate(i.Position) end
			end
		end))
		ctx.maid:Give(UserInputService.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then draggingArea, draggingHue = false, false end
		end))
		hexBox.FocusLost:Connect(function()
			local c = Util.HexToColor(hexBox.Text)
			h, s, v = c:ToHSV(); recompute(true)
		end)

		local open = false
		local function position()
			local p, sz = swatch.AbsolutePosition, swatch.AbsoluteSize
			popup.Position = UDim2.fromOffset(p.X + sz.X - 220, p.Y + sz.Y + 6)
		end
		swatch.MouseButton1Click:Connect(function()
			open = not open
			if open then position(); recompute(false) end
			popup.Visible = open
		end)
		ctx.maid:Give(UserInputService.InputBegan:Connect(function(input)
			if open and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				local m = UserInputService:GetMouseLocation()
				local pp, ps = popup.AbsolutePosition, popup.AbsoluteSize
				local sp, ss = swatch.AbsolutePosition, swatch.AbsoluteSize
				local inPop = m.X>=pp.X and m.X<=pp.X+ps.X and m.Y>=pp.Y and m.Y<=pp.Y+ps.Y
				local inSw = m.X>=sp.X and m.X<=sp.X+ss.X and m.Y>=sp.Y and m.Y<=sp.Y+ss.Y
				if not inPop and not inSw then open = false; popup.Visible = false end
			end
		end))

		function handle:Set(c, fromState)
			value = c; h, s, v = c:ToHSV(); recompute(false); swatch.BackgroundColor3 = value
			if not fromState and opts.Flag then ctx.state:Push(opts.Flag, value) end
			if opts.Callback then task.spawn(opts.Callback, value) end
		end
		function handle:Get() return value end
		function handle:Destroy() popup:Destroy(); row:Destroy() end
		recompute(false)
		if opts.Flag then ctx.state:Register(opts.Flag, handle, value) end
		return handle
	end

	----------------------------------------------------------------------------
	-- Image
	----------------------------------------------------------------------------
	function C.Image(ctx, opts)
		local theme = ctx.theme
		local holder = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, opts.Height or 120),
			LayoutOrder = opts.LayoutOrder, Parent = ctx.parent })
		local img = Create("ImageLabel", { BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1, BorderSizePixel = 0,
			Image = Icons.get(opts.Image) or opts.Image or "", ScaleType = opts.ScaleType or Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1), Parent = holder })
		P.corner(img, opts.Corner or 8); theme:Apply(img, { BackgroundColor3 = "Surface" })
		local imgStroke = P.stroke(img, theme:Get("Border"), 1, 0.35); theme:Apply(imgStroke, { Color = "Border" })
		return { Instance = holder, Set = function(_, id) img.Image = Icons.get(id) or id end, Destroy = function() holder:Destroy() end }
	end

	----------------------------------------------------------------------------
	-- Avatar  (player headshot)
	----------------------------------------------------------------------------
	function C.Avatar(ctx, opts)
		local Players = game:GetService("Players")
		local theme = ctx.theme
		local userId = opts.UserId or (Players.LocalPlayer and Players.LocalPlayer.UserId) or 1
		local size = opts.Size or 48
		local row = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, size + 8),
			LayoutOrder = opts.LayoutOrder, Parent = ctx.parent })
		local img = Create("ImageLabel", { BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
			Size = UDim2.fromOffset(size, size), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0,0,0.5,0), Parent = row })
		P.corner(img, size/2); P.stroke(img, theme:Get("Accent"), 2, 0)
		task.spawn(function()
			local ok, content = pcall(function()
				return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)
			if ok then img.Image = content end
		end)
		if opts.Name ~= false then
			-- opts.Name may be a string (explicit), nil, or `true` (auto-fetch). Only a
			-- string is a usable label; anything else means "look it up from the userId".
			local name = opts.Name
			if type(name) ~= "string" then
				name = nil
				pcall(function() name = Players:GetNameFromUserIdAsync(userId) end)
			end
			local nameLabel = Create("TextLabel", { BackgroundTransparency = 1, Text = name or "Player", Font = theme:Get("FontBold"),
				TextSize = 15, TextColor3 = theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(size + 12, 0), Size = UDim2.new(1, -size-12, 1, 0), Parent = row })
			theme:Apply(nameLabel, { TextColor3 = "Text" })
		end
		return { Instance = row, Destroy = function() row:Destroy() end }
	end

	----------------------------------------------------------------------------
	-- ProgressBar
	----------------------------------------------------------------------------
	function C.ProgressBar(ctx, opts)
		local theme = ctx.theme
		local value = Util.Clamp(opts.Default or 0, 0, 1)
		local card = P.card({ BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1, Size = UDim2.new(1,0,0, opts.Label and 44 or 24),
			LayoutOrder = opts.LayoutOrder, Parent = ctx.parent })
		theme:Apply(card, { BackgroundColor3 = "Surface" })
		local cardStroke = P.stroke(card, theme:Get("Border"), 1, 0.35); theme:Apply(cardStroke, { Color = "Border" })
		P.padding(card, 8)
		local lbl
		if opts.Label then
			lbl = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Label, Font = theme:Get("Font"),
				TextSize = 12, TextColor3 = theme:Get("TextDim"), TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 14), Parent = card })
			theme:Apply(lbl, { TextColor3 = "TextDim" })
		end
		local track = Create("Frame", { BackgroundColor3 = theme:Get("SurfaceAlt"), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0,1), Position = UDim2.new(0,0,1,0), Size = UDim2.new(1, 0, 0, 8), Parent = card })
		P.corner(track, 4); theme:Apply(track, { BackgroundColor3 = "SurfaceAlt" })
		local fill = Create("Frame", { BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
			Size = UDim2.fromScale(value, 1), Parent = track })
		P.corner(fill, 4); theme:Apply(fill, { BackgroundColor3 = "Accent" })
		P.gradient(fill, ColorSequence.new(theme:Get("AccentDim"), theme:Get("AccentGlow")), 0)
		local handle = { Instance = card }
		function handle:Set(v) value = Util.Clamp(v, 0, 1); Tween.to(fill, { Size = UDim2.fromScale(value, 1) }, "Slide") end
		function handle:Get() return value end
		function handle:Destroy() card:Destroy() end
		return handle
	end

	----------------------------------------------------------------------------
	-- LoadingSpinner
	----------------------------------------------------------------------------
	function C.Spinner(ctx, opts)
		local theme = ctx.theme
		local size = opts.Size or 28
		local holder = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, size + 8),
			LayoutOrder = opts.LayoutOrder, Parent = ctx.parent })
		-- Asset-free spinner: a dim track ring + an orbiting accent dot.
		local ring = Create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size, size), Parent = holder })
		P.corner(ring, 999)
		local track = P.stroke(ring, theme:Get("SurfaceAlt"), 3, 0.2)
		theme:Apply(track, { Color = "SurfaceAlt" })
		local dot = Create("Frame", { BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.fromOffset(math.max(5, size * 0.22), math.max(5, size * 0.22)), Parent = ring })
		P.corner(dot, 999); theme:Apply(dot, { BackgroundColor3 = "Accent" })
		local conn = Tween.bind(function(dt) ring.Rotation = (ring.Rotation + dt * 300) % 360 end)
		ctx.maid:Give(conn)
		return { Instance = holder, Stop = function() conn:Disconnect() end, Destroy = function() conn:Disconnect(); holder:Destroy() end }
	end



	return C
end)


--============================================================================--
--  MODULE :: Config   (save / load / import / export, migration, validation)
--============================================================================--
define("Config", function(import)
	local HttpService = game:GetService("HttpService")
	local Util = import("Util")

	-- Executor filesystem shims with graceful fallback to an in-memory store.
	local hasFS = (typeof(writefile) == "function") and (typeof(readfile) == "function")
	local _mem = {}
	local function safe(fn, ...) local ok, r = pcall(fn, ...) if ok then return r end return nil end

	local function fsWrite(path, data) if hasFS then safe(writefile, path, data) else _mem[path] = data end end
	local function fsRead(path) if hasFS then return safe(readfile, path) else return _mem[path] end end
	local function fsDelete(path) if hasFS and typeof(delfile) == "function" then safe(delfile, path) else _mem[path] = nil end end
	local function fsList(folder)
		if hasFS and typeof(listfiles) == "function" then return safe(listfiles, folder) or {} end
		local out = {}
		for k in pairs(_mem) do if k:find(folder, 1, true) == 1 then table.insert(out, k) end end
		return out
	end
	-- NOTE: isfolder/makefolder yield on some executors. Both are wrapped in `safe`
	-- (pcall) so they can never crash — including the "thread is not yieldable" error
	-- raised if this somehow runs inside a C metamethod. Folder creation is also done
	-- lazily (see Config:_ensureFolders) so Config.new performs no filesystem I/O.
	local function fsMkDir(folder)
		if hasFS and typeof(makefolder) == "function" and typeof(isfolder) == "function" then
			if not safe(isfolder, folder) then safe(makefolder, folder) end
		end
	end

	local Config = {}; Config.__index = Config
	local SCHEMA_VERSION = 2

	function Config.new(opts)
		local self = setmetatable({}, Config)
		self.Folder = opts.Folder or "i2Library"
		self.Name = opts.Name or "default"
		self.State = opts.State
		self.Theme = opts.Theme
		self.Window = opts.Window
		self.AutoSave = opts.AutoSave ~= false
		-- Folders are created lazily on first write (NOT here): doing yielding
		-- filesystem calls in Config.new can crash when Library.new is reached
		-- through the Facade's __index metamethod, which is not yieldable.
		return self
	end

	-- Create the config folders on demand. Always runs from a write call, which
	-- happens in normal (yieldable) script/task context.
	function Config:_ensureFolders()
		if self._foldersReady then return end
		self._foldersReady = true
		fsMkDir(self.Folder)
		fsMkDir(self.Folder .. "/configs")
	end

	-- Normalize a config name into a safe, canonical file stem so the SAME logical
	-- name always maps to the SAME file. Without this, "ESP", "ESP " (trailing
	-- space) and "ESP/" would each create a separate file and the saved-config list
	-- would fill up with near-duplicates of the same name.
	function Config:_sanitize(name)
		name = tostring(name or self.Name or "default")
		name = name:gsub("[/\\:%*%?\"<>|%.]", " ")   -- strip path/illegal chars
		name = name:gsub("%s+", " ")                  -- collapse whitespace runs
		name = name:gsub("^%s*(.-)%s*$", "%1")        -- trim ends
		if name == "" then name = "default" end
		return name
	end

	function Config:_path(name)
		return self.Folder .. "/configs/" .. self:_sanitize(name or self.Name) .. ".json"
	end

	-- Build the full config payload from live state + theme + window geometry.
	function Config:Build()
		return {
			__schema = SCHEMA_VERSION,
			__saved = os.time(),
			flags = self.State and self.State:Snapshot() or {},
			theme = self.Theme and self.Theme:Serialize() or nil,
			window = self.Window and self.Window:SerializeLayout() or nil,
		}
	end

	-- Migrate older config payloads forward. Extend as the schema evolves.
	function Config:Migrate(data)
		data.__schema = data.__schema or 1
		if data.__schema < 2 then
			-- v1 stored flags at the root; lift them under `flags`.
			if not data.flags then
				data.flags = {}
				for k, v in pairs(data) do
					if not k:match("^__") and k ~= "theme" and k ~= "window" then data.flags[k] = v end
				end
			end
			data.__schema = 2
		end
		return data
	end

	function Config:Validate(data)
		if type(data) ~= "table" then return false, "not a table" end
		if type(data.flags) ~= "table" then return false, "missing flags" end
		return true
	end

	function Config:Save(name)
		self:_ensureFolders()
		local payload = self:Build()
		local ok, encoded = pcall(HttpService.JSONEncode, HttpService, payload)
		if not ok then return false, "encode failed" end
		fsWrite(self:_path(name), encoded)
		return true
	end

	function Config:Load(name)
		local raw = fsRead(self:_path(name))
		if not raw then return false, "not found" end
		local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
		if not ok then return false, "decode failed" end
		data = self:Migrate(data)
		local valid, err = self:Validate(data)
		if not valid then return false, err end
		if self.Theme and data.theme then self.Theme:Deserialize(data.theme) end
		if self.State and data.flags then self.State:Restore(data.flags) end
		if self.Window and data.window then self.Window:RestoreLayout(data.window) end
		return true
	end

	function Config:Delete(name) fsDelete(self:_path(name)); return true end
	function Config:Rename(oldName, newName)
		self:_ensureFolders()
		local raw = fsRead(self:_path(oldName)); if not raw then return false end
		fsWrite(self:_path(newName), raw); fsDelete(self:_path(oldName)); return true
	end
	function Config:Duplicate(name, newName)
		self:_ensureFolders()
		local raw = fsRead(self:_path(name)); if not raw then return false end
		fsWrite(self:_path(newName or (name .. "_copy")), raw); return true
	end

	function Config:List()
		local files = fsList(self.Folder .. "/configs")
		local names, seen = {}, {}
		for _, f in ipairs(files) do
			local n = tostring(f):match("([^/\\]+)%.json$")
			-- Dedup: some executors' listfiles return a path more than once (or with
			-- mixed separators), which would otherwise stack duplicate names in the
			-- dropdown. A set guard keeps each name exactly once.
			if n and not seen[n] then seen[n] = true; table.insert(names, n) end
		end
		table.sort(names)
		return names
	end

	-- Export current config as a JSON string (for clipboard / sharing).
	function Config:Export()
		local payload = self:Build()
		return select(2, pcall(HttpService.JSONEncode, HttpService, payload))
	end
	function Config:Import(str)
		local ok, data = pcall(HttpService.JSONDecode, HttpService, str)
		if not ok then return false, "invalid JSON" end
		data = self:Migrate(data)
		local valid, err = self:Validate(data); if not valid then return false, err end
		if self.Theme and data.theme then self.Theme:Deserialize(data.theme) end
		if self.State and data.flags then self.State:Restore(data.flags) end
		if self.Window and data.window then self.Window:RestoreLayout(data.window) end
		return true
	end

	function Config:CopyToClipboard()
		local str = self:Export()
		if typeof(setclipboard) == "function" then setclipboard(str); return true end
		return false, "clipboard unavailable"
	end
	function Config:PasteFromClipboard()
		if typeof(getclipboard) == "function" then return self:Import(getclipboard()) end
		return false, "clipboard unavailable"
	end

	-- Track the "last used" config for auto-load on next launch.
	function Config:SetLast(name) self:_ensureFolders(); fsWrite(self.Folder .. "/last.txt", name or self.Name) end
	function Config:GetLast() return fsRead(self.Folder .. "/last.txt") end

	return Config
end)


--============================================================================--
--  MODULE :: Builders   (Section, Tab, Window)
--============================================================================--
define("Builders", function(import)
	local UserInputService = game:GetService("UserInputService")
	local Util = import("Util")
	local Tween = import("Tween")
	local Maid = import("Maid")
	local Icons = import("Icons")
	local P = import("Primitives")
	local Signal = import("Signal")
	local Components = import("Components")
	local Create = Util.Create

	local B = {}

	--==[ Section ]===========================================================--
	local Section = {}; Section.__index = Section

	function Section.new(tab, name, opts)
		opts = opts or {}
		local self = setmetatable({}, Section)
		self.Tab = tab
		self.Window = tab.Window
		self.Name = name
		self.maid = Maid.new()
		local theme = self.Window.Theme
        self.Container = P.card({ BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = opts.LayoutOrder, Parent = tab.Content })
        theme:Apply(self.Container, { BackgroundColor3 = "SurfaceAlt" })
        P.stroke(self.Container, theme:Get("Border"), 1, 0.5)
		P.padding(self.Container, 12)

		-- Header (collapsible).
		self.Header = Create("TextButton", { BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 20), Parent = self.Container })
		self.Title = Create("TextLabel", { BackgroundTransparency = 1, Text = name or "Section",
			Font = theme:Get("FontBold"), TextSize = 15, TextColor3 = theme:Get("Text"),
			TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, -20, 1, 0), Parent = self.Header })
		theme:Apply(self.Title, { TextColor3 = "Text" })
		self.Chevron = Create("ImageLabel", { BackgroundTransparency = 1, Image = Icons.get("chevron-down") or "",
			ImageColor3 = theme:Get("TextDim"), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(18, 18), Parent = self.Header })

		-- The container stacks [header, body] vertically and auto-grows.
		Create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.Container })
		self.Header.LayoutOrder = 0

		-- BodyClip wraps the body so collapse/expand can animate its height. While
		-- fully expanded it uses AutomaticSize and does NOT clip, so the rows' outward
		-- UIStroke borders are never shaved off. Clipping is only turned on during a
		-- transition (or while collapsed), where a fixed, clipped height is required.
		self.BodyClip = Create("Frame", { BackgroundTransparency = 1, ClipsDescendants = false,
			Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1, Parent = self.Container })
		self.Body = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, Parent = self.BodyClip })
		P.listLayout(self.Body, 8)

		self._collapsed = opts.Collapsed or false
		self.Collapsible = opts.Collapsible ~= false
		if not self.Collapsible then self.Chevron.Visible = false end

		self.Header.MouseButton1Click:Connect(function()
			if self.Collapsible then self:Toggle() end
		end)

		-- The component context shared by everything in this section.
		self.ctx = {
			theme = self.Window.Theme, state = self.Window.State, hotkeys = self.Window.Hotkeys,
			notify = self.Window.Notifier, root = self.Window.Gui, parent = self.Body, maid = self.maid,
			library = self.Window.Library, window = self.Window,
		}
		self:_applyCollapsed(false)
		return self
	end

	function Section:_applyCollapsed(animate)
		-- Chevron points down when open, rotates to point right when collapsed.
		local rot = self._collapsed and -90 or 0
		if animate then
			self._animating = true
			-- Clip only for the duration of the height tween.
			self.BodyClip.ClipsDescendants = true
			Tween.to(self.Chevron, { Rotation = rot }, "Toggle")
			-- Capture the current rendered height BEFORE freezing AutomaticSize
			-- (turning it off snaps the frame back to its Size offset otherwise).
			local fromH = self.BodyClip.AbsoluteSize.Y
			local toH = self._collapsed and 0 or self.Body.AbsoluteSize.Y
			self.BodyClip.AutomaticSize = Enum.AutomaticSize.None
			self.BodyClip.Size = UDim2.new(1, 0, 0, fromH)
			Tween.to(self.BodyClip, { Size = UDim2.new(1, 0, 0, toH) }, "Expand", function()
				self._animating = false
				-- Hand height management back to AutomaticSize and stop clipping so
				-- dynamic content fits exactly and row borders are never shaved off.
				if not self._collapsed then
					self.BodyClip.AutomaticSize = Enum.AutomaticSize.Y
					self.BodyClip.ClipsDescendants = false
				end
			end)
		else
			self.Chevron.Rotation = rot
			if self._collapsed then
				self.BodyClip.AutomaticSize = Enum.AutomaticSize.None
				self.BodyClip.Size = UDim2.new(1, 0, 0, 0)
				self.BodyClip.ClipsDescendants = true
			else
				self.BodyClip.AutomaticSize = Enum.AutomaticSize.Y
				self.BodyClip.ClipsDescendants = false
			end
		end
	end
	function Section:Toggle() self._collapsed = not self._collapsed; self:_applyCollapsed(true) end
	function Section:Collapse() self._collapsed = true; self:_applyCollapsed(true) end
	function Section:Expand() self._collapsed = false; self:_applyCollapsed(true) end
	function Section:IsCollapsed() return self._collapsed end

	-- Generic add: Section:Add("Toggle", { ... }).
	function Section:Add(componentType, opts)
		local ctor = Components[componentType]
		assert(ctor, "i2Library: unknown component type '" .. tostring(componentType) .. "'")
		opts = opts or {}
		local handle = ctor(self.ctx, opts)
		return handle
	end

	-- Sugar methods for every component.
	local SUGAR = {
		"Label","Paragraph","Divider","Button","Toggle","Checkbox","RadioGroup","Code",
		"Slider","Dropdown","MultiDropdown","SearchDropdown","ComboBox","List",
		"Keybind","Textbox","ColorPicker","Image","Avatar","ProgressBar","Spinner",
	}
	for _, name in ipairs(SUGAR) do
		Section["Add" .. name] = function(self, opts) return self:Add(name, opts) end
	end

	function Section:Destroy() self.maid:DoCleaning(); self.Container:Destroy() end

	--==[ Tab ]==============================================================--
	local Tab = {}; Tab.__index = Tab

	function Tab.new(window, opts)
		local self = setmetatable({}, Tab)
		self.Window = window
		self.Name = opts.Name or "Tab"
		self.Icon = opts.Icon
		self.Category = opts.Category
		self.maid = Maid.new()
		self.Sections = {}
		local theme = window.Theme

		-- Sidebar button.
		self.Button = Create("TextButton", { BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1,
			AutoButtonColor = false, Text = "", Size = UDim2.new(1, 0, 0, 36),
			LayoutOrder = opts.LayoutOrder or (#window.Tabs + 1), Parent = window.TabList })
		P.corner(self.Button, 7)
		local tx = 14
		self.IconLabel = self.Icon and P.icon(self.Button, self.Icon, 18, theme:Get("TextDim"), {
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0) })
		if self.IconLabel then tx = 40 end
		self.Label = Create("TextLabel", { BackgroundTransparency = 1, Text = self.Name,
			Font = theme:Get("FontMedium") or theme:Get("Font"), TextSize = 14, TextColor3 = theme:Get("TextDim"),
			TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.fromOffset(tx, 0),
			Size = UDim2.new(1, -tx, 1, 0), Parent = self.Button })
		-- active indicator bar
		self.Indicator = Create("Frame", { BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(3, 0), Parent = self.Button })
		P.corner(self.Indicator, 2); theme:Apply(self.Indicator, { BackgroundColor3 = "Accent" })

		-- Content page (a scrolling frame inside the window content area).
		self.Content = Create("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), Visible = false, CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4,
			ScrollBarImageColor3 = theme:Get("Accent"), ScrollBarImageTransparency = 0.3,
			Parent = window.ContentArea })
		theme:Apply(self.Content, { ScrollBarImageColor3 = "Accent" })
		P.padding(self.Content, 4, { PaddingRight = UDim.new(0, 8) })
		P.listLayout(self.Content, 12)

		self.Button.MouseEnter:Connect(function()
			if window.ActiveTab ~= self then Tween.to(self.Button, { BackgroundTransparency = 0.4 }, "Hover") end
		end)
		self.Button.MouseLeave:Connect(function()
			if window.ActiveTab ~= self then Tween.to(self.Button, { BackgroundTransparency = 1 }, "Hover") end
		end)
		self.Button.MouseButton1Click:Connect(function() window:SelectTab(self) end)
		return self
	end

	function Tab:AddSection(name, opts) local s = Section.new(self, name, opts); table.insert(self.Sections, s); return s end
	Tab.AddGroup = Tab.AddSection

	local function tintIcon(label, color)
		if not label then return end
		if label:IsA("TextLabel") then Tween.to(label, { TextColor3 = color }, "Hover")
		else Tween.to(label, { ImageColor3 = color }, "Hover") end
	end
	function Tab:SetActive(active)
		local theme = self.Window.Theme
		self.Content.Visible = active
		if active then
			Tween.to(self.Button, { BackgroundTransparency = 0 }, "Hover")
			Tween.to(self.Button, { BackgroundColor3 = theme:Get("SurfaceAlt") }, "Hover")
			Tween.to(self.Label, { TextColor3 = theme:Get("Text") }, "Hover")
			Tween.to(self.Indicator, { Size = UDim2.fromOffset(3, 20) }, "Toggle")
			tintIcon(self.IconLabel, theme:Get("Accent"))
			-- fade-in content
			self.Content.Position = UDim2.fromOffset(0, 8)
			Tween.to(self.Content, { Position = UDim2.fromOffset(0, 0) }, "Slide")
		else
			Tween.to(self.Button, { BackgroundTransparency = 1 }, "Hover")
			Tween.to(self.Label, { TextColor3 = theme:Get("TextDim") }, "Hover")
			Tween.to(self.Indicator, { Size = UDim2.fromOffset(3, 0) }, "Toggle")
			tintIcon(self.IconLabel, theme:Get("TextDim"))
		end
	end

	function Tab:Destroy()
		for _, s in ipairs(self.Sections) do s:Destroy() end
		self.maid:DoCleaning(); self.Button:Destroy(); self.Content:Destroy()
	end

	B.Section = Section
	B.Tab = Tab

	--==[ Window ]===========================================================--
	local Window = {}; Window.__index = Window

	function Window.new(library, opts)
		opts = opts or {}
		local self = setmetatable({}, Window)
		self.Library = library
		self.Theme = library.Theme
		self.State = library.State
		self.Hotkeys = library.Hotkeys
		self.Notifier = library.Notifier
		self.Tabs = {}
		self.maid = Maid.new()
		self.Visible = true
		self.Minimized = false
		self.Closed = Signal.new()
		local theme = self.Theme

		self.Gui = library.Gui

		local W, H = opts.Width or 640, opts.Height or 460
		local glassT = theme:Get("BackgroundOpacity") or 0.12

		-- Glassmorphism backdrop: a real blur of the scene behind the window plus a
		-- subtle exposure/tint, so the semi-transparent panel reads as frosted glass.
		-- Both are animated with the window's visibility (see _setGlass).
        local Lighting = game:GetService("Lighting")
        self._glassBlur = 12
        self.Blur = Create("BlurEffect", { Name = "i2_GlassBlur", Size = 0, Parent = Lighting })
        self.Glass = Create("ColorCorrectionEffect", { Name = "i2_GlassExposure",
            Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.fromRGB(255, 255, 255), Parent = Lighting })
        self.maid:Give(self.Blur); self.maid:Give(self.Glass)

		-- A CanvasGroup so the entire window (background + every child) can be faded
		-- as a single unit via GroupTransparency. Fading only the frame background
		-- left the children visible mid-animation, which looked broken on hide.
		self.Main = Create("CanvasGroup", {
			Name = "i2_Window", BackgroundColor3 = theme:Get("Background"), BackgroundTransparency = glassT,
			GroupTransparency = 0,
			BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(W, H), ClipsDescendants = true, Parent = self.Gui,
		})
		theme:Apply(self.Main, { BackgroundColor3 = "Background" })
		P.corner(self.Main, 14)
		local mainStroke = P.stroke(self.Main, theme:Get("Border"), 1.5, 0.1)
		theme:Apply(mainStroke, { Color = "Border" })
		-- A UIStroke on a CanvasGroup is NOT covered by GroupTransparency, so we fade
		-- it by hand alongside the group (otherwise the outline lingers on hide).
		self._mainStroke = mainStroke
		P.shadow(self.Main, theme:Get("ShadowIntensity"), 60)
		-- (No UIGradient on the window itself: a gradient on a CanvasGroup tints the
		-- whole composited group — including all child text/controls — not just the
		-- background, so the glass sheen is intentionally omitted here.)

		--==[ Decorative background: animated diagonal streaks ]==--
		local bg = Create("Frame", { Name = "Backdrop", BackgroundTransparency = 1, ClipsDescendants = true,
			Size = UDim2.fromScale(1, 1), ZIndex = 0, Parent = self.Main })
		local streaks = {}
		for i = 1, 14 do
			local s = Create("Frame", { BackgroundColor3 = theme:Get("AccentGlow"), BorderSizePixel = 0,
				BackgroundTransparency = 0.9, Rotation = 18, AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(2, math.random(40, 90)), ZIndex = 0, Parent = bg })
			P.corner(s, 2)
			P.gradient(s, ColorSequence.new(theme:Get("AccentGlow")), 90,
				NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1) }))
			streaks[i] = { f = s, x = math.random(), y = math.random() * 1.4 - 0.2, speed = 0.12 + math.random() * 0.22 }
		end
		self.maid:Give(Tween.bind(function(dt)
			if not self.Visible then return end
			for _, st in ipairs(streaks) do
				st.y += st.speed * dt
				st.x -= st.speed * dt * 0.25
				if st.y > 1.25 then st.y = -0.25; st.x = math.random() end
				st.f.Position = UDim2.fromScale(st.x, st.y)
			end
		end, 1/45))

		-- Global UI scale (responsive across resolutions) + open/close pop.
        self.MinBar = Create("CanvasGroup", {
            Name = "i2_MinBar", BackgroundColor3 = theme:Get("Background"), BackgroundTransparency = 0.2,
            GroupTransparency = 0, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 20),
            Size = UDim2.fromOffset(280, 40), ClipsDescendants = true, Parent = self.Gui, Visible = false,
        })
        P.corner(self.MinBar, 10)
        local minBarStroke = P.stroke(self.MinBar, theme:Get("Border"), 1, 0.5)
        -- A UIStroke on a CanvasGroup is NOT covered by GroupTransparency, so we must
        -- fade it by hand whenever the MinBar fades (otherwise its outline lingers and
        -- then snaps away). Keep a reference for the show/hide transitions.
        self._minBarStroke = minBarStroke
        theme:Apply(self.MinBar, { BackgroundColor3 = "Background" })
        theme:Apply(minBarStroke, { Color = "Border" })

        local minTitle = Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Title or "i2Library",
            Font = theme:Get("FontBold"), TextSize = 14, TextColor3 = theme:Get("Text"),
            TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
            Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -96, 1, 0), Parent = self.MinBar })
        theme:Apply(minTitle, { TextColor3 = "Text" })

        local function ctlMinButton(assetId, order, hoverColor, glyph, callback)
            local b = Create("TextButton", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1,
                AutoButtonColor = false, Text = "", AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -((order-1)*30 + 8), 0.5, 0), Size = UDim2.fromOffset(26, 26), Parent = self.MinBar })
            P.corner(b, 7); P.stroke(b, theme:Get("Border"), 1, 0.4)
            local ic
            if glyph then
                ic = Create("TextLabel", { BackgroundTransparency = 1, Text = glyph, Font = theme:Get("FontBold"),
                    TextSize = 16, TextColor3 = theme:Get("TextDim"), AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20), Parent = b })
            else
                ic = Create("ImageLabel", { BackgroundTransparency = 1, Image = assetId, ImageColor3 = theme:Get("TextDim"),
                    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 14), Parent = b })
            end
            local prop = glyph and "TextColor3" or "ImageColor3"
            b.MouseEnter:Connect(function()
                Tween.to(b, { BackgroundColor3 = theme:Get("Elevated"), BackgroundTransparency = 0.8 }, "Hover")
                Tween.to(ic, { [prop] = hoverColor or theme:Get("Text") }, "Hover")
            end)
            b.MouseLeave:Connect(function()
                Tween.to(b, { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1 }, "Hover")
                Tween.to(ic, { [prop] = theme:Get("TextDim") }, "Hover")
            end)
            b.MouseButton1Click:Connect(callback)
            return b
        end
        
        ctlMinButton("rbxassetid://10747384394", 1, theme:Get("Error"), nil, function() self:Close() end)
        ctlMinButton(nil, 2, nil, "+", function() self:Minimize() end)

        -- The minimized card is draggable on its own. The control buttons sit on
        -- top and swallow their own clicks, so grabbing the card body (or title)
        -- moves it without triggering close/restore.
        self:_enableDrag(self.MinBar, self.MinBar)

        self.Scale = Create("UIScale", { Scale = theme:Get("UIScale"), Parent = self.Main })
		theme.Changed:Connect(function() self.Scale.Scale = theme:Get("UIScale") end)

		--==[ Sidebar ]==--
		-- A floating, fully transparent panel: no fill, just a subtle outline, inset on
		-- all sides so it reads as a card hovering above the (frosted) main UI.
		local SIDEBAR = opts.SidebarWidth or 180
		local SIDEBAR_INSET = 12
		self.Sidebar = Create("Frame", { BackgroundColor3 = theme:Get("Surface"), BackgroundTransparency = 1,
			BorderSizePixel = 0, Position = UDim2.fromOffset(SIDEBAR_INSET, SIDEBAR_INSET),
			Size = UDim2.new(0, SIDEBAR - SIDEBAR_INSET - 6, 1, -SIDEBAR_INSET * 2), Parent = self.Main })
		P.corner(self.Sidebar, 12)
        local sbStroke = P.stroke(self.Sidebar, Color3.fromRGB(255, 255, 255), 1, 0.9)

		-- Brand header. The title is clipped to the sidebar card (right padding) and
		-- may wrap to two lines when there is no subtitle, so long game names stay in.
		local brand = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 56), Parent = self.Sidebar })
		P.padding(brand, 0, { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0, 13) })
        Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Title or "i2Library", Font = theme:Get("FontBold"), TextSize = 15, TextColor3 = theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, opts.SubTitle and 16 or 32), Parent = brand })
        if opts.SubTitle then
            Create("TextLabel", { BackgroundTransparency = 1, Text = opts.SubTitle, Font = theme:Get("Font"), TextSize = 11, TextColor3 = theme:Get("TextMuted"), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Position = UDim2.fromOffset(0, 18), Size = UDim2.new(1, 0, 0, 14), Parent = brand })
        end

		-- Tab list (scrollable).
		self.TabList = Create("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 64), Size = UDim2.new(1, -16, 1, -110),
			CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0, Parent = self.Sidebar })
		P.listLayout(self.TabList, 4)

		-- Settings shortcut pinned at bottom.
		self.SettingsButtonHolder = Create("Frame", { BackgroundTransparency = 1, AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 8, 1, -10), Size = UDim2.new(1, -16, 0, 36), Parent = self.Sidebar })

		--==[ Content area ]==--
		self.ContentRoot = Create("Frame", { BackgroundTransparency = 1,
			Position = UDim2.fromOffset(SIDEBAR, 0), Size = UDim2.new(1, -SIDEBAR, 1, 0), Parent = self.Main })

		-- Top bar (drag handle + window controls + current tab title).
		self.TopBar = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 48), Parent = self.ContentRoot })
		P.padding(self.TopBar, 0, { PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 14), PaddingTop = UDim.new(0,14) })
		self.TabTitle = Create("TextLabel", { BackgroundTransparency = 1, Text = "", Font = theme:Get("FontBold"),
			TextSize = 18, TextColor3 = theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -80, 0, 22), Parent = self.TopBar })
		theme:Apply(self.TabTitle, { TextColor3 = "Text" })

		-- Window control buttons. Pass `glyph` to render a text label instead of an
		-- image (used by Minimize, whose icon asset doesn't render reliably).
		local function ctlButton(assetId, order, hoverColor, glyph)
            local b = Create("TextButton", { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1,
				AutoButtonColor = false, Text = "", AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -((order-1)*30), 0, 0), Size = UDim2.fromOffset(26, 26), Parent = self.TopBar })
			P.corner(b, 7); P.stroke(b, theme:Get("Border"), 1, 0.4)
			local ic
			if glyph then
				ic = Create("TextLabel", { BackgroundTransparency = 1, Text = glyph, Font = theme:Get("FontBold"),
					TextSize = 16, TextColor3 = theme:Get("TextDim"), AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(20, 20), Parent = b })
			else
				ic = Create("ImageLabel", { BackgroundTransparency = 1, Image = assetId, ImageColor3 = theme:Get("TextDim"),
					AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(14, 14), Parent = b })
			end
			local prop = glyph and "TextColor3" or "ImageColor3"
			b.MouseEnter:Connect(function()
                Tween.to(b, { BackgroundColor3 = theme:Get("Elevated"), BackgroundTransparency = 0.8 }, "Hover")
				Tween.to(ic, { [prop] = hoverColor or theme:Get("Text") }, "Hover")
			end)
			b.MouseLeave:Connect(function()
                Tween.to(b, { BackgroundColor3 = theme:Get("SurfaceAlt"), BackgroundTransparency = 1 }, "Hover")
				Tween.to(ic, { [prop] = theme:Get("TextDim") }, "Hover")
			end)
			return b
		end
		local closeBtn = ctlButton("rbxassetid://10747384394", 1, theme:Get("Error"))
		local minBtn = ctlButton(nil, 2, nil, "—")
		closeBtn.MouseButton1Click:Connect(function() self:Close() end)
		minBtn.MouseButton1Click:Connect(function() self:Minimize() end)

		-- Content pages stack here.
		self.ContentArea = Create("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 48),
			Size = UDim2.new(1, -28, 1, -60), Parent = self.ContentRoot })

		--==[ Dragging ]==--
		self:_enableDrag(self.TopBar)
		self:_enableDrag(brand)

		--==[ Resizing (drag the bottom-right corner) ]==--
		self.MinSize = opts.MinSize or Vector2.new(440, 320)
		self.MaxSize = opts.MaxSize or Vector2.new(1100, 820)
		self:_enableResize()

		--==[ Toggle keybind — one key minimizes / restores the UI ]==--
		-- The minimized state IS the toggle now; there is no separate full-hide key.
		self.ToggleKey = opts.ToggleKey or opts.MinimizeKey or Enum.KeyCode.BackSlash
		self.Hotkeys:Reserve("__i2_toggle", self.ToggleKey)
		self.maid:Give(UserInputService.InputBegan:Connect(function(input, gpe)
			-- Honor gpe only for actual typing, so Shift/Ctrl toggle keys still work.
			if gpe and UserInputService:GetFocusedTextBox() then return end
			-- Ignore input while a keybind is being captured, otherwise assigning a
			-- new toggle key would also trigger it on the very same press.
			if self.Hotkeys:IsCapturing() then return end
			if input.KeyCode == Enum.KeyCode.Unknown then return end
			if self.ToggleKey and input.KeyCode == self.ToggleKey then
				self:Minimize()
			end
		end))

		-- Opening animation (scale pop + fade the whole group in).
		self._size = Vector2.new(W, H)
		self.Scale.Scale = (theme:Get("UIScale") or 1) * 0.92
		self.Main.GroupTransparency = 1
		self._mainStroke.Transparency = 1
		Tween.to(self.Scale, { Scale = theme:Get("UIScale") or 1 }, "Window")
		Tween.to(self.Main, { GroupTransparency = 0 }, "Window")
		Tween.to(self._mainStroke, { Transparency = 0.1 }, "Window")
		self:_setGlass(true)

		table.insert(library.Windows, self)
		return self
	end

	-- Drag `handle` to move `target` (defaults to the main window). Passing a
	-- separate target lets the minimized state card be dragged on its own.
	function Window:_enableDrag(handle, target)
		target = target or self.Main
		local dragging, dragStart, startPos
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true; dragStart = input.Position; startPos = target.Position
				input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
		self.maid:Give(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local d = input.Position - dragStart
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end))
	end

	-- A grab handle in the bottom-right corner. Dragging it outward grows the
	-- window; dragging back inward shrinks it. Because the window is centered
	-- (AnchorPoint 0.5,0.5) the corner is made to track the cursor by growing the
	-- size at twice the cursor delta, keeping the window centered as it scales.
	function Window:_enableResize()
		local theme = self.Theme
		local grip = Create("TextButton", {
			Name = "i2_ResizeGrip", BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -3, 1, -3),
			Size = UDim2.fromOffset(20, 20), ZIndex = 50, Parent = self.Main,
		})
		-- Classic diagonal dot-grid grip.
		for _, off in ipairs({ {3,3}, {3,9}, {9,3}, {3,15}, {9,9}, {15,3} }) do
			local dot = Create("Frame", { BackgroundColor3 = theme:Get("TextMuted"), BackgroundTransparency = 0.2,
				BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -off[1], 1, -off[2]), Size = UDim2.fromOffset(2, 2), Parent = grip })
			P.corner(dot, 1)
			theme:Apply(dot, { BackgroundColor3 = "TextMuted" })
		end

		local resizing, startPos, startSize
		grip.MouseEnter:Connect(function() Tween.to(grip, { BackgroundTransparency = 0.92 }, "Hover") end)
		grip.MouseLeave:Connect(function() if not resizing then Tween.to(grip, { BackgroundTransparency = 1 }, "Hover") end end)
		grip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startPos = input.Position
				startSize = self.Main.AbsoluteSize
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
						Tween.to(grip, { BackgroundTransparency = 1 }, "Hover")
					end
				end)
			end
		end)
		self.maid:Give(UserInputService.InputChanged:Connect(function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local scale = self.Scale and self.Scale.Scale or 1
				if scale <= 0 then scale = 1 end
				local d = input.Position - startPos
				-- AbsoluteSize already includes the UIScale, so divide back out to
				-- store the unscaled offset size the frame actually uses.
				local newW = Util.Clamp((startSize.X + d.X * 2) / scale, self.MinSize.X, self.MaxSize.X)
				local newH = Util.Clamp((startSize.Y + d.Y * 2) / scale, self.MinSize.Y, self.MaxSize.Y)
				self.Main.Size = UDim2.fromOffset(newW, newH)
				self._size = Vector2.new(newW, newH)
			end
		end))
	end

	function Window:AddTab(opts)
		opts = opts or {}
		local tab = Tab.new(self, opts)
		table.insert(self.Tabs, tab)
		-- Auto-select the first *user* tab as the default. The pinned Settings tab
		-- is built before any user tabs, so it must NOT claim the default slot.
		if not self.ActiveTab and not opts._isSettings then self:SelectTab(tab) end
		return tab
	end

	function Window:SelectTab(tab)
		if self.ActiveTab == tab then return end
		for _, t in ipairs(self.Tabs) do t:SetActive(t == tab) end
		if self._settingsTab then self._settingsTab:SetActive(self._settingsTab == tab) end
		self.ActiveTab = tab
		self.TabTitle.Text = tab.Name
	end
    function Window:Minimize()
        self.Minimized = not self.Minimized
        local base = self.Theme:Get("UIScale") or 1
        if self.Minimized then
            Tween.to(self.Scale, { Scale = base * 0.92 }, "Window")
            Tween.to(self._mainStroke, { Transparency = 1 }, "Window")
            Tween.to(self.Main, { GroupTransparency = 1 }, "Window", function()
                if self.Minimized then self.Main.Visible = false end
            end)
            self:_setGlass(false)

            self.MinBar.Visible = true
            self.MinBar.GroupTransparency = 1
            if self._minBarStroke then self._minBarStroke.Transparency = 1 end
            Tween.to(self.MinBar, { GroupTransparency = 0 }, "Window")
            if self._minBarStroke then Tween.to(self._minBarStroke, { Transparency = 0.5 }, "Window") end
        else
            Tween.to(self.MinBar, { GroupTransparency = 1 }, "Window", function()
                if not self.Minimized then self.MinBar.Visible = false end
            end)
            -- Fade the outline together with the group so it never lingers behind.
            if self._minBarStroke then Tween.to(self._minBarStroke, { Transparency = 1 }, "Window") end

            self.Main.Visible = true
            self.Scale.Scale = base * 0.92
            Tween.to(self.Scale, { Scale = base }, "Window")
            Tween.to(self._mainStroke, { Transparency = 0.1 }, "Window")
            Tween.to(self.Main, { GroupTransparency = 0 }, "Window")
            self:_setGlass(true)
        end
    end

    function Window:_setGlass(on)
        if not self.Blur then return end
        Tween.to(self.Blur, { Size = on and (self._glassBlur or 12) or 0 }, "Window")
        Tween.to(self.Glass, { Brightness = on and 0.04 or 0, Contrast = on and 0.06 or 0,
            Saturation = on and 0.08 or 0,
            TintColor = on and Color3.fromRGB(244, 244, 255) or Color3.fromRGB(255, 255, 255) }, "Window")
    end

    function Window:Toggle(force)
        if force ~= nil then self.Visible = force else self.Visible = not self.Visible end
        local base = self.Theme:Get("UIScale") or 1
        
        if self.Visible and self.Minimized then
            self.Minimized = false
            self.MinBar.Visible = false
        end

        if self.Visible then
            self.Main.Visible = true
            self.Main.GroupTransparency = 1
            self._mainStroke.Transparency = 1
            self.Scale.Scale = base * 0.92
            Tween.to(self.Scale, { Scale = base }, "Window")
            Tween.to(self.Main, { GroupTransparency = 0 }, "Window")
            Tween.to(self._mainStroke, { Transparency = 0.1 }, "Window")
            self:_setGlass(true)
        else
            self:_setGlass(false)
            if self.Minimized then
                Tween.to(self.MinBar, { GroupTransparency = 1 }, "Window", function()
                    if not self.Visible then self.MinBar.Visible = false end
                end)
                if self._minBarStroke then Tween.to(self._minBarStroke, { Transparency = 1 }, "Window") end
            else
                Tween.to(self.Scale, { Scale = base * 0.92 }, "Window")
                Tween.to(self._mainStroke, { Transparency = 1 }, "Window")
                Tween.to(self.Main, { GroupTransparency = 1 }, "Window", function()
                    if not self.Visible then self.Main.Visible = false end
                end)
            end
        end
    end

    function Window:Close()
        self.Visible = false
        self:_setGlass(false)
        if self.Minimized then
            Tween.to(self.MinBar, { GroupTransparency = 1 }, "Window", function()
                self.Closed:Fire()
                self:Destroy()
            end)
            if self._minBarStroke then Tween.to(self._minBarStroke, { Transparency = 1 }, "Window") end
        else
            Tween.to(self.Scale, { Scale = (self.Theme:Get("UIScale") or 1) * 0.92 }, "Window")
            Tween.to(self._mainStroke, { Transparency = 1 }, "Window")
            Tween.to(self.Main, { GroupTransparency = 1 }, "Window", function()
                self.Closed:Fire()
                self:Destroy()
            end)
        end
    end

    function Window:SerializeLayout()
        return {
            pos = { self.Main.Position.X.Scale, self.Main.Position.X.Offset, self.Main.Position.Y.Scale, self.Main.Position.Y.Offset },
            activeTab = self.ActiveTab and self.ActiveTab.Name or nil,
            minimized = self.Minimized,
        }
    end

    function Window:RestoreLayout(data)
        if not data then return end
        if data.pos then self.Main.Position = UDim2.new(data.pos[1], data.pos[2], data.pos[3], data.pos[4]) end
        if data.activeTab then
            for _, t in ipairs(self.Tabs) do
                if t.Name == data.activeTab then self:SelectTab(t); break end
            end
        end
        -- NOTE: the minimized state is intentionally NOT restored. The window must
        -- always boot in its normal (open) state; auto-minimizing on load looked like
        -- a bug (the UI would pop up, then immediately collapse to the min-bar).
    end

	function Window:Destroy()
		self.Hotkeys:Unbind("__i2_toggle")
		for _, t in ipairs(self.Tabs) do t:Destroy() end
		if self._settingsTab then self._settingsTab:Destroy() end
		self.maid:DoCleaning()
		self.Main:Destroy()
		local idx = Util.IndexOf(self.Library.Windows, self)
		if idx then table.remove(self.Library.Windows, idx) end
	end

	B.Window = Window


	return B
end)


--============================================================================--
--  MODULE :: Settings   (auto-generated, zero-config Settings tab)
--============================================================================--
define("Settings", function(import)
	local Settings = {}

	-- Builds a full Settings tab into `window`, wired to `library` subsystems.
	function Settings.build(window, library)
		local theme = window.Theme
		local cfg = library.Config
		local tab = window:AddTab({ Name = "Settings", Icon = "settings", LayoutOrder = 999, _isSettings = true })

		--==[ Configuration Management ]==--
		local cfgSec = tab:AddSection("Configuration")
		local nameBox = cfgSec:AddTextbox({ Name = "Config name", Placeholder = "my config", Default = "default" })
		local listDropdown = cfgSec:AddDropdown({ Name = "Saved configs", Search = true,
			Options = cfg:List(), Default = nil })

		local function refreshList()
			listDropdown:SetOptions(cfg:List())
		end

		cfgSec:AddButton({ Name = "Save", Icon = "save", Primary = true, Callback = function()
			local n = nameBox:Get(); if n == "" then n = "default" end
			cfg.Name = n; cfg:Save(n); cfg:SetLast(n); refreshList()
			library.Notifier:Push({ Type = "success", Title = "Saved", Content = "Config '" .. n .. "' saved." })
		end })
		cfgSec:AddButton({ Name = "Load", Icon = "download", Callback = function()
			local n = listDropdown:Get() or nameBox:Get()
			if not n then library.Notifier:Push({ Type = "warning", Title = "Select a config first" }); return end
			local ok = cfg:Load(n)
			cfg:SetLast(n)
			library.Notifier:Push({ Type = ok and "success" or "error", Title = ok and "Loaded" or "Load failed", Content = "Config '" .. n .. "'" })
		end })
		cfgSec:AddButton({ Name = "Delete", Icon = "trash", Callback = function()
			local n = listDropdown:Get(); if not n then return end
			library:Confirm({ Title = "Delete config?", Content = "This will permanently delete '" .. n .. "'.", Confirm = "Delete", OnConfirm = function()
				cfg:Delete(n); refreshList()
				library.Notifier:Push({ Type = "info", Title = "Deleted", Content = n })
			end })
		end })
		cfgSec:AddToggle({ Name = "Auto-save", Description = "Save the active config on change",
			Default = cfg.AutoSave, Callback = function(v) library:SetAutoSave(v) end })

		--==[ Theme Settings ]==--
		local themeSec = tab:AddSection("Theme")
		local presetNames = {}
		do
			local ThemeMod = import("Theme")
			for name in pairs(ThemeMod.Presets) do table.insert(presetNames, name) end
			table.sort(presetNames)
		end
		themeSec:AddDropdown({ Name = "Theme", Options = presetNames, Default = theme.Name,
			Callback = function(v) theme:SetPreset(v) end })
		themeSec:AddColorPicker({ Name = "Accent color", Default = theme:Get("Accent"),
			Callback = function(c) theme:SetAccent(c) end })

		--==[ Library Settings ]==--
		local libSec = tab:AddSection("Library")
		-- These keybinds only DISPLAY/REBIND the window keys. The window itself
		-- handles the actual key press (see Window's direct input listener), so we
		-- must NOT also toggle here or it would fire twice and cancel out.
		libSec:AddKeybind({ Name = "Toggle UI", Mode = "Always", Default = window.ToggleKey, NoBind = true,
			Id = "__i2_toggle", OnChanged = function(k) window.ToggleKey = k end })
		libSec:AddToggle({ Name = "Animations", Default = true,
			Callback = function(v) import("Tween").Enabled = v end })
		libSec:AddToggle({ Name = "Notification sounds", Default = true,
			Callback = function(v) library.Notifier.SoundEnabled = v end })
		libSec:AddButton({ Name = "Unload", Icon = "power", Callback = function()
			library:Destroy()
		end })

		window._settingsTab = tab
		return tab
	end

	return Settings
end)


--============================================================================--
--  MODULE :: Dialogs   (modal + confirmation dialogs, context menu)
--============================================================================--
define("Dialogs", function(import)
	local Util = import("Util")
	local Tween = import("Tween")
	local P = import("Primitives")
	local Create = Util.Create

	local Dialogs = {}

	-- Modal with arbitrary content builder + buttons. Centered, auto-sized, glassy.
	function Dialogs.modal(library, opts)
		local theme = library.Theme
		local width = opts.Width or 380
		local overlay = Create("Frame", { BackgroundColor3 = theme:Get("Overlay"), BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1), ZIndex = 8000, Parent = library.Gui })
		Tween.to(overlay, { BackgroundTransparency = 0.45 }, "Hover")

		-- AnchorPoint-centered card; AutomaticSize.Y on Y only (fixed width).
		local box = Create("Frame", { BackgroundColor3 = theme:Get("Elevated"), BackgroundTransparency = 0.04,
			BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(width, 0), AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 8001, Parent = overlay })
		P.corner(box, 14); P.stroke(box, theme:Get("Border"), 1.5, 0.1); P.shadow(box, 0.6)
		P.gradient(box, ColorSequence.new(Util.Shade(theme:Get("Elevated"), 0.04), theme:Get("Elevated")), 90)
		local scale = Create("UIScale", { Scale = 0.9, Parent = box })

		-- Inner content frame owns the UIListLayout + padding. Keeping the shadow on
		-- `box` (no layout) prevents it from being stacked into the card, which would
		-- otherwise blow up the height and push the buttons outside the card.
		local content = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 8002, Parent = box })
		P.padding(content, 18)
		Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

		Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Title or "Dialog", Font = theme:Get("FontBold"),
			TextSize = 17, TextColor3 = theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 22), ZIndex = 8002, Parent = content })
		if opts.Content then
			Create("TextLabel", { BackgroundTransparency = 1, Text = opts.Content, Font = theme:Get("Font"),
				TextSize = 14, TextColor3 = theme:Get("TextDim"), TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true, RichText = true, AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 14), ZIndex = 8002, Parent = content })
		end

		if opts.Build then opts.Build(content) end

		local function close() Tween.to(scale, { Scale = 0.9 }, "Press"); Tween.to(overlay, { BackgroundTransparency = 1 }, "Hover", function() overlay:Destroy() end) end

		local btnRow = Create("Frame", { BackgroundTransparency = 1, LayoutOrder = 50, Size = UDim2.new(1, 0, 0, 36), ZIndex = 8002, Parent = content })
		Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Parent = btnRow })
		for _, b in ipairs(opts.Buttons or {}) do
			local btn = Create("TextButton", { BackgroundColor3 = b.Primary and theme:Get("Accent") or theme:Get("SurfaceAlt"),
				AutoButtonColor = false, Text = b.Text or "OK", Font = theme:Get("FontBold"), TextSize = 14,
				TextColor3 = theme:Get("Text"), Size = UDim2.fromOffset(b.Width or 100, 36), ZIndex = 8003, Parent = btnRow })
			P.corner(btn, 9)
			if b.Primary then P.stroke(btn, theme:Get("AccentGlow"), 1, 0.3) end
			btn.MouseEnter:Connect(function() Tween.to(btn, { BackgroundColor3 = b.Primary and theme:Get("AccentGlow") or theme:Get("Elevated") }, "Hover") end)
			btn.MouseLeave:Connect(function() Tween.to(btn, { BackgroundColor3 = b.Primary and theme:Get("Accent") or theme:Get("SurfaceAlt") }, "Hover") end)
			btn.MouseButton1Click:Connect(function()
				if b.Callback then task.spawn(b.Callback) end
				if b.Close ~= false then close() end
			end)
		end

		Tween.to(scale, { Scale = 1 }, "Window")
		return { Close = close, Frame = box }
	end

	function Dialogs.confirm(library, opts)
		return Dialogs.modal(library, {
			Title = opts.Title or "Are you sure?",
			Content = opts.Content,
			Buttons = {
				{ Text = opts.Cancel or "Cancel", Callback = opts.OnCancel },
				{ Text = opts.Confirm or "Confirm", Primary = true, Callback = opts.OnConfirm },
			},
		})
	end

	-- Prompt: a modal with a single text field plus Cancel/Confirm. The confirm
	-- callback receives the typed text. Press Enter in the field to confirm too.
	function Dialogs.prompt(library, opts)
		local theme = library.Theme
		local field
		local handle
		local function submit()
			if opts.OnConfirm then opts.OnConfirm(field and field.Text or "") end
		end
		handle = Dialogs.modal(library, {
			Title = opts.Title or "Enter text",
			Content = opts.Content,
			Width = opts.Width or 380,
			Build = function(content)
				field = Create("TextBox", {
					BackgroundColor3 = theme:Get("SurfaceAlt"), Text = opts.Default or "",
					PlaceholderText = opts.Placeholder or "Type here...", PlaceholderColor3 = theme:Get("TextMuted"),
					Font = theme:Get("Font"), TextSize = 14, TextColor3 = theme:Get("Text"),
					ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 10, Size = UDim2.new(1, 0, 0, 36), ZIndex = 8002, Parent = content,
				})
				P.corner(field, 8); local fStroke = P.stroke(field, theme:Get("Border"), 1, 0.3)
				P.padding(field, 0, { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
				field.Focused:Connect(function() Tween.to(fStroke, { Color = theme:Get("Accent"), Transparency = 0 }, "Hover") end)
				field.FocusLost:Connect(function(enter)
					Tween.to(fStroke, { Color = theme:Get("Border"), Transparency = 0.3 }, "Hover")
					if enter then submit(); if handle then handle.Close() end end
				end)
			end,
			Buttons = {
				{ Text = opts.Cancel or "Cancel", Callback = function() if opts.OnCancel then opts.OnCancel() end end },
				{ Text = opts.Confirm or "Confirm", Primary = true, Callback = submit },
			},
		})
		return handle
	end

	-- Right-click context menu at the mouse position (glassy, edge-aware).
	function Dialogs.contextMenu(library, items)
		local UserInputService = game:GetService("UserInputService")
		local theme = library.Theme
		local m = UserInputService:GetMouseLocation()
		local W = 170
		-- Transparent, glassy menu: tinted backdrop + crisp outline, no drop shadow.
		local menu = Create("Frame", { BackgroundColor3 = theme:Get("Background"), BackgroundTransparency = 0.25,
			BorderSizePixel = 0, Position = UDim2.fromOffset(m.X, m.Y), Size = UDim2.fromOffset(W, 0),
			AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 8500, Parent = library.Gui })
		P.corner(menu, 10); P.stroke(menu, theme:Get("Border"), 1.5, 0)
		local scale = Create("UIScale", { Scale = 0.92, Parent = menu })
		Tween.to(scale, { Scale = 1 }, "Expand")

		-- Inner content frame owns the layout so the shadow (on `menu`) stays out of it.
		local content = Create("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 8501, Parent = menu })
		P.padding(content, 6)
		Create("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = content })

		local closed = false
		local closeConn
		local function close()
			if closed then return end
			closed = true
			if closeConn then closeConn:Disconnect() end
			menu:Destroy()
		end
		for _, item in ipairs(items) do
			local entry = Create("TextButton", { BackgroundColor3 = theme:Get("Elevated"), BackgroundTransparency = 1,
				AutoButtonColor = false, Text = "  " .. (item.Text or "Item"), Font = theme:Get("Font"), TextSize = 13,
				TextColor3 = item.Danger and theme:Get("Error") or theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 28), ZIndex = 8501, Parent = content })
			P.corner(entry, 6)
			entry.MouseEnter:Connect(function() Tween.to(entry, { BackgroundTransparency = 0, BackgroundColor3 = theme:Get("SurfaceAlt") }, "Hover") end)
			entry.MouseLeave:Connect(function() Tween.to(entry, { BackgroundTransparency = 1 }, "Hover") end)
			entry.MouseButton1Click:Connect(function() if item.Callback then task.spawn(item.Callback) end close() end)
		end

		-- Keep on-screen, then close when clicking outside.
		task.defer(function()
			local cam = workspace.CurrentCamera
			local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
			local sz = menu.AbsoluteSize
			local x = math.min(m.X, vp.X - sz.X - 8)
			local y = math.min(m.Y, vp.Y - sz.Y - 8)
			menu.Position = UDim2.fromOffset(math.max(x, 8), math.max(y, 8))
		end)
		task.delay(0.06, function()
			if closed then return end
			closeConn = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
					local mp = UserInputService:GetMouseLocation()
					local p, s = menu.AbsolutePosition, menu.AbsoluteSize
					if not (mp.X >= p.X and mp.X <= p.X+s.X and mp.Y >= p.Y and mp.Y <= p.Y+s.Y) then close() end
				end
			end)
			if library._maid then library._maid:Give(closeConn) end
		end)
		return { Close = close }
	end

	return Dialogs
end)


--============================================================================--
--  MAIN :: library entry point
--============================================================================--
local Library = {}
Library.__index = Library
Library.Version = "1.0.0"

local Util = import("Util")
local Theme = import("Theme")
local State = import("State")
local Hotkeys = import("Hotkeys")
local Notify = import("Notify")
local Config = import("Config")
local Builders = import("Builders")
local SettingsMod = import("Settings")
local Dialogs = import("Dialogs")
local Maid = import("Maid")
local Icons = import("Icons")

function Library.new(opts)
	opts = opts or {}
	local self = setmetatable({}, Library)
	self.Windows = {}
	self.PerformanceMode = false
	self.DevMode = false
	self.AutoLoadLast = opts.AutoLoadLast ~= false
	self._maid = Maid.new()

	-- Root ScreenGui. Use the safest available parent for the executor.
	local parent
	local ok = pcall(function()
		if typeof(gethui) == "function" then parent = gethui()
		elseif game:GetService("CoreGui") then parent = game:GetService("CoreGui") end
	end)
	if not parent then parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

	self.Gui = Util.Create("ScreenGui", {
		Name = opts.Name or "i2Library",
		ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true, DisplayOrder = 999, Parent = parent,
	})
	-- Protect from detection clearing where supported.
	pcall(function() if syn and syn.protect_gui then syn.protect_gui(self.Gui) end end)
	self._maid:Give(self.Gui)

	self.Theme = Theme.new(opts.Theme)
	if opts.Accent then self.Theme:SetAccent(opts.Accent) end
	self.State = State.new()
	self.Hotkeys = Hotkeys.new()
	self._maid:Give(self.Hotkeys)
	self.Notifier = Notify.new(self.Theme, self.Gui)
	self._maid:Give(self.Notifier)

	self.Config = Config.new({
		Folder = opts.ConfigFolder or (opts.Name or "i2Library"),
		State = self.State, Theme = self.Theme, AutoSave = opts.AutoSave,
	})

	-- Auto-save debounce.
	if self.Config.AutoSave then
		self.State.Changed:Connect(function()
			if self._autoSaveScheduled then return end
			self._autoSaveScheduled = true
			task.delay(1.5, function()
				self._autoSaveScheduled = false
				if self.Config.AutoSave then self.Config:Save() end
			end)
		end)
	end
	return self
end

--==[ Public API ]==--

function Library:CreateWindow(opts)
	local window = Builders.Window.new(self, opts)
	window.Config = self.Config
	self.Config.Window = window

	-- Auto Settings tab (unless disabled).
	if not (opts and opts.Settings == false) then
		SettingsMod.build(window, self)
	end

	-- Auto-load last config after the window/tabs exist.
	if self.AutoLoadLast then
		task.defer(function()
			local last = self.Config:GetLast()
			if last and last ~= "" then
				last = Util.Trim(last)
				pcall(function() self.Config:Load(last) end)
			end
		end)
	end
	return window
end

function Library:Notify(opts) return self.Notifier:Push(opts) end
function Library:Confirm(opts) return Dialogs.confirm(self, opts) end
function Library:Dialog(opts) return Dialogs.modal(self, opts) end
function Library:Prompt(opts) return Dialogs.prompt(self, opts) end
function Library:ContextMenu(items) return Dialogs.contextMenu(self, items) end

function Library:SetTheme(name) self.Theme:SetPreset(name) end
function Library:SetAccent(color) self.Theme:SetAccent(color) end
function Library:SetAutoSave(v) self.Config.AutoSave = v end

function Library:GetFlag(flag) return self.State:Get(flag) end
function Library:SetFlag(flag, value) self.State:Set(flag, value) end
function Library:RegisterIcon(name, assetId) Icons.register(name, assetId) end
function Library:RegisterTheme(name, palette) Theme.Presets[name] = palette end

-- Plugin system: register a custom component constructor at runtime.
function Library:RegisterComponent(name, constructor)
	local Components = import("Components")
	Components[name] = constructor
	-- expose sugar on Section
	Builders.Section["Add" .. name] = function(section, o) return section:Add(name, o) end
end

function Library:Destroy()
	for i = #self.Windows, 1, -1 do self.Windows[i]:Destroy() end
	self._maid:DoCleaning()
end

-- The module returns a thin facade so users can call i2:CreateWindow(...).
local instance
local Facade = setmetatable({}, {
	__index = function(_, k)
		if not instance then instance = Library.new() end
		local v = instance[k]
		if type(v) == "function" then
			return function(_, ...) return v(instance, ...) end
		end
		return v
	end,
})

-- Allow both styles:
--   local i2 = loadstring(...)()        ; i2:CreateWindow{...}        (lazy default instance)
--   local i2 = loadstring(...)().new{}  ; explicit instance with options
Facade.new = function(o) instance = Library.new(o); return instance end
Facade.Library = Library
Facade.Version = Library.Version

return Facade
