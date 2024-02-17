module AdventOfCode2023

using Printf

day_nums = 1:11
data::Vector{String} = []
for day_num in day_nums
    day_num_str = @sprintf("%.2d", day_num)

    day_data = open(joinpath(@__DIR__, "../data/day$day_num_str.txt")) do file
        strip(read(file, String))
    end
    push!(data, day_data)

    include(joinpath(@__DIR__, "day$day_num_str.jl"))
end

export data

end # module AdventOfCode2023
