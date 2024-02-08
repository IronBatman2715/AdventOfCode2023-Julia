module Day02
"""
Load inputs and solve the [Day 2](https://adventofcode.com/2023/day/2) puzzle.
"""
function run()::Tuple{Int64,Int64}
    inputs = readlines(joinpath(@__DIR__, "../data/day02.txt"))
    return solve(inputs), solve(inputs, true)
end

MAX_RED_CUBES = 12
MAX_GREEN_CUBES = 13
MAX_BLUE_CUBES = 14

function solve(list::Array{String,1}, part_2=false)::Int64
    if part_2
        return 1
    end

    sum = 0
    for line in list
        game = parse_game(line)

        add = true
        for set in game.sets
            if set.red > MAX_RED_CUBES || set.green > MAX_GREEN_CUBES || set.blue > MAX_BLUE_CUBES
                # Impossible state, exclude
                add = false
            end
        end

        if add
            sum += game.id
        end
    end
    println(sum)
    return sum
end

"Set of cubes drawn"
struct CubeSet
    red::Int64
    green::Int64
    blue::Int64
end

"Game definiton"
struct Game
    id::Int64
    sets::Vector{CubeSet}
end

"Parse raw string data into Game struct"
function parse_game(line::String)::Game
    s = split(line, ":")
    if length(s) != 2
        error("Invalid data format!")
    end

    id = parse(Int64, replace(first(s), "Game " => ""))
    sets = parse_cube_sets(last(s))
    return Game(id, sets)
end

"Parse raw string data into CubeSet struct(s)"
function parse_cube_sets(game_data::AbstractString)::Vector{CubeSet}
    sets::Vector{CubeSet} = []

    # CubeSet's within game_data are seperated by `;`
    for set_data in split(game_data, ";")
        red = 0
        green = 0
        blue = 0

        # Color entry within set_data are seperated by `,`
        for entry in split(strip(set_data), ",")
            split_result = split(strip(entry), " ")

            if length(split_result) != 2
                error("Invalid number and color format!")
            end
            quantity = parse(Int64, first(split_result))
            color = last(split_result)

            if color == "red"
                red = quantity
            elseif color == "green"
                green = quantity
            elseif color == "blue"
                blue = quantity
            else
                error("Unexpected color string: $color")
            end
        end
        push!(sets, CubeSet(red, green, blue))
    end

    return sets
end

end # module
