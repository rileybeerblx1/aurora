local BaseURL = "https://api.pandauth.com/api/v1"
local Client_ServiceID = "aurora"

local ConfigURL = "https://getaurora.pages.dev/android/config/AuroraRBLX.json"
local http_service = (cloneref and cloneref(game:GetService("HttpService"))) or game:GetService("HttpService")

local AuroraConfiguration = {}
pcall(function()
    local rawConfig = game:HttpGet(ConfigURL)
    AuroraConfiguration = http_service:JSONDecode(rawConfig)
end)

local function safe_clone(fn)
    if type(fn) == "function" then
        if clonefunction then
            local success, res = pcall(clonefunction, fn)
            if success and res then return res end
        end
        return fn
    end
    return function() end
end

local raw_request = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)

--// Instances
local function Notify(messages)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Aurora",
            Text = tostring(messages),
            Icon = "rbxassetid://138333994428979",
            Duration = 5,
        })
    end)
end

local function getHardwareId()
    local success, hwid = pcall(function() return gethwid() end)
    if success and hwid then
        return hwid
    end
  
    local RbxAnalyticsService = game:GetService("RbxAnalyticsService")  
    local clientId = tostring(RbxAnalyticsService:GetClientId())  
    return clientId:gsub("-", "")
end

local function makeRequest(endpoint, body)
    local HttpService = game:GetService("HttpService")
    local url = BaseURL .. endpoint  
    local jsonBody = HttpService:JSONEncode(body)  

    if not raw_request then return nil end

    local response = raw_request({  
        Url = url,  
        Method = "POST",  
        Headers = {  
            ["Content-Type"] = "application/json"  
        },  
        Body = jsonBody  
    })  

    if response and response.Body then  
        return HttpService:JSONDecode(response.Body)  
    end  

    return nil
end

function GetKeyURL()
    local hwid = getHardwareId()
    return "https://ads.pandauth.com/getkey/" .. Client_ServiceID .. "?hwid=" .. hwid
end

function OpenGetKey()
    local url = GetKeyURL()
    local cb = setclipboard or (syn and syn.write_clipboard)
    if cb then
        cb(url)
        print("Key URL copied to clipboard: " .. url)
    end
    return url
end

function Validate(key, Premium_Verification)
    local hwid = getHardwareId()

    local result = makeRequest("/keys/validate", {  
        ServiceID = Client_ServiceID,  
        HWID = hwid,  
        Key = key  
    })  

    if not result then  
        return {  
            success = false,  
            message = "Failed to connect to server",  
            isPremium = false,  
            expireDate = nil  
        }  
    end  

    local isAuthenticated = result.Authenticated_Status == "Success"  
    local isPremium = result.Key_Premium or false  

    local isValid = isAuthenticated  
    local message = result.Note or (isAuthenticated and "Key validated!" or "Invalid key")  

    if Premium_Verification and isAuthenticated and not isPremium then  
        isValid = false  
        message = "Premium key required"  
    end  

    return {  
        success = isValid,  
        message = message,  
        isPremium = isPremium,  
        expireDate = result.Expire_Date  
    }
end

local IsKeyLess = true
local function CheckKey(ClientKey, Premium_Verification)
    if IsKeyLess then
        if typeof(Notify) == "function" then
            Notify("Key System Disabled...")
        end
        return true
    end
    local result = Validate(ClientKey, Premium_Verification)
    if result and result.success then
        print("Authorized Complete")
        return true
    else
        warn("Failed to Authorize: " .. tostring(result and result.message or "Unknown error"))
        return false
    end
end

function Load_CustomFunctions()
    print("Custom Features successfully loaded...")
end

--[[ Settings ]]--
local maxLines = 250;

--[[ Variables ]]--
local httpService = game:GetService("HttpService");
local teleportService = game:GetService("TeleportService");
local textService = game:GetService("TextService");
local tweenService = game:GetService("TweenService");
local userInputService = game:GetService("UserInputService");

local localPlayer = game:GetService("Players").LocalPlayer;
local hugeVector2 = Vector2.new(math.huge, math.huge);

local rScriptsApiKey = "0";
local env = (getgenv and getgenv()) or _G;
local isFirstTimeExecution = true;

local _newcclosure = safe_clone(newcclosure or function(f) return f end);
local _setfpscap = safe_clone(setfpscap or function() end);
local _getfpsmax = safe_clone(getfpsmax or function() return 60 end);

local _getconnections = safe_clone(getconnections or function() return {} end);
local _getcustomasset = safe_clone(getcustomasset or getsynasset or function() return "" end);

local _isfile = safe_clone(isfile or function() return false end);
local _readfile = safe_clone(readfile or function() return "" end);
local _writefile = safe_clone(writefile or function() end);
local _delfile = safe_clone(delfile or function() end);
local _listfiles = safe_clone(listfiles or function() return {} end);

local _isfolder = safe_clone(isfolder or function() return false end);
local _makefolder = safe_clone(makefolder or function() end);

local _getclipboard = safe_clone(getclipboard or function() return "" end);
local _setclipboard = safe_clone(setclipboard or function() end);

local _request = safe_clone(raw_request or function() end);
local _base64decode = crypt and crypt.base64 and safe_clone(crypt.base64.decode) or function(s) return s end;

local urlEncode = function(svc, str) return svc:UrlEncode(str) end;
local jsonEncode = function(svc, tbl) return svc:JSONEncode(tbl) end;
local jsonDecode = function(svc, str) return svc:JSONDecode(str) end;

local _gethui = safe_clone(gethui or function()
    return game:GetService("CoreGui");
end);

local validSearchFunctions = { 
    ScriptBlox = "rbxassetid://13107640311",
    RScripts = "rbxassetid://13107640500"
};

local serverHopModes = { "full", "empty", "bestPing", "random" };

