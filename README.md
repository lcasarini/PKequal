# PKequal

------------------------------------------------------------------------
DESCRIPTION:

PKequal is a package that implements the spectral equivalence 
described in Casarini, Macció and Bonometto (2009), and Casarini, 
Tessarotto and Corasaniti (2016), in order to provide a prediction 
of non linear matter power spectrum for varying equation of state 
models.

------------------------------------------------------------------------
INSTRUCTIONS:

You can use PKequal in 2 ways:


1 - with CAMB/COSMOMC:

1.1 - download CAMB from http://camb.info/CAMBsubmit.html or COSMOMC 
from http://cosmologist.info/cosmomc/submit.html and substitute 
halofit_ppf.f90 in the camb directory with the original one.

1.2 - compile the code, including halofit_ppf.f90 in the 
Makefile_main with the original equations_ppf.f90 as usual in CAMB.


2 - with FrankenEmu: 

2.1 - download the FrankenEmu from 
http://www.hep.anl.gov/cosmology/CosmicEmu/emu.html and compile it. 

2.2 - download and compile pkequal

2.3 - modify the lines 5 and 6 of emu_w0_wa.sh putting the paths of 
the exe files of FrankenEmu and pkequal. 

2.4 - make emu_w0_wa.sh executable:
digit 'chmod +x emu_w0_wa.sh' and use it.


------------------------------------------------------------------------
REFERENCES:

If you use PKequal please refer our papers:
 
'Dynamical Dark Energy simulations: high accuracy Power Spectra at 
high redshift' L. Casarini, A. V. Macció and S. A. Bonometto, 
arXiv:0810.0190[astro-ph.CO], JCAP 0903, 014 (2009)

'Extending the Coyote emulator to dark energy models with standard 
w_0-w_a parametrization of the equation of state' L. Casarini, S. A. 
Bonometto, E. Tessarotto and P.-S. Corasaniti, arXiv:

and in case you use the COSMOMC/CAMB and FrankEmu cite the papers 
indicated in:

http://cosmologist.info/cosmomc/http://cosmologist.info/cosmomc/

http://camb.info/readme.html

http://www.hep.anl.gov/cosmology/CosmicEmu/emu.htmlhttp://www.hep.anl.
gov/cosmology/CosmicEmu/emu.html
