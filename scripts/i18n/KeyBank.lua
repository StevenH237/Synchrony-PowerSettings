local Controls = require "necro.config.Controls"

local module = {}

module.SearchHint = function() return L.formatKey("Use %s to search!", "searchHint",
    Controls.getFriendlyMiscKeyBind(Controls.Misc.SEARCH))
end

return module
