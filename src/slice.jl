using DrWatson
@quickactivate "ens"


function cutter(spiketrain::Array{Float64,1}, landmark::Number, around::AbstractVector)::Array{Float64, 1}
    idxs = spiketrain[landmark + around[1] .< spiketrain .< landmark + around[2]]
	return idxs .- landmark .- around[1]
end


function slice_(spiketrain::Array{Float64,1}, landmark::Number, around::AbstractVector, binsize=1.)::Array{Float64, 1}
	s = zeros(round(Int, diff(around)[1]/binsize))

    idxs = spiketrain[landmark + around[1] .< spiketrain .< landmark + around[2]]
	idxs = idxs .- landmark .- around[1] 
    s[ceil.(Int, idxs ./ binsize)] .= 1
    s
end

function bigSlice(spiketrain::Array{T, 1}, lift::T, cover::T, grasp::T, nbins, around)::Array{T, 1} where {T <: Float64}
	reachBin = (cover - lift) / nbins
	graspBin = (grasp - cover) / nbins
	aroundBin = 50. / nbins

	binsizes = [fill(aroundBin, nbins*around)..., fill(reachBin, nbins)..., fill(graspBin, nbins)..., fill(aroundBin, nbins*around)...]

	t0 = lift - nbins*around*aroundBin
	t1 = grasp + nbins*around*aroundBin

	s = spiketrain[t0 .<= spiketrain .<= t1]
	sbin = zeros(2nbins + 2around*nbins)

	if length(s) == 0
		return sbin
	end
	s .= s .- t0

	t = 0
	for i in 1:length(sbin)
		sbin[i] = sum(0 .<= s.-t .< binsizes[i]) / binsizes[i]
		t += binsizes[i]
	end
	sbin
end

