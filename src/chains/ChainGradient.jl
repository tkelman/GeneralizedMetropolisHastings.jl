### ChainGradient

# Stores the output of a Monte Carlo run
type ChainGradient{N<:Number,T<:AbstractFloat,V<:AbstractVector,A<:AbstractArray} <: AbstractChain
    values::A
    loglikelihood::V
    gradloglikelihood::A
    numburnin::Int
    accepted::Int
    proposed::Int
    runtime::Real
    ChainGradient(v::AbstractArray{N},ll::AbstractVector{T},gl::AbstractArray{T},b::Int,a::Int,p::Int,r::Real) = new(v,ll,gl,b,a,p,r)
end

@inline function _chain{N<:Number,T<:AbstractFloat}(::Type{Val{:gradient}},nparas::Int,nsamples::Int,::Type{N},::Type{T};numburnin::Int =0)
    v = zeros(N,_valuestuple(nparas,nsamples))
    ChainGradient{N,T,Vector,Array}(v,Vector{T}(nsamples),similar(v,T),numburnin,0,0,0.0)
end

function store!{O<:GradientOrder}(c::ChainGradient,s::AbstractSample{O},j::Int)
    nparas = numparas(s)
    @assert numparas(c) == nparas && j <= numsamples(s)
    if c.proposed < numsamples(c)
        c.proposed += 1
        copy!(c.values,(c.proposed-1)*nparas+1,s.values,(j-1)*nparas+1,nparas)
        copy!(c.gradloglikelihood,(c.proposed-1)*nparas+1,s.gradloglikelihood,(j-1)*nparas+1,nparas)
        c.loglikelihood[c.proposed] = s.loglikelihood[j]
    else
        warn("Chain is full. Additional results cannot be stored")
    end
end

function show(io::IO,c::ChainGradient)
  println("ChainGradient with numparas = $(numparas(c)) and numsamples = $(numsamples(c))")
  println("Samples proposed = $(c.proposed), samples accepted = $(c.accepted), acceptance rate = $(c.accepted/c.proposed)")
  println("Total runtime = $(c.runtime)")
  println("Additional fields: :values, :loglikelihood, :gradloglikelihood")
end
