
Data-driven attitude control design for multirotor UAVs
=======================================================

This is the code used for my thesis. An up-to-date version of the final report is available `here <thesis>`_. In this work I applied `Virtual Reference Feedback Tuning <vrft>`_ to a multirotor UAV. The ``MATLAB`` toolbox is available `here <vrft_toolbox>`_.

In the ``Papers/`` folder you can find information on a variety of data-driven control methods. The papers on VRFT and CbT are particularly interesting especially the ``[VRFT, CbT]  Data-driven_attitude_control_law_of_a_variable-pitch_quadrotor_a_comparison_study.pdf`` paper that compares VRFT and CbT (spoiler: CbT is better for signals with a low signal to noise ratio). 

I'll now explain what all the different bits and pieces do. You'll often find links to pieces of the diary I wrote as I was working on my thesis. Don't take it as a bible, most of it is probably wrong but if you're curious it may help to explain certain choices. 

One thing to note is that, even though VRFT is a data-driven method and one of its great advantages is not having to identify the plant model before hand, nearly all of the code here uses simulations with a previously identified model. A rationale for this can be found in Chapter 3 (Simulation Results) of my thesis. In short, if a model is available, why deprive yourself of it. It can be a great tool to inform the controller synthesis process. 

Another thing to note is that as much as possible is done in continuous time. This is simply beacuse the controllers on the drone I used are implemented with a continuous time simulink model. As such transfer functions are converted to discrete time only long enough to actually do the VRFT. The rest of the time we're working in the continuous time domain. 

``MATLAB`` Folder
^^^^^^^^^^^^^^^^^

This is where the magic happens. Make sure to run the ``startup.m`` script to load everything. This is a pretty nifty little script that recursively explores subfolders and adds them to the path if it finds matlab extensions. This could be done with a simple ``addpath(genpath('.'))`` but then you wouldn't get all the pretty printing stuff. 

The first thing you need to do is to run ``mk_quad_copter_models.m``. This will create a mat file with the data needed for the next steps. Specifically it creates all the transfer functions we need and stores them in a ``.mat`` file that we can simply load. 




.. _thesis: thibaud.chupin.me/thesis
.. _vrft: comkieffer.com/vrft
.. _vrft toolbox: http://marco-campi.unibs.it/VRFTwebsite/