local resizeFunctions, languageItems, languageDatabase = {}, {}, {
    English = {
        flag = "rbxassetid://13084648602",
        indicator = "English",
        order = 1,
        phrases = {
            FreeLogin = "Free Login",
            AdlessLogin = "Adless Login",
            EnterKey = "Enter Key",
            CopyKeyLink = "Copy Key Link",
            ["Key..."] = "Key...",
            SubmitCredentials = "Submit Credentials",
            ["User..."] = "Username...",
            ["Password..."] = "Password...",
            Editor = "Editor",
            Execute = "Execute",
            Clear = "Clear",
            Clipboard = "Clipboard",
            CopyScript = "Copy Script",
            LoadScript = "Load Script",
            ["Search..."] = "Search...",
            Search = "Search",
            ClearConsole = "Clear Console",
            CopyConsole = "Copy Console",
            UnlockFPS = "Unlock FPS",
            VSync = "V-Sync",
            FPS = "FPS",
            AntiAFK = "Anti AFK",
            Full = "Full",
            Empty = "Empty",
            BestPing = "Best Ping",
            Random = "Random",
            ServerHop = "Server Hop",
            RejoinServer = "Rejoin Server"
        }
    },
    Turkish = {
        flag = "rbxassetid://13084681224",
        indicator = "Türkçe",
        order = 2,
        phrases = {
            FreeLogin = "Ücretsiz Giriş",
            AdlessLogin = "Reklamsız Giriş",
            EnterKey = "Anahtarı Gir",
            CopyKeyLink = "Anahtar Linkini Kopyala",
            ["Key..."] = "Anahtar...",
            SubmitCredentials = "Giriş Yap",
            ["User..."] = "İsim...",
            ["Password..."] = "Şifre...",
            Editor = "Düzenleyici",
            Execute = "Yürüt",
            Clear = "Temizle",
            Clipboard = "Pano",
            CopyScript = "Panoya Kopyala",
            LoadScript = "Panodan Yükle",
            ["Search..."] = "Arat...",
            Search = "Arama",
            ClearConsole = "Konsolu Temizle",
            CopyConsole = "Konsolu Kopyala",
            UnlockFPS = "FPS Kilidini Aç",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    },
    Spanish = {
        flag = "rbxassetid://13084681842",
        indicator = "Español",
        order = 4,
        phrases = {
            FreeLogin = "Iniciar sesion gratis",
            AdlessLogin = "Iniciar sesion sin anuncios",
            EnterKey = "Ingresar Key",
            CopyKeyLink = "Copiar enlace de la Key",
            ["Key..."] = "Key...",
            SubmitCredentials = "Enviar Credenciales",
            ["User..."] = "Usuario...",
            ["Password..."] = "Contraseña...",
            Editor = "Editor",
            Execute = "Executar",
            Clear = "Limpiar",
            Clipboard = "Portapapeles",
            CopyScript = "Copiar Script",
            LoadScript = "Cargar Script",
            ["Search..."] = "Buscar...",
            Search = "Buscar",
            ClearConsole = "Limpiar Consola",
            CopyConsole = "Copiar Consola",
            UnlockFPS = "Unlocar FPS",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    },
    Latvian = {
        flag = "rbxassetid://13084681629",
        indicator = "Latviski",
        order = 5,
        phrases = {
            FreeLogin = "Bezmaksas pieeja",
            AdlessLogin = "Bez-reklāmu pieeja",
            EnterKey = "Ievadi atslēgu",
            CopyKeyLink = "Kopēt atslēgas saiti",
            ["Key..."] = "Atslēga...",
            SubmitCredentials = "Apstiprināt akreditācijas datus",
            ["User..."] = "Lietotājs...",
            ["Password..."] = "Parole...",
            Editor = "Redaktors",
            Execute = "Izpildīt",
            Clear = "Iztīrīt",
            Clipboard = "Kopējumi",
            CopyScript = "Kopēt skriptu",
            LoadScript = "Ielādēt skriptu",
            ["Search..."] = "Meklēt...",
            Search = "Meklēt",
            ClearConsole = "Iztīrīt konsoli",
            CopyConsole = "Kopēt konsoli",
            UnlockFPS = "Atbloķējiet FPS",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    },
    Dutch = {
        flag = "rbxassetid://15984949262",
        indicator = "Nederlands",
        order = 6,
        phrases = {
            FreeLogin = "Gratis Login",
            AdlessLogin = "ReclameVrij Login",
            EnterKey = "Toegangs Sleutel",
            CopyKeyLink = "Kopieer Sleutel Link",
            ["Key..."] = "Sleutel...",
            SubmitCredentials = "Verzend Gegevens",
            ["User..."] = "Gebruiker...",
            ["Password..."] = "Wachtwoord...",
            Editor = "Editor",
            Execute = "Uitvoeren",
            Clear = "Clear",
            Clipboard = "Klembord",
            CopyScript = "Kopieer Script ",
            LoadScript = "Laad Script",
            ["Search..."] = "Zoeken...",
            Search = "Zoeken",
            ClearConsole = "Clear Console",
            CopyConsole = "Kopieer Console",
            UnlockFPS = "Ontgrendelen FPS",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    },
    Filipino = {
        flag = "rbxassetid://15984949030",
        indicator = "Filipino",
        order = 7,
        phrases = {
            FreeLogin = "Libreng Login",
            AdlessLogin = "Ad-Free Login",
            EnterKey = "Ilagay ang susi",
            CopyKeyLink = "Kopyahin ang Susi Link",
            ["Key..."] = "Susi...",
            SubmitCredentials = "Ipasa ang Kredensyals",
            ["User..."] = "User",
            ["Password..."] = "Password",
            Editor = "Editor",
            Execute = "Execute",
            Clear = "Clear",
            Clipboard = "Clipboard",
            CopyScript = "Kopyahin ang script",
            LoadScript = "I-Load ang script",
            ["Search..."] = "Maghanap...",
            Search = "Maghanap",
            ClearConsole = "ClearConsole",
            CopyConsole = "CopyConsole",
            UnlockFPS = "",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    },
    German = {
        flag = "rbxassetid://15984949736",
        indicator = "Deustch",
        order = 8,
        phrases = {
            FreeLogin = "Kostenloser Login",
            AdlessLogin = "Adless Login",
            EnterKey = "Key checken",
            CopyKeyLink = "Link kopieren",
            ["Key..."] = "Schlüssel",
            SubmitCredentials = "Einloggen",
            ["User..."] = "Nutzername",
            ["Password..."] = "Passwort",
            Editor = "Editor",
            Execute = "Ausführen",
            Clear = "Löschen",
            Clipboard = "",
            CopyScript = "Skript Kopieren",
            LoadScript = "Skript Laden",
            ["Search..."] = "Suchen...",
            Search = "Suchen",
            ClearConsole = "Konsole löschen",
            CopyConsole = "Konsole kopieren",
            UnlockFPS = "Freischalten FPS",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    },
    Romanian = {
        flag = "rbxassetid://15984948805",
        indicator = "Română",
        order = 9,
        phrases = {
            FreeLogin = "Logare Gratis",
            AdlessLogin = "Logare fara reclame",
            EnterKey = "Introduce cheie",
            CopyKeyLink = "Copie adresa pentru cheie",
            ["Key..."] = "Cheie...",
            SubmitCredentials = "Introduce-ti datele",
            ["User..."] = "Utilizator...",
            ["Password..."] = "Parola...",
            Editor = "Editor",
            Execute = "Executa",
            Clear = "Goleste",
            Clipboard = "Clipboard",
            CopyScript = "Copiaza Script",
            LoadScript = "Incarca Script",
            ["Search..."] = "Cauta...",
            Search = "Cauta",
            ClearConsole = "Goleste Consola",
            CopyConsole = "Copiaza din Consola",
            UnlockFPS = "Deblocați FPS",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    },
    Russian = {
        flag = "rbxassetid://15984948564",
        indicator = "Русский",
        order = 10,
        phrases = {
            FreeLogin = "Бесплатный логин",
            AdlessLogin = "Логин с рекламой ",
            EnterKey = "Ввести ключ ",
            CopyKeyLink = "Скопировать ссылку на ключ",
            ["Key..."] = "Ключ...",
            SubmitCredentials = "Подтвердить реквизиты для входа",
            ["User..."] = "Юзер...",
            ["Password..."] = "Пароль...",
            Editor = "Эдитор",
            Execute = "Запустить",
            Clear = "Очистить",
            Clipboard = "Буфер Обмена",
            CopyScript = "Скопировать скрипт",
            LoadScript = "Загрузить скрипт",
            ["Search..."] = "Искать...",
            Search = "Искать",
            ClearConsole = "Очистить консоль",
            CopyConsole = "Скопировать консоль",
            UnlockFPS = "Разблокировать FPS",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    },
    French = {
        flag = "rbxassetid://15984949489",
        indicator = "Français",
        order = 11,
        phrases = {
            FreeLogin = "Connexion gratuite",
            AdlessLogin = "Connexion AdLess",
            EnterKey = "Confirmer la clé",
            CopyKeyLink = "Copier le lien de la clé",
            ["Key..."] = "Clé...",
            SubmitCredentials = "Se connecter",
            ["User..."] = "Nom d'utilisateur...",
            ["Password..."] = "Mot de passe...",
            Editor = "Éditeur",
            Execute = "Exécuter",
            Clear = "Effacer",
            Clipboard = "Presse-papier",
            CopyScript = "Copier le script",
            LoadScript = "Charger le script",
            ["Search..."] = "Rechercher...",
            Search = "Chercher",
            ClearConsole = "Effacer la console",
            CopyConsole = "Copier la console",
            UnlockFPS = "Déverrouiller les FPS",
            VSync = "Synchronisation verticale",
            FPS = "FPS",
            AntiAFK = "Anti-AFK",
            Full = "Rempli",
            Empty = "Vide",
            BestPing = "Meilleur ping",
            Random = "Au hasard",
            ServerHop = "Changer de serveur",
            RejoinServer = "Rejoindre le serveur"
        }
    },
    Arabic = {
        flag = "rbxassetid://15984948296",
        indicator = "عربي",
        order = 12,
        phrases = {
            FreeLogin = "المجاني الدخول تسجيل",
            AdlessLogin = "إعلانات بلا دخول تسجيل",
            EnterKey = "المفتاح أدخل",
            CopyKeyLink = "المفتاح رابط نسخ",
            ["Key..."] = "المفتاح",
            SubmitCredentials = "الاعتماد بيانات إرسال",
            ["User..."] = "المستخدم",
            ["Password..."] = "المرور كلمة",
            Editor = "المحرر",
            Execute = "تنفيذ",
            Clear = "إخلاء",
            Clipboard = "الحافظة",
            CopyScript = "النصي البرنامج نسخ",
            LoadScript = "النصي البرنامج حمل",
            ["Search..."] = "بحث",
            Search = "بحث",
            ClearConsole = "التحكم وحدة إخلاء",
            CopyConsole = "التحكم وحدة نسخ",
            UnlockFPS = "افتح FPS",
            VSync = "",
            FPS = "",
            AntiAFK = "",
            Full = "",
            Empty = "",
            BestPing = "",
            Random = "",
            ServerHop = "",
            RejoinServer = ""
        }
    }
};

local sortedLanguageDatabase = {};
for i, v in next, languageDatabase do
    sortedLanguageDatabase[v.order] = {
        key = i,
        value = v
    };
end

--[[ Settings ]]--
local uiSettings = {
    key = "",
    userName = "",
    editorInit = "print(\"Aurora-Android >>>\");",
    searchAPI = "ScriptBlox",
    language = "English",
    unlockFps = false,
    vSync = false,
    fps = 60,
    antiAfk = false,
    serverHopMode = "full"
};

if _isfolder("auroraui") == false then
    _makefolder("auroraui");
end
if _isfile("auroraui/settings.json") then
    isFirstTimeExecution = false;
    local succ, res = pcall(jsonDecode, httpService, _readfile("auroraui/settings.json"));
    if succ and type(res) == "table" then
        for i, v in next, uiSettings do
            if res[i] ~= nil and type(res[i]) == type(v) then
                uiSettings[i] = res[i];
            end
        end
    end
    if languageDatabase[uiSettings.language] == nil then
        uiSettings.language = "English";
    end
    if validSearchFunctions[uiSettings.searchAPI] == nil then
        uiSettings.searchAPI = "ScriptBlox";
    end
    if table.find(serverHopModes, uiSettings.serverHopMode) == nil then
        uiSettings.serverHopMode = serverHopModes[1];
    end
end

--[[ Functions ]]--
local function create(className, properties, children)
    local inst = Instance.new(className);
    for i, v in next, properties do
        if i == "LanguageItem" then
            languageItems[inst] = v;
            if languageDatabase[uiSettings.language] and languageDatabase[uiSettings.language].phrases then
                inst[v.property] = languageDatabase[uiSettings.language].phrases[v.identifier] or "";
            end
        elseif i ~= "Parent" then
            inst[i] = v;
        end
    end
    if children then
        for i, v in next, children do
            v.Parent = inst;
        end
    end
    inst.Parent = properties.Parent;
    return inst;
end

local function tween(obj, dur, props, ...)
    local t = tweenService:Create(obj, TweenInfo.new(dur, ...), props);
    t:Play();
    return t;
end

local function addTransparencyHighlights(btn)
    btn.MouseButton1Down:Connect(function()
        tween(btn, 0.18, { BackgroundTransparency = 0 });
    end);
    btn.MouseButton1Up:Connect(function()
        tween(btn, 0.18, { BackgroundTransparency = 1 });
    end);
end

local function addColourHighlights(btn, col)
    local original = btn.BackgroundColor3;
    btn.MouseButton1Down:Connect(function()
        tween(btn, 0.18, { BackgroundColor3 = col });
    end);
    btn.MouseButton1Up:Connect(function()
        tween(btn, 0.18, { BackgroundColor3 = original });
    end);
end

local function removeTrace(str)
    local x = env[str];
    return x;
end

local function changeLanguage(lang)
    local language = languageDatabase[lang] or languageDatabase.English;
    uiSettings.language = language == languageDatabase.English and "English" or lang;
    for i, v in next, languageItems do
        local phrase = language.phrases[v.identifier];
        i[v.property] = (phrase and phrase ~= "") and phrase or languageDatabase.English.phrases[v.identifier];
    end
    task.defer(function()
        for i = 1, #resizeFunctions do
            pcall(resizeFunctions[i]);
        end
    end);
end

local function updateSettings(key, value)
    uiSettings[key] = value;
    if key == "language" then
        changeLanguage(value);
    end
    pcall(_writefile, "auroraui/settings.json", jsonEncode(httpService, uiSettings));
end

--[[ Create UI ]]--
local gui = create("ScreenGui", { 
    DisplayOrder = 11, 
    IgnoreGuiInset = true, 
    Name = "androidCheat", 
    Parent = _gethui(), 
    ResetOnSpawn = false
});

local loadMainUI; -- Forward declaration

local function loadKeyUI(callback)
    local keyFrame = create("Frame", { 
        AnchorPoint = Vector2.new(0.5, 0), 
        BackgroundColor3 = Color3.fromHex("ffffff"), 
        BorderSizePixel = 0, 
        Name = "keyFrame", 
        Parent = gui, 
        Position = UDim2.new(0.5, 0, 0, 25), 
        Size = UDim2.new(1, -110, 0, 94)
    }, {
        create("UIGradient", { 
            Color = ColorSequence.new({ 
                ColorSequenceKeypoint.new(0, Color3.fromHex("1c1c1c")), 
                ColorSequenceKeypoint.new(1, Color3.fromHex("242424"))
            }), 
            Name = "gradient", 
            Rotation = 78
        }),
        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
        create("TextButton", { 
            AutoButtonColor = false, 
            BackgroundColor3 = Color3.fromHex("ffffff"), 
            BackgroundTransparency = 1, 
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), 
            FontSize = Enum.FontSize.Size14, 
            Name = "clickThroughBlocker", 
            Size = UDim2.new(1, 0, 1, 0), 
            Text = "", 
            TextColor3 = Color3.fromHex("000000"), 
            TextSize = 14, 
            ZIndex = 0
        }),
        create("ImageLabel", { 
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundColor3 = Color3.fromHex("ffffff"), 
            BackgroundTransparency = 1, 
            Image = "rbxassetid://12874061329", 
            ImageColor3 = Color3.fromHex("000000"), 
            Name = "blur", 
            Position = UDim2.new(0.5, 0, 0.5, 0), 
            ScaleType = Enum.ScaleType.Slice, 
            Size = UDim2.new(1, 10, 1, 10), 
            SliceCenter = Rect.new(10, 10, 118, 118), 
            ZIndex = 0
        }),
        create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 0.8 }),
        create("UISizeConstraint", { MaxSize = Vector2.new(800, 94), Name = "constraint" }),
        create("Frame", { 
            AnchorPoint = Vector2.new(0.5, 0.5), 
            BackgroundColor3 = Color3.fromHex("ffffff"), 
            BackgroundTransparency = 1, 
            Name = "content", 
            Position = UDim2.new(0.5, 0, 0.5, 0), 
            Size = UDim2.new(1, 0, 1, 0)
        }, {
            create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Name = "list", Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
            create("UIPadding", { Name = "padding", PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8) }),
            create("Frame", { 
                AnchorPoint = Vector2.new(0, 0.5), 
                BackgroundColor3 = Color3.fromHex("ffffff"), 
                BackgroundTransparency = 1, 
                Name = "buttons", 
                Position = UDim2.new(0, 8, 0.5, 0), 
                Size = UDim2.new(0, 124, 1, 0)
            }, {
                create("TextButton", { 
                    AnchorPoint = Vector2.new(0.5, 0), 
                    AutoButtonColor = false, 
                    BackgroundColor3 = Color3.fromHex("181818"), 
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), 
                    FontSize = Enum.FontSize.Size11, 
                    Name = "freemium", 
                    Position = UDim2.new(0.5, 0, 0, 0), 
                    Size = UDim2.new(1, 0, 0, 34), 
                    Text = "", 
                    TextColor3 = Color3.fromHex("ebebeb"), 
                    TextSize = 11
                }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                    create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 }),
                    create("ImageLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://13048298432", Name = "icon", Position = UDim2.new(1, -7, 0.5, 0), Size = UDim2.new(0, 20, 0, 20) }),
                    create("TextLabel", { LanguageItem = { property = "Text", identifier = "FreeLogin" }, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "title", Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.new(1, -43, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                }),
                create("TextButton", { 
                    AnchorPoint = Vector2.new(0.5, 1), 
                    AutoButtonColor = false, 
                    BackgroundColor3 = Color3.fromHex("181818"), 
                    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), 
                    FontSize = Enum.FontSize.Size11, 
                    Name = "premium", 
                    Position = UDim2.new(0.5, 0, 1, 0), 
                    Size = UDim2.new(1, 0, 0, 34), 
                    Text = "", 
                    TextColor3 = Color3.fromHex("ebebeb"), 
                    TextSize = 11,
                    Visible = false
                }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                    create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 }),
                    create("ImageLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://13048298207", Name = "icon", Position = UDim2.new(1, -7, 0.5, 0), Size = UDim2.new(0, 20, 0, 20) }),
                    create("TextLabel", { LanguageItem = { property = "Text", identifier = "AdlessLogin" }, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "title", Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.new(1, -43, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                })
            }),
            create("Frame", { BackgroundColor3 = Color3.fromHex("141414"), BorderSizePixel = 0, Name = "separator", Position = UDim2.new(0, 140, 0, 0), Size = UDim2.new(0, 1, 1, 0) }),
            create("Frame", { BackgroundTransparency = 1, Name = "tabs", Size = UDim2.new(1, -140, 1, 0) }, {
                create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Name = "freemium", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0) }, {
                    create("TextButton", { LanguageItem = { property = "Text", identifier = "EnterKey" }, AnchorPoint = Vector2.new(1, 1), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("181818"), FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "enterKey", Position = UDim2.new(1, 0, 1, 0), Size = UDim2.new(0, 90, 0, 34), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11 }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                        create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 })
                    }),
                    create("TextButton", { LanguageItem = { property = "Text", identifier = "CopyKeyLink" }, AnchorPoint = Vector2.new(0, 1), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("181818"), FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "getKeyLink", Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(0, 105, 0, 34), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11 }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                        create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 })
                    }),
                    create("TextBox", { LanguageItem = { property = "PlaceholderText", identifier = "Key..." }, AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Color3.fromHex("181818"), FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "keyInput", Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(1, 0, 0, 34), Text = "", TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                        create("UIPadding", { Name = "padding", PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
                        create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 })
                    })
                }),
                create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Name = "premium", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0), Visible = false }, {
                    create("TextButton", { LanguageItem = { property = "Text", identifier = "SubmitCredentials" }, AnchorPoint = Vector2.new(1, 1), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("181818"), FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "enterDetails", Position = UDim2.new(1, 0, 1, 0), Size = UDim2.new(0, 130, 0, 34), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11 }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                        create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 })
                    }),
                    create("TextBox", { LanguageItem = { property = "PlaceholderText", identifier = "User..." }, AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = Color3.fromHex("181818"), FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "userInput", Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(1, 0, 0, 34), Text = uiSettings.userName, TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                        create("UIPadding", { Name = "padding", PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
                        create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 })
                    }),
                    create("TextBox", { LanguageItem = { property = "PlaceholderText", identifier = "Password..." }, AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromHex("181818"), FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "passInput", Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, -140, 0, 34), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                        create("UIPadding", { Name = "padding", PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
                        create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 }),
                        create("TextLabel", { BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "dots", Size = UDim2.new(1, 0, 1, 0), Text = "", TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
                    })
                })
            })
        }),
        create("Frame", { AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.fromHex("ffffff"), Name = "languages", Position = UDim2.new(1, 0, 1, 10), Size = UDim2.new(0, 200, 0, 156), Visible = isFirstTimeExecution }, {
            create("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHex("1c1c1c")), ColorSequenceKeypoint.new(1, Color3.fromHex("242424")) }), Name = "gradient", Rotation = 78 }),
            create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
            create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12874061329", ImageColor3 = Color3.fromHex("000000"), Name = "blur", Position = UDim2.new(0.5, 0, 0.5, 0), ScaleType = Enum.ScaleType.Slice, Size = UDim2.new(1, 10, 1, 10), SliceCenter = Rect.new(10, 10, 118, 118), ZIndex = 0 }),
            create("ScrollingFrame", { Active = true, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, BottomImage = "rbxassetid://12651249430", CanvasSize = UDim2.new(), MidImage = "rbxassetid://12651249103", Name = "container", Position = UDim2.new(0.5, 0, 0.5, 0), ScrollBarImageColor3 = Color3.fromHex("141414"), ScrollBarThickness = 4, Size = UDim2.new(1, -16, 1, -16), TopImage = "rbxassetid://12651248921" }, {
                create("UIListLayout", { Name = "list", Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
                create("UIPadding", { Name = "padding", PaddingBottom = UDim.new(0, 1), PaddingLeft = UDim.new(0, 1), PaddingRight = UDim.new(0, 1), PaddingTop = UDim.new(0, 1) })
            })
        }),
        create("TextButton", { AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("ffffff"), BorderColor3 = Color3.fromHex("1b2a35"), FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "toggleLanguages", Position = UDim2.new(1, 10, 0, 0), Size = UDim2.new(0, 34, 0, 34), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
            create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
            create("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHex("1c1c1c")), ColorSequenceKeypoint.new(1, Color3.fromHex("242424")) }), Name = "gradient", Rotation = 78 }),
            create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://13084553682", Name = "icon", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -14, 1, -14) }),
            create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12874061329", ImageColor3 = Color3.fromHex("000000"), Name = "blur", Position = UDim2.new(0.5, 0, 0.5, 0), ScaleType = Enum.ScaleType.Slice, Size = UDim2.new(1, 10, 1, 10), SliceCenter = Rect.new(10, 10, 118, 118), ZIndex = 0 })
        })
    });

    local content = keyFrame.content;
    local tabs = content.tabs;

    local function validLogin()
        Load_CustomFunctions();
        table.clear(resizeFunctions);
        if gui:FindFirstChild("keyFrame") then
            gui.keyFrame:Destroy();
        end
        if callback then callback() end
    end

    do
        local selectedTab = tabs.freemium;
        local buttons = content.buttons;

        local function selectTab(name)
            local btn, tab = buttons:FindFirstChild(name), tabs:FindFirstChild(name);
            if tab and selectedTab ~= tab then
                selectedTab.Visible = false;
                selectedTab = tab;
                tab.Visible = true;
            end
        end

        local buttonList = buttons:GetChildren();
        for i = 1, #buttonList do
            local v = buttonList[i];
            if v:IsA("TextButton") then
                v.MouseButton1Click:Connect(function()
                    selectTab(v.Name);
                end);
            end
        end

        resizeFunctions[#resizeFunctions + 1] = function()
            local size = math.max(buttons.freemium.title.TextBounds.X, buttons.premium.title.TextBounds.X) + 47;
            buttons.Size = UDim2.new(0, size, 1, 0);
            tabs.Size = UDim2.new(1, -(size + 16), 1, 0);
        end;
    end

    do
        local freeFrame = tabs.freemium;
        local getKeyLink = freeFrame.getKeyLink;
        local enterKey = freeFrame.enterKey;

        getKeyLink.MouseButton1Click:Connect(function()
            local url = GetKeyURL()
            if setclipboard then
                setclipboard(url)
            elseif _setclipboard then
                _setclipboard(url)
            end
            Notify("Successfully Copied Key")
        end)

        enterKey.MouseButton1Click:Connect(function()
            local userKey = freeFrame.keyInput.Text
            if CheckKey(userKey) then
                updateSettings("key", userKey)
                validLogin()
            else
                Notify("Invalid Key")
            end
        end)

        resizeFunctions[#resizeFunctions + 1] = function()
            getKeyLink.Size = UDim2.new(0, getKeyLink.TextBounds.X + 30, 0, 34);
            enterKey.Size = UDim2.new(0, enterKey.TextBounds.X + 30, 0, 34);
        end;
    end

    do
        do
            local isOpen = isFirstTimeExecution;
            keyFrame.toggleLanguages.MouseButton1Click:Connect(function()
                isOpen = not isOpen;
                keyFrame.languages.Visible = isOpen;
            end);
        end

        local template = create("TextButton", { 
            AutoButtonColor = false,
            BackgroundColor3 = Color3.fromHex("ffffff"), 
            BackgroundTransparency = 1, 
            Text = "",
            Name = "languageExample", 
            Size = UDim2.new(1, 0, 0, 30)
        }, {
            create("Frame", { BackgroundColor3 = Color3.fromHex("181818"), Name = "flagContainer", Size = UDim2.new(0, 40, 0, 30) }, {
                create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 }),
                create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "", Name = "icon", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -8, 1, -6) })
            }),
            create("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "title", Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(1, -50, 1, 0), Text = "", TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
        });

        local languages = keyFrame.languages;
        local container = languages.container;

        container.list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, container.list.AbsoluteContentSize.Y + 2);			
        end);

        for i, v in next, sortedLanguageDatabase do
            local clone = template:Clone();
            clone.Name = v.key;
            clone.title.Text = v.value.indicator;
            clone.flagContainer.icon.Image = v.value.flag;

            clone.MouseButton1Click:Connect(function()
                updateSettings("language", v.key);
            end);

            clone.Parent = container;
        end
    end

    changeLanguage(uiSettings.language);

    if CheckKey(uiSettings.key) then
        validLogin();
    else
        Notify("Saved Key is no longer valid")
    end
