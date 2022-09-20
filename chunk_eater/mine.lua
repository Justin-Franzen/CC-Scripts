-- Usage mine3d (how far) (how many rows to the left) (how deep)
-- supply enderchest in slot 16
-- Enderchest should resupply(regulate) fuel in slot 1

local arg = { ... }
local x, y, z, x_dist, y_dist, z_dist, offsetx, offsety, offsetz, max_slots, work, debug, auto_refuel, direction, breakAttackItems

debug = false
auto_refuel = false
max_slots = 12
breakAttackItems= true


function mine()
  turtle.digUp()
  turtle.dig()
  turtle.digDown()
end

function mine1()
  turtle.digUp()
  turtle.dig()
end

function mineUpDown()
  turtle.digUp()
  turtle.digDown()
end

function unload(slot)
  print("Unloading items...")
  for n = 1, slot do
    turtle.select(n)
    if  turtle.getItemCount()> 0 then
      repeat
      until turtle.dropUp()
    end
  end
  turtle.select(1)
end

function place_chest()
  turtle.select(16)
  repeat
    turtle.attackUp()
    turtle.digUp()
  until turtle.placeUp()
end

function break_chest()
  turtle.select(16)
  turtle.digUp()
  turtle.select(1)
end

function move(dir)
  if(dir == "forward") then
    if turtle.forward() == false then
      repeat
        if breakAttackItems then
          turtle.attack()
          mine1()
        end
        sleep(0.3)
      until turtle.forward() == true
    end
    if (direction == 0) then
      y = y + 1
    elseif(direction == 1) then
      x = x + 1
    elseif(direction == 2) then
      y = y - 1
    elseif(direction == 3) then
      x = x - 1
    end
  end
  if(dir == "down") then
    if turtle.down() == false then
      repeat
        if breakAttackItems then
          turtle.attackDown()
          turtle.digDown()
        end
        sleep(0.3)
      until turtle.down() == true
    end
    z = z - 1
  end
  if(dir == "up") then
    if turtle.up() == false then
      repeat
        if breakAttackItems then
          turtle.attackUp()
          turtle.mineUp()
        end
        sleep(0.3)
      until turtle.up() == true
    end
    z = z + 1
  end
end

function turn(dir)
  if (dir == "left") then
    direction = direction - 1
    if (direction == -1) then
      direction = 3
    end
    turtle.turnLeft()
  elseif (dir == "right") then
    direction = direction + 1
    if (direction == 4) then
      direction = 0
    end
    turtle.turnRight()
  end
end

function new_layer()
  local go_down
  if z_dist - z > -3 then
    go_down = z_dist - z
  else
    go_down = -3
  end
  if debug then print("go_down: "..tostring(go_down)) end
  while go_down < 0
  do
    if debug then print("y: "..y.. " x: " .. x .. " z: "  .. z .. " dir: " .. direction) end
    move("down")
    go_down = go_down + 1
  end
  turn("left")
  turn("left")
  oddRow = not oddRow
end

function go_home()
  x_return = x
  y_return = y
  z_return = z
  direction_return = direction
  while direction ~= 3 do
    turn("left")
  end
  for i = 0, math.abs(x)-1 do
    move("forward")
  end

  while direction ~= 2 do
    turn("left")
  end
  for i = 0, math.abs(y)-1 do
    move("forward")
  end
  for i = 0, math.abs(z)-1 do
    move("up")
  end
end

function fuel_me()
  if debug then print(turtle.getFuelLevel()) end
  turtle.suckUp(8)
  turtle.refuel(64)
  if debug then print(turtle.getFuelLevel()) end
end

function check_fuel()
  if turtle.getFuelLevel() < 200 then
    print("Out of fuel!")
    if auto_refuel == true then
      for f = 1, max_slots do
        turtle.select(f)
        if turtle.refuel(8) then
          turtle.select(1)
          return false
        end
      end
    end
    return true
  else
    return false
  end
end

function cycle()
  if (check_fuel()) then
    if debug then print("need fuel") end
    place_chest()
    unload(max_slots+2)
    fuel_me()
    break_chest()
  elseif ( turtle.getItemCount(max_slots) > 0)  then
    if debug then print("inv full") end
    place_chest()
    unload(max_slots+2)
    break_chest()
  end
  if debug then print("y: "..y.. " x: " .. x .. " z: "  .. z .. " dir: " .. direction) end
  mine()
  move("forward")
  if ((y == y_dist and direction == 0) or (y == 0 and direction == 2)) then
    if debug == true then print("End of col") end
    if ((x == x_dist and oddRow)or (x == 0 and not oddRow)) then
      if debug == true then print("End of row") end
      if(z == z_dist) then
        if debug == true then print("done") end
        mineUpDown()
        place_chest()
        unload(max_slots+2)
        break_chest()
        go_home()
        work = false
      else
        mineUpDown()
        new_layer()
        if debug then print("oddRow: "..tostring(oddRow)) end
      end
    else
      local turn_dir
      if ((direction == 0 and oddRow) or (direction == 2 and not oddRow)) then
        turn_dir = "right"
      else
        turn_dir = "left"
      end
        turn(turn_dir)
        mine()
        move("forward")
        if debug then print("y: "..y.. " x: " .. x .. " z: "  .. z .. " dir: " .. direction) end
        turn(turn_dir)
    end

  end
  if debug then sleep(2.0) end
end

function querry()
  shell.run("clear")

  x=0
  y=0
  z=0
  oddRow = true
  work = true
  turtle.select(1)
  if debug == true then
    print("")
    print("I'm mining " .. y_dist .. " blocks deep!")
    print("I'm mining " .. x_dist .. " Row(s) over!")
    print("Fuel level: " .. turtle.getFuelLevel())
  end

  -- Start Program
  repeat
    cycle()
  until work == false
  print("Finished mining")
end


function goToStart()
  direction = 0
  x = 0
  y = 0
  z = 0
  for i = 0, math.abs(offsetz) do
    move("down")
  end
  if offsety < 0 then
   turn("left")
   turn("left")
  end
  for i = 0, math.abs(offsety) do
    if (offsety == 0) then break end
    move("forward")
  end
  while direction ~= 1 do
    turn("left")
  end
  for i = 0, math.abs(offsetx) do
    if (offsety == 0) then break end
    move("forward")
  end
  while direction ~= 0 do
    turn("left")
  end
  for i = 0, math.abs(offsetz) do
    if (offsety == 0) then break end
    move("down")
  end

  move("down")
  move("down")
end

function returnToMothership()
  move("up")
  move("up")
  breakAttackItems = false
  if offsety < 0 then
   turn("left")
   turn("left")
  end
  for i = 0, math.abs(offsety) do
    if (offsety == 0) then break end
    move("forward")
  end
  while direction ~= 1 do
    turn("left")
  end
  for i = 0, math.abs(offsetx) do
     if (offsety == 0) then break end
     move("forward")
  end
  for i = 0, math.abs(offsetz) do
    move("up")
  end
end

function main()
  turtle.select(1)
  while turtle.getItemCount(1) < 0 do
    sleep(0.3)
  end
  turtle.transferTo(16)
  goToStart()
  querry()
  returnToMothership()
end