# OCHP 1.5 User Stories
**This section is currently under development/Work in Progress**

This page contains the User Stories upon which the design of OCHP 1.5 is based.
The User Stories represent the Motivation of the protocol design, answering the question of "Why?" certain things should happen.
Following the definition of the User Stories, Use Cases will be developed to fulfill the needs identified by the User Stories.  
A "User" is the party whose motivation is represented by a User Story. It does not necessarily describe an end user or EV-Driver.  
"Actors" are the parties who are involved in a user story.  
User Stories should follow the "As a *role* I want to *task* in order to *motivation*" Format.

## Roles
The following roles are used to describe Users and Actors in the User Stories. 
Please note that many companies occupy multiple roles within the electric mobility ecosystem.
This list is currently not exhaustive and will be updated as user stories are added & developed.

|Abbreviation|Role|Description|
|---|---|---|
|BSP|Billing Service Provider| Entity providing billing services towards end-customers or between companies.|
|DSO|Distribution System Operator| Entity operating an energy distribution grid.|
|CPO|Charge Point Operator| An entity operating charging stations. Identified by an 'Operator ID'.|
|EMP|Electric Mobility Provider|An entity providing access to charging stations for end users. Identified by a 'Provider ID'.|
|EV-Driver|Electric Vehicle Driver|End user of electromobility services.|
|HUB|Roaming Platform| Entity providing data exchange & connectivity services for e-mobility market roles.|
|NSP|Navigation Service Provider| An entity providing information on charge point locations to end consumers. Often coincides with the EMP role.|
|PSO|Parking Spot Operator| Entity providing information on status of parking spots via sensor technology.|

## User Stories
The User Stories are grouped into the following categories:
- Authorisation: User Stories related to starting a charging session when physically at the charger
- Navigation: User Stories related to finding charge points & their status, parking
- Charging: User Stories related to everything that happens during a charging session (but not starting it)
- Tariffs & Billing: User Stories related to pricing and billing information
- Smart Grids: User Stories related to integrating E-Mobility charging into Smart Grid systems
- Extended Scope: User Stories not strictly related to Electric Mobility (Other alternative Fuels, Heavy Duty Vehicles, Shore-to-Ship Power etc.)

User Stories will be further grouped by topics within these categories.  
Note that while **Security* will appear as a category in various categories, it does not mean that 

### User Stories - Authorisation
'Authorisation' User stories refer to all aspects related to starting a charging session at a charging station.  
#### Authorisation - General
1. As an EV-Driver, I want to start a charging session at a charge point with an existing EMP subscription in order to recharge my vehicle.
   1. To access the charger, I want to use a physical RFID Token.
   2. To access the charger, I want to use an app on my smartphone.
   3. To access the charger, I want to scan a QR-Code on the charger.
   4. To access the charger, I want to identify automatically when plugging in.

2. As an EV-Driver, I want to start a charging session at a charge point without a pre-existing contract (Ad-Hoc) in order to recharge my vehicle.
   1. To access the charger, I want to use an app on my smartphone.
   2. To access the charger, I want to scan a QR-Code on the charger.
   3. To access the charger, I want to identify automatically when plugging in.
      
3. As an EV-Driver with a reservation, I want to be able to identify at a charge point using a physical RFID Token in order to not have to dig out my smartphone.

#### Authorisation - Security
1. As an EV-Driver, I want to be informed whenever a charging session is started on my account in order to detect abuse.
2. As an EV-Driver, I want to use two-factor authorisation in order to increase security of my charging sessions.
3. As an EMSP, I want to be informed about each charging session started by my users so that I can detect abuse or fraud early.
   1. I want my approval to be necessary in order for a charging session to start in order to increase security and reliability.
  
#### Authorisation - Service
1. As an EV-Driver, I want to be able to receive support at the charge point in order to not be without options if something isn't working.
2. As an EV-Driver, I want to access a user guide to start a charging session at a charge point in order to be aware of any minor details in the necessary steps or their order that differ from charger to charger.

### User Stories - Navigation  
'Navigation' User Stories refer to locating charging points, checking their availability and capabilities as well as related infrastructure like parking spots.
1. As an EV-Driver, I want to know where a charge point is located in order to go there and charge my vehicle.
2. As an EV-Driver, I want to know the current status of a charge point in order to decide whether to go there for a charge or find another charging opportunity.
3. As a CPO, I want to define which charging points are public and which ones are private in order to show private charge points only to relevant parties.
