Power Settings supports settings in the `shared` and `entitySchema` modes only. For settings that use only those modes, it aims to be fully backwards compatible with the built-in settings API, such that you can simply change `require "necro.config.Settings"` to `require "PowerSettings.PowerSettings"` without breaking anything. If something breaks, please open an issue!

But the main draw of Power Settings is its expanded settings types and options.

# Extra setting options

## Global options
* **`basicName`**: `string` - The name used on an option when basic settings are enabled.

## `number` options
(these also apply to `percent` and `time`)

* **`lowerBound`**: `string` or `function` - The lowest this value should go.
* **`upperBound`**: `string` or `function` - The highest this value should go.

If `lowerBound` or `upperBound` are strings, they are treated as setting ID nodes, and their value is the value of the referenced setting at the time you try to change this one. If they don't start with `mod.`, then they'll be prefixed with `mod.CurrentModName.` (then you can just enter the same as `id`).

If they're functions, they're called with no parameters, and the return value should be numeric.

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

## `label`
A label setting just inserts a dummy item with text on it.

The setting's base type is `action`, but it does nothing.

It takes the following options, in addition to global options:

* `large`: A boolean; if true the text will be displayed at normal size; if false or omitted, the label will be small.

## `list`
List settings let the player create a multi-item list. They come in multiple types and have an interface for editing the list.

All list settings' base types are `table`.

In addition to the global options, a `list` setting has these:

* `limit`: Maximum number of items in the list, defaults to `math.huge`.
* `duplicates`: Whether or not the list allows duplicate values, defaults to `true`.
* `itemFormat`: Format of individual items in the list view.

The types of list are as follows:

* `string`: List entries are strings. The following options are available:
  * `maxLength`: Inclusive upper bound for the length of each string.
* `number`: List entries are numeric. The following options are available:
  * `minimum`: The minimum value of each number.
  * `maximum`: The maximum value of each number.
  * `step`: The value by which the number changes with offsets.
  * `precision`: The value of which each number must be a multiple (offset by the minimum, or 0 if the minimum is nil).