This file summarizes the changes made in OCHP version 1.5, coming from version 1.4.1

## Token Data Type
More authorization methods are being used to access charging stations than RFID cards or remote tokens.
To enable full support of additional identification methods, OCHP 1.5 is aligning with OCPP version 2.0 where feasible for the roaming usecase.

*Instance set to 36 characters (was 256)
*TokenType enum changed to be in line with OCPP 2.0

### EmtId *class*

The authorisation tokens are defined according to the specification of
the EMT-ID (Token ID). Each token consists of an token instance which
holds the payload and at least the token type. The sub-type is for
further specification of the general token type.

 Field Name      |  Field Type           |  Card.  |  Description
:----------------|:----------------------|:--------|:------------
 instance        |  string(36)           |  1      |  Specification according to the token type.
 representation  |  tokenRepresentation  |  1      |  The token instance may be represented by its hash value (hexadecimal representation of the hash value). This specifies in which representation the token instance is set.
 type            |  tokenType            |  1      |  The type of the supplied instance.
 subType         |  tokenSubType         |  ?      |  The exact type of the supplied instance.



### tokenType *enum*

The type of the supplied instance for basic filtering.

 Value       |  Description
:------------|:-------------
 iso14443    |  All kinds of RFID-Cards. Field tokenInstance holds the hexadecimal representation of the card's UID, Byte order: big endian, no zero-filling. Formerly 'rfid'
 iso15693    |  All kinds of NFC identification. Field tokenInstance holds the hexadecimal representation of the card's UID, Byte order: big endian, no zero-filling.
 iso15118    |  All authentication means defined by ISO/IEC 15118 except RFID-cards.
 remote      |  All means of remote authentication through the backend. Field tokenInstance holds a reference to the remote authorization or session. In case of a OCHPdirect authorization the _directId_.


### tokenSubType *enum*

The exact type of the supplied instance for referencing purpose.

 Value       |  Description
:------------|:-------------
 mifareCls   |  Mifare Classic Card
 mifareDes   |  Mifare Desfire Card
 calypso     |  Calypso Card


### tokenRepresentation *enum*

Specifies the representation of the token to allow hashed token values.

 Value       |  Description
:------------|:-------------
 plain       |  The token instance is represented in plain text. (default)
 sha-160     |  The token instance is represented in its 160bit SHA1 hash in 40 hexadecimal digits.
 sha-256     |  The token instance is represented in its 256bit SHA2 hash in 64 hexadecimal digits.

###### eMT-ID Semantics
The EMT ID can be used to identify any identification token for
e-mobility. The EMT ID is a non-global ID and therefore has no country
code or operator/provider part. This information about the "owning
operator/provider" is delivered by the context of the communication.


### RoamingAuthorisationInfo *class*

Contains information about a roaming authorisation (card/token)

 Field Name     |  Field Type      |  Card.  |  Description
:---------------|:---------------  |:--------|:------------
 EmtId          |  EmtId           |  1      |  Electrical Vehicle Contract Identifier
 contractId     |  ContractId      |  1      |  EMA-ID the token belongs to.
 permissions    |  PermissionsType |  +      |  What fuel types the contract may charge.
 printedNumber  |  string(150)     |  ?      |  Might be used for manual authorisation.
 expiryDate     |  DateTimeType    |  1      |  Tokens may be used until the date of expiry is reached. To be handled by the partners systems. Expired roaming authorisations may be erased locally by each partner's systems.
