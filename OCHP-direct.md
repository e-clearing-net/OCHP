![Open Clearing House Protocol (OCHP)](http://www.ochp.eu/wp-content/uploads/2015/02/OCHPlogo.png)

 OCHP-direct Extension
 
 * * *



## Protocol Release Log

Prot. Version | Date       | Comment
:-------------|:-----------|:-------
0.1           | 28‑02‑2012 | Concept, Functional specification


Copyright (c) 2012-2015 smartlab, bluecorner.be, e-laad.nl

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files 
(the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, 
publish, distribute, sublicense, and/or sell copies of the Software, 
and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


 * * *

# Contents



 * * *
 


# Preface

This document defines an extension to the Open Clearing House Protocol 
(OCHP). For more information visit [ochp.eu](http://ochp.eu).


## Conventions

_This extesnsion follows the same conventions as OCHP:_

The key words *must*, *must not*, *required*, *shall*, *shall
not*, *should*, *should not*, *recommended*, *may* and
*optional* in this document are to be interpreted as described in
[https://tools.ietf.org/html/rfc2119](RFC 2119).

The cardinality is defined by the indicators _*_, *+*, *?* and
*1*, where the last one is the default. The meaning and mapping to
XML syntax is as follows:

Meaning      | XML Schema                                    | DTD
:------------|:----------------------------------------------|---
At most one  | `minOccurs="0" maxOccurs="1"`                 | ?
one or more  | `minOccurs="1" maxOccurs="unbounded"`         | +
zero or more | `minOccurs="0" maxOccurs="unbounded"`         | *
exactly one  | *(default)*                                   | 1

For some data fields a [http://en.wikipedia.org/wiki/Regular_expression](Regular Expression) is
provided as an additional but very precise definition of the data
format.

The character *>* in front of any data field indicates a choice of 
multiple possibilities.

The character *~* appended to any data field indicates the 
implementation as XML attribute instead of an element.





# Introduction


For a general introduction to the OCHP, see the introduction section in 
the [OCHP documentation](OCHP.md).



## Use Cases of OCHP direct

The overall use case for this interface is to control services like 
charging sessions in an operator's backend while handling the user 
authorisation within an (from the operator's point of view) external 
system.

The customer story can be shortened to: 

> One (provider) app for all charging stations – regardless of their operator.

This generic main use cases splits up in several sub parts. Those are:

#### Basic use cases
 * **Remote Start:** A user starts a charging process at an operator‘s 
   charge pole by using a provider‘s app. They are starting the process 
   from a – of the operator's point of view – remote service.
 * **Remote Stop:** A user stops a charging process at an operator‘s 
   charge pole by using a provider‘s app (that was remotely started).
 * **Live Info:** A user requests information about a charging process 
   at an operator’s charge pole by using a provider’s app (from which 
   the process was started).

#### Advanced use cases
 * **Charge Event:** A user gets informed by a provider’s app about 
   status changes of a charging process at an operator’s charge pole, 
   even if it wasn't started remotely.
 * **Remote Control:** A user controls a charging process at an 
   operator‘s charge pole that was not remotely started by using a 
   provider‘s app.

The __basic use cases__ require the operator to act as a server in 
order to receive information and commands from the provider. The
__advanced use cases__ require also the provider to act as a server.




## Basic Principles of OCHP direct

The OCHP direct Interface describes a set of methods to control 
charging sessions in an EVSE operator's backend. While dedicated 
methods in the clearing house's interface extend its functionality to 
provide remote services, the actually service requests are sent between 
the operator and the provider directly. In those cases the operator 
backend acts as a server, in contrast to pure clients as common for all 
other OCHP communication. The backward communication, from the operator 
system to the provider system is also possible. In that case the 
provider system will act as a SOAP server and the operator system as 
the client.

The following Figure illustrates the communication paths of OCHP direct.
The extending messages of OCHP allow the publication of backend 
specification and the discovery of roaming partner's backends.

![Figure OCHP direct Communication Overview](media/OCHPdirectCommunicationOverview.png "OCHP direct Communication Overview")



### Trust and authorisation structure

Based on the assumption that _OCHP direct_ is used in addition to a 
regular OCHP connection via a clearing house, the following trust 
structure applies. However, _OCHP direct_ may also be used in other 
combinations, where the OCHP-part of the following description is to be 
covered by alternative methods.


#### The usual situation without OCHP direct

When two roaming partners connect via OCHP and the clearing house, the 
authorisation and trust structure can be defined as follows:

 * Both roaming partners trust the clearing house
 * The operator authorises the provider to use their charging stations
   generally, by setting the roaming connection in the clearing house
 * The provider authorises and trusts the operator to authorise the
   provider's customers generally
 * The operator authorises the provider's customers at their charging
   stations for inividual charging sessions

In this situation the single authorisation is be done in the operator's 
backend _on behalf of_ the provider. The provider trusts the operator 
that all sent customer tokens are getting authorised on all charge 
points or as based on the contract between both.


#### The situation with OCHP direct

When direct authorisation requests come in place, the situation turns 
around:

 * Both roaming partners trust the clearing house
 * The operator authorises the provider to use their charging stations
   generally, by setting the roaming connection in the clearing house
 * __The operator authorises and trusts the provider to authorise their
   customers at the operator's charge points generally__
 * _The provider authorises their own customers at the charging stations 
   of the operator for inividual charging sessions_

In this new situation the operator gives the responsiblity to authorise 
charging sessions away to the provider. A operator therefore should not 
decline an remote authorisation for other than contractual or technical 
valid reasons.


#### Security of the OCHP direct interface







# Partner-to-partner interface description





## Exchange operator backend definition _Basic_



### Update own operator backend definition in the CHS




### Download updates in operator backend definitions from the CHS






## Exchange provider backend definition _Advanced_



### Update own provider backend definition in the CHS




### Download updates in provider backend definitions from the CHS






## Generate an own backend definition _Basic_








## Start and stop a charging process remotely _Basic_



### Request a remote start at an operator's charge point



### Request a remote start at an operator's charge point



### Request information about a charging process from an operator





## Inform a provider about a charging process _Advanced_



### Send charging process information of a provider's customer













# Messages












# Types









# Binding to Transport Protocol


## OCHP direct over SOAP

For this protocol the SOAP Version 1.1 MUST be used.



## OCHP direct over JSON

For this protocol JSON and JSON Schema Version 4 MUST be used.



## Partner Identification





