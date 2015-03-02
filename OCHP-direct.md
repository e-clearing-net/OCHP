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
   at an operator's charge pole by using a provider's app (from which 
   the process was started).

#### Advanced use cases
 * **Charge Event:** A user gets informed by a provider's app about 
   status changes of a charging process at an operator's charge pole, 
   even if it wasn't started remotely.
 * **Remote Control:** A user controls a charging process at an 
   operator‘s charge pole that was not remotely started by using a 
   provider‘s app.
 * **Remote Action:** A user triggers advanced and not charging process 
   related actions at a charge point or charging station of an operator.

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

The backend specification is send and updated regularly. It contents 
all properties that describe the roaming partner's backend:

 * The URL of the backend's OCHP direct endpoint(s).
 * The security token of the backend. (See chapter [Security of the OCHP direct interface](#security-of-the-OCHP-direct-interface) 
   for more information.)
 * All business objects that are operated by this backend, represented 
   by blacklists and/or whitelists.

This data can be mapped onto a data structure as illustrated in the 
following figure *OCHP direct ER Model*. The depictured data structure 
allows for dynamic updates of endpoints and partner-tokens, which is 
necessary to guaranty an uninterrupted service.

Remarkable about the data model is the absence of an backend entity. 
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

Each roaming partner who makes use of OCHP direct needs provide a SOAP 
server with a public accessible interface. It is obvious that they must secure
those interfaces to:
 * restrict usage only to their current roaming partners and
 * secure the transmitted data.

This applies to the operator and for advanced use cases also to the 
provider.

Therefore the interfaces must be protected on HTTP transport layer 
level, using SSL and Basic Authentication. Please note that this 
mechanism does **not** require client side certificates for 
authentication, only server side certificates in order to provide a 
secure SSL connection.

The OCHP direct interface of every roaming partner must be secured via 
*TLS 1.2* ([RFC6176](http://tools.ietf.org/html/rfc6176)).

The identification of the requester and the access restriction of the 
interface is done by rotating identification tokens which are 
distributed via the clearing house. (See 
[Identification token distribution](#identification-token-distribution) 
for further information.)

Each request to a OCHP direct interface must contain a *Authorization* 
HTTP header:

```http
Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
```

The hash value in this header is composed through the following steps:
 1. The identification tokens of sender and receiver are combined into 
    a string "receiver-token:sender-token"
 2. The resulting string is then encoded using the RFC2045-MIME variant 
    of Base64 ([RFC1945](http://tools.ietf.org/html/rfc1945#section-11)
 3. The authorization method and a space i.e. `Basic␣` is then put 
    before the encoded string.

The OCHP direct endpoint should check for valid authorisation in order 
to prevent unintended usage of their endpoints or cyber-attacks.


#### Identification token distribution

The partner's tokens for identification and authorisation are exchanged 
and distributed through the clearing house. Based on the set roaming 
connections the tokens are made available. Each token is valid for a 
period of full calendar days, synchronus to the UTC time.

This mechanism is used to guarantee uninterupted service in combination 
with a high security level and compatibility with the majority of 
systems. The synchronisation and token-exchange-cycle is as follows.
On day `N` do:

 1. *At 00:30 UTC:* Invalidate/delete all tokens of day `N-1`.
 2. Generate new own token for day `N+1`.
 3. *Before 12:00 UTC:* Send/upload own token for day `N+1`.
 4. *After 12:00 UTC:* Fetch/download partner's tokens for day `N+1`.
 5. Generate token combinations for day `N+1` from own and partner's 
    tokens. Here `AB2`.
 6. *At 23:50 UTC:* Make token combinations for day `N+1` valid.

![Figure OCHP direct Token Exchange](media/OCHPdirectTokenExchange.png "OCHP direct Token Exchange")



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





