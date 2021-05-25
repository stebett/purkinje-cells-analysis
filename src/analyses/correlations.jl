using DrWatson
@quickactivate :ens

function searchsortednearest(a,x)
	idx = searchsortedfirst(a,x)
	if (idx==1); return idx; end
	if (idx>length(a)); return length(a); end
	if (a[idx]==x); return idx; end
	if (abs(a[idx]-x) < abs(a[idx-1]-x))
		return idx
	else
		return idx-1
	end
end

struct TimeCourseGroup
	landmark::Symbol
	group::Symbol
	around::Vector
end

struct TimeCourseGroupMean
	landmark::Symbol
	group::Symbol
	around::Vector
end

struct Correlation
	around::Vector
end

TimeCourseGroup(d::Dict) = TimeCourseGroup(d[:landmark], d[:group], [d[:around]...])


# Wilcox test for signifcancy

function compute(A::TimeCourseGroup, data)
	group = couple(data, A.group)
	couples = find.(Ref(data), group)

	tc1 = Vector{Float64}[]
	tc2 = Vector{Float64}[]
	for c in couples
		cuts1 = cut(c[1, :t], c[1, A.landmark], A.around)
		cuts2 = cut(c[2, :t], c[2, A.landmark], A.around)

		bins1 = bin.(cuts1, diff(A.around)[1])
		bins2 = bin.(cuts2, diff(A.around)[1])

		conv1 = convolve(bins1, 10)
		conv2 = convolve(bins2, 10)

		push!(tc1, conv1...)
		push!(tc2, conv2...)
	end
	tc1, tc2
end

function compute(A::TimeCourseGroupMean, data)
	group = couple(data, A.group)
	couples = find.(Ref(data), group)

	r = Float64[]
	for c in couples
		cuts1 = cut(c[1, :t], c[1, A.landmark], A.around)
		cuts2 = cut(c[2, :t], c[2, A.landmark], A.around)

		bins1 = bin.(cuts1, diff(A.around)[1])
		bins2 = bin.(cuts2, diff(A.around)[1])

		conv1 = convolve(bins1, 10)
		conv2 = convolve(bins2, 10)

		push!(r, mean(cor.(conv1, conv2)))
	end
	r
end

function compute(A::Correlation, data)
	c = Dict(
			 :landmark => [:lift, :cover, :grasp],
			 :group => [:n, :d],
			 :around => Tuple(A.around),
			 )

	d = TimeCourseGroup.(dict_list(c))
	tc = compute.(d, Ref(data))
	[cor.(x[1], x[2]) for x in tc]
end

function visualise!(A::Correlation, fig::Figure, x::Vector, p)
	ax = Axis(fig, title="Average time course of firing rate")

	xval = [1, 2, 4, 5, 7, 8]
	yval = [mean(drop(i)) for i in x]
	err = [sem(drop(i)) for i in x]

	errorbars!(ax, xval, yval, err)
	bars = barplot!(ax, xval, yval,
			dodge = [1, 2, 1, 2, 1, 2],
			color = [p.col_pos, p.col_neg, p.col_pos, p.col_neg, p.col_pos, p.col_neg], 
			labels = ["Neighbors", "Distant"])


	ax.xticks = ([1.5, 4.5, 7.5], ["lift", "cover", "grasp"])
	ax.xlabel = "Landmark"
	ax.ylabel = "Correlation coefficient"

	ax
end

function visualise!(A::TimeCourseGroup, fig::Figure, y::Tuple, p)
	ax1 = Axis(fig)
	ax2 = Axis(fig)
	ax3 = Axis(fig)
	ax4 = Axis(fig)
	ax5 = Axis(fig)
	ax6 = Axis(fig)

	x = A.around[1] : A.around[2]-1
	c = cor.(y[1], y[2])

	medi1 = searchsortednearest(c, 0.3)
	c[medi1] = -1
	medi2 = searchsortednearest(c, 0.3)
	mini1 = searchsortednearest(c, 0)
	c[mini1] = -1
	mini2 = searchsortednearest(c, 0)
	c[isnan.(c)] .= 0
	maxi1 = argmax(c)
	c[maxi1] = -1
	maxi2 = argmax(c)

	lines!(ax1, x, y[1][maxi1]; color = p.col_pos, label="Cell 1", linewidth=p[:linewidth])
	lines!(ax2, x, y[1][medi1]; color = p.col_pos, linewidth=p[:linewidth])
	lines!(ax3, x, y[1][mini1]; color = p.col_pos, linewidth=p[:linewidth])
	lines!(ax4, x, y[1][maxi2]; color = p.col_pos, linewidth=p[:linewidth])
	lines!(ax5, x, y[1][medi2]; color = p.col_pos, linewidth=p[:linewidth])
	lines!(ax6, x, y[1][mini2]; color = p.col_pos, linewidth=p[:linewidth])

	lines!(ax1, x, y[2][maxi1]; color = p.col_neg, label = "Cell 2", linewidth=p[:linewidth])
	lines!(ax2, x, y[2][medi1]; color = p.col_neg, linewidth=p[:linewidth])
	lines!(ax3, x, y[2][mini1]; color = p.col_neg, linewidth=p[:linewidth])
	lines!(ax4, x, y[2][maxi2]; color = p.col_neg, linewidth=p[:linewidth])
	lines!(ax5, x, y[2][medi2]; color = p.col_neg, linewidth=p[:linewidth])
	lines!(ax6, x, y[2][mini2]; color = p.col_neg, linewidth=p[:linewidth])

	axislegend(ax1)

	ax1.xticks = []
	ax2.xticks = []
	ax4.xticks = []
	ax5.xticks = []

	ax1.yticks = []
	ax3.yticks = []
	ax4.yticks = []
	ax5.yticks = []
	ax6.yticks = []

	ax1, ax2, ax3, ax4, ax5, ax6
end


