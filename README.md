# StatTraits.jl

|  Linux        | Coverage |
| :-----------: | :------: |
| [![Build status](https://github.com/alan-turing-institute/StatisticalTraits.jl/workflows/CI/badge.svg)](https://github.com/alan-turing-institute/StatisticalTraits.jl/actions)| [![codecov.io](http://codecov.io/github/alan-turing-institute/StatisticalTraits.jl/coverage.svg?branch=master)](http://codecov.io/github/alan-turing-institute/StatisticalTraits.jl?branch=master) |

A light-weight package defining fall-back implementations for a
collection of traits possessed by statistical objects. Here a "trait"
is a function with a single argument that is a julia type, which might
encode type metadata for inspection, or for use in function
dispatch. 

Here are two examples, which might be applies to both statistical
model types and loss function types:

```julia
target_scitype(::Type) = Unknown
prediction_type(::Type) = :unknown # also :probablistic, :deterministic, :interval
```

Here `Unknown` is a type defined in the light-weight package
[`ScientificTypes.jl`](https://github.com/alan-turing-institute/ScientificTypes.jl),
the only dependency of StatsTraits.jl.

Refer to [source code](src/StatisticalTraits.jl) for a complete list.

The traits defined here are overloaded by assorted model types and
measure types in the
[MLJ](https://github.com/alan-turing-institute/MLJ.jl) universe
(examples of measures are loss functions and scoring rules). However,
this small package might be of independent interest.

A planned StatisticalMeasures.jl package, to contain measures
currently in
[MLJBase.jl](https://github.com/alan-turing-institute/MLJBase.jl),
will have this package as a dependency, allowing it to be independent
of the MLJ packages.
	
