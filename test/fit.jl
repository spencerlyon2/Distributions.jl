# Testing:
#
#  - computation of sufficient statistics
#  - distribution fitting (i.e. estimation)
# 

using Distributions
using Base.Test

n0 = 100
N = 10^5

w = rand(n0)

# DiscreteUniform

x = rand(DiscreteUniform(10, 15), n0)
d = fit(DiscreteUniform, x)
@test isa(d, DiscreteUniform)
@test minimum(d) == minimum(x)
@test maximum(d) == maximum(x)

d = fit(DiscreteUniform, rand(DiscreteUniform(10, 15), N))
@test minimum(d) == 10
@test maximum(d) == 15


# Bernoulli

x = rand(Bernoulli(0.7), n0)

ss = suffstats(Bernoulli, x)
@test isa(ss, Distributions.BernoulliStats)
@test ss.cnt0 == n0 - countnz(x)
@test ss.cnt1 == countnz(x)

ss = suffstats(Bernoulli, x, w)
@test isa(ss, Distributions.BernoulliStats)
@test_approx_eq ss.cnt0 sum(w[x .== 0])
@test_approx_eq ss.cnt1 sum(w[x .== 1])

d = fit(Bernoulli, x)
p = countnz(x) / n0
@test isa(d, Bernoulli)
@test_approx_eq mean(d) p

d = fit(Bernoulli, x, w)
p = sum(w[x .== 1]) / sum(w)
@test isa(d, Bernoulli)
@test_approx_eq mean(d) p 

d = fit(Bernoulli, rand(Bernoulli(0.7), N))
@test isa(d, Bernoulli)
@test_approx_eq_eps mean(d) 0.7 0.01


# Beta

d = fit(Beta, rand(Beta(1.3, 3.7), N))
@test isa(d, Beta)
@test_approx_eq_eps d.alpha 1.3 0.1
@test_approx_eq_eps d.beta  3.7 0.1


# Binomial

x = rand(Binomial(100, 0.3), n0)

ss = suffstats(Binomial, (100, x))
@test isa(ss, Distributions.BinomialStats)
@test_approx_eq ss.ns sum(x)
@test ss.ne == n0
@test ss.n == 100

ss = suffstats(Binomial, (100, x), w)
@test isa(ss, Distributions.BinomialStats)
@test_approx_eq ss.ns dot(float64(x), w)
@test_approx_eq ss.ne sum(w)
@test ss.n == 100

d = fit(Binomial, (100, x))
@test isa(d, Binomial)
@test ntrials(d) == 100
@test_approx_eq succprob(d) sum(x) / (n0 * 100)

d = fit(Binomial, (100, x), w)
@test isa(d, Binomial)
@test ntrials(d) == 100
@test_approx_eq succprob(d) dot(x, w) / (sum(w) * 100)

d = fit(Binomial, 100, rand(Binomial(100, 0.3), N))
@test isa(d, Binomial)
@test ntrials(d) == 100
@test_approx_eq_eps succprob(d) 0.3 0.01


# Categorical

p = [0.2, 0.5, 0.3]
x = rand(Categorical(p), n0)

ss = suffstats(Categorical, (3, x))
h = Float64[countnz(x .== i) for i = 1 : 3]
@test isa(ss, Distributions.CategoricalStats)
@test_approx_eq ss.h h

d = fit(Categorical, (3, x))
@test isa(d, Categorical)
@test d.K == 3
@test_approx_eq d.prob h / sum(h)

d2 = fit(Categorical, x)
@test isa(d2, Categorical)
@test d2.prob == d.prob

ss = suffstats(Categorical, (3, x), w)
h = Float64[sum(w[x .== i]) for i = 1 : 3]
@test isa(ss, Distributions.CategoricalStats)
@test_approx_eq ss.h h

d = fit(Categorical, (3, x), w)
@test isa(d, Categorical)
@test_approx_eq d.prob h / sum(h)

d = fit(Categorical, suffstats(Categorical, 3, x, w))
@test isa(d, Categorical)
@test_approx_eq d.prob (h / sum(h))

d = fit(Categorical, rand(Categorical(p), N))
@test isa(d, Categorical)
@test_approx_eq_eps d.prob p 0.01


# Exponential

x = rand(Exponential(0.5), n0)

ss = suffstats(Exponential, x)
@test isa(ss, Distributions.ExponentialStats)
@test_approx_eq ss.sx sum(x)
@test ss.sw == n0

ss = suffstats(Exponential, x, w)
@test isa(ss, Distributions.ExponentialStats)
@test_approx_eq ss.sx dot(x, w)
@test ss.sw == sum(w)

d = fit(Exponential, x)
@test isa(d, Exponential)
@test_approx_eq d.scale mean(x)

d = fit(Exponential, x, w)
@test isa(d, Exponential)
@test_approx_eq d.scale dot(x, w) / sum(w)

d = fit(Exponential, rand(Exponential(0.5), N))
@test isa(d, Exponential)
@test_approx_eq_eps mean(d) 0.5 0.01


# Normal

μ = 11.3
σ = 3.2

x = rand(Normal(μ, σ), n0)

ss = suffstats(Normal, x)
@test isa(ss, Distributions.NormalStats)
@test_approx_eq ss.s sum(x)
@test_approx_eq ss.m mean(x)
@test_approx_eq ss.s2 sum((x .- ss.m).^2)
@test_approx_eq ss.tw n0

ss = suffstats(Normal, x, w)
@test isa(ss, Distributions.NormalStats)
@test_approx_eq ss.s dot(x, w)
@test_approx_eq ss.m dot(x, w) / sum(w)
@test_approx_eq ss.s2 dot((x .- ss.m).^2, w)
@test_approx_eq ss.tw sum(w)

