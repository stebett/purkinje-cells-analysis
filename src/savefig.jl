import Plots.savefig
using DrWatson 

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
	_ = run(`exiftool -model=$t $fn`)
	_ = run(`exiftool -source=$source $fn`)
	nothing
end
