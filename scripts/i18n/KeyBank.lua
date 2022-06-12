local Controls = require "necro.config.Controls"

local module = {}

module.SearchHint = string.format(L("Use %s to search!", "searchHint"),
  Controls.getFriendlyMiscKeyBind(Controls.Misc.SEARCH))

return module
