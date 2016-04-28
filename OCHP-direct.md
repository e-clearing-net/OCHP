![Open Clearing House Protocol (OCHP)](http://www.ochp.eu/wp-content/uploads/2015/02/OCHPlogo.png)

 OCHP-direct Extension
 
 * * *



## Protocol Release Log

Prot. Version | Date       | Comment
:-------------|:-----------|:-------
0.1           | 27‑03‑2015 | Concept, Functional specification. Commit: [77cccd838db692ab6f8b77fb4be8e81d59ec04e2](../../commit/77cccd838db692ab6f8b77fb4be8e81d59ec04e2)
0.2			  | 		   | 


Copyright (c) 2015 smartlab, bluecorner.be, e-laad.nl

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

- [Preface](#preface)
    - [Conventions](#conventions)
- [Introduction](#introduction)
    - [Use Cases of OCHP direct](#use-cases-of-ochp-direct)
            - [Basic use cases](#basic-use-cases)
            - [Advanced use cases](#advanced-use-cases)
    - [Basic Principles of OCHP direct](#basic-principles-of-ochp-direct)
        - [Trust and authorisation structure](#trust-and-authorisation-structure)
            - [The usual situation without OCHP direct](#the-usual-situation-without-ochp-direct)
            - [The situation with OCHP direct](#the-situation-with-ochp-direct)
            - [Security of the OCHP direct interface](#security-of-the-ochp-direct-interface)
            - [Identification token distribution](#identification-token-distribution)
- [Partner-to-CHS interface description (Extension to OCHP)](#partner-to-chs-interface-description-extension-to-ochp)
    - [Exchange of interface definition _Basic_](#exchange-of-interface-definition-basic)
        - [Set own interface definition in the CHS](#set-own-interface-definition-in-the-chs)
        - [Get roaming partners interface definitions from the CHS](#get-roaming-partners-interface-definitions-from-the-chs)
- [Partner-to-partner interface description (_OCHP direct_ interface)](#partner-to-partner-interface-description-ochp-direct-interface)
    - [Get status information of charge points _Basic_](#get-status-information-of-charge-points-basic)
        - [Request current live status from an Operator](#request-current-live-status-from-an-operator)
        - [Report a data or compatibility discrepancy to an Operator](#report-a-data-or-compatibility-discrepancy-to-an-operator)
    - [Start, stop and control a charging process remotely _Basic_](#start-stop-and-control-a-charging-process-remotely-basic)
        - [Select a charge point of an operator](#select-a-charge-point-of-an-operator)
        - [Control a selected charge point in an operator's backend](#control-a-selected-charge-point-in-an-operators-backend)
        - [Release a selected charge point in an operator's backend](#release-a-selected-charge-point-in-an-operators-backend)
    - [Inform a provider about a charging process _Advanced_](#inform-a-provider-about-a-charging-process-advanced)
        - [Send charging process information of a provider's customer](#send-charging-process-information-of-a-providers-customer)
- [Messages](#messages)
    - [Messages for the exchange of interface definitions](#messages-for-the-exchange-of-interface-definitions)
        - [AddServiceEndpoints.req](#addserviceendpointsreq)
        - [AddServiceEndpoints.conf](#addserviceendpointsconf)
        - [GetServiceEndpoints.req](#getserviceendpointsreq)
        - [GetServiceEndpoints.conf](#getserviceendpointsconf)
    - [Messages for the _OCHP direct_ interface](#messages-for-the-ochp-direct-interface)
        - [DirectEvseStatus.req](#directevsestatusreq)
        - [ReportDiscrepancy.req](#reportdiscrepancyreq)
        - [ReportDiscrepancy.conf](#reportdiscrepancyconf)
        - [SelectEvse.req](#selectevsereq)
        - [SelectEvse.conf](#selectevseconf)
        - [ControlEvse.req](#controlevsereq)
        - [ControlEvse.conf](#controlevseconf)
        - [ReleaseEvse.req](#releaseevsereq)
        - [ReleaseEvse.conf](#releaseevseconf)
        - [InformProvider.req](#informproviderreq)
        - [InformProvider.conf](#informproviderconf)
- [Types](#types)
    - [Types that extend the OCHP interface _Basic_](#types-that-extend-the-ochp-interface-basic)
        - [DirectEndpoint *class*](#directendpoint-class)
        - [ProviderEndpoint *class*](#providerendpoint-class)
        - [OperatorEndpoint *class*](#operatorendpoint-class)
        - [ContractPattern *class*](#contractpattern-class)
        - [EvsePattern *class*](#evsepattern-class)
    - [Types for the _OCHP direct_ interface](#types-for-the-ochp-direct-interface)
        - [DirectResult *enum*](#directresult-enum)
        - [DirectResultCodeType *enum*](#directresultcodetype-enum)
        - [DirectId *class*](#directid-class)
        - [DirectOperation *enum*](#directoperation-enum)
        - [DirectMessage *enum*](#directmessage-enum)
- [Binding to Transport Protocol](#binding-to-transport-protocol)
    - [OCHP direct over SOAP](#ochp-direct-over-soap)
    - [Partner Identification](#partner-identification)
- [Combining OCHP_direct_ with OCHP](#combining-ochpdirect-with-classic-ochp)


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

For some data fields a [http://en.wikipedia.org/wiki/Regular_expression](http://en.wikipedia.org/wiki/Regular_expression) is
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

 * **Remote Start:** A user starts a charging process at an operator‘s 
   charge pole by using a provider‘s app. They are starting the process 
   from a – of the operator's point of view – remote service.
 * **Remote Stop:** A user stops a charging process at an operator‘s 
   charge pole by using a provider‘s app (that was remotely started).
 * **Live Info:** A user requests information about a charging process 
   at an operator's charge pole by using a provider's app (from which 
   the process was started).
 * **Charge Event:** A user gets informed by a provider's app about 
   status changes of a charging process at an operator's charge pole, 
   even if it wasn't started remotely.
 * **Remote Control:** A user controls a charging process at an 
   operator‘s charge pole that was not remotely started by using a 
   provider‘s app.
 * **Remote Action:** A user triggers advanced and not charging process 
   related actions at a charge point or charging station of an operator.

While all remote actions (start, stop, remote control) require the operator
to act as a server to receive information and commands from the provider,
the remaining use cases (charge event, live info) require the provider to
act as a server as well.




## Basic Principles of OCHP direct

The OCHP direct Interface describes a set of methods to control 
charging sessions in an EVSE operator's backend. While dedicated 
methods in the clearing house's interface extend its functionality to 
provide remote services, the actual service requests are sent between 
the operator and the provider directly. In those cases the operator 
backend acts as a server, in contrast to pure clients as common for all 
other OCHP communication. The reverse communication, from the operator 
system to the provider system is also possible. In that case the 
provider system will act as a SOAP server and the operator system as 
the client.

The following Figure illustrates the communication paths of OCHP direct.
The extending messages of OCHP allow the publication of backend 
specification and the discovery of roaming partner's backends.

![Figure OCHP direct Communication Overview](media/OCHPdirectCommunicationOverview.png "OCHP direct Communication Overview")

The backend specification is send and updated regularly. It contains 
all properties that describe the roaming partner's backend:

 * The URL of the backend's OCHP direct endpoint(s).
 * The security token of the backend. (See chapter [Security of the OCHP direct interface](#security-of-the-ochp-direct-interface) 
   for more information.)
 * All business objects that are operated by this backend, represented 
   by blacklists and/or whitelists.

This data can be mapped onto a data structure as illustrated in the 
following figure *OCHP direct ER Model*. The depictured data structure 
allows for dynamic updates of endpoints and partner-tokens, which is 
necessary to guarantee an uninterrupted service.

Remarkable about the data model is the absence of a backend entity. 
All related entities are bound to the roaming partner (operator or 
provider), identified by their IDs. Thus, each roaming partner is free 
to operate their services on one or multiple backend systems or even 
share one backend system with another roaming partner. This should 
cover all possible market situations. 

![Figure OCHP direct ER Model](media/OCHPdirectErModel.png "OCHP direct ER Model")



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
   in general, by setting the roaming connection in the clearing house
 * __The operator authorises and trusts the provider to authorise their
   customers at the operator's charge points__
 * _The provider authorises their own customers at the charging stations 
   of the operator for inividual charging sessions_
 * This is based on the assumption that the provider in turn, will 
   compensate the operator for all charging processes started this way.

In this new situation the operator gives the responsiblity to authorise 
charging sessions away to the provider. An operator therefore should not 
decline a remote authorisation for other than contractual or technically 
valid reasons. Essentially, the situation is the same with a whitelist
exchange of RFID tokens - the operator trusts the provider to only send
those tokens to the Clearing House that are authorised to access the 
charging infrastructure. Here, those trusted tokens / contracts get sent
via OCHPdirect instead of through the CHS whitelist.


#### Security of the OCHP direct interface

Each roaming partner who makes use of OCHP direct needs provide a SOAP 
server with a publicly accessible interface. It is obvious that they must
secure those interfaces to:
 * restrict usage only to their current roaming partners and
 * secure the transmitted data.

This applies to both the operator and the provider.

Therefore the interfaces must be protected on HTTP transport layer 
level, using SSL and Basic Authentication. Please note that this 
mechanism does **not** require client side certificates for 
authentication, only server side certificates in order to provide a 
secure SSL connection.

The OCHP direct interface of every roaming partner must be secured via 
*TLS 1.2* ([RFC6176](http://tools.ietf.org/html/rfc6176)).

The identification of the requester and the access restriction of the 
interface is done by varying identification tokens which are exchanged
via the clearing house. (See [Identification token distribution](#identification-token-distribution) 
for further information.)

Each request to a OCHP direct interface must contain an *Authorization* 
HTTP header:

```http
Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
```

The hash value in this header is composed through the following steps:
 1. The identification tokens of sender and receiver are combined into 
    a string "receiver-token:sender-token"
 2. The resulting string is then encoded using the RFC2045-MIME variant 
    of Base64 ([RFC1945](http://tools.ietf.org/html/rfc1945#section-11)
	This encoded string shall further be called (encoded) token combination.
 3. The authorization method and a space i.e. `Basic␣` is then put 
    before the encoded token combination.

The OCHP direct endpoint should check for valid authorisation in order 
to prevent unintended usage of their endpoints or cyber-attacks.


#### Identification token distribution

The partner's tokens for identification and authorisation are exchanged 
and distributed through the clearing house. Based on the set roaming 
connections the tokens are made available. Each token is valid for a 
period of one full calendar day, synchronus to the UTC time, with an
additional short overlap for token exchange.

This mechanism is used to guarantee uninterupted service in combination 
with a high security level and compatibility with the majority of 
systems. The synchronisation and token-exchange-cycle is as follows.
On day `N` do:

 1. *At 00:30 UTC:* Invalidate/delete all token combinations of day `N-1`.
 2. Generate new own token for day `N+1`.
 3. *Before 11:55 UTC:* Send/upload own token for day `N+1` to the clearing house.
 4. *After 12:05 UTC:* Fetch/download partner's tokens for day `N+1` from the clearing house.
 5. Generate token combinations for day `N+1` from own and partner's 
    tokens. Here `AB2`.
 6. *At 23:50 UTC:* Make token combinations for day `N+1` valid.
 
This means that each night from 23:50 UTC to 0:30 UTC, a set of two
token combinations is valid. Each token that is valid for a given day `N`
shall be considered valid from 23:50 UTC on day `N-1` until 00:30 UTC
on day `N+1`, giving it a total validity of 24:40 hours.
When communicating with another partners OCHPdirect system, the token
combination for day `N` shall be used from 00:00 UTC (day `N`)until 
00:00 UTC of day `N+1`.

![Figure OCHP direct Token Exchange](media/OCHPdirectTokenExchange.png "OCHP direct Token Exchange")



# Partner-to-CHS interface description (Extension to OCHP)

This interface description extends the OCHP protocol. The additional
methods are available in the interface of the Clearing House.



## Exchange of interface definition



### Set own interface definition in the CHS

The backend of each roaming partner has to send the definition of its 
OCHP direct interface to the Clearing House to share that data with 
their connected roaming partners. The upload of the own interface 
definition is done in the following way:

 * CMS or MDM sends the AddServiceEndpoints.req PDU.
 * CHS responds with a AddServiceEndpoints.conf PDU.



### Get roaming partners interface definitions from the CHS

The backend of each roaming partner has to fetch the global list of
interface definitions from the CHS. The download of all interface
of connected partners is done in the following way:

 * CMS or MDM sends the GetServiceEndpoints.req PDU.
 * CHS responds with GetServiceEndpoints.conf PDU.






# Partner-to-partner interface description (_OCHP direct_ interface)

This interface description is the core of OCHP-direct. The described
methods must be available at the provider's backend _MDM_ (InformProvider)
and the operator's backend _CMS_ (all other methods).
The partners have to make sure they only connect to other partners'
endpoints which their endpoint is compatible with. Partners may 
operate multiple endpoints and versions to allow connectivity to a 
higher number of roaming partners. In the case of two partners running 
multiple compatible versions, it is advised to use the most advanced 
version.


## Get status information of charge points (_CMS_ interface)



### Request current live status from an Operator

The backend of a provider may request the current live status for a list
of EVSEs. This allows for a lower latency than the status distribution
via the Clearing House and should provide better data quality.

 * MDM sends the GetEvseStatus.req PDU.
 * CMS responds with a GetStatus.conf PDU.
   See OCHP/[GetStatus.conf](OCHP.md#getstatus-conf)


### Report a data or compatibility discrepancy to an Operator

The backend of a provider may report an issue concerning the data or
the compatibility or status of an EVSE to the operator to their
information. The operator may decide how to handle the report (optional).

 * MDM sends the ReportDiscrepancy.req PDU.
 * CMS responds with a ReportDiscrepancy.conf PDU.




## Start, stop and control a charging process remotely (_CMS_ interface)

The remote operation of a charging process in an operator backend is
done in three steps:

 1. Selection and reservation of the charge point
 2. Controlling of the charge point
 3. Release of the charge point

In step (1) an OCHP-direct session ID is generated by the operator and
returned. This ID must be used in step (2) and (3). Step (2) may occur
multiple times to change the parameters. The session is ended in step (3).

This makes it possible to maintain a mutal charging session in two
systems.

The following figure gives an overview of the communication. After step
(3) follows the CDR exchange process as described in OCHP. Calls from
the operator to the provider (_italic_) are handled through the _MDM_
interface at the provider backend (using the InformProvider method).

![Figure OCHP direct basic process](media/OCHPdirectProcess-1.png "OCHP direct basic process")


### Select a charge point of an operator

Before a charging process can be started, the provider needs to select
an EVSE in an operator's backend. This establishes the session and generates
the OCHP-direct session ID. The operator must reserve the selected
charging station for the communicated Contract-ID.

The provider may request reservation until a certain time and for a 
specific RFID token. It is up to the operator to decide whether or not 
to accept the provider's request for a reservation (duration). If the 
reservation request cannot be fulfilled the operator should return the 
maximum TTL for the reservation they would accept, but establish the 
session nonetheless. It is then up to the provider to decide whether 
to accept this offer from the operator (and otherwise release the EVSE, 
cancelling the reservation).

 * MDM sends the SelectEvse.req PDU.
 * CMS responds with a SelectEvse.conf PDU.


### Control a selected charge point in an operator's backend

When an EVSE was selected and a session successfully established, the 
EVSE can be controlled in the limits of the charging process by the 
provider.

 * MDM sends the ControlEvse.req PDU.
 * CMS responds with a ControlEvse.conf PDU.

**Note:** The control method _ControlEvse.req_ can be called multiple times (at least once) during a charging session. Its parameters define whether the provider requests a start or end of the charging session or if they want to change it (in terms of it's parameters). The operator shall handle all three operations and respond to it's capabilities to actually execute the request accordingly. 


### Release a selected charge point in an operator's backend

After the end of the charging process the provider should release the
prior selected EVSE.

 * MDM sends the ReleaseEvse.req PDU.
 * CMS responds with a ReleaseEvse.conf PDU.

**Note:** To end a charging session properly, the provider should always call _ReleaseEvse.req_. Alternatively, they can also call _ControlEvse.req_ with the parameter _operation='end'_ to explicitly end a charging process. A session with no ongoing charging process (_ControlEvse.req_ with _operation='start'_ was not called or not successful) shall always be closed with _ReleaseEvse.req_.
When the operator receives a valid _ReleaseEvse.req_ for an ongoing charging process which was not ended with a call to _ControlEvse.req_ with parameter _operation='end'_, the operator should implicitly end the process.
It is up to the operator to decide how long to keep any OCHPdirect session open and valid when there is no longer an active charging process attached to it (i.e. the charging process was explicitly stopped by _ControlEvse.req_ with the parameter _operation='end'_, but no _ReleaseEvse.req_ was sent).


## Inform a provider about a charging process (both interfaces)

The provider must get informed by the operator about any status updates to an 
OCHP-direct charging process, at least when a charging process starts as well as when it ends.
The operator's backend must make use of a threshold in order to avoid too many messages (It is recommended
not to send InformProvider more than once every 15 minutes, unless
the parameters of the charging process were changed).

The provider may request additional InformProvider messages from the CPO to follow the progress of the charging process. In order not to overwhelm any system involved, it is recommended not to exceed a frequency of 15 minutes between each such request.

The information types are:
 * Start of a charging session: _The process was authorized and the car is properly connected._ The operator must send an InformProvider to the provider in this case. 
 * End of a charging session: _The charging session has ended by any event and will not be resumed._ The operator must send an InformProvider to the provider in this case.
 * Metering information (status). This information should also be included in start and end messages. If possible, meter values should always be included in their most up-to-date form in any InformProvider message.
 * Power management information (status)
 * Invoicing ready, CDR sent (finish)

 
![Figure OCHP direct InformProvider example](media/OCHPdirectProcess-2.png "OCHP direct InformProvider example")



### Send charging process information of a provider's customer

When a status update to a charging process gets available, the operator
informs the concerned provider.

 * CMS sends the InformProviderMessage PDU.
 * MDM responds with a InformProvider.conf PDU.


### Request charging process information for a provider's customer

When a customer requests updated charging information to their charging 
process or when the provider deems it necessary to collect updated 
information on their behalf. May be called directly after SelectEvse 
to collect current meter values for the selected EVSE.

 * MDM sends the InformProvider.req PDU.
 * CMS responds with a InformProviderMessage PDU.









# Messages


## Messages for the exchange of interface definitions

These messages are used to exchange the interface definitions of the
OCHP direct interfaces between roaming partners.


### AddServiceEndpoints.req

This contains the field definition of the AddServiceEndpoints.req 
sent by the MDM or CMS towards the CHS.

 Field Name            |  Field Type        |  Card.  |  Description
:----------------------|:-------------------|:--------|:------------
providerEndpointArray  |  ProviderEndpoint  |  *      |  Array of endpoints of the partners provider system.
operatorEndpointArray  |  OperatorEndpoint  |  *      |  Array of endpoints of the partners operator system.


### AddServiceEndpoints.conf

This contains the field definition of the AddServiceEndpoints.conf
sent by the CHS as response to the AddServiceEndpoints.req.

 Field Name  |  Field Type  |  Card.  |  Description
:------------|:-------------|:--------|:------------
result       |  Result      |  1      |  This contains the result of AddServiceEndpoints.req.


### GetServiceEndpoints.req

This contains the field definition of the GetServiceEndpoints.req sent
by a partner's system to the CHS.
No fields are defined.


### GetServiceEndpoints.conf

This contains the field definition of the GetServiceEndpoints.conf
sent by the CHS as response to the GetServiceEndpoints.req.

 Field Name            |  Field Type        |  Card.  |  Description
:----------------------|:-------------------|:--------|:------------
result                 |  Result            |  1      |  This contains the result of GetServiceEndpoints.req.
providerEndpointArray  |  ProviderEndpoint  |  *      |  Array of endpoints of all providers connected to the requester.
operatorEndpointArray  |  OperatorEndpoint  |  *      |  Array of endpoints of all operators connected to the requester.



## Messages for the _OCHP direct_ interface


### DirectEvseStatus.req

This contains the field definition of the DirectEvseStatus.req 
sent by the MDM towards the CMS.

 Field Name      |  Field Type  |  Card.  |  Description
:----------------|:-------------|:--------|:------------
requestedEvseId  |  EvseId      |  +      |  List of EVSE-IDs the live status is requested for.



### ReportDiscrepancy.req

This contains the field definition of the ReportDiscrepancy.req 
sent by the MDM towards the CMS.

 Field Name  |  Field Type    |  Card.  |  Description
:------------|:---------------|:--------|:------------
evseId       |  EvseId        |  1      |  The charge point which is affected by the report.
report       |  string(2000)  |  1      |  Textual or generated report of the discrepancy.



### ReportDiscrepancy.conf

This contains the field definition of the ReportDiscrepancy.conf 
sent by the CMS as a response to ReportDiscrepancy.req.
No fields are defined.



### SelectEvse.req

This contains the field definition of the SelectEvse.req 
sent by the MDM towards the CMS.

 Field Name  |  Field Type  |  Card.  |  Description
:------------|:-------------|:--------|:------------
evseId       |  EvseId      |  1      |  The charge point which is selected by the provider.
contractId   |  ContractId  |  1      |  Contract-ID for which the charge point is selected.
reserveUntil |  DateTimeType|  ?      |  The desired TTL for the reservation created for the selected EVSE (in UTC).
reserveEmtId |  EmtId       |  ?      |  If defined, a reservation can be made for a specific physical token that is to be used to start the charging process.

**Note:** If no reserveUntil is defined in the request, it is up to the CPO to set a pre-defined TTL for the reservation and the session established (recommendation: 5 minutes). Once that TTL expires, the session and reservation should be invalidated.
**Note:** A specific token may be defined for a reservation, which would enable access to the charging station with the customers RFID card as well. If this is the case, the operator must still accept all ControlEvse requests coming in for that session ID.



### SelectEvse.conf

This contains the field definition of the SelectEvse.conf 
sent by the CMS as a response to SelectEvse.req.

 Field Name  |  Field Type    |  Card.  |  Description
:------------|:---------------|:--------|:------------
result       |  DirectResult  |  1      |  This contains the result of SelectEvse.req.
directId     |  DirectId      |  ?      |  The session id for this direct charging process on success.
ttl          |  DateTimeType  |  ?      |  On success the time until this selection is valid.

**Note:** Should the CPO not accept the extended duration of reservation for the selected EVSE, they should still create the session and return the maximum TTL they are willing to grant the provider. It is then up to provider or their customer to accept this proposed TTL / reservation or to reject it (in which case the session should be closed by calling _ReleaseEvse.req_).



### ControlEvse.req

This contains the field definition of the ControlEvse.req 
sent by the MDM towards the CMS.

 Field Name   |  Field Type       |  Card.  |  Description
:-------------|:------------------|:--------|:------------
directId      |  DirectId         |  1      |  The session id referencing the direct charging process to be controlled.
operation     |  DirectOperation  |  1      |  The operation to be performed for the selected charge point.
maxPower      |  float            |  ?      |  Maximum authorised power in kilowatts. Example: "3.7", "8", "15"
maxEnergy     |  float            |  ?      |  Maximum authorised energy in kilowatthours. Example: "5.5", "20", "85"



### ControlEvse.conf

This contains the field definition of the ControlEvse.conf 
sent by the CMS as a response to ControlEvse.req.

 Field Name  |  Field Type    |  Card.  |  Description
:------------|:---------------|:--------|:------------
result       |  DirectResult  |  1      |  This contains the result of ControlEvse.req.
directId     |  DirectId      |  1      |  The session id for this direct charging process.
ttl          |  DateTimeType  |  ?      |  On success the timeout for this session.



### ReleaseEvse.req

This contains the field definition of the ReleaseEvse.req 
sent by the MDM towards the CMS.

 Field Name  |  Field Type  |  Card.  |  Description
:------------|:-------------|:--------|:------------
directId     |  DirectId    |  1      |  The session id referencing the direct charging process to be released.



### ReleaseEvse.conf

This contains the field definition of the ReleaseEvse.conf 
sent by the CMS as a response to ReleaseEvse.req.

 Field Name  |  Field Type    |  Card.  |  Description
:------------|:---------------|:--------|:------------
result       |  DirectResult  |  1      |  This contains the result of ReleaseEvse.req.
directId     |  DirectId      |  1      |  The session id for this direct charging process.
ttl          |  DateTimeType  |  ?      |  On success the timeout for this session.



### InformProviderMessage

This contains the field definition of the InformProviderMessage 
sent by the CMS towards the MDM.

 Field Name       |  Field Type     |  Card.  |  Description
:-----------------|:----------------|:--------|:------------
result            |  DirectResult   |  ?      |  This contains the result of InformProvider.req. Only applicable if the InformProviderMessage is sent as a response to InformProvider.req.
message           |  DirectMessage  |  1      |  The operation that triggered the operator to send this message.
evseId            |  EvseId         |  1      |  The charge point which is used for this charging process.
contractId        |  ContractId     |  1      |  Contract-ID to which the charge point is assigned.
directId          |  DirectId       |  1      |  The session id for this direct charging process.
ttl               |  DateTimeType   |  ?      |  On success the timeout for this session.
maxPower          |  float          |  ?      |  Maximum authorised power in kilowatts. Example: "3.7", "8", "15"
maxEnergy         |  float          |  ?      |  Maximum authorised energy in kilowatthours. Example: "5.5", "20", "85"
currentPower      |  float          |  ?      |  The currently supplied power limit in kilowatts in case of load management. Example: "3.7", "8", "15"
chargedEnergy     |  float          |  ?      |  The amount of energy in kilowatthours transferred during this charging process. Example: "5.5", "20", "85"
meterValue        |  float          |  ?      |  The current meter value (in kWh) as displayed on the meter to enable displaying it to the user. Example: "12345.67"
localTime         |  LocalDateTimeType |  ?   |  The local time at the charge point. To be sent along with meterValue.
currentCost       |  float          |  ?      |  The total cost of the charging process that will be billed by the operator up to this point.
currency          |  string(3)      |  ?      |  The displayed and charged currency. Defined in ISO 4217 - Table A.1, alphabetic list.



### InformProvider.req

This contains the field definition of the InformProvider.req 
sent by the MDM towards the CMS.

 Field Name      |  Field Type    |  Card.  |  Description
:----------------|:---------------|:--------|:------------
directId         |  DirectId      |  1      |  The session id for this direct charging process.



### InformProvider.conf

This contains the field definition of the InformProvider.conf 
sent by the MDM as a response to InformProvider.conf.

 Field Name      |  Field Type    |  Card.  |  Description
:----------------|:---------------|:--------|:------------
result           |  DirectResult  |  1      |  This contains the result of InformProviderMessage.




# Types


## Types that extend the OCHP interface _Basic_

These data types extend the OCHP interface and are understood by the
Clearing House.


### DirectEndpoint *class*

Contains a generic endpoint definition.

 Field Name    |  Field Type  |  Card.  |  Description
:--------------|:-------------|:--------|:------------
 url           | string(255)  | 1       | The endpoint address.
 version 	   | string(3)	  | + 		| The OCHPdirect version used by this endpoint (e.g. 0.2)
 namespaceUrl  | string(255)  | ?       | The WSDL namespace definition.
 accessToken   | string(255)  | 1       | The secret token to access this endpoint.
 validDate     | DateType     | 1       | The day on which this endpoint/token combination is valid.
 
 **Note:** Any token for day N has to be treated as valid from day N-1 23:50 UTC to day N+1 0:30 UTC.


### ProviderEndpoint *class*

Contains the endpoint definition of a provider's MDM system.
Expands the DirectEndpoint.

 Field Name    |  Field Type      |  Card.  |  Description
:--------------|:-----------------|:--------|:------------
 url           | string(255)      | 1       | The endpoint address.
 version 	   | string(3)		  | + 		| The OCHPdirect version used by this endpoint (e.g. 0.2)
 namespaceUrl  | string(255)      | ?       | The WSDL namespace definition.
 accessToken   | string(255)      | 1       | The secret token to access this endpoint.
 validDate     | DateType         | 1       | The day on which this endpoint/token combination is valid.
 useProxy      | boolean          | ?       | To be set to "true" in case a proxy system is being used to handle all OCHPdirect requests.
 whitelist     | ContractPattern  | +       | List of patterns that match all Contract-IDs the endpoint is responsible for.
 blacklist     | ContractPattern  | *       | List of patterns that match Contract-IDs the endpoint is not responsible for, but are matched by the whitelist.

 **Note:** Any token for day N has to be treated as valid from day N-1 23:50 UTC to day N+1 0:30 UTC.

### OperatorEndpoint *class*

Contains the endpoint definition of an operator's CMS backend.
Expands the DirectEndpoint.

 Field Name    |  Field Type  |  Card.  |  Description
:--------------|:-------------|:--------|:------------
 url           | string(255)  | 1       | The endpoint address.
 version 	   | string(3)	  | + 		| The OCHPdirect version used by this endpoint (e.g. 0.2)
 namespaceUrl  | string(255)  | ?       | The WSDL namespace definition.
 accessToken   | string(255)  | 1       | The secret token to access this endpoint.
 validDate     | DateType     | 1       | The day on which this endpoint/token combination is valid.
 useProxy      | boolean      | ?       | To be set to "true" in case a proxy system is being used to handle all OCHPdirect requests.
 whitelist     | EvsePattern  | +       | List of patterns that match all EVSE-IDs the endpoint is responsible for.
 blacklist     | EvsePattern  | *       | List of patterns that match EVSE-IDs the endpoint is not responsible for, but are matched by the whitelist.

 **Note:** Any token for day `N` has to be treated as valid from day `N-1` 23:50 UTC to day `N+1` 0:30 UTC.
 

### ContractPattern *class*

Defines a pattern that matches Contract-IDs. The pattern must be
specified for IDs without optional seperators. The wildcard character
for the pattern is `%`. The pattern as well as the ID is case sensitive.

```regex
[A-Za-z]{2}[A-Za-z0-9]{3}[Cc][A-Za-z0-9]{0,8}%?
```


### EvsePattern *class*

Defines a pattern that matches EVSE-IDs. The pattern must be
specified for IDs without optional seperators. Seperators in the ID's
instance are handled as part of the alphabet. The wildcard character
for the pattern is `%`.

```regex
[A-Z]{2}[A-Z0-9]{3}[E]([A-Z0-9]?[A-Z0-9\*]{0,30})%?
```


## Types for the _OCHP direct_ interface


### DirectResult *enum*

Contains result information.

 Field Name         |  Field Type            |  Card.  |  Description
:-------------------|:-----------------------|:--------|:------------
 resultCode         |  DirectResultCodeType  |  1      |  The machine-readable result code.
 resultDescription  |  string                |  1      |  The human-readable error description.


### DirectResultCodeType *enum*

Result and error codes for the class Result as return value for method calls.

 Value          |  Description
:---------------|:-------------
 ok             | Data accepted and processed.
 partly         | Not all control parameters could be applied.
 not-found      | Given EVSE-ID is not known to the operator.
 not-supported  | Given EVSE-ID does not support OCHP-direct.
 invalid-id     | The DirectId is not valid or has expired.
 server         | Internal server error.

#### Usage of DirectResultCodes

This quick chapter shall give an overview of how certain result codes are supposed to be treated by OCHPdirect endpoints in order to reduce potential misunderstandings.


 
 
 

### DirectId *class*

The session ID for one OCHP-direct charging process. The ID is created
by the operator and used to reference the session by the provider. Must
be unique per Operator-ID.
There are two events that create a new DirectId:

 * A successful call to SelectEvse by the provider
 * Local start of a charging session (e.g. via RFID) for an OCHP-direct
   enabled Contract-ID at an OCHP-direct enabled EVSE

```regex
[A-Z0-9\-]{1,255}
```


### DirectOperation *enum*

Operations to control an OCHP-direct charging process.

 Value   |  Description
:--------|:-------------
 start   | Initiate the start. Operator should allow the user to plug in.
 change  | Change the parameters of the charging process.
 end     | End the charging process. Operator should allow the user to plug out.


### DirectMessage *enum*

Messages to inform a provider about an OCHP-direct charging process.

 Value   |  Description
:--------|:-------------
 start   | A OCHP-direct charging process has been started.
 change  | The parameters of the charging process were changed.
 info    | A informative update is available, e.g. updated consumed energy value.
 end     | The charging process has ended, the connector was unplugged.
 finish  | The session is finished and the CDR was sent out.






# Binding to Transport Protocol


## OCHP direct over SOAP

For this protocol the SOAP Version 1.1 MUST be used.



# Combining OCHP​_direct_ with classic OCHP

OCHP​_direct_ is made to be used in association with the classic OCHP
and a clearing house. This section gives additional advice of how
integrate it.


## CDRs for OCHP​_direct_ sessions

 Field Name       |  Field Type         |  Card.  |  Additional advice
:-----------------|:--------------------|:--------|:--------------------
 cdrId            |  string(36)         |  1      |
 evseId           |  EvseId             |  1      |
 emtId            |  EmtId              |  1      |  The field _tokenType_ should be set to `remote`, the field _instance_ should enhold the _directId_.
 contractId       |  ContractId         |  1      |
 liveAuthId       |  LiveAuthId         |  ?      |  Not used with OCHPdirect.
 status           |  CdrStatusType      |  1      |
 startDateTime    |  LocalDateTimeType  |  1      |  Start date and time of the direct session (successfull SelectEvse). Must be set in the local time of the charge point.
 endDateTime      |  LocalDateTimeType  |  1      |  End date and time of the charge session (log-off with the RFID badge, ControlEvse.operation = _end_ or physical disconnect). Must be set in the local time of the charge point.


