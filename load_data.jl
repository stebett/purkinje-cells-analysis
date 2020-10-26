import JSON
using DataStructures

data = OrderedDict()

open("data/ordered_data.json", "r") do f
      global data
      data=JSON.parse(f)  # parse and transform data
end


# TODO implement histogram stuff

function order(data)
      data = sort!(OrderedDict(data))
      for (key1, rat) in data
            data[key1] = sort!(OrderedDict(data[key1]))
            for (key2, site) in rat
                  data[key1][key2] = sort!(OrderedDict(data[key1][key2]))
                  for (key3, tetrode) in site
                        data[key1][key2][key3] = sort!(OrderedDict(data[key1][key2][key3]))
                        # for (key4, neuron in tetrode)
                        #       data[key1][key2][key3][key4] = sort!(OrderedDict(data[key1][key2][key3][key4]))
                        # end
                  end
            end
      end
      data
end

function extract(attr::String)
      X = Array{Array{Float64,1}, 1}()
      for (key1, rat) in data
            for (key2, site) in rat
                  for (key3, tetrode) in site
                        for (key4, neuron) in tetrode
                              x = neuron[attr]
                              x[isnothing.(x)] .= -1
                              x[isnan.(x)] .= -1
                              push!(X, Array{Float64,1}(x))
                              # push!(x, isnothing(neuron[attr][1]) ||  ? Float64[] : Array{Float64,1}(neuron[attr]))
                        end
                  end
            end
      end
      X
end
