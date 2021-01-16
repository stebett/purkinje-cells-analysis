import nixio as nix
import pyarrow.feather as feather
import neo
df = feather.read_feather("data/data.arrow")

"""
# How to make nix2neo work:

    1. You need positions.unit
    2. You need a neo.spiketrain multitag
    3. You need a t_stop, which I didn't manage to create so I changed the source code in nixio
    4. Do you need a group?
"""

file = nix.File.open("example.h5", nix.FileMode.Overwrite)
block = file.create_block("block", "nix.session")
block.definition = "No definition"

s1 = block.create_data_array("spiketrain 1", "nix.positions", data= df.t[0])
s1.unit = "ms"

s2 = block.create_data_array("spiketrain 2", "nix.positions", data= df.t[1])
s2.unit = "ms"

mt1= block.create_multi_tag("spiketrain tag 1", "neo.spiketrain", s1)
mt2= block.create_multi_tag("spiketrain tag 2", "neo.spiketrain", s2)

def make_source(idx):
    subject = block.create_source(df.iloc[idx].rat, "nix.experimental_subject")
    site = subject.create_source(df.iloc[idx].site, "nix.experimental_subject")
    tetrode = site.create_source(df.iloc[idx].tetrode, "nix.experimental_subject")
    neuron = tetrode.create_source(df.iloc[idx].neuron, "nix.experimental_subject")
    return neuron

multi_tag.sources.append(neuron)
multi_tag.units = "s"

group = block.create_group("segment", "neo.segment")
group.multi_tags.append(mt1)
group.multi_tags.append(mt2)


file.close()

neo_obj = neo.io.NixIO("example.h5")
neo_blk = neo_obj.read_block("block")
neo_seg = neo_blk.segments[0]

neo_obj.close()
