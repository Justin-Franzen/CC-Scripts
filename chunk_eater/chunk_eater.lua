
function updateFile(x, y, z)
    fileTemplate = fs.open("disk/mine.lua", "r")
    file = fs.open("disk/startup.lua", "w")

    file.write(fileTemplate.readAll())
    fileTemplate.close()

    file.write("\n\n")
    file.write("offsetx = "..x.."\n")
    file.write("offsety = "..y.."\n")
    file.write("offsetz = "..z.."\n")
    file.write("y_dist = 4 - 1\n")
    file.write("x_dist = 4 - 1\n")
    file.write("z_dist = 4 * -1\n")
    file.write("main()")

    file.close()
end

function removeTurtle()
  tut = peripheral.wrap("front")
  print(tut.getID())
  turtle.select(4)
  turtle.suck()
  turtle.select(1)
  turtle.dig()
  turtle.dropDown()
end

function placeTurtle()
  turtle.select(1)
  turtle.up()
  updateFile(0,-1,2)
  turtle.down()
  turtle.suckDown()
  turtle.place()
  sleep(.5)
  tut = peripheral.wrap("front")
  print(tut.getID())
  tut.turnOn()
  turtle.select(4)
  turtle.drop()
end

placeTurtle()

while turtle.detect() == false do
    sleep(1)
end
removeTurtle()