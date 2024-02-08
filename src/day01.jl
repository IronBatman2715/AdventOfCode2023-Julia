module Day01

function day01()
    inputs = readlines(joinpath(@__DIR__, "../data/day01.txt"))
    return [solve(inputs), solve(inputs, true)]
end

function solve(list::Array{String,1}, part_2=false)
    sum = 0

    for line in list
        number_str = ""

        if part_2
            # Replace string representarions of digits with actual digits
            line = string_to_digit(line)
        end

        # Split line into Array{String, 1} where each String has length of 1
        for string in split(line, "")
            char = only(string) # convert String to char
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

        sum += parse(Int64, number_str)
    end

    return sum
end

function string_to_digit(s::String)
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

end # module
