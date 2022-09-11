local arg = { ... }
local x, y, z, x_dist, y_dist, z_dist, x_return, y_return, z_return, direction_return, max_slots, work, torchs, debug, auto_refuel, direction

debug = true
auto_refuel = false 
max_slots = 12


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
        turtle.attack()
        mine1()
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
        turtle.attackDown()
        turtle.digDown()
        sleep(0.3)
      until turtle.down() == true
    end
    z = z - 1
  end
  if(dir == "up") then
    if turtle.up() == false then
      repeat
        turtle.attackUp()
        turtle.mineUp()
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
  if (x > 0) then
    if (direction == 0) then
      turn("left")
    else
      turn("right")
    end
  else
    if (direction == 0) then
      turn("right")
    else
      turn("left")
    end
  end
  for i = 0, math.abs(x)-1 do
    go_forward()
  end
  if (direction == 3) then
    turn("left")
  elseif (direction == 1) then
    turn("right")
  end
  for i = 0, y-1 do
    go_forward()
  end
end

function fuel_me()
  if debug then print(turtle.getFuelLevel()) end
  turtle.suckUp(2)
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
    unload(max_slots)
    fuel_me()
    break_chest()
  elseif ( turtle.getItemCount(max_slots) > 0)  then
    if debug then print("inv full") end
    place_chest()
    unload(max_slots)
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
        --mineUpDown()
        --go_home()
        work = false
      else
      end
      mineUpDown()
      new_layer()  
      if debug then print("oddRow: "..tostring(oddRow)) end
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

--Get info
shell.run("clear")
print("How far you you like me to go?")
y_dist = read()
print("How many rows would you like me to mine?")
x_dist = read()
print("How far down?")
z_dist = read()
y_dist = y_dist - 1
x_dist = tonumber(x_dist)
z_dist = (z_dist-1) * -1
if x_dist > 0 then
  x_dist = x_dist - 1
else
  x_dist = x_dist + 1
end
x=0
y=0
z=0
direction = 0
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
print("All Done :D")
