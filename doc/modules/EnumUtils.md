`local EnumUtils = require "PowerSettings.EnumUtils"`

---

# `getName(table, value)`: string
* `table` - enum: The enum to search
* `value` - any: The value for which to find a name

Attempts to find a name for a given value from a given enum. Searches through `data`, `prettyNames`, and `names` tables in the enum, if they exist.
