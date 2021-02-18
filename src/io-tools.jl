using DrWatson
@quickactivate "ens"

import Plots.savefig
export savefig

function savefig(fn::AbstractString, source::AbstractString)
	fn = abspath(expanduser(fn))
    # get the extension
    _, ext = splitext(fn)
    ext = chop(ext, head = 1, tail = 0)
    if isempty(ext)
        ext = "png"
    end

	fn = "$fn.$ext"
	savefig(fn)
	@show fn
	d = Dict()
	t = tag!(d)["gitcommit"]
	run(`exiftool -model=$t $fn`)
	run(`exiftool -source=$source $fn`)
end


