module Day06

using AdventOfCode2023

"""
Load inputs and solve the [Day 6](https://adventofcode.com/2023/day/6) puzzle.
"""
function run()::Tuple{Int,Int}
    input = AdventOfCode2023.data[6]
    return solve(input), solve(input, true)
end

function solve(input::String, part_2=false)::Int
    race_records = parse_input(input, part_2)
    return prod(*, [length(get_winning_times(race_record)) for race_record in race_records])
end

struct RaceRecord
    time::Int
    record_dist::Int
end

function parse_input(input::String, part_2::Bool)::Vector{RaceRecord}
    lines = split(strip(input), '\n')
    if length(lines) != 2
        error("Malformed input string")
    end

    times::Vector{Int} = parse_values(lines[1], part_2)
    record_dists::Vector{Int} = parse_values(lines[2], part_2)

    if length(times) != length(record_dists)
        error("Received different number of times and record_dists")
    end
    num_race_records = length(times)

    if part_2 && num_race_records != 1
        error("Incorrectly parsed part_2 input!")
    end

    return [RaceRecord(times[i], record_dists[i]) for i in 1:num_race_records]
end

function parse_values(str::AbstractString, part_2::Bool)::Vector{Int}
    str_vec = split(strip(str), ':')
    if length(str_vec) != 2
        error("Unexpected values format")
    end

    if part_2
        str_vec = split(strip(str), ':')
        if length(str_vec) != 2
            error("Unexpected values format")
        end

        return [parse(Int, replace(strip(str_vec[2]), " " => ""))]
    else
        value_strs = split(strip(str_vec[2]))
        if length(value_strs) < 1
            error("Couldn't parse ANY values")
        end

        return [parse(Int, value_str) for value_str in value_strs]
    end
end

"""
Calculate the distance traveled given the duration the button is held `t0` and duration of the race `t`
"""
function boat_distance(t0, t::Int)
    if t < 1
        error("Invalid t entered!")
    end
    if t0 > t || t0 < 0
        error("Invalid t0 entered!")
    end

    return t0 * (t - t0) # may be float!
end

"""
Get the optimal amount of time to charge the boat.

# Explanation:
d: total distance traveled
s: speed
t: time duration of race
t0: time button is held

d = s(t-t0)
s = t0 ∴ d = st - s^2 = s(t-s) = t0(t-t0)

Since t is given,
d(s) = s(t-s) = -s(s-t) = -s^2 + st -> d'(s) = -2s + t = d'(t0) = -2t0 + t

d'(t0) = 0 = -2t0 + t => t0 = t/2
∴ t0_best = t/2
"""
function get_optimal_time(race_record::RaceRecord)::Float64
    race_record.time / 2.0
end

function get_t0_limits(race_record::RaceRecord)
    # Find when record_dist < dist(t0) = t0(t-t0) is no longer true
    # 
    # 0 = dist(t0) - record_dist = t0(t-t0) - record_dist = t0^2 - tt0 + record_dist
    # 
    # quadratic formula => t0 = (-(-t) ± sqrt((-t)^2 - 4(1)(record_dist))) / 2(1) = (t ± sqrt(t^2 - 4 * record_dist)) / 2

    t = race_record.time
    record_dist = race_record.record_dist

    discriminant = t^2 - 4 * record_dist
    if discriminant < 0
        error("Record distance should be impossible...?")
    end
    if discriminant == 0
        return t / 2, t / 2
    end

    sqrt_discriminant = sqrt(discriminant)

    t0_lower_lim = (t - sqrt_discriminant) / 2
    t0_upper_lim = (t + sqrt_discriminant) / 2

    return t0_lower_lim, t0_upper_lim
end

function get_winning_times(race_record::RaceRecord)::Vector{Int}
    winning_times::Vector{Int} = []

    t0_best = get_optimal_time(race_record)
    is_t0_best_float = t0_best != round(t0_best)

    t0_lower_lim, t0_upper_lim = get_t0_limits(race_record)
    t0_lower_lim_int::Int = t0_lower_lim == round(t0_lower_lim) ? t0_lower_lim + 1 : ceil(t0_lower_lim)
    t0_upper_lim_int::Int = t0_upper_lim == round(t0_upper_lim) ? t0_upper_lim - 1 : floor(t0_upper_lim)

    # Add values in -t0 direction
    t0_best_lower_int = is_t0_best_float ? floor(t0_best) : t0_best - 1
    append!(winning_times, t0_lower_lim_int:t0_best_lower_int)

    if !is_t0_best_float
        # t0_best is an integer. Add to valid winning times
        push!(winning_times, t0_best)
    end

    # Add values in +t0 direction
    t0_best_upper_int = is_t0_best_float ? ceil(t0_best) : t0_best + 1
    append!(winning_times, t0_best_upper_int:t0_upper_lim_int)

    return winning_times
end

end # module
