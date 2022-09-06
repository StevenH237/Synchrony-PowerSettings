`local PowerSettings = require "PowerSettings.PowerSettings"`

Note: Some of this is too complex to document here. See [settings.md](../settings.md) or [`necro.config.Settings`](https://vortexbuffer.com/synchrony/docs/modules/necro.config.Settings/) for more information.

Note that this module only has `shared` and `entitySchema` settings, not `user` or `overridable` or any of the enums from Settings.

---

# `autoRegister()`: nil
Once used, all further setting definitions from the calling mod have an `autoRegister = true` injected.

---

# `get(id, layers)`: any
* `id`: string - The string of the setting node to get. Make sure to include the `mod.ModName.` prefix!
* `layers`: table, string, or nil - The setting layers to check. If `nil`, gets the effective value. If a string, is converted to a table containing only that value.

Returns the value of a setting node by its ID. However, it also checks for `ignoredIf` conditions and returns the default (or otherwise specified) value if those conditions are met. Otherwise, if layers are specified, the first non-nil is returned.

---

# `getRaw(id, layers)`: any
* `id`: string - The string of the setting node to get. Make sure to include the `mod.ModName.` prefix!
* `layers`: table, string, or nil - The setting layers to check. If `nil`, gets the effective value. If a string, is converted to a table containing only that value.

Returns the value of a setting node by its ID. Ignore-conditions are themselves ignored, such that the value is always pulled from SettingsStorage. If layers are specified, the first non-nil is returned.