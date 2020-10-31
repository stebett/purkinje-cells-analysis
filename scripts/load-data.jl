using DrWatson
@quickactivate "ens"

import JSON
using DataStructures

struct Data
      dict::OrderedDict
      t::Array{Array{Float64, 1}, 1}
      l::Array{Array{Float64, 1}, 1}
      c::Array{Array{Float64, 1}, 1}
      g::Array{Array{Float64, 1}, 1}

      function Data()
            dict = OrderedDict()

            io = open(datadir("data.json"), "r")
            dict = JSON.parse(io)
            close(io)

            dict = order(dict)

            t = extract("t", dict)
            l = extract("lift", dict)
            c = extract("cover", dict)
            g = extract("grasp", dict)
            
            new(dict, t, l, c, g)
      end
end

function order(data)
      data = sort!(OrderedDict(data))
      for (key1, rat) in data
            data[key1] = sort!(OrderedDict(data[key1]))
            for (key2, site) in rat
                  data[key1][key2] = sort!(OrderedDict(data[key1][key2]))
                  for (key3, tetrode) in site
                        data[key1][key2][key3] = sort!(OrderedDict(data[key1][key2][key3]))
                  end
            end
      end
      data
end

function extract(attr::String, data::OrderedDict=data)
      X = Array{Array{Float64,1}, 1}()
      for (key1, rat) in data
            for (key2, site) in rat
                  for (key3, tetrode) in site
                        for (key4, neuron) in tetrode
                              x = neuron[attr]
                              x[isnothing.(x)] .= -1
                              x[isnan.(x)] .= -1
                              push!(X, Array{Float64,1}(x))
                        end
                  end
            end
      end
      X
end

function retrive(d::Data, idx::Int)
      i = 0
      for (key1, rat) in d.dict
            for (key2, site) in rat
                  for (key3, tetrode) in site
                        for (key4, neuron) in tetrode
                              i += 1
                              if i == idx
                                    return key1, key2, key3, key4
                              end
                        end
                  end
            end
      end
end

data=Data()