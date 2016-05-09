
Cascade VRFT
============

An extension of the `VRFT`_ method handles nested control systems. It is still a one-shot method and does not require multiple experiments. 

.. figure:: {filename}/static/pages/about-cascade-vrft/vrft_cascade_block_diagram.png
    :align: center
    :alt: The block Diagram for a cascade control system with VRFT

    Block Diagram of a generic cascade control system showing the inner and outer reference models.

    Note that the outputs of the plant and the reference models are identical.

The method assumes that the input and output of the system of the system have been measured. More specifically: 

* :math:`u(t)`, the input to the *inner* part of the plant
* :math:`y_i(t)`, the output of the *outer* part of the plant which is also the input of the *outer* part of the plant
* :math:`y_o(t)`, the output of the *outer* part of the plant
  
We also need a reference model for the inner loop (:math:`M_{Ri}(z)`) and for the outer loop (:math:`M_{Ro}(z)`) and controller classes :math:`C_i(z; \theta_i)` and :math:`C_o(z; \theta_o)` for the inner and outer controllers.

We can apply VRFT on the inner control loop easily since the input and output of the *inner* plant are known. This gives us the optimal inner controller :math:`C_i(z)`. 

To apply VRFT on the outer loop we need to know the input and output of the *outer* part of the plant however the plant we are considering now is not just :math:`P_o` but entire block from :math:`r_i` to :math:`y_o` the input of which is :math:`r_i`, an unknown signal. This is the signal that would be required such that: 

.. math::

    y_o(t) = \left( \frac{C_i P_i}{1 + C_i P_i} \cdot P_o \right) r_i(t)

However we have enough information to able to calculate it. We know that the error signal is:

.. math::

    \begin{aligned}
        e_i(t) &= r_i(t) - y_i(t) \\
               &= C_i^{-1} u(t)
    \end{aligned}

This allows us to write that: 

.. math::

    r_i(t) = e_i(t) + y_i(t) = C_i^{-1}(z) \ u(t) + y_i(t) 

The calculation for :math:`e_i(t)` is only allowed if :math:`C_i` is minimum phase (has all its poles and zeros inside the unit circle) otherwise we must choose a different reference model such that :math:`C_i` is minimum phase.

From here we can apply the usual VRFT method on the outer loop as well. 

Note that we were able to calculate the *inner* and *outer* controllers with just one set of data. 

.. _VRFT: {filename}about-vrft.rst
