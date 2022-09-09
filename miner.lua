local x, y, x_dist, y_dist, x_return, y_return, direction_return, max_slots, work, torchs, debug, auto_refuel, direction

debug = false
auto_refuel = false 


function mine()
  turtle.digUp()
  turtle.dig()
  turtle.digDown()
end

function mine1()
  turtle.digUp()
  turtle.dig()
end

function unload(slot)
  print("Unloading items...")
  for n = 1, slot do
    turtle.select(n)
    turtle.drop()
  end
  turtle.select(1)
end

function go_forward()
  if turtle.forward() == false then
    repeat
      turtle.attack()
      mine1()
      sleep(0.3)
    until turtle.forward() == true
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

function go_back()
  turn("right")
  turn("right")
  for i = 0, y_return-1 do
    go_forward()
  end
  if (x_return > 0) then
    turn("right")
  else
    turn("left")
  end
  for i = 0, math.abs(x_return) - 1 do
    go_forward()
  end
  while direction ~= direction_return do
    turn("left")
  end
  turtle.suck()
  turtle.suckDown()
end

function go_home()
  x_return = x
  y_return = y
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

function fuel_me(x_local, y_local)
  print ("Waiting for fuel . . .")
  turtle.select(1)
  repeat
    turtle.refuel(64)
    sleep(1)
  until turtle.getFuelLevel() > (y_local * 2) + (math.abs(x_local) * 2) + 10
end

function check_fuel(x_local, y_local)
  if turtle.getFuelLevel() < (y_local * 2) + (math.abs(x_local) * 2) + 10 then
    print("Out of fuel!")
    refueld = false
    if auto_refuel == true then     
      for f = 1, max_slots do
        turtle.select(f)
        if turtle.refuel(2) then
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
  if (check_fuel(x,y)) then
    if debug then print("need fuel") end
    go_home()
    unload(max_slots)
    fuel_me(x,y)
    go_back()
  end
  if ( turtle.getItemCount(max_slots) > 0)  then
    if debug then print("inv full") end
    go_home()
    unload(max_slots)
    if (check_fuel(x_return,y_return)) then 
      fuel_me(x_return,y_return)
    end
    go_back()
  end
  if debug then print("y: "..y.. " x: " .. x .. " dir: " .. direction) end
  mine()
  if (torchs and (y % 7 == 0) and (x % 7 == 0)) then
    turtle.select(16)
    turtle.placeDown()
    turtle.select(1)
  end
  go_forward()
  if (direction == 0) then
    y = y + 1
    if (y == y_dist) then
      if debug == true then print("End of col") end
      if (x == x_dist) then
        if debug == true then print("done") end
        mine()
        go_home()
        unload(16)
        work = false
      else
        if (x_dist > 0) then
          turn("right")
          mine()
          go_forward()
          turn("right")
          x = x + 1
        else
          turn("left")
          mine()
          go_forward()
          turn("left")
          x = x - 1
        end
      end
    end
  elseif (direction == 2) then
    y = y - 1
    if (y == 0) then
      if debug == true then print("End of col") end
      if (x == x_dist) then
        if debug == true then print("done") end
        mine()
        go_home()
        unload(16)
        work = false
      else
        if (x_dist > 0) then
          turn("left")
          mine()
          go_forward()
          turn("left")
          x = x + 1
        else
          turn("right")
          mine()
          go_forward()
          turn("right")
          x = x - 1
        end
      end
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
print("Would you like me to use torches? (yes/no)")
torchs = read()
if torchs == "yes" then
  print("Place torhes in slot 16")
  repeat
    sleep(1)
  until turtle.getItemCount(16) > 0
  torchs = true
  max_slots = 15
else
  torchs = false
  max_slots = 16
end

y_dist = y_dist - 1
x_dist = tonumber(x_dist)
if x_dist > 0 then
  x_dist = x_dist - 1
else
  x_dist = x_dist + 1
end
x=0
y=0
direction = 0
work = true

if debug == true then
  print("")
  print("I'm mining " .. y_dist .. " blocks deep!")
  print("I'm mining " .. x_dist .. " Row(s) over!")
  print("Fuel level: " .. turtle.getFuelLevel())
  if torchs == true then
    print("I will use torches!")
  else
    print("I will not use torches!")
  end
end

-- Start Program
repeat
  cycle()
until work == false
print("All Done :D")