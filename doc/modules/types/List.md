`local PSList = require "PowerSettings.types.List"`

Note: Functions not documented are meant for internal use and not likely to be useful for external scripts.

---

# `format(itemFormat, list)`: string / localizable string
* `itemFormat`: function - The formatter for individual items
* `list`: table - The actual table being wholly formatted

This is the default formatter for list settings.

It returns one of four things, based on the size of the list:

* For an empty list, the string "Empty" is returned. This can be localized.
* For a list of exactly one item, that item is formatted according to `itemFormat`, and surrounded by braces.
* For a list of exactly two items, the string "2 items" is returned. This can be localized.
* For a list of three or more items, a string consisting of the number of items and " items" is returned. This can be localized (and more importantly can be localized differently from "2 items" for languages such as French).