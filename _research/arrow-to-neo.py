import pyarrow.feather as feather
import neo
df = feather.read_feather("data/fixed-landmarks.arrow")

"""
1 segment x rat
1 group per site
1 group per tetrode
1 spiketrain x neuron

"""

block = neo.Block()
for row in df.iterrows():
    spiketrain = neo.SpikeTrain(row[1].t, row[1].t[-1], "ms")
    grasps = neo.Event(row[1].grasp, units="ms", name="grasp")
    covers = neo.Event(row[1].cover, units="ms", name="cover")
    lifts = neo.Event(row[1].lift, units="ms", name="lift")

    seg = neo.Segment()
    seg.spiketrains.append(spiketrain)

    seg.events.append(grasps)
    seg.events.append(covers)
    seg.events.append(lifts)

    block.segments.append(seg)

i = 0
for rat in df['rat'].unique():
    rat_group = neo.Group(name=rat)

    for site in df[df.rat == rat]['site'].unique():
        site_group = neo.Group(name=site)

        for tetrode in df[(df.rat == rat) & (df.site == site)]['tetrode'].unique():
            tetrode_group = neo.Group(name=tetrode)

            for neuron in df[(df.rat == rat) & (df.site == site) & (df.tetrode == tetrode)]['neuron'].unique():
                tetrode_group.spiketrains.append(block.segments[i].spiketrains[0])
                tetrode_group.events.append(block.segments[i].events[0])
                tetrode_group.events.append(block.segments[i].events[1])
                tetrode_group.events.append(block.segments[i].events[2])
                i+=1

            site_group.groups.append(tetrode_group)

        rat_group.groups.append(site_group)

    block.groups.append(rat_group)

import pyarrow.feather as feather
import neo
df = feather.read_feather("data/fixed-landmarks.arrow")

"""
1 segment x rat
1 group per site
1 group per tetrode
1 spiketrain x neuron

"""

block = neo.Block()
for row in df.iterrows():
    spiketrain = neo.SpikeTrain(row[1].t, row[1].t[-1], "ms")
    grasps = neo.Event(row[1].grasp, units="ms", name="grasp")
    covers = neo.Event(row[1].cover, units="ms", name="cover")
    lifts = neo.Event(row[1].lift, units="ms", name="lift")

    seg = neo.Segment()
    seg.spiketrains.append(spiketrain)

    seg.events.append(grasps)
    seg.events.append(covers)
    seg.events.append(lifts)

    block.segments.append(seg)

i = 0
for rat in df['rat'].unique():
    rat_group = neo.Group(name=rat)

    for site in df[df.rat == rat]['site'].unique():
        site_group = neo.Group(name=site)

        for tetrode in df[(df.rat == rat) & (df.site == site)]['tetrode'].unique():
            tetrode_group = neo.Group(name=tetrode)

            for neuron in df[(df.rat == rat) & (df.site == site) & (df.tetrode == tetrode)]['neuron'].unique():
                tetrode_group.spiketrains.append(block.segments[i].spiketrains[0])
                tetrode_group.events.append(block.segments[i].events[0])
                tetrode_group.events.append(block.segments[i].events[1])
                tetrode_group.events.append(block.segments[i].events[2])
                i+=1

            site_group.groups.append(tetrode_group)

        rat_group.groups.append(site_group)

    block.groups.append(rat_group)


writer = neo.io.NixIO("prova.h5")
