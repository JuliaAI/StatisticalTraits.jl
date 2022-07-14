module StatisticalTraits

using ScientificTypesBase
import Base.instances

## CONSTANTS

const TRAITS = [
    :input_scitype,
    :output_scitype,
    :target_scitype,
    :fit_data_scitype, #
    :predict_scitype,  #
    :transform_scitype, #
    :inverse_transform_scitype, #
    :is_pure_julia,
    :package_name,
    :package_license,
    :load_path,
    :package_uuid,
    :package_url,
    :is_wrapper,
    :supports_weights,
    :supports_class_weights,
    :supports_online,
    :docstring,
    :name,
    :human_name,
    :is_supervised,
    :prediction_type,
    :abstract_type, #
    :hyperparameters,
    :hyperparameter_types,
    :hyperparameter_ranges,
    :orientation,
    :reports_each_observation,
    :reports_feature_importances,
    :aggregation,
    :is_feature_dependent,
    :distribution_type,
    :iteration_parameter,
    :supports_training_losses,
    :deep_properties,
    :reporting_operations,
]


## EXPORT

for trait in TRAITS
    eval(:(export $trait))
end

export Mean, Sum, RootMeanSquare


## TYPES

# For the possible values of the `aggregation` trait:
abstract type AggregationMode end
struct Sum <: AggregationMode end
struct Mean <: AggregationMode end
struct RootMeanSquare <: AggregationMode end


## HELPERS

# Some helper functions are needed to construct sensible fallbacks for
# some traits.

if VERSION < v"1.1"
    fieldtypes(t) = Tuple(fieldtype(t, i) for i = 1:fieldcount(t))
end

"""

    typename(T::Type)

Return a symbol corresponding to the name of the type `T`, stripped of
any type-parameters and module qualifications. For example:

    _typename(MLJBase.Machine{MLJModels.ConstantRegressor,true})

returns `:Machine`. Where this does not make sense (eg, instances of
`Union`) `Symbol(string(M))` is returned.

"""
function typename(M)
    if isdefined(M, :name)
        return M.name.name
    elseif isdefined(M, :body)
        return typename(M.body)
    else
        return Symbol(string(M))
    end
end

function is_uppercase(char::Char)
    i = Int(char)
    i > 64 && i < 91
end

"""
    snakecase(str, del='_')

Return the snake case version of the abstract string or symbol, `str`, as in

    snakecase("TheLASERBeam") == "the_laser_beam"

"""
function snakecase(str::AbstractString; delim='_')
    snake = Char[]
    n = length(str)
    for i in eachindex(str)
        char = str[i]
        if is_uppercase(char)
            if i != 1 && i < n &&
                !(is_uppercase(str[i + 1]) && is_uppercase(str[i - 1]))
                push!(snake, delim)
            end
            push!(snake, lowercase(char))
        else
            push!(snake, char)
        end
    end
    return join(snake)
end

snakecase(s::Symbol) = Symbol(snakecase(string(s)))


## TRAITS

# The following can return any scientific type, that is, any type
# defined in the package ScientificTypesBase.jl, and any ordinary type
# that functions as a scientific type (eg, `Missing`). Here "target"
# is a synonym for "labels", as in supervised learning; "input" is a
# synonym for "features":

input_scitype(::Type)          = Unknown
output_scitype(::Type)         = Unknown
target_scitype(::Type)         = Unknown
fit_data_scitype(::Type)       = Unknown
predict_scitype(::Type)        = Unknown
transform_scitype(::Type)      = Unknown
inverse_transform_scitype(::Type)  = Unknown

# The following refer to properties of the package defining a type,
# for use in, say, a registry of machine learning models. All but the
# first must return a string:

is_pure_julia(::Type)          = false # must be `true` or `false`
package_name(::Type)           = "unknown"
package_license(::Type)        = "unknown"
load_path(::Type)              = "unknown"
package_uuid(::Type)           = "unknown"
package_url(::Type)            = "unknown"

# Below "weights" means "per-observation weights":

supports_weights(::Type)       = false
supports_class_weights(::Type) = false

# Possible values of the following are `:deterministic`, `:probabilistic`,
# `:interval`, or `:unknown`:

prediction_type(::Type)        = :unknown

# Miscellaneous:

abstract_type(::Type)   = Any
is_wrapper(::Type)      = false     # or `true`
supports_online(::Type) = false     # or `true`
docstring(M::Type)      = string(M) # some `String`
is_supervised(::Type)   = false     # or `true`
human_name(M::Type)     = snakecase(name(M), delim=' ') # `name` defined below
orientation(::Type)     = :loss  # or `:score`, `:other`
aggregation(::Type)     = Mean()
is_feature_dependent(::Type)     = false
reports_each_observation(::Type) = false
reports_feature_importances(::Type) = false
distribution_type(::Type)        = missing
iteration_parameter(::Type)      = nothing
supports_training_losses(::Type) = false
deep_properties(::Type) = ()
reporting_operations(::Type) = ()

# Returns a tuple, with one entry per field of `T` (the type of some
# statistical model, for example). Each entry is `nothing` or defines
# some kind of default "search range" for the corresponding field (as
# ordered in `fieldnames(T)`).

hyperparameter_ranges(T::Type) = Tuple(fill(nothing, length(fieldnames(T))))

# Not really traits (you would not ordinarily overload them) but
# included here as they are often grouped with true traits:

name(M::Type)                  = string(typename(M))
hyperparameters(M::Type)       = fieldnames(M)
hyperparameter_types(M::Type)  = string.(fieldtypes(M))


## MAKE TRAITS ACT ON INSTANCES AS WELL AS TYPES

for trait in TRAITS
    ex = quote
        $trait(x) = $trait(typeof(x))
    end
    eval(ex)
end


## METHOD STUB FOR LISTING ALL TRAITS OF AN OBJECT

"""
    info(X)

Return a named-tuple of trait values for `X`, keyed on the names of
traits that are meaningful for the object.

*Note on overloading.* This method can be overloaded directly, as in
`info(X::SomeAbstractType) = ...`.
"""
function info end

end #module
