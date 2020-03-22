# Documentation for the EMP Implementation

This document gives a brief overview of the use-cases for the EMP role in the OCHP ecosystem.

## EMP Use Cases

The main functionalities for the EMP are: Publishing token information and receiving Charge Detail Records and Tariff information.

Please note that many EMPs also fill out the "Navigation Service Provider" Role, which receives POI-Data on Chargers, both static and live.



## EMP Methods
The following methods are part of the EMP implementation to be used by the EMP.
Typically, an EMP implementation consists of these methods, as well as the ability 
- [SetRoamingAuthorisationList.req](#setroamingauthorisationlistreq)
- [UpdateRoamingAuthorisationList.req](#updateroamingauthorisationlistreq)
- [GetCDRs.req](#getcdrsreq)
- [GetTariffs.req](#gettariffsreq)
- [GetTariffUpdates.req](#gettariffupdatesreq)
