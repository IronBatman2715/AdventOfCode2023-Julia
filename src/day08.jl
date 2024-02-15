module Day08

using AdventOfCode2023

"""
Load inputs and solve the [Day 8](https://adventofcode.com/2023/day/8) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[8]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    instructions, desert_network = parse_input(input)

    if part_2
        start_nodes = filter(s -> s != "", [endswith(k, 'A') ? k : "" for (k, v) in desert_network])
        is_end_node = curr_node -> !endswith(curr_node, 'Z')
        steps_vec = [follow_network_from(start_node, is_end_node, instructions, desert_network) for start_node in start_nodes]

        return lcm(steps_vec)
    else
        is_end_node = curr_node -> curr_node != "ZZZ"
        return follow_network_from("AAA", is_end_node, instructions, desert_network)
    end
end

function parse_input(input::String)::Tuple{String,Dict{String,Tuple{String,String}}}
    lines = split(strip(input), '\n')
    line_quantity = length(lines)
    if line_quantity < 3
        error("Couldn't parse any values")
    end

    instructions::String = strip(lines[1])

    desert_network::Dict{String,Tuple{String,String}} = Dict([])
    for line in lines[3:end]
        str_vec = split(strip(line), '=')
        if length(str_vec) != 2
            error("Couldn't parse line value")
        end

        next_nodes_vec = split(replace(strip(str_vec[2]), "(" => "", ")" => ""), ',')
        if length(next_nodes_vec) != 2
            error("Couldn't parse next nodes")
        end

        name::String = strip(str_vec[1])
        next_nodes::Tuple{String,String} = strip(next_nodes_vec[1]), strip(next_nodes_vec[2])

        desert_network[name] = next_nodes
    end

    return instructions, desert_network
end

# Not sure how to properly type `is_end_node`. Should be a closure accepting String and outputting Bool
function follow_network_from(start_node::String, is_end_node, instructions::String, desert_network::Dict{String,Tuple{String,String}})::Int
    curr_node = start_node
    steps = 0
    step_size = length(instructions)
    while true
        for direction in collect(instructions)
            dir_index = 1
            if direction == 'L'
                dir_index = 1
            elseif direction == 'R'
                dir_index = 2
            else
                error("Invalid direction!")
            end
            curr_node = desert_network[curr_node][dir_index]
        end
        steps += step_size

        is_end_node(curr_node) || return steps
    end
end

end # module