end

loadMainUI = function()
    local toggleMain = create("TextButton", { 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        AutoButtonColor = false, 
        BackgroundColor3 = Color3.fromHex("ffffff"), 
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), 
        FontSize = Enum.FontSize.Size14, 
        Name = "toggleMain", 
        Parent = gui, 
        Position = UDim2.new(1, -25, 0.5, 0), 
        Size = UDim2.new(0, 40, 0, 40), 
        Text = "", 
        TextColor3 = Color3.fromHex("000000"), 
        TextSize = 14, 
        ZIndex = 99
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
        create("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHex("1c1c1c")), ColorSequenceKeypoint.new(1, Color3.fromHex("242424")) }), Name = "gradient", Rotation = 78 }),
        create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://138333994428979", ImageColor3 = Color3.fromRGB(255, 255, 255), Name = "icon", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -6, 1, -6), ZIndex = 99 })
    });

    local main = create("Frame", { 
        AnchorPoint = Vector2.new(0.5, 0.5), 
        BackgroundColor3 = Color3.fromHex("ffffff"), 
        BorderSizePixel = 0, 
        Name = "main", 
        Parent = gui, 
        Position = UDim2.new(0.5, 0, 0.5, 0), 
        Size = UDim2.new(1, -110, 1, -80),
        Visible = false
    }, {
        create("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromHex("1c1c1c")), ColorSequenceKeypoint.new(1, Color3.fromHex("242424")) }), Name = "gradient", Rotation = 78 }),
        create("Frame", { BackgroundColor3 = Color3.fromHex("181818"), BorderSizePixel = 0, Name = "left", Size = UDim2.new(0, 38, 1, 0) }, {
            create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
            create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1, Image = "rbxassetid://138333994428979", ImageColor3 = Color3.fromRGB(255, 255, 255), Name = "icon", Position = UDim2.new(0.5, 0, 0, 8), Size = UDim2.new(0, 28, 0, 28) }),
            create("Frame", { AnchorPoint = Vector2.new(0.5, 1), BackgroundTransparency = 1, Name = "buttons", Position = UDim2.new(0.5, 0, 1, 0), Size = UDim2.new(1, -8, 1, -44) }, {
                create("UIListLayout", { Name = "list", Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
                create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "editor", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 30, 0, 30), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                    create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12874034829", Name = "icon", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -10, 1, -10) }),
                    create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" })
                }),
                create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "games", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 30, 0, 30), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                    create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12874034639", Name = "icon", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -10, 1, -10) }),
                    create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" })
                }),
                create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "console", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 30, 0, 30), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                    create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12874035024", Name = "icon", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -10, 1, -10) }),
                    create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" })
                }),
                create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "settings", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 30, 0, 30), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                    create("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12874034503", Name = "icon", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -10, 1, -10) }),
                    create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" })
                })
            }),
            create("Frame", { AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.fromHex("181818"), BorderSizePixel = 0, Name = "topRightCover", Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 4, 0, 4) }),
            create("Frame", { AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = Color3.fromHex("181818"), BorderSizePixel = 0, Name = "bottomRightCover", Position = UDim2.new(1, 0, 1, 0), Size = UDim2.new(0, 4, 0, 4) })
        }),
        create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
        create("TextButton", { AutoButtonColor = false, BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "clickThroughBlocker", Size = UDim2.new(1, 0, 1, 0), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14, ZIndex = 0 }),
        create("Folder", { Name = "tabs" }, {
            create("Frame", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Name = "editor", Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(1, -38, 1, 0) }, {
                create("UIListLayout", { Name = "list", FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
                create("UIPadding", { Name = "padding", PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8) }),
                create("Frame", { AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromHex("181818"), Name = "main", Position = UDim2.new(0, 8, 0.5, 0), Size = UDim2.new(1, -118, 1, 0) }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                    create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Name = "list", Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
                    create("ScrollingFrame", { Active = true, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, BottomImage = "rbxassetid://12651249430", CanvasSize = UDim2.new(0, 6, 1, 0), MidImage = "rbxassetid://12651249103", Name = "lineNumbers", Position = UDim2.new(0.5, 0, 0.5, 0), ScrollBarImageColor3 = Color3.fromHex("484848"), ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.Y, ScrollingEnabled = false, Size = UDim2.new(0, 6, 1, 0), TopImage = "rbxassetid://12651248921" }, {
                        create("TextLabel", { BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "label", Size = UDim2.new(1, 0, 1, 0), Text = "1", TextColor3 = Color3.fromHex("d2d2d2"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Top })
                    }),
                    create("UIPadding", { Name = "padding", PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8) }),
                    create("Frame", { BackgroundColor3 = Color3.fromHex("b2b2b2"), BorderSizePixel = 0, Name = "separator", Size = UDim2.new(0, 1, 1, 0) }),
                    create("ScrollingFrame", { Active = true, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, BottomImage = "rbxassetid://12651249430", CanvasSize = UDim2.new(1, -15, 1, 0), MidImage = "rbxassetid://12651249103", Name = "container", Position = UDim2.new(0.5, 0, 0.5, 0), ScrollBarImageColor3 = Color3.fromHex("484848"), ScrollBarThickness = 4, Size = UDim2.new(1, -15, 1, 0), TopImage = "rbxassetid://12651248921" }, {
                        create("TextBox", { BackgroundTransparency = 1, ClearTextOnFocus = false, FontFace = Font.new("rbxasset://fonts/families/Ubuntu.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, MultiLine = true, Name = "content", Size = UDim2.new(1, 0, 1, 0), Text = uiSettings.editorInit, TextColor3 = Color3.fromHex("b2b2b2"), TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd, TextWrap = true, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top })
                    }),
                    create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Name = "stroke", Thickness = 1.2 })
                }),
                create("Frame", { BackgroundColor3 = Color3.fromHex("181818"), BorderSizePixel = 0, Name = "right", Size = UDim2.new(0, 110, 1, 0) }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                    create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Name = "buttons", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -8, 1, -8) }, {
                        create("UIListLayout", { Name = "list", Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
                        create("TextLabel", { LanguageItem = { property = "Text", identifier = "Editor" }, BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size12, Name = "boxLabel", Size = UDim2.new(1, 0, 0, 16), TextColor3 = Color3.fromHex("bebebe"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom }),
                        create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "executeBox", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 22), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                            create("ImageLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12778482262", Name = "icon", Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0, 14, 0, 14) }),
                            create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                            create("TextLabel", { LanguageItem = { property = "Text", identifier = "Execute" }, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "title", Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
                        }),
                        create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "clearBox", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 22), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                            create("ImageLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12778483354", Name = "icon", Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0, 14, 0, 14) }),
                            create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                            create("TextLabel", { LanguageItem = { property = "Text", identifier = "Clear" }, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "title", Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
                        }),
                        create("Frame", { BackgroundTransparency = 1, Name = "separator", Size = UDim2.new(1, 0, 0, 1) }, {
                            create("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromHex("363636"), BorderSizePixel = 0, Name = "bar", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -8, 1, 0) }, {
                                create("UIGradient", { Name = "gradient", Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 0.28), NumberSequenceKeypoint.new(0.28, 0), NumberSequenceKeypoint.new(0.72, 0), NumberSequenceKeypoint.new(0.9, 0.28), NumberSequenceKeypoint.new(1, 1) }) })
                            })
                        }),
                        create("TextLabel", { LanguageItem = { property = "Text", identifier = "Clipboard" }, BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size12, Name = "clipboardLabel", Size = UDim2.new(1, 0, 0, 16), TextColor3 = Color3.fromHex("bebebe"), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Bottom }),
                        create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "executeClip", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 22), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                            create("ImageLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12778483177", Name = "icon", Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0, 14, 0, 14) }),
                            create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                            create("TextLabel", { LanguageItem = { property = "Text", identifier = "Execute" }, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "title", Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
                        }),
                        create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "copyClip", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 22), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                            create("ImageLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12778483077", Name = "icon", Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0, 14, 0, 14) }),
                            create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                            create("TextLabel", { LanguageItem = { property = "Text", identifier = "CopyScript" }, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "title", Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
                        }),
                        create("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), AutoButtonColor = false, BackgroundColor3 = Color3.fromHex("303030"), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size14, Name = "loadClip", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 22), Text = "", TextColor3 = Color3.fromHex("000000"), TextSize = 14 }, {
                            create("ImageLabel", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Image = "rbxassetid://12778482868", Name = "icon", Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0, 14, 0, 14) }),
                            create("UICorner", { CornerRadius = UDim.new(0, 4), Name = "corner" }),
                            create("TextLabel", { LanguageItem = { property = "Text", identifier = "LoadScript" }, AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal), FontSize = Enum.FontSize.Size11, Name = "title", Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.new(1, -30, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left })
                        })
                    })
                })
            }),
            create("Frame", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Name = "games", Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(1, -38, 1, 0), Visible = false }, {
                create("UIPadding", { Name = "padding", PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8) }),
                create("TextBox", { AnchorPoint = Vector2.new(0, 0), BackgroundColor3 = Color3.fromHex("181818"), BorderSizePixel = 0, Name = "searchBox", Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -80, 0, 30), Text = "", TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LanguageItem = { property = "PlaceholderText", identifier = "Search..." } }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
                    create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Thickness = 1.2 })
                }),
                create("TextButton", { AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.fromHex("181818"), Name = "searchBtn", Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 72, 0, 30), Text = "", TextColor3 = Color3.fromHex("ebebeb") }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Thickness = 1.2 }),
                    create("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Name = "title", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, LanguageItem = { property = "Text", identifier = "Search" } })
                }),
                create("ScrollingFrame", { Active = true, AnchorPoint = Vector2.new(0.5, 1), BackgroundColor3 = Color3.fromHex("181818"), BorderSizePixel = 0, Name = "results", Position = UDim2.new(0.5, 0, 1, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = Color3.fromHex("484848"), Size = UDim2.new(1, 0, 1, -38) }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    create("UIPadding", { PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6) }),
                    create("UIListLayout", { Name = "list", Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder })
                })
            }),
            create("Frame", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Name = "console", Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(1, -38, 1, 0), Visible = false }, {
                create("UIPadding", { Name = "padding", PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8) }),
                create("ScrollingFrame", { Active = true, AnchorPoint = Vector2.new(0, 0), BackgroundColor3 = Color3.fromHex("181818"), BorderSizePixel = 0, Name = "consoleLog", Position = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = Color3.fromHex("484848"), Size = UDim2.new(1, 0, 1, -34) }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    create("UIPadding", { PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6) }),
                    create("UIListLayout", { Name = "list", Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder })
                }),
                create("TextButton", { AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromHex("181818"), Name = "clearConsole", Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(0.5, -4, 0, 28), Text = "", TextColor3 = Color3.fromHex("ebebeb") }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Thickness = 1.2 }),
                    create("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Name = "title", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, LanguageItem = { property = "Text", identifier = "ClearConsole" } })
                }),
                create("TextButton", { AnchorPoint = Vector2.new(1, 1), BackgroundColor3 = Color3.fromHex("181818"), Name = "copyConsole", Position = UDim2.new(1, 0, 1, 0), Size = UDim2.new(0.5, -4, 0, 28), Text = "", TextColor3 = Color3.fromHex("ebebeb") }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    create("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = Color3.fromHex("141414"), Thickness = 1.2 }),
                    create("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, Name = "title", Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, LanguageItem = { property = "Text", identifier = "CopyConsole" } })
                })
            }),
            create("Frame", { AnchorPoint = Vector2.new(1, 0.5), BackgroundTransparency = 1, Name = "settings", Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(1, -38, 1, 0), Visible = false }, {
                create("UIPadding", { Name = "padding", PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8) }),
                create("ScrollingFrame", { Active = true, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromHex("181818"), BorderSizePixel = 0, Name = "container", Position = UDim2.new(0.5, 0, 0.5, 0), ScrollBarThickness = 4, ScrollBarImageColor3 = Color3.fromHex("484848"), Size = UDim2.new(1, 0, 1, 0) }, {
                    create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                    create("UIPadding", { PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8) }),
                    create("UIListLayout", { Name = "list", Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
                    create("TextButton", { BackgroundColor3 = Color3.fromHex("242424"), Name = "unlockFpsBtn", Size = UDim2.new(1, 0, 0, 32), Text = "" }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        create("TextLabel", { AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -20, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LanguageItem = { property = "Text", identifier = "UnlockFPS" } })
                    }),
                    create("TextButton", { BackgroundColor3 = Color3.fromHex("242424"), Name = "antiAfkBtn", Size = UDim2.new(1, 0, 0, 32), Text = "" }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        create("TextLabel", { AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -20, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LanguageItem = { property = "Text", identifier = "AntiAFK" } })
                    }),
                    create("TextButton", { BackgroundColor3 = Color3.fromHex("242424"), Name = "serverHopBtn", Size = UDim2.new(1, 0, 0, 32), Text = "" }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        create("TextLabel", { AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -20, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LanguageItem = { property = "Text", identifier = "ServerHop" } })
                    }),
                    create("TextButton", { BackgroundColor3 = Color3.fromHex("242424"), Name = "rejoinBtn", Size = UDim2.new(1, 0, 0, 32), Text = "" }, {
                        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
                        create("TextLabel", { AnchorPoint = Vector2.new(0, 0.5), BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -20, 1, 0), TextColor3 = Color3.fromHex("ebebeb"), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, LanguageItem = { property = "Text", identifier = "RejoinServer" } })
                    })
                })
            })
        })
    });

    toggleMain.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible;
    end);
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        toggleMain.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

