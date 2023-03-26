# Player Info


For now, covers controls.

This includes:

- controls copy themselves
- just_pressed
- just_released
- hold_time
- since_pressed


```LUA
player_info
  [player name]
    ctrl
    just_released
    just_pressed
    hold_time
    since_pressed
```

## player_info.get(player_ref)
Use this to get the player profile. This is the same as player_info.p[player_name] but you don't have to test for `is_player`.

## ctrl
bool or nil

ctrl is just whether the control is pressed.

## just_pressed
bool or nil

Is available for one step after you start pressing a key.

## just_released
bool or nil

Is available for one step after you start letting go of a key.

## since_pressed
number or nil

How long the player has been holding the key.

## since_released
number or nil

How long it has been since the player released the key.
