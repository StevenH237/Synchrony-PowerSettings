`local PSEntity = require "PowerSettings.types.Entity"`

Note: Functions not documented are meant for internal use and not likely to be useful for external scripts.

---

# `format(value)`: string
* `value`: `string` - The entity name being formatted.

This is the default formatter for entity settings.

There are four possible things it can return. In order of precedence (all examples use the `Food1` entity):

1. If the entity exists and has a `friendlyName` component and the player is using advanced settings view, then the friendly name will be shown with the technical name in parentheses. For example: "Apple (Food1)"
2. If the entity exists has a `friendlyName` component but the player is not using advanced settings view, only the friendly name will be shown. For example: "Apple"
3. If the entity exists, but does not have a `friendlyName` component, only the technical name will be shown. For example: "Food1"
4. If the entity does not exist, the technical name will be shown in a "no such entity" wrapper. For example: "(No such entity: Food1)"

---

# `getFilteredEntities(filter)`: table
* `filter`: `function(table):bool` or `table` or `string` or `nil` - The filter that should be used to reduce the returned entities.

This function returns a filtered entity list. How the filter works and what values are returned depends on what type of filter is used:

* Function filter: The function should take a single parameter, which is the entity prototype. The return value of `getFilteredEntities()` includes all entities for which the function returns `true`.
* Table filter: The table should consist of component names. The return value of `getFilteredEntities()` is the set of entities that contain all specified components.
* String filter: The string is a component name. The return value of `getFilteredEntities()` is all entities that contain this component. *Note: `getFilteredEntities("friendlyName")` is equivalent to `getFilteredEntities({"friendlyName"})`.*
* No filter: All entities are returned.

In any case, the return table consists only of entity names and not full prototypes.