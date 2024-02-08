module AdventOfCode2023

using Printf

day_nums = 1:2
for day_num in day_nums
    day_num_str = @sprintf("%.2d", day_num)
    include(joinpath(@__DIR__, "day$day_num_str.jl"))
end

end # module AdventOfCode2023
