# Linear projection-based CEST reconstruction

Demo codes for linear projection-based CEST reconstruction and L1-regularization-based feature selection ('CEST-LASSO').
Uses FISTA as submodule for solving LASSO problems, so use git clone --recursive

* <b>linearCEST_demo1_pinv.m</b>: Demo of fitting linear regression coefficients to a training dataset that directly map from raw, uncorrected Z-spectra to target contrast parameters of interest, which are here conventionally fitted Lorentzian parameters describing APT, NOE, MT and amine effects. Only uses Matlab's native pinv function.
* <b>linearCEST_demo2_LASSO.m</b>: Example for L1-regularization-based feature selection ('CEST-LASSO') for the linear CEST reconstruction method. The regularization enforces sparsity of Z-spectral offsets, such that a potential acceleration of CEST measurements by acquiring less offsets can be achieved. Uses the external FISTA repo for solving LASSO objectives.

Demo data can be downloaded from [here](https://edmond.mpdl.mpg.de/imeji/collection/dF8GJ92tyBNpfeY?q=).

***
Felix Glang<sup>1*</sup>, Moritz S. Fabian<sup>2</sup>, Alexander German<sup>2</sup>, Katrin M. Khakzar<sup>2</sup>, Angelika Mennecke<sup>2</sup>, Andrzej Liebert<sup>3</sup>, Kai Herz<sup>1,4</sup>, Patrick Liebig<sup>5</sup>, Burkhard S. Kasper<sup>6</sup>, Manuel Schmidt<sup>2</sup>, Armin M. Nagel<sup>3</sup>, Frederik B. Laun<sup>3</sup>, Arnd Dörfler<sup>2</sup>, Klaus Scheffler<sup>1,3</sup>, Moritz Zaiss<sup>1,2</sup>

<i><sup>1</sup>Magnetic Resonance Center, Max Planck Institute for Biological Cybernetics, Tübingen, Germany  
<sup>2</sup>Department of Neuroradiology, University Hospital Erlangen, Erlangen, Germany  
<sup>3</sup>Institute of Radiology, University Hospital Erlangen, Friedrich-Alexander-Universität Erlangen-Nürnberg (FAU), Germany  
<sup>4</sup>Department of Biomedical Magnetic Resonance, Eberhard Karls University Tübingen, Tübingen, Germany  
<sup>5</sup>Siemens Healthcare GmbH, Erlangen, Germany  
<sup>6</sup>Department of Neurology, University Clinic of Friedrich Alexander University Erlangen-Nürnberg, Erlangen, Germany  
</i>

<b>Correspondence:</b>  
Felix Glang  
Magnetic Resonance Center  
Max Planck Institute for Biological Cybernetics  
Tübingen, Germany  
felix.glang@tuebingen.mpg.de  

