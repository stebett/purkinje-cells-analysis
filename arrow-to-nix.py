import nixio as nix
import pyarrow.feather as feather
import neo
df = feather.read_feather("data/data.arrow")

"""
# How to make nix2neo work:

    1. You need positions.unit
    2. You need a neo.spiketrain multitag
    3. You need a t_stop, which I didn't manage to create so I changed the source code in nixio
"""

file = nix.File.open("example.h5", nix.FileMode.Overwrite)
block = file.create_block("block 1", "nix.session")
block.definition = "yo"

positions = block.create_data_array("spiketrain", "nix.positions", data= df.t[0])
positions.unit = "ms"

multi_tag = block.create_multi_tag("spike times", "neo.spiketrain", positions)

subject = block.create_source("R16", "nix.experimental_subject")
site = subject.create_source("13", "nix.experimental_subject")
tetrode = site.create_source("tet1", "nix.experimental_subject")
neuron = tetrode.create_source("neuron1", "nix.experimental_subject")

multi_tag.sources.append(neuron)
multi_tag.units = "s"

group = block.create_group("things that belong together", "neo.segment")
group.multi_tags.append(multi_tag)


file.close()

neo_obj = neo.io.NixIO("example.h5")
neo_blk = neo_obj.read_block("block 1")
neo_seg = neo_blk.segments[0]

neo_seg

neo_obj.close()
