# Analysis done
- PSTH 
	-> modulation of firing rates
- Time course correlations 
	-> Barely significant difference between neigh and dist
- Covariance of instantaneous firing rates 
	-> significant difference between neigh and dist at all landmarks **in firing rates**
- cross-correlograms 
	-> short-time correlation of individual spike times
- spline fitting 
	-> significance in co-modulation of spike times
- spline complex model analysis
	-> importance of neighbor cells spike times to predict neuron activity
- cross-correlograms on artificial data 
	-> neighbor cells fire in near synchrony with <5ms delays
- cross-correlograms on sleep and free exploration data 
	-> coordinated firing is not state-dependent **but** it is stronger during task-modulated activity
- coherence spectra of lfp 
	-> fast oscillations are related to coordinated firing in neighbor cells
- correlation between complex spikes
	-> neighbor cells belonging to same microzone
- fluorecence microscopy 
	-> convergence of neighboring cells in a small area (so?)


# Open questions
- Individual units within a microzone encode related but distinct elements of the movements, probably in population activity
	- Can we test this hypothesis?
	- Can we extract other elements of the movements? (e.g. acceleration, direction, movement distance)
	- Would it make sense to look for preferred values of those features of a neuron, at least to discard linear relations? 
	- To prove that movement features are encoded through population activity, do we have enough data?
	- If so, what analysis could we perform to prove a relation?

- Purkinje cells produce transient events of inhibition of their postsynaptic targets
	- This is proved by the cross-correlogram, but there is correlation also during sleep and exploration
	- Can we show that the count of near-synchronyzed spikes is related to some feature of the movement? 

- Motor activity (or overall activity?) could attenuate field oscillations

- Recurrent inhibition between parallel fibers and purkinje cells could produce fast oscillations 
	- Model this?

# Redo
- Can we start from the data we have, or should we redo spike sorting?
- cross-correlograms for distant|neighbor and similar|dissimilar firing rate course
- Spline fitting, also doing it for fast vs slow groups trials?
- All complex spikes in a tetrode are correlated? Are there correlations between tetrodes, or absence of correlation within a tetrode? If so, does this influence coordinated activity?


# Papers
### Modeling 
1. Marr, D. (1969). A theory of cerebellar cortex. J. Physiol. 202, 
2. Albus, J.S. (1971) A theory of cerebellar function Math. Biosci. 10,
3. Ito, M. (1984) The Cerebellum and Neural Control, Raven Press
Ohyama, T., Nores, W.L., Murphy, M., and Mauk, M.D. (2003). What the cerebellum computes. Trends Neurosci. 26, 222–227.

### Inverse model hypothesis
4. Kawato, M., Furawaka, K. and Suzuki, R. (1987) A hierarchical neural
network model for the control and learning of voluntary movements
Biol. Cybern.

### Damage
5. Holmes, G. (1917). The symptoms of acute cerebellar injuries due to gunshot injuries. Brain 40, 461–535.
6. Bonnefoi-Kyriacou, B., Legallet, E., Lee, R.G., and Trouche, E. (1998). Spatiotemporal and kinematic analysis of pointing movements performed by cerebellar patients with limb ataxia. Exp. Brain Res.

### Stimulation
7. Monze´ e, J., Drew, T., and Smith, A.M. (2004). Effects of muscimol inactivation of the cerebellar nuclei on precision grip. J. Neurophysiol. 91, 1240–1249.  Noda, H., Murakami, S., Yamada, J., Tamada, J., Tamaki, Y., and Aso, T.
8. Ekerot, C.F., Jo¨ rntell, H., and Garwicz, M. (1995). Functional relation between corticonuclear input and movements evoked on microstimulation in cerebellar nucleus interpositus anterior in the cat. Exp. Brain Res. 106, 365–376.

### Activity 
9. Hoogland, T.M., De Gruijl, J.R., Witter, L., Canto, C.B., and De Zeeuw, C.I.  (2015). Role of synchronous activation of cerebellar Purkinje cell ensembles in multi-joint movement control. Curr. Biol. 25, 1157–1165.

##### Mid cerebellum
10. Chen, S., Augustine, G.J., and Chadderton, P. (2016). The cerebellum linearly encodes whisker position during voluntary movement. eLife 5, e10509.

##### Cortex
11. Marr, David, and W. Thomas Thach. "A theory of cerebellar cortex." From the Retina to the Neocortex. Birkhäuser Boston, 1991. 11-50.

### Anatomy
12. Low, A.Y.T., Thanawalla, A.R., Yip, A.K.K., Kim, J., Wong, K.L.L., Tantra, M., Augustine, G.J., and Chen, A.I. (2018). Precision of discrete and rhythmic fore- limb movements requires a distinct neuronal subpopulation in the interposed anterior nucleus. Cell Rep. 22, 2322–2333.

13. Palay, Sanford L., and Victoria Chan-Palay. Cerebellar cortex: cytology and organization. Springer Science & Business Media, 2012.


