br_sounds = {}
br_sounds.master = 1


function br_sounds.default()
    return {
      footstep =  {name = "br_step_carpet", gain = (br_sounds.master or 1) * 0.15, pitch = 1},
      dig =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      dug =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      place =     {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},}
end
function br_sounds.carpet()
    return {
      footstep =  {name = "br_step_carpet", gain = (br_sounds.master or 1) * 0.15, pitch = 1},
      dig =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      dug =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      place =     {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},}
end
function br_sounds.concrete()
    return {
      footstep =  {name = "br_concrete_step", gain = (br_sounds.master or 1) * 1, pitch = 1},
      dig =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      dug =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      place =     {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},}
end
function br_sounds.steel()
    return {
      footstep =  {name = "br_concrete_step", gain = (br_sounds.master or 1) * 1, pitch = 1},
      dig =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      dug =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      place =     {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},}
end
function br_sounds.tile()
    return {
      footstep =  {name = "br_tile_step", gain = (br_sounds.master or 1) * 1, pitch = 1},
      dig =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      dug =       {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},
      place =     {name = "br_step_carpet", gain = (br_sounds.master or 1) * 1},}
end
function br_sounds.water()
  return {
    footstep =  {name = "br_water_step", gain = (br_sounds.master or 1) * 1, pitch = 1},
    dig =       {name = "br_water_step", gain = (br_sounds.master or 1) * 1},
    dug =       {name = "br_water_step", gain = (br_sounds.master or 1) * 1},
    place =     {name = "br_water_step", gain = (br_sounds.master or 1) * 1},}
end
