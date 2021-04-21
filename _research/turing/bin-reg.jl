### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ edbb4db2-9966-11eb-0958-c1c7dba2efe0
using DrWatson
@quickactivate :ens


using DataFramesMeta
using StatsPlots; pyplot()
using StatsBase
using StatsFuns: logistic
using Turing



include(srcdir("spline", "mkdf.jl"))

# ╔═╡ a404acf8-9967-11eb-16b8-b5d234bb7e94
#' Loading
data = load_data("data-v6.arrow")

neigh = couple(data, :n)
dist = couple(data, :d)
idx = dist[19]

df = find(data, idx) |> mkdf
df = @where(df, :nearest .<= 50)

#' Visualising

# ╔═╡ ae03bf08-9967-11eb-2583-a5fe4b60fec9
histogram(df.event, bins=2)

# ╔═╡ b4a4667a-9967-11eb-313b-2797236c5733
histogram(df.nearest, bins=50)

# ╔═╡ c9b0b5b4-9967-11eb-28d5-d7d57f5e84b0


# ╔═╡ 56b05be6-9967-11eb-2edb-83e4ee1ccb4d


# ╔═╡ 524948a6-9967-11eb-05fa-0569aeed702a


# ╔═╡ 47863fdc-9967-11eb-3496-7b7fcab313d9


# ╔═╡ Cell order:
# ╠═edbb4db2-9966-11eb-0958-c1c7dba2efe0
# ╠═a404acf8-9967-11eb-16b8-b5d234bb7e94
# ╠═ae03bf08-9967-11eb-2583-a5fe4b60fec9
# ╠═b4a4667a-9967-11eb-313b-2797236c5733
# ╠═c9b0b5b4-9967-11eb-28d5-d7d57f5e84b0
# ╠═56b05be6-9967-11eb-2edb-83e4ee1ccb4d
# ╠═524948a6-9967-11eb-05fa-0569aeed702a
# ╠═47863fdc-9967-11eb-3496-7b7fcab313d9
