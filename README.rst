
Data-driven attitude control design for multirotor UAVs
=======================================================

This is the code used for my thesis. An up-to-date version of the final report is available `here <thesis>`_. In this work I applied `Virtual Reference Feedback Tuning <vrft>`_ to a multirotor UAV. The ``MATLAB`` toolbox is available `here <vrft_toolbox>`_.

In the ``Papers/`` folder you can find information on a variety of data-driven control methods. The papers on VRFT and CbT are particularly interesting especially the ``[VRFT, CbT]  Data-driven_attitude_control_law_of_a_variable-pitch_quadrotor_a_comparison_study.pdf`` paper that compares VRFT and CbT (spoiler: CbT is better for signals with a low signal to noise ratio). 

I'll now explain what all the different bits and pieces do. You'll often find links to pieces of the diary I wrote as I was working on my thesis. Don't take it as a bible, most of it is probably wrong but if you're curious it may help to explain certain choices. 

One thing to note is that, even though VRFT is a data-driven method and one of its great advantages is not having to identify the plant model before hand, nearly all of the code here uses simulations with a previously identified model. A rationale for this can be found in Chapter 3 (Simulation Results) of my thesis. In short, if a model is available, why deprive yourself of it. It can be a great tool to inform the controller synthesis process. 

Another thing to note is that as much as possible is done in continuous time. This is simply beacuse the controllers on the drone I used are implemented with a continuous time Simulink model. As such transfer functions are converted to discrete time only long enough to actually do the VRFT. The rest of the time we're working in the continuous time domain. 

``MATLAB`` Folder
^^^^^^^^^^^^^^^^^

This is where the magic happens. Make sure to run the ``startup.m`` script to load everything. This is a pretty nifty little script that recursively explores subfolders and adds them to the path if it finds matlab extensions. This could be done with a simple ``addpath(genpath('.'))`` but then you wouldn't get all the pretty printing stuff. 

The first thing you need to do is to run ``mk_quad_copter_models.m``. This will create a mat file with the data needed for the next steps. Specifically it creates all the transfer functions we need and stores them in a ``.mat`` file that we can simply load. 

If you want to see where all of these numbers come from take a peek inside ``quad_copter_model.mlx``. The actual VRFT is performed in ``inner_vrft_ct.mlx`` and ``outer_vrft_ct.mlx``. 

The ``Simulink/`` Folder contains a simple Simulink model of the VRFT and H infinity tuned controllers. 

``MATLAB/Hardware Testing/`` Folder
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is where the magic happens ! No, just kidding, this is simply were the files required for the hardware testing are stored. The testing procedure happens in 3 steps. 

1. First off: generate a controller. Run the ``inner_vrft_ct`` and  ``outer_vrft_ct`` script to generate a suitable controller and run the ``prepare_test`` script. This script will generate an ``attitude_quadrotor.cpp`` file and replace the existing one in the ``r2p-ide`` folder. If you don't know what ``r2p-ide`` is then you're probably not using the same drone and need to adapt that part of the code to yours. In anycase you will probably have to adjust the path to point to the right file. (Note: In practice you just need the ``inner_pid_params`` and ``outer_pd_params`` arrays to run the script). 
2. Now you can head over to ``r2p-ide`` and recompile the ``Proximity`` component and upload the code. 
3. Run your testing script over the serial connection. There are a handful in the folder if you're lazy: ``pitch_test.m``, ``pitch_test_long.m`` and ``pitch_test_disturbed.m``.
4. Grab the SD card from the drone and plug it into the PC. 
5. Run ``process_test_data`` to fetch the data from the SD card, parse it and put into the correct folder. Additionally this will run the  ``make_dashboard`` script to show you the results. 
   
Why this complicated you ask ? Well, I wanted to be sure which dataset came from which controllers so this pipeline keeps a copy of everything !! It creates a folder with the test name and puts into it: the controller parameters and reference models, the ``attitude_quadorotor.cpp`` file in case you need it later. When you process the test data they will also get added to the correct folder so that you have everything in the same place.

Yes, this could be simpler. The log parser is a piece of shit java app that barely works. Yes I want to rip it to pieces and replace it with something sane. How did you guess ?

The other files are simple. Go take a look. 

Lessons Learned
^^^^^^^^^^^^^^^

Live scripts look great. I really wanted a **Jupyter** like experience for ``MATLAB``. Don't use them. They're great to show off simple results but in practice they're slow. ``MATLAB`` is already pretty slow but in an ``mlx`` file it seems even more obscenely slow. Also they're binary files that don't play nice with source control. Sure ``MATLAB`` has a nifty diff tool that can show you differences ... when it works.

Just go with plain ``.m`` files. At least you'll be able to see what changed with git. 


.. _thesis: http://thibaud.chupin.me/thesis
.. _vrft: http://comkieffer.com/vrft
.. _vrft toolbox: http://marco-campi.unibs.it/VRFTwebsite/
