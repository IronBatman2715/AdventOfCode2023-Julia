using AdventOfCode2023
using Test

@testset "Day 1" begin
    part_1, part_2 = AdventOfCode2023.Day01.run()
    @test part_1 == 54388
    @test part_2 == 53515
end
