Power Settings supports settings in the `shared` and `entitySchema` modes only. For settings that use only those modes, it aims to be fully backwards compatible with the built-in settings API, such that you can simply change `require "necro.config.Settings"` to `require "PowerSettings.PowerSettings"` without breaking anything. If something breaks, please open an issue!

But the main draw of Power Settings is its expanded settings types and options.

Power Settings has the following additional global setting options:

* `basicName` (string): A name to be displayed when basic settings are enabled.

And the following additional settings types:

* [`bitflag`](#bitflag): A bitflag setting lets the player set the individual bits of an integer when using advanced options.
* [`entity`](#entity): An entity setting lets the player select a single entity from a limited subset.

# Notes
Some settings are labeled **requires global**. These settings only work when `PowerSettings.setGlobal` has been used.

# `bitflag`
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

# `entity`
The entity setting lets the player select an entity from a limited subset of entities.

The setting's base type is `text`. The text returned is the selected entity's `name`.

It takes the following options, in addition to global options:

* `filter`: Has different meanings depending on the type of its value:
  * `nil`: The list of allowed entities is unfiltered; any entity type may be selected.
  * `string`: The list of allowed entities is filtered only to entities containing this component.
  * `table`: The list of allowed entities is filtered only to entities containing all of these components.
  * `function(table):bool`: All entities are passed into this function; the entities for which the function returns true are the entities that may be selected.