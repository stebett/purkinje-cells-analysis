using Printf

# TODO check if times is measured in ms

function allineate(times::T, landmarks::T, outline=20)  where {T<:Array{Array{Float64, 1}, 1}}
      new_times = []
      for i in 1:size(times, 1)
            for l in landmarks[i]
                  x = @views times[i][l - outline .< times[i] .< l + outline] .- l
                  push!(new_times,  x )
            end
      end
      Array{Array{Float64, 1}, 1}(new_times)
end

function allineate(times::T, landmarks::T, next_landmarks::T)  where {T<:Array{Array{Float64, 1}, 1}}
      new_times = []

      distances = []

      for (l, nl) in zip(landmarks, next_landmarks)
            if length(l) != length(nl)
                  continue
            end
            push!(distances, abs.(nl .- l)...)
      end

      distances = distances[.!isnan.(distances)]
      distances = distances[distances .!= 0.]
      outline = minimum(distances)
      @printf "Outline set to %s" outline

      for i in 1:size(times, 1)
            for l in landmarks[i]
                  x = @views times[i][l - outline .< times[i] .< l + outline] .- l
                  push!(new_times,  x )
            end
      end
      Array{Array{Float64, 1}, 1}(new_times)
end

function allineate(times::T, landmarks::T, landmarks_before::T, next_landmarks::T) where {T<:Array{Array{Float64, 1}, 1}}
      new_times =[]

      distances = []
      for (l, nl, lb) in zip(landmarks, next_landmarks, landmarks_before)
            if length(l) != length(nl) || length(l) != length(lb)
                  continue
            end
            push!(distances, abs.(nl .- l)...) # what if n is different?
            push!(distances, abs.(l .- lb)...) # what if n is different?
      end

      distances = distances[.!isnan.(distances)]
      distances = distances[distances .!= 0.]
      outline = minimum(distances)
      @printf "Outline set to %.0f\n" outline

      for i in 1:size(times, 1)
            for l in landmarks[i]
                  x = @views times[i][l - outline .< times[i] .< l + outline] .- l
                  push!(new_times, x)
            end
      end
      Array{Array{Float64, 1}, 1}(new_times)
end

function discretize(spiketrains, time, binsize)
      discrete = zeros(size(spiketrains, 1), time÷binsize)

      @inbounds for (i, s) in enumerate(spiketrains)
            @inbounds for (k, bin) in enumerate(-time÷2:binsize:time÷2-1)
                  discrete[i, k] = length(s[bin .< s .< bin + binsize])/binsize
            end
      end
      discrete
end
