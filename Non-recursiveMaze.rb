#!/usr/bin/env ruby

class Wall
    attr_accessor :broken

    def initialize
        @broken = false
    end
end

class Room
    attr_accessor :left, :upper, :isVisited, :rowPos, :colPos, :roomNumber

    def initialize(left, upper)
        @isVisited = false
        @left = left
        @upper = upper
    end
end

class Maze
    attr_accessor :map, :rows, :columns, :unVisitedRooms

    def initialize(rows, columns)
        @rows= rows 
        @columns= columns  
        @map = Array.new(rows) {Array.new(columns){Room.new(Wall.new, Wall.new)}} 
        @unVisitedRooms = Array.new

        count = 0
        @map.each_index {|i|
            @map[i].each_index {|j|
                @map[i][j].rowPos = i
                @map[i][j].colPos = j

                if i == @rows - 1 and j == 0
                    @map[i][j].isVisited = true
                end

                if @map[i][j].isVisited == false
                    @unVisitedRooms[count] = @map[i][j]
                    #sets the room number to the index at which it's being put in the unVisited list
                    @map[i][j].roomNumber = count
                    count = count + 1
                end

            }
        }

        generateMaze(@rows - 1, 0)
    end

    def generateMaze(rw, col)

        stack = Array.new
        currentRoom = @map[rw][col]

        while @unVisitedRooms.empty? == false do
            adjacentRooms = findAdjRooms(currentRoom.rowPos, currentRoom.colPos)

            if adjacentRooms.empty? == false 

                randDirection = Random.rand(adjacentRooms.length)
                wall = adjacentRooms[randDirection]
                stack.push(currentRoom)

                if wall == "upper" 
                    @map[currentRoom.rowPos][currentRoom.colPos].upper.broken = true
                    @map[currentRoom.rowPos - 1][currentRoom.colPos].isVisited = true
                    chosenRoom = @map[currentRoom.rowPos - 1][currentRoom.colPos]
                elsif wall == "lower"
                    @map[currentRoom.rowPos + 1][currentRoom.colPos].upper.broken = true
                    @map[currentRoom.rowPos + 1][currentRoom.colPos].isVisited = true
                    chosenRoom = @map[currentRoom.rowPos + 1][currentRoom.colPos]
                elsif wall == "left"
                    @map[currentRoom.rowPos][currentRoom.colPos].left.broken = true
                    @map[currentRoom.rowPos][currentRoom.colPos - 1].isVisited = true
                    chosenRoom = @map[currentRoom.rowPos][currentRoom.colPos - 1]
                elsif wall == "right"
                    @map[currentRoom.rowPos][currentRoom.colPos + 1].left.broken = true
                    @map[currentRoom.rowPos][currentRoom.colPos + 1].isVisited = true
                    chosenRoom = @map[currentRoom.rowPos][currentRoom.colPos + 1]
                end
                currentRoom = chosenRoom

                #The last room number = to the current room number because i'm going to swap the positions
                #of the current Room and the last room
                @unVisitedRooms[@unVisitedRooms.length - 1].roomNumber = currentRoom.roomNumber
                swap(@unVisitedRooms[currentRoom.roomNumber], @unVisitedRooms[@unVisitedRooms.length - 1])
                
                #I then pop off the last one thus efficiently deleting the last element of the unVisitedRooms Array
                #because we have just visited the current room
                @unVisitedRooms.pop

            elsif stack.empty? == false
                currentRoom = stack.pop
            else
                randomRoom = Random.rand(@unVisitedRooms.length)
                currentRoom = @unVisitedRooms[randomRoom]
                currentRoom.isVisited = true
                @map[currentRoom.rowPos][currentRoom.colPos].isVisited = true

                #swap room numbers of the last one in the array and the new room chosen since the two rooms positions
                #in the unVisitedRooms array are being swapped
                @unVisitedRooms[@unVisitedRooms.length - 1].roomNumber = randomRoom.roomNumber
                swap(@unVisitedRooms[randomRoom], @unVisitedRooms[@unVisitedRooms.length - 1])

                #effectively delete the new random room that was visited efficiently
                @unVisitedRooms.pop
            end
        end
    end

    def swap(a, b)
        tmp = a
        a = b
        b = tmp
    end

    #find whether any of the adjacent rooms have been visited or not
    def findAdjRooms(rw, col)
        adjacentRooms = Array.new

        #if above
        if rw - 1 >= 0 and @map[rw - 1][col].isVisited == false  
            adjacentRooms<<"upper"
        end

        #if below
        if rw + 1 <= (@rows - 1) and @map[rw + 1][col].isVisited == false
            adjacentRooms<<"lower"
        end

        #if to the left
        if col - 1 >= 0 and @map[rw][col - 1].isVisited == false
            adjacentRooms<<"left"
        end

        #if to the right
        if col + 1 <= (@columns - 1) and @map[rw][col + 1].isVisited == false
            adjacentRooms<<"right"
        end
        return adjacentRooms

    end

    def printMaze

        squarePiece = "\u{2588}"
        topAndBottomPiece = "\u{2588}"
        cornerPiece = "\u{2588}"

        @map.each_index { |i|
            pipes = ""
            dashes = ""
            @map[i].each_index { |j|

                if @map[i][j].upper.broken == false
                    dashes = dashes << cornerPiece << topAndBottomPiece
                else
                    dashes = dashes << cornerPiece << " "
                end

                if i == rows - 1 and j == 0 
                    pipes = pipes << "  "
                else
                    if @map[i][j].left.broken == false
                        pipes = pipes << squarePiece  << " "
                    else
                        pipes = pipes << "  "
                    end

                    if j == @columns - 1 
                        dashes = dashes << cornerPiece
                        if j == columns - 1 and i == 0
                            pipes = pipes << " "
                        else
                            pipes = pipes << squarePiece
                        end
                    end
                end
            }
            puts dashes
            puts pipes
        }

        bottomString = (cornerPiece << topAndBottomPiece)*@columns << cornerPiece
        puts bottomString
    end

    def solveMaze

    end
end


maze = Maze.new(ARGV[0].to_i, ARGV[1].to_i)
maze.printMaze
