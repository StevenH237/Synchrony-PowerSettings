`local PSBitflag = require "PowerSettings.types.Bitflag"`

Note: Functions not documented are meant for internal use and not likely to be useful for external scripts.

---

# `format(value, presets)`: string / localizable string
* `value`: number - The value being formatted
* `presets`: table - The table of preset values for the bitflag

This is the default formatter for bitflag settings.

If `value` is present in `presets`, then the name of that preset is returned. If the player is using advanced settings, then the current value is also given in hexadecimal.

If `value` is not present in `presets`, then the number of enabled bits is returned as well as the value in hexadecimal. This can be localized with different values for 0, 1, 2, or many.
