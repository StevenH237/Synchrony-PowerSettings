Power Settings supports settings in the `shared` and `entitySchema` modes only. For settings that use only those modes, it aims to be fully backwards compatible with the built-in settings API, such that you can simply change `require "necro.config.Settings"` to `require "PowerSettings.PowerSettings"` without breaking anything. If something breaks, please open an issue!

But the main draw of Power Settings is its expanded settings types and options.

# Extra setting options

## Global options
* **`basicName`**: `string` - The name used on an option when basic settings are enabled.
* **`ignoredIf`**: `bool` or `function` - The condition under which a setting should be ignored (`PowerSettings.get()` returns default value). If not specified, the setting is never ignored.
* **`ignoredIsNil`**: `bool` - If true, returns `nil` instead of the default value when the setting is ignored.
* **`ignoredValue`**: `any` - If not nil, this value is returned instead of the default value when the setting is ignored.
* **`refreshOnChange`**: `bool` - If true, changing the value causes a `Menu.update()`. *This doesn't seem to be working in recent Synchrony versions.*
* **`visibleIf`**: `function` - Whether or not the setting should be visible. If not specified, defaults to showing.

## `number` options
(these also apply to `percent` and `time`)

* **`lowerBound`**: `string` or `function` - The lowest this value should go.
* **`upperBound`**: `string` or `function` - The highest this value should go.

If `lowerBound` or `upperBound` are strings, they are treated as setting ID nodes, and their value is the value of the referenced setting at the time you try to change this one. If they don't start with `mod.`, then they'll be prefixed with `mod.CurrentModName.` (then you can just enter the same as `id`).

If they're functions, they're called with no parameters, and the return value should be numeric.

**Note:** These bounds are not enforced in the Shift+F9 editor!

# Extra setting types

## `bitflag`
The bitflag setting lets the player set the individual bits of an integer when using advanced options.

The setting's base type is `number`. 

It takes the following options, in addition to global options:

* `flags`¹: This should be a bitmask enum, or a table with values that are powers of 2 (optionally with a `names` or `prettyNames` sub-table).
* `presets`¹: This should be either an enum or a table with numeric values (optionally with a `names` or `prettyNames` sub-table).
* ~~`editAsString`~~: Bitflags *cannot* be edited as string, and this option is forcibly set to `false`.
* ~~`maximum`~~: Bitflags' maximum values are the highest value you can create with the provided flags or presets.
* ~~`minimum`~~: Bitflags' minimum values are the lowest value you can create with the provided flags or presets (either 0 or -2147483648).
* ~~`step`~~: Bitflags' step values should always be 1. However, not all values are accessible with the arrow keys.

¹ Either `flags` or `presets` is required.

## `component`
The component setting lets the player select a component from a limited subset of components.

The setting's base type is `text`. The text returned is the selected component's `name`.

It takes the following options, in addition to global options:

* `filter`: Has different meanings depending on the type of its value:
  * `nil`: The list of allowed components is unfiltered; any component may be selected.
  * `string`: The list of allowed components is filtered to those that start with this string.
  * `table`: The list of allowed components is filtered only to specified components that actually exist.
  * `function(table):bool`: All components are passed into this function one at a time; the components for which the function returns true are the components that may be selected.

## `entity`
The entity setting lets the player select an entity from a limited subset of entities.

The setting's base type is `text`. The text returned is the selected entity's `name`.

It takes the following options, in addition to global options:

* `filter`: Has different meanings depending on the type of its value:
  * `nil`: The list of allowed entities is unfiltered; any entity type may be selected.
  * `string`: The list of allowed entities is filtered only to entities containing this component.
  * `table`: The list of allowed entities is filtered only to entities containing all of these components.
  * `function(table):bool`: All entities are passed into this function one at a time; the entities for which the function returns true are the entities that may be selected.

## `header`
A header setting is a different color, and the player can use left/right (or their controller equivalents) to jump between multiple headers in the same screen.

The setting's base type is `action`, but it does nothing.

It *DOES NOT* takes the following options, despite `action` allowing them:

* ~~`action`~~: This is forcibly set to `function() end`, so it can be selected but not do anything when activated.
* ~~`leftAction`~~: This is automatically set to jump to the previous header.
* ~~`rightAction`~~: This is automatically set to jump to the next header.

Additionally, the name will automatically be bounded by `\3*cc5` and `\3r`, giving it a bright yellow color. You can override this behavior by using your own color code.

## `label`
A label setting just inserts a dummy item with text on it.

The setting's base type is `action`, but it does nothing.

It takes the following options, in addition to global options:

* `large`: A boolean; if true the text will be displayed at normal size; if false or omitted, the label will be small.
* ~~`action`~~: This is forcibly set to `function() end` so that it doesn't do anything.

The text of a label is simply its `name`.

## `list`
List settings let the player create a multi-item list. They come in multiple types and have an interface for editing the list.

All list settings' base types are `table`.

In addition to the global options, a `list` setting has these:

* `limit`: Maximum number of items in the list, defaults to `math.huge`.
* `duplicates`: Whether or not the list allows duplicate values, defaults to `true`.
* `itemFormat`: Format of individual items in the list view.
* `itemDefault`: The default for newly created items.

The types of list are as follows:

* `component`: List entries are names of components. Use the `filter` arg the same way as in a [component setting](#component).
* `entity`: List entries are names of entities. Use the `filter` arg the same way as in an [entity setting](#entity).
* `enum`: List entries are enums. Use the `enum` arg to specify which enum to use.
* `number`: List entries are numeric. The following options are available:
  * `minimum`: The minimum value of each number.
  * `maximum`: The maximum value of each number.
  * `step`: The value by which the number changes with offsets.
  * `precision`: The value of which each number must be a multiple (offset by the minimum, or 0 if the minimum is nil).
* `string`: List entries are strings. The following options are available:
  * `maxLength`: Inclusive upper bound for the length of each string.

## `multiLabel`
A multi-label setting lets you define multiple [labels](#label) in a row using a single setting. This is good for long labels that might need translating, for example.

Note that a multi-label uses non-integer order keys to maintain a consistent order without interspersing themselves between the other settings defined in the group. For example, a five-line multi-label at order=2 will use orders 2, 2.2, 2.4, 2.6, and 2.8.

You can define the text of a multi-label in two ways:
* Use a `texts` table with individual texts (not recommended for translatable multi-labels).
* Use a `name`, which will be split at line breaks.

Other than that, this setting type takes the same args as a [label setting](#label), with the following exception:
* ~~`autoRegister`~~: This is forcibly true for multi-labels since one setting definition becomes many actual nodes. See [auto-registration](#auto-registration) for more information on what this is.

# Auto-registration
A relatively new feature of Synchrony is setting auto-registration. Using it (by putting `autoRegister = true` in your setting definition) allows you to skip defining global variables for the settings, instead accessing their values through `SettingsStorage` calls.

If you're not sure what auto-registration is, that's fine - you don't need to use it. The one exception to that is multi-labels - these *must* be auto-registered because your single setting definition is actually turned into multiple definitions internally. However, you still don't need to worry about those too much because multi-labels don't produce usable values.

If, however, you wish to auto-register all of your settings, well I've got some good news for you! PowerSettings includes a function to automatically auto-register all settings you define through it. Simply use `PowerSettings.autoRegister()` before any of your setting calls, and an `autoRegister = true` will be automatically injected into every setting.

Need it on all but one or two? You can override this later on individual settings by adding an `autoRegister = false` to those specific settings.