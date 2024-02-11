module Day01

using AdventOfCode2023

"""
Load inputs and solve the [Day 1](https://adventofcode.com/2023/day/1) puzzle.
"""
function run()::Tuple{UInt,UInt}
    inputs::Vector{String} = split(AdventOfCode2023.data[1], '\n')
    return solve(inputs), solve(inputs, true)
end

function solve(list::Vector{String}, part_2=false)::UInt
    return sum(l -> parse_calibration_value(l, part_2), list)
end

"""
Replace substrings within s matching a digit's string representaion into their respective digit.

Ex: "hellonethereighttwoone" => "hell1ther821"
    "shareeighthreecharacters" => "share83characters"
"""
function string_to_digit(s::String)::String
    # Replace number strings that share characters...
    s = replace(s,
        "twone" => "twoone",
        "oneight" => "oneeight",
        "threeight" => "threeeight",
        "fiveight" => "fiveeight",
        "sevenine" => "sevennine",
        "eightwo" => "eighttwo",
        "eighthree" => "eightthree")

    return replace(s,
        "one" => "1",
        "two" => "2",
        "three" => "3",
        "four" => "4",
        "five" => "5",
        "six" => "6",
        "seven" => "7",
        "eight" => "8",
        "nine" => "9")
end

function parse_calibration_value(line::String, part_2=false)::UInt
    number_str = ""

    if part_2
        # Replace string representarions of digits with actual digits
        line = string_to_digit(line)
    end

    # Split line into Vector{Char}
    for char in collect(line)
        if isdigit(char)
            # Add ALL digit characters in this line to number_str
            number_str *= char
        end
    end

    if length(number_str) < 1
        # Expecting at least one digit
        error("Could not parse ANY digits!")
    elseif length(number_str) < 2
        # If only one digit, duplicate it
        number_str *= number_str
    elseif length(number_str) > 2
        # If more than 2 digits, remove all except first and last digits
        number_str = first(number_str) * last(number_str)
    end

    return parse(UInt, number_str)
end

end # module