toggleMain.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleMain.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

    local tabsFolder = main.tabs;
    local leftButtons = main.left.buttons;
    local currentMainTab = tabsFolder.editor;

    local function switchMainTab(tabName)
        local target = tabsFolder:FindFirstChild(tabName);
        if target then
            currentMainTab.Visible = false;
            currentMainTab = target;
            currentMainTab.Visible = true;
            for _, btn in ipairs(leftButtons:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundTransparency = (btn.Name == tabName) and 0 or 1;
                end
            end
        end
    end

    for _, btn in ipairs(leftButtons:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.MouseButton1Click:Connect(function()
                switchMainTab(btn.Name);
            end);
        end
    end

    local editorContent = tabsFolder.editor.main.container.content;
    local lineNumbersLabel = tabsFolder.editor.main.lineNumbers.label;

    local function updateLineNumbers()
        local text = editorContent.Text;
        local lines = 1;
        for _ in string.gmatch(text, "\n") do
            lines = lines + 1;
        end
        lines = math.min(lines, maxLines);
        local str = "";
        for i = 1, lines do
            str = str .. tostring(i) .. "\n";
        end
        lineNumbersLabel.Text = str;
        updateSettings("editorInit", text);
    end

    editorContent:GetPropertyChangedSignal("Text"):Connect(updateLineNumbers);
    updateLineNumbers();

    local edButtons = tabsFolder.editor.right.buttons;

    edButtons.executeBox.MouseButton1Click:Connect(function()
        local code = editorContent.Text;
        if code and #code > 0 then
            local fn, err = execute.execute_script(code);
            if fn then
                task.spawn(fn);
                Notify("Script Executed!");
            else
                warn("Execution Error: " .. tostring(err));
                Notify("Syntax Error! Check Console.");
            end
        end
    end);

    edButtons.clearBox.MouseButton1Click:Connect(function()
        editorContent.Text = "";
    end);

    edButtons.executeClip.MouseButton1Click:Connect(function()
        local clip = _getclipboard();
        if clip and #clip > 0 then
            local fn, err = execute.execute_script(clip);
            if fn then
                task.spawn(fn);
                Notify("Clipboard Executed!");
            else
                warn("Clipboard Execution Error: " .. tostring(err));
            end
        end
    end);

    edButtons.copyClip.MouseButton1Click:Connect(function()
        if _setclipboard then
            _setclipboard(editorContent.Text);
            Notify("Script copied to clipboard!");
        end
    end);

    edButtons.loadClip.MouseButton1Click:Connect(function()
        if _getclipboard then
            editorContent.Text = _getclipboard();
            Notify("Loaded from clipboard!");
        end
    end);

    local consoleLogFrame = tabsFolder.console.consoleLog;
    local function addConsoleLog(msg, msgType)
        local lbl = Instance.new("TextLabel");
        lbl.Size = UDim2.new(1, 0, 0, 18);
        lbl.BackgroundTransparency = 1;
        lbl.Font = Enum.Font.Ubuntu;
        lbl.TextSize = 11;
        lbl.TextXAlignment = Enum.TextXAlignment.Left;
        lbl.Text = "[" .. os.date("%X") .. "] " .. tostring(msg);
        lbl.TextColor3 = (msgType == Enum.MessageType.MessageWarning and Color3.fromRGB(255, 200, 50))
            or (msgType == Enum.MessageType.MessageError and Color3.fromRGB(255, 80, 80))
            or Color3.fromRGB(220, 220, 220);
        lbl.Parent = consoleLogFrame;
        consoleLogFrame.CanvasSize = UDim2.new(0, 0, 0, consoleLogFrame.list.AbsoluteContentSize.Y + 10);
    end

    pcall(function()
        game:GetService("LogService").MessageOut:Connect(addConsoleLog);
    end);

    tabsFolder.console.clearConsole.MouseButton1Click:Connect(function()
        for _, child in ipairs(consoleLogFrame:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy(); end
        end
        consoleLogFrame.CanvasSize = UDim2.new(0, 0, 0, 0);
    end);

    tabsFolder.console.copyConsole.MouseButton1Click:Connect(function()
        local logs = {};
        for _, child in ipairs(consoleLogFrame:GetChildren()) do
            if child:IsA("TextLabel") then table.insert(logs, child.Text); end
        end
        if _setclipboard then
            _setclipboard(table.concat(logs, "\n"));
            Notify("Console copied!");
        end
    end);

    local gamesTab = tabsFolder.games;
    local searchBox = gamesTab.searchBox;
    local searchBtn = gamesTab.searchBtn;
    local resultsFrame = gamesTab.results;

    local function performSearch()
        local query = searchBox.Text;
        if #query == 0 then return end
        for _, child in ipairs(resultsFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy(); end
        end

        task.spawn(function()
            if not _request then return end
            local url = "https://scriptblox.com/api/script/search?q=" .. urlEncode(httpService, query) .. "&page=1";
            local res = _request({ Url = url, Method = "GET" });
            if res and res.Body then
                local succ, data = pcall(jsonDecode, httpService, res.Body);
                if succ and data and data.result and data.result.scripts then
                    for _, scriptData in ipairs(data.result.scripts) do
                        local sCard = Instance.new("Frame");
                        sCard.Size = UDim2.new(1, 0, 0, 40);
                        sCard.BackgroundColor3 = Color3.fromHex("242424");
                        sCard.Parent = resultsFrame;
                        Instance.new("UICorner", sCard).CornerRadius = UDim.new(0, 4);

                        local title = Instance.new("TextLabel");
                        title.Size = UDim2.new(1, -70, 1, 0);
                        title.Position = UDim2.new(0, 8, 0, 0);
                        title.BackgroundTransparency = 1;
                        title.Text = scriptData.title or "Script";
                        title.TextColor3 = Color3.fromHex("ebebeb");
                        title.TextSize = 11;
                        title.TextXAlignment = Enum.TextXAlignment.Left;
                        title.Parent = sCard;

                        local execBtn = Instance.new("TextButton");
                        execBtn.Size = UDim2.new(0, 56, 0, 26);
                        execBtn.Position = UDim2.new(1, -62, 0.5, -13);
                        execBtn.BackgroundColor3 = Color3.fromHex("303030");
                        execBtn.Text = "Execute";
                        execBtn.TextColor3 = Color3.fromHex("ebebeb");
                        execBtn.TextSize = 10;
                        execBtn.Parent = sCard;
                        Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 4);

                        execBtn.MouseButton1Click:Connect(function()
                            local sCode = scriptData.script;
                            if sCode then
                                local fn = execute.execute_script(sCode);
                                if fn then task.spawn(fn); Notify("Executing " .. tostring(scriptData.title)); end
                            end
                        end);
                    end
                    resultsFrame.CanvasSize = UDim2.new(0, 0, 0, resultsFrame.list.AbsoluteContentSize.Y + 10);
                end
            end
        end);
    end

    searchBtn.MouseButton1Click:Connect(performSearch);

    local settingsContainer = tabsFolder.settings.container;
    settingsContainer.unlockFpsBtn.MouseButton1Click:Connect(function()
        uiSettings.unlockFps = not uiSettings.unlockFps;
        if uiSettings.unlockFps and _setfpscap then
            _setfpscap(240);
            Notify("FPS Unlocked to 240");
        elseif _setfpscap then
            _setfpscap(60);
            Notify("FPS Capped to 60");
        end
        updateSettings("unlockFps", uiSettings.unlockFps);
    end);

    settingsContainer.antiAfkBtn.MouseButton1Click:Connect(function()
        uiSettings.antiAfk = not uiSettings.antiAfk;
        if uiSettings.antiAfk then
            pcall(function()
                local VirtualUser = game:GetService("VirtualUser");
                localPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController();
                    VirtualUser:ClickButton2(Vector2.new());
                end);
            end);
            Notify("Anti-AFK Enabled");
        end
        updateSettings("antiAfk", uiSettings.antiAfk);
    end);

    settingsContainer.serverHopBtn.MouseButton1Click:Connect(function()
        Notify("Server Hopping...");
        teleportService:Teleport(game.PlaceId, localPlayer);
    end);

    settingsContainer.rejoinBtn.MouseButton1Click:Connect(function()
        Notify("Rejoining Server...");
        teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer);
    end);

    changeLanguage(uiSettings.language);
end

loadKeyUI(loadMainUI);
