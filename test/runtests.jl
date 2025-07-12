using Test
using StatisticalTraits
using ScientificTypesBase
import SparseArrays
using REPL

module Fruit

struct RedApple{T}
    x::T
end

end

import .Fruit


## HELPERS

@testset "typename" begin
    @test StatisticalTraits.typename(Fruit.RedApple) == :RedApple
    @test StatisticalTraits.typename(Fruit.RedApple{Int}) == :RedApple
    @test StatisticalTraits.typename(Nothing) == :Nothing
    @test StatisticalTraits.typename(UnionAll) == :UnionAll
    @test StatisticalTraits.typename(Union{Char,Int}) ==
        Symbol("Union{Char, Int64}")
    T = SparseArrays.sparse([1,2], [1,3], [0.5, 0.6]) |> typeof
    @test StatisticalTraits.typename(T) == :SparseMatrixCSC
end

@testset "snakecase" begin
    @test StatisticalTraits.snakecase("AnthonyBlaomsPetElk") ==
        "anthony_blaoms_pet_elk"
    @test StatisticalTraits.snakecase("TheLASERBeam", delim=' ') ==
        "the laser beam"
    @test StatisticalTraits.snakecase(:TheLASERBeam) == :the_laser_beam
end


## TRAITS WITH NON-CONSTANT FALL-BACK

struct Foo
    x::Int
    y::Char
end

@testset "docstring" begin
    @test docstring(Foo(1,'x')) == "Foo"
    @test docstring(Fruit.RedApple(4)) == "Main.Fruit.RedApple{Int64}"
    @test docstring(sin) == Base.Docs.doc(sin) |> string
end

@testset "hyperparameter_ranges" begin
    @test hyperparameter_ranges(Foo(1, 'x')) == (nothing, nothing)
    @test hyperparameter_ranges(Fruit.RedApple(4)) == (nothing, )
end

@testset "name" begin
    @test name(Float64) == "Float64"
    @test name(Fruit.RedApple) == "RedApple"
    @test name(Fruit.RedApple(4)) == "RedApple"
end

@testset "human_name" begin
    @test human_name(AbstractString) == "abstract string"
    @test human_name(Fruit.RedApple) == "red apple"
    @test human_name(Fruit.RedApple(4)) == "red apple"
end

@testset "hyperparameters" begin
    @test hyperparameters(Foo(1, 'x')) == (:x, :y)
    @test hyperparameters(Fruit.RedApple(4)) == (:x, )
end

@testset "hyperparameter_types" begin
    @test hyperparameter_types(Foo(1, 'x')) == ("Int64", "Char")
    @test hyperparameter_types(Fruit.RedApple(4)) == ("Int64", )
end


## TRAITS WITH CONSTANT FALL-BACK

const NONCONSTANT = [:docstring,
                     :hyperparameter_ranges,
                     :name,
                     :human_name,
                     :hyperparameters,
                     :hyperparameter_types]

@testset "traits with constant fall-back" begin
    for trait in setdiff(StatisticalTraits.TRAITS, NONCONSTANT)
        ex = quote
            a = $trait(Fruit.RedApple(4))
            b = $trait(Foo(1, 'x'))
            if ismissing(a)
                @test ismissing(b)
            else
                @test a == b
            end
        end
        Main.eval(ex)
    end
end
