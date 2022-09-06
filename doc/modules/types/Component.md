`local PSComponent = require "PowerSettings.types.Component"`

Note: Functions not documented are meant for internal use and not likely to be useful for external scripts.

---

# `format(value)`: string
* `value`: `string` - The value to format.

This is the default formatter for component settings.

If the currently selected component exists, its name is returned unchanged. Otherwise, it is returned as "(No such component: {name})", which can be localized.

---

# `getFilteredComponents(filter)`: table
* `filter`: `function(table):bool` or `table` or `string` or `nil` - The filter that should be used to reduce the returned components.

This function returns a filtered component list. How the filter works and what values are returned depends on what type of filter is used:

* Function filter: The function should take a single parameter, which is the component definition as a table. The return value of `getFilteredComponents()` includes all components for which the function returns `true`.
* Table filter: The table should consist of component names. The return value of `getFilteredComponents()` is the subset of names which actually exist as components.
* String filter: The string is a prefix. The return value of `getFilteredComponents()` is all components that start with this prefix.
* No filter: All components are returned.

In any case, the return table consists only of component names and not definitions.