d = fit(Normal, x)
@test isa(d, Normal)
@test_approx_eq d.μ mean(x)
@test_approx_eq d.σ sqrt(mean((x .- d.μ).^2))

d = fit(Normal, x, w)
@test isa(d, Normal)
@test_approx_eq d.μ dot(x, w) / sum(w)
@test_approx_eq d.σ sqrt(dot((x .- d.μ).^2, w) / sum(w))

d = fit(Normal, rand(Normal(μ, σ), N))
@test isa(d, Normal)
@test_approx_eq_eps d.μ μ 0.1
@test_approx_eq_eps d.σ σ 0.1

import Distributions.NormalKnownMu, Distributions.NormalKnownSigma

ss = suffstats(NormalKnownMu(μ), x)
@test isa(ss, Distributions.NormalKnownMuStats)
@test ss.μ == μ
@test_approx_eq ss.s2 sum((x .- μ).^2)
@test_approx_eq ss.tw n0

ss = suffstats(NormalKnownMu(μ), x, w)
@test isa(ss, Distributions.NormalKnownMuStats)
@test ss.μ == μ
@test_approx_eq ss.s2 dot((x .- μ).^2, w)
@test_approx_eq ss.tw sum(w)

d = fit_mle(Normal, x; mu=μ)
@test isa(d, Normal)
@test d.μ == μ
@test_approx_eq d.σ sqrt(mean((x .- d.μ).^2))

d = fit_mle(Normal, x, w; mu=μ)
@test isa(d, Normal)
@test d.μ == μ
@test_approx_eq d.σ sqrt(dot((x .- d.μ).^2, w) / sum(w))


ss = suffstats(NormalKnownSigma(σ), x)
@test isa(ss, Distributions.NormalKnownSigmaStats)
@test ss.σ == σ
@test_approx_eq ss.sx sum(x)
@test_approx_eq ss.tw n0

ss = suffstats(NormalKnownSigma(σ), x, w)
@test isa(ss, Distributions.NormalKnownSigmaStats)
@test ss.σ == σ
@test_approx_eq ss.sx dot(x, w)
@test_approx_eq ss.tw sum(w)

d = fit_mle(Normal, x; sigma=σ)
@test isa(d, Normal)
@test d.σ == σ
@test_approx_eq d.μ mean(x)

d = fit_mle(Normal, x, w; sigma=σ)
@test isa(d, Normal)
@test d.σ == σ
@test_approx_eq d.μ dot(x, w) / sum(w)


# Uniform

x = rand(Uniform(1.2, 5.8), n0)
d = fit(Uniform, x)
@test isa(d, Uniform)
@test 1.2 <= minimum(d) <= maximum(d) <= 5.8
@test minimum(d) == minimum(x)
@test maximum(d) == maximum(x)

d = fit(Uniform, rand(Uniform(1.2, 5.8), N))
@test 1.2 <= minimum(d) <= maximum(d) <= 5.8
@test_approx_eq_eps minimum(d) 1.2 0.02
@test_approx_eq_eps maximum(d) 5.8 0.02


# Gamma

x = rand(Gamma(3.9, 2.1), n0)

ss = suffstats(Gamma, x)
@test isa(ss, Distributions.GammaStats)
@test_approx_eq ss.sx sum(x)
@test_approx_eq ss.slogx sum(log(x))
@test_approx_eq ss.tw n0

ss = suffstats(Gamma, x, w)
@test isa(ss, Distributions.GammaStats)
@test_approx_eq ss.sx dot(x, w)
@test_approx_eq ss.slogx dot(log(x), w)
@test_approx_eq ss.tw sum(w)

d = fit(Gamma, rand(Gamma(3.9, 2.1), N))
@test isa(d, Gamma)
@test_approx_eq_eps d.shape 3.9 0.1
@test_approx_eq_eps d.scale 2.1 0.2


# Geometric

x = rand(Geometric(0.3), n0)

ss = suffstats(Geometric, x)
@test isa(ss, Distributions.GeometricStats)
@test_approx_eq ss.sx sum(x)
@test_approx_eq ss.tw n0

ss = suffstats(Geometric, x, w)
@test isa(ss, Distributions.GeometricStats)
@test_approx_eq ss.sx dot(x, w)
@test_approx_eq ss.tw sum(w)

d = fit(Geometric, x)
@test isa(d, Geometric)
@test_approx_eq d.prob inv(1. + mean(x))

d = fit(Geometric, x, w)
@test isa(d, Geometric)
@test_approx_eq d.prob inv(1. + dot(x, w) / sum(w))

d = fit(Geometric, rand(Geometric(0.3), N))
@test isa(d, Geometric)
@test_approx_eq_eps d.prob 0.3 0.01


# Laplace

d = fit(Laplace, rand(Laplace(5.0, 3.0), N))
@test isa(d, Laplace)
@test_approx_eq_eps d.location 5.0 0.1
@test_approx_eq_eps d.scale 3.0 0.2


# Poisson

x = rand(Poisson(8.2), n0)

ss = suffstats(Poisson, x)
@test isa(ss, Distributions.PoissonStats)
@test_approx_eq ss.sx sum(x)
@test_approx_eq ss.tw n0

ss = suffstats(Poisson, x, w)
@test isa(ss, Distributions.PoissonStats)
@test_approx_eq ss.sx dot(x, w)
@test_approx_eq ss.tw sum(w)

d = fit(Poisson, x)
@test isa(d, Poisson)
@test_approx_eq mean(d) mean(x)

d = fit(Poisson, x, w)
@test isa(d, Poisson)
@test_approx_eq mean(d) dot(float64(x), w) / sum(w)

d = fit(Poisson, rand(Poisson(8.2), N))
@test isa(d, Poisson)
@test_approx_eq_eps mean(d) 8.2 0.2

