-- This exists for backwards compatibility! Do not use!
local Controls = require "necro.config.Controls"

local module = {}

module.SearchHint = function() return L.formatKey("Use %s to search!", "searchHint",
        Controls.getFriendlyMiscKeyBind(Controls.Misc.SEARCH))
end

module.SettingIDError = L("Settings defined through PowerSettings must have an id (recommended) or autoRegister.",
    "settingIDError")

return module
