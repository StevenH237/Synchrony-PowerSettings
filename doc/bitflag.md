Bitflag settings are numeric settings that give players a defined set of presets but also, when they're using advanced settings, allow them to set the individual bits of the setting.

# The basic setup
The parameters you're most likely to be concerned with in a bitflag setting are `flags` and `presets`.

The `flags` parameter should be a bitmask enum. This contains the individual flags that can be turned on and off. For example, if you want to make an item-ban-type setting, the value here would be `ItemBan.Flag`. (`ItemBan` being [this Synchrony module](https://vortexbuffer.com/synchrony/docs/modules/necro.game.item.ItemBan/))

The `presets` parameter should be a regular sequence enum. This contains the most common values you think your players will want. Following our previous example, the value here would be `ItemBan.Type`. *Players not using advanced settings will only be able to select presets unless they use Shift+F9!*

It's recommended that you fill both parameters, but you can deal with just one. If you only specify `flags`, `presets` will be copied from it, such that each single flag is a preset. If you only specify `presets`, then `flags` will be built from each individual bit that's enabled in at least one preset (where names will only be copied over for presets that are powers of two, the rest simply becoming "Unnamed bit"s). If you specify neither, the setting is invalid.

# Some more power
There is a `names` parameter you can set to a table where numeric keys are the combinations of flags you explicitly want to name, and the values are the names you want to use for those flags. This allows you to name more settings without making them presets and without using a custom formatter.

Additionally, you can set `editAsFlags` to true to allow all players to use the per-bit configuration menu even when not using advanced settings (by pressing the confirmation button, usually enter).