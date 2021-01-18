using Test
using StatisticalTraits
using ScientificTypes
import SparseArrays

module Fruit

struct RedApple end

end

import .Fruit


## HELPERS

@testset "typename" begin
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
end


## TRAITS WITH NON-CONSTANT FALL-BACK

struct Foo
    x::Int
    y::Char
end

@testset "docstring" begin
    @test docstring(Foo(1,'x')) == "Foo"
    @test docstring(Fruit.RedApple()) == "Main.Fruit.RedApple"
end

@testset "hyperparameter_ranges" begin
    @test hyperparameter_ranges(Foo(1, 'x')) == (nothing, nothing)
    @test hyperparameter_ranges(Fruit.RedApple()) == ()
end

@testset "name" begin
    @test name(Float64) == "Float64"
    @test name(Fruit.RedApple) == "RedApple"
    @test name(Fruit.RedApple()) == "RedApple"
end

@testset "human_name" begin
    @test human_name(AbstractString) == "abstract string"
    @test human_name(Fruit.RedApple) == "red apple"
    @test human_name(Fruit.RedApple()) == "red apple"
end

@testset "hyperparameters" begin
    @test hyperparameters(Foo(1, 'x')) == (:x, :y)
    @test hyperparameters(Fruit.RedApple()) == ()
end

@testset "hyperparameter_types" begin
    @test hyperparameter_types(Foo(1, 'x')) == ("Int64", "Char")
    @test hyperparameter_types(Fruit.RedApple()) == ()
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
            @test $trait(Fruit.RedApple()) == $trait(Foo(1, 'x'))
        end
        Main.eval(ex)
    end
end


## INFO STUB

@test StatisticalTraits.info(42) == NamedTuple()
