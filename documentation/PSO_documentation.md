# Documentation for the PSO Implementation

This document gives a brief overview of the use-cases for the PSO role in the OCHP ecosystem.

## PSO Use Cases

The main functionality of the PSO is to provide live information about parking spot availability.
The PSO offers multiple services to the Operator as well as the EV Driver and NSP. They offer access to a parking spot associated with an EVSE to the EV driver and sometimes the location for the EVSE to the EVSE-Op. Furthermore, they may operate services that allow detailed tracking of the occupation of single parking spots, thus enhancing Operator-data sent to an NSP.




## PSO Method
The following method is part of the PSO implementation to be used by the PSO.
Typically, an PSO implementation consists of these methods, as well as the ability 
- [UpdateStatus.req](/documentation/NewDocumentation.md/#updatestatusreq)
