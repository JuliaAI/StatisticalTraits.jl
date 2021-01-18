module StatisticalTraits

using ScientificTypes


## CONSTANTS

const TRAITS = [
    :input_scitype,
    :output_scitype,
    :target_scitype,
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
    :is_supervised,
    :prediction_type,
    :hyperparameters,
    :hyperparameter_types,
    :hyperparameter_ranges]


## EXPORT

for trait in TRAITS
    eval(:(export $trait))
end


## HELPERS

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
        return _typename(M.body)
    else
        return Symbol(string(M))
    end
end


## TRAITS

# The following can return any scientific type, that is, any type
# defined in the package ScientificTypes.jl, and any ordinary type
# that functions as a scientific type (eg, `Missing`). Here "target"
# is a synonym for "labels", as in supervised learning; "input" is a
# synonym for "features":

input_scitype(::Type)          = Unknown
output_scitype(::Type)         = Unknown
target_scitype(::Type)         = Unknown

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

prediction_type(::Type)        = :unknown # used for measures too

# Miscellaneous:

is_wrapper(::Type)             = false     # or `true`
supports_online(::Type)        = false     # or `true`
docstring(M::Type)             = string(M) # some `String`
is_supervised(::Type)          = false     # or `true`

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

## INFO METHOD FOR QUERYING TRAITS

"""
    info(X)

Return a named-tuple of trait values for `X`, keyed on a list of
traits that are meaninful for the object.

*Note on overloading.* This method can be overloaded directly, as in
`info(X::SomeAbstractType) = ...` or, using `info(X,
::Val{:some_trait}) = ...` where `:some_trait` is a key of
`ScientificTypes.TRAIT_FUNCTION_GIVEN_NAME`.

"""
info(X) = info(X, Val(ScientificTypes.trait(X)))
info(X, ::Val{:other}) = NamedTuple()

end # module

