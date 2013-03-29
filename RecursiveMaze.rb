#!/usr/bin/env ruby

class Wall
    attr_accessor :broken

    def initialize
        @broken = false
    end
end

class Room
    attr_accessor :left, :upper, :isVisited

    def initialize(left, upper)
        @isVisited = false
        @left = left
        @upper = upper
    end
end

class Maze
    attr_accessor :map, :rows, :columns

    def initialize(rows, columns)
        @rows= rows 
        @columns= columns  
        @map = Array.new(rows) {Array.new(columns){Room.new(Wall.new, Wall.new)}} 
        lookForWallToBreak(@rows - 1, 0)
    end

    def lookForWallToBreak(rw, col)

        adjacentRooms = findAdjRooms(rw, col)
        currentRowColumn = Array.new
        @map[rw][col].isVisited = true

        while adjacentRooms.empty? == false do
            randDirection = Random.rand(adjacentRooms.length)
            wall = adjacentRooms[randDirection]

            if wall == "upper" 
                @map[rw][col].upper.broken = true
                lookForWallToBreak(rw - 1, col)
            elsif wall == "lower"
                @map[rw + 1][col].upper.broken = true
                lookForWallToBreak(rw + 1, col)
            elsif wall == "left"
                @map[rw][col].left.broken = true
                lookForWallToBreak(rw, col - 1)
            elsif wall == "right"
                @map[rw][col + 1].left.broken = true
                lookForWallToBreak(rw, col + 1)
            end

            adjacentRooms = findAdjRooms(rw, col)
        end

        return
    end

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
                        pipes = pipes << squarePiece <<  " "
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
end


maze = Maze.new(ARGV[0].to_i, ARGV[1].to_i)
maze.printMaze()
